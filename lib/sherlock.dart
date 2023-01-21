library sherlock;

import 'dart:ffi';

import 'package:sherlock/priority.dart';

/// Returns `true`. Can be used to test if "sherlock" is correctly installed.
bool helloSherlock() {
  return true;
}

typedef Element = Map<String, dynamic>;
typedef Column = Map<String, dynamic>;
typedef PointsMap = Map<int, List<Element>>;

/// The search functions add the found elements in [results]. No function
/// returns a result.
class Sherlock {
  /// Where to search.
  final List<Element> elements;

  /// Column priorities to sort results.
  PriorityMap priorities;

  /// Points map of the results.
  PointsMap _unsortedResults;

  Element currentElement;

  /// Sorted research findings.
  List<Element> get results {
    List<Element> sortedResults = [];

    for (int resultKey in _unsortedResults.keys.toList()
      ..sort((a, b) => -a.compareTo(b))) {
      for (Element result in _unsortedResults[resultKey]!) {
        sortedResults.add(result);
      }
    }

    return sortedResults;
  }

  List<Element> get unsortedResults {
    List<Element> results = [];
    _unsortedResults.forEach((_, elements) => results.addAll(elements));
    return results;
  }

  Sherlock({required this.elements, this.priorities = const {'*': 1}})
      : _unsortedResults = {},
        currentElement = {};

  /// Resets the [results].
  void forget() {
    _unsortedResults = {};
  }

  /// Smart search in [where], from a user's [input].
  ///
  /// The value [where] can be either a [String] (whe equal to `'*'`) or a
  /// [List] of [String] being the columns where to search.
  ///
  /// Adds the perfect matches.
  /// Creates a regex from the [input] and searches in specified columns.
  void search({required dynamic where, required String input}) {
    /// Creates a regex to find other elements corresponding to the search.
    String regex = r'(';

    var keywords = input.split(' ');
    for (var keyword in keywords) {
      regex += keyword;
      if (keyword != keywords.last) {
        regex += r'|';
      }
    }

    regex += r')';

    if (where == '*') {
      /// Global search
      _searchWhere(where: where, input: input, regex: regex);
      return;
    }

    /// Searches in all specified columns.

    if (where.runtimeType != List<String>) {
      throw TypeError();
    }

    for (var column in where) {
      _searchWhere(where: column, input: input, regex: regex);
    }
  }

  void _searchWhere({
    required String where,
    required String input,
    required String regex,
  }) {
    /// Matches, no matter the case.
    queryBool(
      where: where,
      fn: (value) => (value.runtimeType == String)
          ? value.toLowerCase() == input.toLowerCase()
          : false,
    );

    query(where: where, regex: regex);
  }

  void query({
    required String where,
    required String regex,
    bool caseSensitive = false,
  }) {
    queryContain(where: where, regex: regex, caseSensitive: caseSensitive);
  }

  /// Searches for values matching with the [regex], in column [where].
  void queryContain({
    required String where,
    required String regex,
    bool caseSensitive = false,
  }) {
    var what = RegExp(regex, caseSensitive: caseSensitive);

    /// Whether the search is to be performed in all columns
    var isGlobal = (where == '*');

    /// The [element] is a [Map] following the same structure.
    /// It means that [where] must be a column of [element].
    for (Element element in elements) {
      currentElement = element;

      /// Searches in all columns.
      if (isGlobal) {
        for (var key in element.keys) {
          addWhenContains(
            dyn: element[key],
            regex: what,
            importance: priorities[key] ?? priorities['*']!,
          );
        }

        continue;
      }

      addWhenContains(
        dyn: element[where],
        regex: what,
        importance: priorities[where] ?? priorities['*']!,
      );
    }
  }

  /// Searches if a matching expression of [regex] is contained in [dyn], when
  /// [dyn] is either a [String] or a [List] of [String].
  ///
  /// Recursive function for [List].
  void addWhenContains(
      {required dynamic dyn, required RegExp regex, required int importance}) {
    if (dyn == null) {
      return;
    }

    if (dyn.runtimeType == String) {
      if (dyn.contains(regex)) {
        addResult(importance: importance);
      }
    } else if (dyn.runtimeType == List<String>) {
      for (String element in dyn) {
        addWhenContains(dyn: element, regex: regex, importance: importance);
      }
    }
  }

  /// Searches for values when a key exists for [what] in [where].
  void queryExist({required String where, required String what}) {
    /// Cannot be global
    if (where == '*') {
      return;
    }

    for (Element element in elements) {
      currentElement = element;

      /// Searches in the specified column.
      /// When it does not exist, does nothing.
      var value = currentElement[where];
      if (value != null && value[what] != null) {
        addResult(importance: priorities[where] ?? priorities['*']!);
      }
    }
  }

  /// Searches for a value corresponding to a boolean expression in [where].
  void queryBool({
    required String where,
    required bool Function(dynamic value) fn,
  }) {
    /// Whether the search is to be performed in all columns
    var isGlobal = (where == '*');

    /// The [element] is a [Map] following the same structure.
    /// It means that [where] must be a column of [element].
    for (Element element in elements) {
      currentElement = element;

      /// Checks the boolean expression in all columns.
      if (isGlobal) {
        for (var key in element.keys) {
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
  void queryMatch({required String where, required dynamic match}) {
    queryBool(where: where, fn: (value) => value == match);
  }

  /// Adds the [currentElement] in the [results].
  ///
  // /// Avoid duplicates, does not add the element if it's already in the
  // /// [results].
  void addResult({required int importance}) {
    // Avoid duplicates.
    for (List<Element> results in _unsortedResults.values) {
      if (results.contains(currentElement)) {
        return;
      }
    }

    if (_unsortedResults[importance] == null) {
      _unsortedResults[importance] = [currentElement];
    } else {
      _unsortedResults[importance]!.add(currentElement);
    }
  }
}
