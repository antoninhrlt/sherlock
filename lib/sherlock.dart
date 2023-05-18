library sherlock;

import 'package:sherlock/result.dart';
import 'package:sherlock/stopwords.dart';
import 'package:sherlock/types.dart';
import 'package:sherlock/regex.dart';
import 'package:sherlock/normalize.dart';

/// Returns `true`. Can be used to test if "sherlock" is correctly installed.
bool helloSherlock() {
  return true;
}

/// Creates a local [Sherlock] object and perform queries.
///
/// [elements], [priorities], [normalization] are the same parameters as the
/// [Sherlock] constructor.
///
/// [queries] is a callback which has the [Sherlock] object to perform queries
/// and should return the results since this function aims to return them.
///
/// Returns the results of the [Sherlock] object.
List<Result> sherlock({
  required List<Element> elements,
  PriorityMap priorities = const {'*': 1},
  NormalizationSettings normalization = const NormalizationSettings.defaults(),
  required List<Result> Function(Sherlock sherlock) queries,
}) {
  final sherlock = Sherlock(elements: elements, normalization: normalization, priorities: priorities);
  return queries(sherlock);
}

class Sherlock {
  /// Where to search. Basically, a map described like a JSON file.
  final List<Element> elements;

  /// Column priorities to sort the results.
  PriorityMap priorities;

  /// Settings for strings normalization.
  NormalizationSettings normalization;

  /// The current manipulated element. Used in loops by the query functions.
  Element _currentElement = {};

  /// Stores the results in this list before returning it in functions.
  ///
  /// It can be sorted thanks to [sortResults].
  List<Result> _currentResults = [];

  /// Creates a [Sherlock] instance that will search in [elements] with a given
  /// map of [priorities].
  ///
  /// If [priorities] are not specified, the default priority is the only one
  /// specified for the priorities.
  /// But [priorities] can be specified, and with another "default priority".
  /// > The default priority ('*') is 1.
  ///
  /// If [normalization] is not specified, the defaults settings are used. See
  /// [NormalizationSettings.defaults] for more.
  ///
  /// If [sortResultsBeforeReturning] is not specified, it is true.
  Sherlock({
    required this.elements,
    PriorityMap priorities = const {'*': 1},
    this.normalization = const NormalizationSettings.defaults(),
  }) : priorities = {
          ...{'*': 1},
          ...priorities
        };

  /// Smart search in [where], from a *natural* user [input].
  ///
  /// Searches are performed in the following order, first researches give the
  /// results with the greatest priorities :
  /// - Being equal
  /// - Starting with
  /// - All keywords in
  /// - At least one keyword in
  ///
  /// If [stopWords] are not specified, English stop-words are used, otherwise
  /// they are a list of words that will be removed of the input. A specific
  /// list of [stopWords] can be specified to use another language for example.
  /// > See [StopWords].
  ///
  /// If [where] is not specified, it is a global search ('*'), otherwise it is
  /// a list of the keys of the columns where to search.
  ///
  /// Returns the research findings of this function.
  List<Result> search({
    dynamic where = '*',
    required String input,
    List<String> stopWords = StopWords.en,
  }) {
    Where(where: where).checkValidity();

    // Stores the [normalization] to restore it at the end of the search.
    final storedOldNormalization = normalization;

    // Its own [NormalizationSettings].
    normalization = NormalizationSettings(
      normalizeCase: true,
      normalizeCaseType: false,
      removeDiacritics: true,
    );

    // Normalizes the input string and remove the [stopWords].
    input = input.normalize(normalization).removeStopWords(stopWords);

    if (input.isEmpty) {
      return [];
    }

    // Splits the input into keywords.
    final inputKeywords = input.split(' ')..removeWhere((e) => e.isEmpty);

    // Creates an easily-manipulable 'where'.
    var smartWhere = Where(where: where);

    List<Result> results = [];

    // Avoid duplicate code.
    void smartQuery({required List<Result> Function(String where) query}) {
      if (smartWhere.isGlobal) {
        results += query(where);
        return;
      }

      for (var column in smartWhere.columns) {
        results += query(column);
      }
    }

    // Being equal.
    smartQuery(
      query: (where) => queryBool(
        where: where,
        fn: (value) {
          if (value.runtimeType != String) {
            return false;
          }

          return value.toString().normalize(normalization) == input;
        },
      ),
    );

    // Starting with.
    smartQuery(
      query: (where) => queryBool(
        where: where,
        fn: (value) {
          if (value.runtimeType != String) {
            return false;
          }

          final normalizedValue = value.toString().normalize(normalization);
          return normalizedValue.startsWith(input);
        },
      ),
    );

    // Searches for all the keywords at once.
    final regexAll = RegexHelper.flexAll(
      keywords: inputKeywords,
      searchWords: true,
    );

    // All keywords in.
    smartQuery(
      query: (where) => query(where: where, regex: regexAll),
    );

    // Searches any word from the keywords.
    final regexAny = RegexHelper.any(
      keywords: inputKeywords,
      searchWords: true,
    );

    // At least all keywords in.
    smartQuery(
      query: (where) => query(where: where, regex: regexAny),
    );

    // Restores the [normalization].
    normalization = storedOldNormalization;

    return results;
  }

  /// Searches for values matching with the [regex], in [where].
  ///
  /// If [where] is not specified, it is a global search ('*'), otherwise it is
  /// the key of the column where to search.
  ///
  /// Applies the [normalization] or the [specificNormalization] when specified.
  ///
  /// Returns the research findings of this function.
  List<Result> query({
    String where = '*',
    required String regex,
    NormalizationSettings? specificNormalization,
  }) {
    // Stores the [normalization] to restore it at the end of the query.
    var savedOldNormalization = normalization;

    // Uses the specific normalization parameters.
    if (specificNormalization != null) {
      normalization.updateFrom(specificNormalization);
    }

    /// Creates the [RegExp] from the given [String] regex.
    var what = RegExp(regex, caseSensitive: normalization.caseSensitivity);

    /// Adds result when [what] is matching with the [regex].
    ///
    /// Recursive function when [stringOrList] is a [List].
    void addWhenMatch(dynamic stringOrList, int priority) {
      if (stringOrList == null) {
        return;
      }

      if (stringOrList.runtimeType == String) {
        // Normalize the string following the [normalizeSettings].
        stringOrList = stringOrList.toString().normalize(normalization);
        // The string contains a value matching with the [regex], adds the current
        // element to the results.
        if (what.hasMatch(stringOrList)) {
          _addResult(priority: priority);
        }

        return;
      }

      /// Recursive call to check each string of the list.
      if (stringOrList.runtimeType == List<String>) {
        /// Calls this function recursively for all the strings of the list.
        for (String string in stringOrList) {
          addWhenMatch(string, priority);
        }

        return;
      }

      /// Recursive call for list of list or list of list of list etc...
      if (stringOrList.runtimeType == List<dynamic>) {
        /// Calls this function recursively for all the objects of the list.
        for (dynamic dyn in stringOrList) {
          addWhenMatch(dyn, priority);
        }

        return;
      }
    }

    /// Performs the query.
    final results = _queryAny(where, (columnId, priority) {
      addWhenMatch(_currentElement[columnId], priority);
    });

    // Restores the [normalization].
    normalization = savedOldNormalization;

    return results;
  }

  /// Searches for values when a key exists for [what] in [where].
  ///
  /// Returns the research findings of this function.
  List<Result> queryExist({required String where, required String what}) {
    return _queryAny(where, (columnId, priority) {
      /// Searches in the specified column.
      /// When [what] does not exist, does nothing.
      var value = _currentElement[columnId];

      /// Does not exist, or the value exists but it is null.
      if (value == null || value[what] == null) {
        return;
      }

      _addResult(priority: priorities[columnId] ?? priorities['*']!);
    });
  }

  /// Searches for a value corresponding to a boolean expression in [where].
  ///
  /// If [where] is not specified, it is a global search ('*'), otherwise it is
  /// the key of the column where to search.
  ///
  /// Returns the research findings of this function.
  List<Result> queryBool({
    String where = '*',
    required bool Function(dynamic value) fn,
  }) {
    return _queryAny(where, (columnId, priority) {
      final colVal = _currentElement[columnId];

      if (colVal == null) {
        return;
      }

      /// The return value of [fn] is true, it's a match !
      if (fn(colVal)) {
        _addResult(
          priority: priorities[columnId] ?? priorities['*']!,
        );
      }
    });
  }

  /// Searches for a value which is equal to [match], in [where].
  ///
  /// If [where] is not specified, it is a global search ('*'), otherwise it is
  /// the key of the column where to search.
  ///
  /// Applies the [normalization] or the [specificNormalization] when specified.
  ///
  /// Returns the research findings of this function.
  List<Result> queryMatch({
    String where = '*',
    required dynamic match,
    NormalizationSettings? specificNormalization,
  }) {
    // Stores the [normalization] to restore it at the end of the query.
    var savedOldNormalization = normalization;

    // Uses the specific normalization parameters.
    if (specificNormalization != null) {
      normalization.updateFrom(specificNormalization);
    }

    bool stringComparison = match.runtimeType == String;

    if (stringComparison) {
      final results = queryBool(
        where: where,
        fn: (value) {
          /// Cannot lowercase a non-string value.
          if (value.runtimeType != String) {
            return false;
          }

          return value.toString().normalize(normalization) == match.toString().normalize(normalization);
        },
      );

      return results;
    }

    /// Dynamic comparison.
    final results = queryBool(where: where, fn: (value) => value == match);

    // Restores the [normalization].
    normalization = savedOldNormalization;

    return results;
  }

  /// Browses the [elements] to perform a research, calls [fn] giving the column
  /// id where the search has to be performed in, and the priority of this
  /// column.
  ///
  /// The callback [fn] can do anything, but it is designed to [_addResult]
  /// with the matching values.
  ///
  /// Returns the research findings of this function.
  List<Result> _queryAny(
    String where,
    void Function(String columnId, int priority) fn,
  ) {
    for (Element element in elements) {
      /// Sets the [_currentElement] in order to be used by the other functions.
      _currentElement = element;

      if (Where(where: where).isGlobal) {
        /// Performs search in all the columns of the [_currentElement].
        for (var key in _currentElement.keys) {
          fn(
            key,
            priorities[key] ?? priorities['*']!,
          );
        }
      } else {
        /// Performs a search in the specified column.
        fn(
          where,
          priorities[where] ?? priorities['*']!,
        );
      }
    }

    return _results();
  }

  /// Adds the [_currentElement] wrapped into a [Result] object, into the
  /// [_currentResults].
  ///
  /// Don't add duplicates.
  void _addResult({required int priority}) {
    final result = Result(
      element: _currentElement,
      priority: priority,
    );

    // Avoid duplicates
    for (var element in _currentResults.map((result) => result.element)) {
      if (element == _currentElement) {
        return;
      }
    }

    _currentResults.add(result);
  }

  /// Function to call at the end of a query in order the return the results.
  List<Result> _results() {
    // Stores the results to return them.
    List<Result> results = List.from(_currentResults);
    // Resets the list to use it again in other calls.
    _currentResults = [];

    return results;
  }
}
