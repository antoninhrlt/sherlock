library sherlock;

import 'package:flutter/cupertino.dart';

bool helloSherlock() {
  return true;
}

/// The search functions add the found elements in [results]. No function
/// returns a result.
class Sherlock {
  /// Where to seek.
  ///
  /// Parameter [elements] is a [List] of [Map].
  /// Every element should have the same columns.
  ///
  /// ```dart
  /// final elements = [
  ///  {
  ///    'title': 'lorem ipsum',
  ///    'description': 'dolor sit amet',
  ///    'id': 1,
  ///  },
  ///  {
  ///    'title': 'ipsum',
  ///    'description': 'pretium porta',
  ///    'id': 2,
  ///  },
  ///  {
  ///    'title': 'condimentum quis sollicitudin',
  ///    'description': 'cras pretium lorem dignissim',
  ///    'id': 3,
  ///  },
  ///  {
  ///    'title': 'et lacus bibendum,',
  ///    'description': 'nec porttitor ante porta',
  ///    'id': 4,
  ///  }
  // ];
  /// ```
  final List<Map<String, dynamic>> elements;

  /// Research findings.
  List<Map<String, dynamic>> results;

  Map<String, dynamic> currentElement;

  Sherlock({required this.elements})
      : results = [],
        currentElement = {};

  /// Resets the [results].
  void forget() {
    results = [];
  }

  /// Smart search.
  void search({required String input}) {
    // todo : transform the input into a regex
    // todo : make it possible to do grammar errors.
    // - "activty" -> "activity"
    throw UnimplementedError();
  }

  /// Searches for values matching with the [regex], in the column [where] of
  /// the [elements].
  void query({required String where, required String regex}) {
    var what = RegExp(regex);

    /// Whether the search is to be performed in all columns
    var isGlobal = (where == '*');

    /// The [element] is a [Map] following the same structure.
    /// It means that [where] must be a column of [element].
    for (var element in elements) {
      currentElement = element;

      /// Searches in all columns.
      if (isGlobal) {
        _columnSearch(column: element, what: what);
        continue;
      }

      /// Searches in the specified column.
      /// When the column does not exist, does nothing.
      var value = element[where];
      if (value != null) {
        _valueSearch(value: value, what: what);
      }
    }
  }

  /// Searches for values when a key exists for [what] in [where].
  void queryExists({required String where, required String what}) {
    /// Cannot be global
    if (where == '*') {
      return;
    }

    for (var element in elements) {
      currentElement = element;

      /// Searches in the specified column.
      /// When it does not exist, does nothing.
      var value = currentElement[where];
      if (value != null) {
        if (value[what] != null) {
          results.add(currentElement);
        }
      }
    }
  }

  /// Searches for a value corresponding to a boolean expression in [where].
  void queryBool({
    required String where,
    required bool Function(dynamic value) fn,
  }) {
    /// The [element] is a [Map] following the same structure.
    /// It means that [where] must be a column of [element].
    for (var element in elements) {
      currentElement = element;

      /// Check the boolean expression, in the specified column.
      /// When the column does not exist, does nothing.
      var value = element[where];
      if (value == null) {
        continue;
      }

      // The boolean expression is true.
      if (fn(value)) {
        results.add(element);
      }
    }
  }

  /// Searches the value corresponding to [what] in the value [value].
  void _valueSearch({required String value, required RegExp what}) {
    if (value.toLowerCase().contains(what)) {
      /// Avoid duplicates
      if (!results.contains(currentElement)) {
        results.add(currentElement);
      }
    }
  }

  /// Searches the value corresponding to [what] in the [column].
  void _columnSearch({required Map column, required RegExp what}) {
    for (var columnOrValue in column.values) {
      if (columnOrValue.runtimeType == String) {
        /// Here, [columnOrValue] is a value.
        _valueSearch(value: columnOrValue, what: what);
      }
    }
  }
}
