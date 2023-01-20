library sherlock;

import 'package:flutter/foundation.dart';

bool helloSherlock() {
  return true;
}

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

  void query({required String where, required String regex}) {
    var what = RegExp(regex);

    /// Whether the search is to be performed in all columns
    var isGlobal = (where == '*');

    /// The [element] is a [Map] following the same structure.
    /// It means that [where] must be a column of [element].
    for (var element in elements) {
      currentElement = element;

      if (isGlobal) {
        throw UnimplementedError();
      }

      /// Where the search will be performed as requested in parameters.
      var columnOrValue = element[where];

      if (columnOrValue.runtimeType == String) {
        var value = columnOrValue.toString();
        if (value.toLowerCase().contains(what)) {
          results.add(element);
        }
      } else {
        throw UnimplementedError();
      }
    }
  }

  /// Searches the value [what] in the value [value].
  void valueSearch({required String value, required String what}) {
    if (value.toLowerCase().contains(what.toLowerCase())) {
      results.add(currentElement);
    }
  }
}
