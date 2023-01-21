library sherlock;

/// Returns `true`. Can be used to test if "sherlock" is correctly installed.
bool helloSherlock() {
  return true;
}

/// The search functions add the found elements in [results]. No function
/// returns a result.
class Sherlock {
  /// Where to search.
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
    String regex = r'(';

    var keywords = input.split(' ');
    for (var keyword in keywords) {
      regex += keyword;
      if (keyword != keywords.last) {
        regex += r'|';
      }
    }

    regex += r')';

    queryBool(
      where: '*',
      fn: (value) => (value.runtimeType == String)
          ? value.toLowerCase() == input.toLowerCase()
          : false,
    );
    query(where: '*', regex: regex);
  }

  void query({
    required String where,
    required String regex,
    bool caseSensitive = false,
  }) {
    queryContain(where: where, regex: regex, caseSensitive: caseSensitive);
  }

  /// Searches for values matching with the [regex], in [where].
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
    for (var element in elements) {
      currentElement = element;

      /// Searches in all columns.
      if (isGlobal) {
        for (var dyn in element.values) {
          /// Cannot check for a non-string value.
          if (dyn.runtimeType != String) {
            continue;
          }

          /// Here, [dyn] is a [String].
          if (dyn.contains(what)) {
            addResult();
          }
        }

        continue;
      }

      /// Searches in the specified column.

      /// When the column does not exist, or if the column's value is not a
      /// string, does nothing.
      var value = element[where];
      if (value == null || value.runtimeType != String) {
        continue;
      }

      if (value.contains(what)) {
        addResult();
      }
    }
  }

  /// Searches for values when a key exists for [what] in [where].
  void queryExist({required String where, required String what}) {
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
          addResult();
        }
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
    for (var element in elements) {
      currentElement = element;

      /// Checks the boolean expression in all columns.
      if (isGlobal) {
        for (var dyn in element.values) {
          if (fn(dyn)) {
            addResult();
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
        addResult();
      }
    }
  }

  /// Searches for a value which is equal to [match], in [where].
  void queryMatch({required String where, required dynamic match}) {
    queryBool(where: where, fn: (value) => value == match);
  }

  /// Adds the [currentElement] in the [results].
  ///
  /// Avoid duplicated, does not add the element if it's already in the
  /// [results].
  void addResult() {
    /// Avoid duplicates
    if (!results.contains(currentElement)) {
      results.add(currentElement);
    }
  }
}
