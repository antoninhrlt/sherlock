library sherlock;

import 'package:sherlock/tools/normalize.dart';
import 'package:sherlock/tools/regex.dart';
import 'package:sherlock/result.dart';
import 'package:sherlock/stopwords.dart';
import 'package:sherlock/types.dart';

export 'tools/normalize.dart';

/// Efficient and customizable search engine for local data.
///
/// ## More
/// Usage information on the README.md
class Sherlock {
  /// The local data organised in a list of maps. It's where researches are done.
  ///
  /// ## Example
  /// ```json
  /// [
  ///   {
  ///     'name': 'Jiji',
  ///     'description': 'Cute cat',
  ///     'from': 'Kiki\'s delivery service',
  ///     'by': 'Studio Ghibli'
  ///   },
  ///   {
  ///     'name': 'Wall-E',
  ///     'description': 'Beep boop!',
  ///     'by': ['Disney', 'Pixar']
  ///   }
  /// ]
  /// ```
  final List<Element> elements;

  /// Map (column identifier as the key, priority number as the value) defining the importance of each column in the
  /// results.
  ///
  /// The bigger it is, the more important it is in results.
  ///
  /// Initially set to "all the columns have an importance of 1". The default value for a column is 1 if the key '*' is
  /// not defined.
  final PriorityMap priorities;

  /// See [NormalizationSettings]'s documentation.
  ///
  /// Initially set to the default settings given by [NormalizationSettings.defaults].
  final NormalizationSettings normalization;

  /// Creates a new [Sherlock] object to search in [elements].
  Sherlock({
    required this.elements,
    PriorityMap priorities = const {'*': 1},
    this.normalization = const NormalizationSettings.defaults(),
  }) : priorities = {
          ...{'*': 1},
          ...priorities
        };

  /// Creates a unique [Sherlock] object which cannot be used outside this function and perform queries.
  ///
  /// The parameters are organised and defined like the [Sherlock] constructor.
  ///
  /// Returns the results returned by the callback [queries].
  static Future<List<Result>> processUnique({
    required List<Element> elements,
    PriorityMap priorities = const {'*': 1},
    NormalizationSettings normalization = const NormalizationSettings.defaults(),
    required List<Result> Function(Sherlock sherlock) queries,
  }) async {
    final sherlock = Sherlock(elements: elements, normalization: normalization, priorities: priorities);
    return queries(sherlock);
  }

  /// Searches for values matching more or less with the [input].
  ///
  /// Like all other query functions:
  /// - When [where] is not specified, it's a global search in every column of the elements
  ///
  /// Unlike all the other query functions:
  /// - [where] can be a string (for global search) or a list of columns. Even if there is only one column where to
  /// search, it must be put in a list.
  ///
  /// Default [stopWords] to be removed are the English ones (see [StopWords.en]).
  /// > Provide an empty list of [stopWords] to not remove the stop words.
  ///
  /// It is not especially recommanded but, it's possible to not use the chosen normalization settings for the smart
  /// search but use instead the global [normalization] settings.
  ///
  /// Returns its research findings.
  Future<List<Result>> search({
    dynamic where = '*',
    required String input,
    List<String> stopWords = StopWords.en,
    bool useGlobalNormalization = false,
  }) async {
    // No where parameter provided or no input provided.
    if (where == [] || input.isEmpty) {
      return [];
    }

    // Manager for the where parameter.
    var smartWhere = Where(where: where);
    smartWhere.checkValidity();

    // Uses the global normalization settings only when it is specified, otherwise uses its own normalization settings.
    var localNormalization = useGlobalNormalization ? normalization : const NormalizationSettings.defaults();

    // Normalises the input and removes the stop words.
    input = input.normalize(normalization).removeStopWords(stopWords);

    // Normalization might have killed the input.
    // Defence code, God only knows.
    if (input.isEmpty) {
      return [];
    }

    // Equality search.
    final Future<List<Result>> resultsEquality = _searchExtension(
      smartWhere,
      query: (where) => queryBool(
        where: where,
        fn: (value) {
          // Cannot compare the whole input with a non-string value.
          if (value.runtimeType != String) {
            return false;
          }

          // Whether the whole input is perfectly equals to the value.
          return value.toString().normalize(localNormalization) == input;
        },
      ),
    );

    // "Starts with" search.
    final Future<List<Result>> resultsStarting = _searchExtension(
      smartWhere,
      query: (where) => queryBool(
        where: where,
        fn: (value) {
          // Cannot compare the whole input with a non-string value.
          if (value.runtimeType != String) {
            return false;
          }

          // Whether the whole input is the beginning of the value.
          return value.toString().normalize(normalization).startsWith(input);
        },
      ),
    );

    // Splits the input into keywords and removes the empty keyword the split might create because of the double spaces.
    final inputKeywords = input.split(' ')..removeWhere((e) => e.isEmpty);

    // "All keywords at once" search.
    final regexAll = RegexHelper.flexAll(
      keywords: inputKeywords,
      searchWords: true,
    );

    final Future<List<Result>> resultsRegexAll = _searchExtension(
      smartWhere,
      query: (where) => query(where: where, regex: regexAll),
    );

    // "Any word from the keywords" search.
    final regexAny = RegexHelper.any(
      keywords: inputKeywords,
      searchWords: true,
    );

    // At least all keywords in.
    final Future<List<Result>> resultsRegexAny = _searchExtension(
      smartWhere,
      query: (where) => query(where: where, regex: regexAny),
    );

    // Creates a new list of results that will be returned by this function.
    List<Result> results = [];

    // Removes the duplicates.
    // Browses the unchecked results (that might contain duplicates) to create a new safe list of results.
    final uncheckedResults = [
      ...await resultsEquality,
      ...await resultsStarting,
      ...await resultsRegexAll,
      ...await resultsRegexAny
    ];

    for (final Result result in uncheckedResults) {
      // Results already in the results are not added.
      _addResultChecked(refDestination: results, element: result.element, priority: result.priority);
    }

    return results;
  }

  /// Extension of the [search] function for repetitive tasks.
  Future<List<Result>> _searchExtension(
    Where smartWhere, {
    required Future<List<Result>> Function(String where) query,
  }) async {
    // Calls the query for all the columns.
    if (smartWhere.isGlobal) {
      // Returns the results of the query call.
      return query('*');
    }

    // All the results from the query calls.
    List<Result> allResults = [];

    // Calls the query for every column specified.
    for (var column in smartWhere.columns) {
      // Adds the results of this query to the list of results which will be returned by this function.
      final queryResults = await query(column);
      allResults.addAll(queryResults);
    }

    return allResults;
  }

  /// Searches for values matching with the given regular expression in the column(s) [where].
  ///
  /// Could be renamed `queryRegex`.
  ///
  /// Like all other query functions:
  /// - When [where] is not specified, it's a global search in every column of the elements
  /// - When [specificNormalization] is specified, it is used instead of the global [normalization] settings. However,
  /// the global [normalization] settings are still used as fallback when [specificNormalization] does not provide a
  /// setting.
  ///
  /// Returns its research findings.
  Future<List<Result>> query({
    String where = '*',
    required String regex,
    NormalizationSettings? specificNormalization,
  }) async {
    // Normalization settings to give when function needs them.
    final localNormalization = specificNormalization ?? normalization;

    // Creates a regular expression object from the regular expression given as string.
    // Takes into consideration the normalization case sensitivity setting.
    final what = RegExp(regex, caseSensitive: normalization.caseSensitivity);

    return _anyQuery(where, (element, columnId, priority, refResults) {
      // Can be both a string, a list or even something another object but it would be ignored.
      final value = element[columnId];
      _queryExtension(refResults, value, element, priority, what, localNormalization);
    });
  }

  /// Extension of the [query] function in order to make recursive calls.
  _queryExtension(
    List<Result> refResults,
    dynamic stringOrList,
    Element element,
    int priority,
    RegExp what,
    NormalizationSettings localNormalization,
  ) {
    // Defence code, only God knows.
    if (stringOrList == null) {
      return;
    }

    // String case
    if (stringOrList.runtimeType == String) {
      // Regular expression is invalid with this value. Returns.
      if (!what.hasMatch(stringOrList.toString().normalize(localNormalization))) {
        return;
      }

      // The result is matching, adds it.
      _addResultChecked(refDestination: refResults, element: element, priority: priority);

      return;
    }

    // List of strings case
    if (stringOrList.runtimeType == List<String>) {
      // Recursive call for each string in the list of strings.
      for (String string in stringOrList) {
        _queryExtension(refResults, string, element, priority, what, localNormalization);
      }

      return;
    }

    // List of ?? of ?? ... case
    if (stringOrList.runtimeType == List<dynamic>) {
      // Recursive call for each object in the list.
      for (dynamic stringOrList in stringOrList) {
        _queryExtension(refResults, stringOrList, element, priority, what, localNormalization);
      }

      return;
    }
  }

  /// Searches for [what] existing in the [where] column when exists.
  ///
  /// Like all other query functions:
  /// - When [where] is not specified, it's a global search in every column of the elements
  /// - When [specificNormalization] is specified, it is used instead of the global [normalization] settings. However,
  /// the global [normalization] settings are still used as fallback when [specificNormalization] does not provide a
  /// setting.
  ///
  /// Returns its research findings.
  Future<List<Result>> queryExist({
    required String where,
    required String what,
  }) async {
    return _anyQuery(where, (element, columnId, priority, refResults) {
      // Gets the value from the currently "studied" column of the element.
      final value = element[columnId];

      // Does not exist or the value exists but it is null.
      if (value == null || value[what] == null) {
        return;
      }

      // The result is matching, adds it.
      _addResultChecked(refDestination: refResults, element: element, priority: priority);
    });
  }

  /// Searches for values corresponding to a boolean expression in the column(s) [where].
  ///
  /// Like all other query functions:
  /// - When [where] is not specified, it's a global search in every column of the elements
  /// - When [specificNormalization] is specified, it is used instead of the global [normalization] settings. However,
  /// the global [normalization] settings are still used as fallback when [specificNormalization] does not provide a
  /// setting.
  ///
  /// Returns its research findings.
  Future<List<Result>> queryBool({
    String where = '*',
    required bool Function(dynamic value) fn,
  }) async {
    return _anyQuery(where, (element, columnId, priority, refResults) {
      // Gets the value from the currently "studied" column of the element.
      final value = element[columnId];

      // Defence code, only God knows.
      if (value == null) {
        return;
      }

      if (!fn(value)) {
        // Negative result from the callback, returns nothing.
        return;
      }

      // The result is matching, adds it.
      _addResultChecked(refDestination: refResults, element: element, priority: priority);
    });
  }

  /// Searches for values equal to [match] in the column(s) [where].
  ///
  /// Like all other query functions:
  /// - When [where] is not specified, it's a global search in every column of the elements
  /// - When [specificNormalization] is specified, it is used instead of the global [normalization] settings. However,
  /// the global [normalization] settings are still used as fallback when [specificNormalization] does not provide a
  /// setting.
  ///
  /// Returns its research findings.
  Future<List<Result>> queryMatch({
    String where = '*',
    required dynamic match,
    NormalizationSettings? specificNormalization,
  }) async {
    // Whether the object to compare is a string.
    if (match.runtimeType == String) {
      // Normalization settings to give when function needs them.
      final localNormalization = specificNormalization ?? normalization;

      // Classic comparison with a string.
      // Normalization settings are applied.
      return queryBool(
        where: where,
        fn: (value) {
          // Comparison is supposed to be done between two strings if the match object is a string.
          if (value.runtimeType != String) {
            // If they don't have the same type, they cannot be equal.
            // The previous test could also be (value.runtimeType == match.runtimeType) which would mean that both are
            // strings.
            return false;
          }

          return value.toString().normalize(localNormalization) == match.toString().normalize(localNormalization);
        },
      );
    }

    // Dynamic comparison between unknown objects.
    // No normalization is applied to values.
    return queryBool(where: where, fn: (value) => value == match);
  }

  /// Repeated browsing process for all the query functions.
  ///
  /// The [callback] should add the results it found in the given [callback.refResults] variable.
  ///
  /// The returned value of this function is supposed to be returned by the query function calling it.
  Future<List<Result>> _anyQuery(
    String where,
    void Function(
      Element element,
      String columnId,
      int priority,
      List<Result> refResults,
    ) callback,
  ) async {
    // Nothing to search, no results to return.
    if (elements.isEmpty) {
      return [];
    }

    // All the results of this function.
    List<Result> results = [];

    /// Browses all the elements one by one and call the callback whenever it's
    /// needed.
    for (final element in elements) {
      if (Where(where: where).isGlobal) {
        // In global queries, all columns of the element are tested.
        // The callback is called for each column.
        for (final key in element.keys) {
          // Gives results like a reference since the callback shall modify this variable.
          callback(element, key, priorities[key] ?? priorities['*']!, results);
        }

        continue;
      }

      // Query in a specified column.
      // Gives results like a reference since the callback shall modify this variable.
      callback(element, where, priorities[where] ?? priorities['*']!, results);
    }

    return results;
  }

  /// Checks if the [element] is not already in [refDestination]. If it's the case, it is not added to [refDestination],
  /// otherwise calls [_addResultUnchecked] to add the element in [refDestination] wrapped as a [Result] with its
  /// priority.
  ///
  /// Lists in Dart are passed like references, it means that the function directly modify the given list. Don't give a
  /// copy of the list!
  void _addResultChecked({
    required List<Result> refDestination,
    required Element element,
    required int priority,
  }) {
    // Partially unwraps the results from [refDestination] in order to get the
    // elements.
    final destElements = refDestination.map((result) => result.element);

    for (final destElement in destElements) {
      // This element is already in the list of results. Don't add it.
      if (destElement == element) {
        return;
      }
    }

    // Result already checked, can safely call the add function that does not check anything.
    _addResultUnchecked(refDestination: refDestination, element: element, priority: priority);
  }

  /// Creates a [Result] object from the [element] and its [priority] and adds it to the [refDestination].
  ///
  /// Lists in Dart are passed like references, it means that the function directly modify the given list. Don't give a
  /// copy of the list!
  void _addResultUnchecked({
    required List<Result> refDestination,
    required Element element,
    required int priority,
  }) {
    // Adds it to the list of results as a result.
    final result = Result(element: element, priority: priority);
    refDestination.add(result);
  }
}
