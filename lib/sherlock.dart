library sherlock;

import 'package:sherlock/result.dart';
import 'package:sherlock/types.dart';
import 'package:sherlock/regex.dart';
import 'package:sherlock/normalize.dart';

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
  PriorityMap priorities;

  /// Settings for strings normalization.
  NormalizeSettings normalizeSettings;

  /// The current manipulated element. Used in loops by the query functions.
  Element _currentElement = {};

  /// Unsorted research findings, wrapped into a list of [Result].
  ///
  /// Use [sortResults] to sort them still wrapped, or use the [results] getter
  /// to sort them unwrapped.
  List<Result> unsortedResults = [];

  /// Sorted research findings.
  ///
  /// Results are unwrapped to a list of [Element].
  List<Element> get results =>
      sortResults(unsortedResults: unsortedResults).unwrap();

  /// Creates a [Sherlock] instance that will search in [elements] with a given
  /// map of [priorities].
  ///
  /// If [priorities] are not specified, the default priority is the only one
  /// specified for the priorities.
  /// But [priorities] can be specified, and with another "default priority".
  ///
  /// The default priority ('*') is 1.
  ///
  /// If [normalizeSettings] are not specified, the defaults settings are used.
  /// See [NormalizeSettings.defaults].
  Sherlock({
    required this.elements,
    PriorityMap priorities = const {'*': 1},
    this.normalizeSettings = const NormalizeSettings.defaults(),
  }) : priorities = {
          ...{'*': 1},
          ...priorities
        };

  /// Resets the [results].
  void forget() {
    unsortedResults = [];
  }

  /// Smart search in [where], from a *natural* user [input].
  ///
  /// Searches are performed in the following order, first searches gives the
  /// results with the greatest priorities :
  /// - Being equal
  /// - Starting with
  /// - All keywords in
  /// - At least one keyword in
  ///
  /// The specified [normalizeSettings] in [Sherlock] instancing are totally
  /// ignored. The smart search want to be smart and efficient, it uses its own
  /// [NormalizeSettings] object.
  ///
  /// If [where] is not specified, it is a global search ('*'), otherwise it is
  /// the key of the column where to search.
  void search({dynamic where = '*', required String input}) {
    Where(where: where).checkValidity();

    // Stores the [normalizeSettings] to restore them after the search.
    final storedOldNormalizeSettings = normalizeSettings;

    // Its own [NormalizeSettings].
    // Everything is normalized.
    normalizeSettings = NormalizeSettings(
      normalizeCase: true,
      normalizeCaseType: false,
      removeDiacritics: true,
    );

    // Splits the input into keywords.
    input = input.normalize(normalizeSettings);
    final inputKeywords = input.split(' ');

    // Creates an easily-manipulable 'where'.
    var smartWhere = Where(where: where);

    // Avoid duplicate code.
    void smartQuery({required void Function(String where) query}) {
      if (smartWhere.isGlobal) {
        query(where);
        return;
      }

      for (var column in smartWhere.columns) {
        query(column);
      }
    }

    // Being equal.
    smartQuery(
      query: (where) => queryMatch(
        where: where,
        match: input,
      ),
    );

    // Starting with.
    smartQuery(
      query: (where) => queryBool(
        where: where,
        fn: (value) => (value.runtimeType == String)
            ? value.toLowerCase().startsWith(input)
            : false,
      ),
    );

    // Searches for all the keywords at once.
    final regexAll = RegexHelper.all(
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

    // Restores the [normalizeSettings].
    normalizeSettings = storedOldNormalizeSettings;
  }

  /// Searches for values matching with the [regex], in [where].
  ///
  /// If [where] is not specified, it is a global search ('*'), otherwise it is
  /// the key of the column where to search.
  ///
  /// Applies the [normalizeSettings].
  void query({
    String where = '*',
    required String regex,
  }) {
    /// Creates the [RegExp] from the given [String] regex.
    var what = RegExp(regex, caseSensitive: normalizeSettings.caseSensitivity);

    /// Adds result when [what] is matching with the [regex].
    ///
    /// Recursive function when [stringOrList] is a [List].
    void addWhenMatch(dynamic stringOrList, int priority) {
      if (stringOrList == null) {
        return;
      }

      if (stringOrList.runtimeType == String) {
        // Normalize the string following the [normalizeSettings].
        stringOrList = stringOrList.toString().normalize(normalizeSettings);
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
    _queryAny(where, (columnId, priority) {
      addWhenMatch(_currentElement[columnId], priority);
    });
  }

  /// Searches for values when a key exists for [what] in [where].
  void queryExist({required String where, required String what}) {
    _queryAny(where, (columnId, priority) {
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
  void queryBool({
    String where = '*',
    required bool Function(dynamic value) fn,
  }) {
    _queryAny(where, (columnId, priority) {
      /// The return value of [fn] is true, it's a match !
      if (fn(_currentElement[columnId])) {
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
  /// Applies the [normalizeSettings].
  void queryMatch({
    String where = '*',
    required dynamic match,
  }) {
    bool stringComparison = match.runtimeType == String;

    if (stringComparison) {
      queryBool(
        where: where,
        fn: (value) {
          /// Cannot lowercase a non-string value.
          if (value.runtimeType != String) {
            return false;
          }

          return value.toString().normalize(normalizeSettings) ==
              match.toString().normalize(normalizeSettings);
        },
      );
      return;
    }

    /// Dynamic comparison.
    queryBool(where: where, fn: (value) => value == match);
  }

  /// Adds the [_currentElement] wrapped into a [Result] object, into the
  /// [results].
  void _addResult({required int priority}) {
    /// Avoid duplicates
    for (Result e in unsortedResults) {
      if (e.element == _currentElement) {
        return;
      }
    }

    // Adds the [_currentElement] to the results, with its [priority].
    unsortedResults.add(
      Result(
        element: _currentElement,
        priority: priority,
      ),
    );
  }

  /// Browses the [elements] to perform a search, calls [fn] giving the column
  /// id where the search has to be performed in, and the priority of this
  /// column.
  ///
  /// The callback [fn] can do anything, but it is designed to [_addResult]
  /// with the matching values.
  void _queryAny(
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
  }
}
