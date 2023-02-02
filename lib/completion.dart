import 'package:sherlock/sherlock.dart';
import 'package:sherlock/result.dart';
import 'package:sherlock/types.dart';

/// A search completion tool.
///
/// Uses [Sherlock] to help user completing their input.
class SherlockCompletion {
  /// [Sherlock] instance used to find completions.
  Sherlock sherlock;

  /// ```json
  /// {
  ///   'name': 'farm',
  ///   'description': 'a beautiful farm with cows'
  /// },
  /// {
  ///   'name': 'far west',
  ///   'description': 'somewhere far away, in the west'
  /// },
  /// {
  ///   'name': 'nightclub',
  ///   'description': 'the coolest nightclub in France'
  /// }
  /// ```
  /// The user input might be `far...` in order to find a *farm* or the *far
  /// west*, it seems the user is not looking for a *nightclub*...
  /// [SherlockCompletion] might be used in the `'name'` column.
  /// ```dart
  /// SherlockCompletion(where: 'name', elements: /*todo*/);
  /// ```
  String where;

  /// Results found by [Sherlock] in [input].
  List<Element> results = [];

  SherlockCompletion({required this.where, required elements})
      : sherlock = Sherlock(elements: elements);

  /// Gets values which could be the completion of [input]. These values are the
  /// columns [where] of the matching [elements]. The [Sherlock]'s [results] can
  /// be retrieved to get the matching [elements] instead.
  ///
  /// Sets the minimum number of results wanted with [minResults]. If
  /// [minResults] is -1 or less or equal than the number of results, the normal
  /// search is done. Otherwise, more searches will be performed but the results
  /// might be less relevant. Besides, it is possible to get less results than
  /// [minResults].
  ///
  /// Sets a maximum number of results with [maxResults]. If [maxResults] is -1
  /// or greater than the number of results, all the results are returned.
  List<String> input({
    required String input,
    bool caseSensitive = false,
    bool? caseSensitiveFurtherSearches,
    int minResults = -1,
    int maxResults = -1,
  }) {
    // No input, no results.
    if (input.isEmpty) {
      return [];
    }

    // Checks for strings starting with [input].
    sherlock.queryBool(
      where: where,
      fn: (value) {
        // Only matches with strings.
        if (value.runtimeType != String) {
          return false;
        }

        if (!caseSensitive) {
          // Ignores the case
          return value.toLowerCase().startsWith(input.toLowerCase());
        }

        return value.startsWith(input);
      },
    );

    // Performs further searches to get at least minimum number of results
    // wanted.
    if (minResults != -1 && minResults > sherlock.unsortedResults.length) {
      // Searches for keyword starting with the [input].
      sherlock.queryBool(
        where: where,
        fn: (value) {
          // Only matches with strings.
          if (value.runtimeType != String) {
            return false;
          }

          // If [caseSensitiveFurtherSearches] is not defined, [caseSensitive]
          // is used instead.
          if (!(caseSensitiveFurtherSearches ?? caseSensitive)) {
            // Ignores the case
            for (var keyword in value.toLowerCase().split(' ')) {
              if (keyword.startsWith(input.toLowerCase())) {
                return true;
              }
            }
          }

          for (var keyword in value.split(' ')) {
            if (keyword.startsWith(input.toLowerCase())) {
              return true;
            }
          }

          return false;
        },
      );

      // Searches [input] in strings.
      sherlock.queryBool(
        where: where,
        fn: (value) {
          // Only matches with strings.
          if (value.runtimeType != String) {
            return false;
          }

          // If [caseSensitiveFurtherSearches] is not defined, [caseSensitive]
          // is used instead.
          if (!(caseSensitiveFurtherSearches ?? caseSensitive)) {
            // Ignores the case
            return value.toLowerCase().contains(input.toLowerCase());
          }

          return value.contains(input);
        },
      );
    }

    // Saves the [Sherlock] results, unwrapped
    results = sherlock.unsortedResults.unwrap();

    // Does not return the elements but the fields [where].
    var stringResults = results.map((e) => e[where].toString()).toList();

    // Destroys the [Sherlock] results.
    sherlock.forget();

    // Returns only [maxResults] results.
    if (maxResults != -1 && maxResults < results.length) {
      return stringResults.getRange(0, maxResults).toList();
    }

    // Returns all the results.
    return stringResults;
  }

  /// Returns the ranges of the unchanged parts of the completion results.
  ///
  /// The unchanged part is the part of a completion result being the input.
  List<Range> unchangedRanges({
    required String input,
    required List<String> results,
  }) {
    var ranges = <Range>[];

    for (var result in results) {
      var ix = result.toLowerCase().indexOf(input.toLowerCase());
      ranges.add(Range(start: ix, end: ix + input.length));
    }

    return ranges;
  }
}
