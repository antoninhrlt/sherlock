library sherlock;

import 'package:sherlock/types.dart';
import 'package:sherlock/regex.dart';

/// Returns `true`. Can be used to test if "sherlock" is correctly installed.
bool helloSherlock() {
  return true;
}

/// The search functions add the found elements in [results]. No function
/// returns a result.
class Sherlock {
  /// Where to search.
  final List<Element> elements;

  /// Column priorities to sort the results.
  final PriorityMap priorities;

  /// Default column priorities
  static PriorityMap _defaults = {'*': 1};

  /// Results are wrapped in a map of points. When they have priority 5 for
  /// example, they are added in [_unsortedResults]`[5]`
  Map<int, List<Element>> _unsortedResults;

  /// The current manipulated element. Used in loops by the query functions.
  Element _currentElement;

  /// Sorted research findings.
  List<Element> get results {
    List<Element> sortedResults = [];

    /// Orders the [_unsortedResults]' keys by points.
    /// The keys are actually the points of each column.
    /// Greater points are above the smaller points.
    var sortedKeys = _unsortedResults.keys.toList()..sort((a, b) => -a.compareTo(b));

    for (int resultKey in sortedKeys) {
      // Adds all the results ranged in this column.
      sortedResults.addAll(_unsortedResults[resultKey]!);
    }

    /// Finally, returns the results sorted by points.
    /// Results with greatest points are above.
    return sortedResults;
  }

  /// Unsorted research findings.
  List<Element> get unsortedResults {
    List<Element> results = [];

    /// Extracts the results from [_unsortedResults] to get a list instead of a
    /// map. Points don't matter.
    _unsortedResults.forEach((_, elements) => results.addAll(elements));
    return results;
  }

  /// Creates a [Sherlock] instance that will search in [elements].
  ///
  /// The parameter [priorities] can be provided to sort the results.
  /// The default set value for `'*'` is 1. If some columns are set with an
  /// importance smaller than 1, they will be less important than all the other
  /// non-specified columns.
  ///
  /// Basically :
  /// ```dart
  /// final elements = [
  ///   {
  ///     'col1': 'foo1',
  ///     'col2': 'foo2',
  ///     'col3': 'foo3",
  ///   },
  ///   // ...
  /// ];
  ///
  /// final priorities = {
  ///   'col1': 2, // 'col1' is more important than the other columns.
  ///   'col2': 0, // 'col2' is less important than the other columns.
  ///   // 'col3' has the priority set to 1.
  /// };
  ///
  /// final prioritiesWithSpecifiedStar = {
  ///   'col1': 3, // 'col1' is more important the other columns.
  ///   'col2': 1, // 'col2' is less important than the other columns
  ///   '*': 2, // 'col3' has the priority set to 2.
  /// };
  /// ```
  Sherlock({required this.elements, priorities = const {'*': 1}})
      : _unsortedResults = {},
        _currentElement = {},
        priorities = {..._defaults, ...priorities};

  /// Resets the [results].
  void forget() {
    _unsortedResults = {};
  }

  /// Smart search in [where], from a natural user [input].
  ///
  /// At first, adds perfect matches, to make them on top of the results list.
  /// Then, searches the matches for all keywords of the user [input].
  /// Finally, searches match for any keyword of the user [input].
  ///
  /// The [where] parameter is either equal to `'*'` for global search (in all
  /// columns) or a list of columns.
  void search({dynamic where = "*", required String input}) {
    /// The type of [where] can be either a list of keywords or '*'.
    if ((where.runtimeType != List<String>) && (where.runtimeType != String)) {
      throw TypeError();
    } else if (where.runtimeType == String && where != '*') {
      /// [String] type is only accepted when [where] equals '*'.
      throw Error();
    }

    final inputKeywords = input.split(' ');

    /// Searches for all the keywords at once.
    final regexAll = RegexHelper.all(keywords: inputKeywords);

    /// Searches any word from the keywords.
    final regexAny = RegexHelper.any(keywords: inputKeywords);

    /// Searches globally.
    if (where == '*') {
      queryBool(
        where: where,
        fn: (value) => (value.runtimeType == String) ? value.toLowerCase() == input.toLowerCase() : false,
      );

      query(where: where, regex: regexAll);
      query(where: where, regex: regexAny);
      return;
    }

    /// Separate the loops

    /// Searches perfect matches.
    for (var column in where) {
      /// The case does not matter.
      queryBool(
        where: column,
        fn: (value) => (value.runtimeType == String) ? value.toLowerCase() == input.toLowerCase() : false,
      );
    }

    /// Searches in specified columns.
    for (var column in where) {
      /// Searches for all the keywords at once.
      query(where: column, regex: regexAll);
    }

    for (var column in where) {
      /// Searches any word from the keywords.
      query(where: column, regex: regexAny);
    }
  }

  /// Equivalent to [queryContain].
  void query({
    String where = "*",
    required String regex,
    bool caseSensitive = false,
  }) {
    queryContain(where: where, regex: regex, caseSensitive: caseSensitive);
  }

  /// Searches for values which contain a value matching with the [regex], in
  /// [where].
  ///
  /// The parameter [where] is either '*' (global search) or a column key.
  void queryContain({
    String where = "*",
    required String regex,
    bool caseSensitive = false,
  }) {
    /// Creates the [RegExp] from the given [String] regex.
    var what = RegExp(regex, caseSensitive: caseSensitive);

    /// Whether the search is to be performed in all columns
    var isGlobal = (where == '*');

    /// The [element] is a [Map] following the same structure.
    /// It means that [where] must be a column of [element].
    for (Element element in elements) {
      _currentElement = element;

      /// Searches in all columns.
      if (isGlobal) {
        for (var key in element.keys) {
          _addWhenContains(
            dyn: element[key],
            regex: what,
            importance: priorities[key] ?? priorities['*']!,
          );
        }

        continue;
      }

      /// Searches in the specified column.
      _addWhenContains(
        dyn: element[where],
        regex: what,
        importance: priorities[where] ?? priorities['*']!,
      );
    }
  }

  /// Searches if a matching expression of [regex] is contained in [dyn],
  ///
  /// The parameter [dyn] is either a [String] or a list of [String].
  ///
  /// When [dyn] is a [List] object, the function is called recursively for all
  /// the strings in the list.
  void _addWhenContains({
    required dynamic dyn,
    required RegExp regex,
    required int importance,
  }) {
    /// Nothing cannot contains something.
    if (dyn == null) {
      return;
    }

    if (dyn.runtimeType == String) {
      /// The string contains a value matching with the [regex], adds the current
      /// element to the results.
      if (dyn.contains(regex)) {
        addResult(importance: importance);
      }
    } else if (dyn.runtimeType == List<String>) {
      /// Calls this function recursively for all the elements of the list.
      for (String element in dyn) {
        _addWhenContains(dyn: element, regex: regex, importance: importance);
      }
    }
  }

  /// Searches for values when a key exists for [what] in [where].
  void queryExist({required String where, required String what}) {
    /// Cannot be global.
    if (where == '*') {
      return;
    }

    for (Element element in elements) {
      _currentElement = element;

      /// Searches in the specified column.
      /// When it does not exist, does nothing.
      var value = _currentElement[where];
      if (value != null && value[what] != null) {
        addResult(importance: priorities[where] ?? priorities['*']!);
      }
    }
  }

  /// Searches for a value corresponding to a boolean expression in [where].
  void queryBool({
    String where = "*",
    required bool Function(dynamic value) fn,
  }) {
    /// Whether the search is to be performed in all columns
    var isGlobal = (where == '*');

    /// The [element] is a [Map] following the same structure.
    /// It means that [where] must be a column of [element].
    for (Element element in elements) {
      _currentElement = element;

      /// Checks the boolean expression in all columns.
      if (isGlobal) {
        for (var key in element.keys) {
          /// The boolean expression is true.
          if (fn(element[key])) {
            addResult(
              importance: priorities[key] ?? priorities['*']!,
            );
          }
        }

        continue;
      }

      /// Checks the boolean expression, in the specified column.
      /// When the column does not exist, does nothing.
      var value = element[where];
      if (value == null) {
        continue;
      }

      // The boolean expression is true.
      if (fn(value)) {
        addResult(importance: priorities[where] ?? priorities['*']!);
      }
    }
  }

  /// Searches for a value which is equal to [match], in [where].
  void queryMatch({String where = "*", required dynamic match}) {
    queryBool(where: where, fn: (value) => value == match);
  }

  /// Adds the [_currentElement] in the [results].
  ///
  /// There should be duplicated since [shouldContinue] is used in loops over
  /// [elements].
  void addResult({required int importance}) {
    for (List<Element> results in _unsortedResults.values) {
      if (results.contains(_currentElement)) {
        return;
      }
    }

    /// There is/are already element/s of this importance in the results.
    if (_unsortedResults[importance] != null) {
      /// Adds the element to the results.
      _unsortedResults[importance]!.add(_currentElement);
      return;
    }

    /// Initialises a list for elements of this importance, with the current
    /// element as first element of this list.
    _unsortedResults[importance] = [_currentElement];
  }
}
