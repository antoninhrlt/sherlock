import 'package:sherlock/sherlock.dart';
import 'package:sherlock/result.dart';
import 'package:sherlock/types.dart';

/// Tool to complete the user input in search bars.
///
/// **This is not AI**. It works with [Sherlock]. For example, it can complete the name the user is writing from the
/// names database if a user wants to find someone from their name. "Linus To" (user input) -> "Linus Torvalds"
/// (completion/suggestion).
///
/// Also called "suggestions" instead of "completions" in the [SearchAnchor] by Flutter.
class SherlockCompletion {
  /// Researcher to find completion texts from the given [elements].
  final Sherlock sherlock;

  /// # Example/Explanations
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
  /// [SherlockCompletion] might be used in the `'name'` column as following:
  /// ```dart
  /// SherlockCompletion(where: 'name', elements: /* ... */);
  /// ```
  final String where;

  /// Creates a new [SherlockCompletions]. Basically the given [elements] are the same given to the [Sherlock] object
  /// which might have been built before for researches.
  ///
  /// To optimise, the [elements] could contain only the columns [where].
  SherlockCompletion({required this.where, required elements}) : sherlock = Sherlock(elements: elements);

  /// Returns the possible completions of the given user [input].
  ///
  /// The researches are done in two times:
  /// - Basic researches that might return no result.
  /// - Forced further researches when the minimum of results is not reached
  ///
  /// ## Minimum and maximum numbers of results.
  /// The minimum number of results expected from this function can be specified with [minResults].
  /// The maximum number of results expected from this function can be specified with [maxResults].
  ///
  /// When the minimum or results is reached, the "further researches" are not done. Otherwise, it forces to search more
  /// to try to get enough results as expected.
  ///
  /// Never returns more than [maxResults] results.
  Future<List<Result>> input({
    required String input,
    bool caseSensitive = false,
    bool? caseSensitiveFurtherSearches,
    int? minResults,
    int? maxResults,
  }) async {
    // No input, no results.
    if (input.isEmpty) {
      return [];
    }

    // Checks for strings starting with [input].
    final Future<List<Result>> startingResults = sherlock.queryBool(
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
    if (minResults != null && minResults > (await startingResults).length) {
      // Searches for keyword starting with the input.
      final Future<List<Result>> keywordStartingResults = sherlock.queryBool(
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

      // Searches the input in strings.
      final Future<List<Result>> inResults = sherlock.queryBool(
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

      return _selectResults(
        [...await startingResults, ...await keywordStartingResults, ...await inResults],
        minResults,
        maxResults,
      );
    }

    return _selectResults(
      await startingResults,
      minResults,
      maxResults,
    );
  }

  List<Result> _selectResults(
    List<Result> allResults,
    int? minResults,
    int? maxResults,
  ) {
    // The actual results from Sherlock.
    final results = allResults.sorted();

    // Returns only [maxResults] results.
    if (maxResults != null && maxResults < results.length) {
      return results.getRange(0, maxResults).toList();
    }

    // Returns all the results.
    return results;
  }

  /// Returns the value of [where] for each result's element in order to return
  /// a list of strings instead of results.
  Future<List<String>> getStrings({required List<Result> fromResults}) async {
    return fromResults.unwrap().map((e) => e[where].toString()).toSet().toList();
  }

  /// Returns the range of the text which has not been changed by the
  /// completions for each completion.
  ///
  /// Can be used to bold the unchanged part, the part typed by the user.
  ///
  /// ## Example
  /// input: "Linus T" -> completion: "Linus Torvalds". The unchanged range is from 'L' to 'T' so 0 to 6.
  static Future<List<Range>> unchangedRanges({
    required String input,
    required List<String> results,
  }) async {
    var ranges = <Range>[];

    for (final result in results) {
      final ix = result.toLowerCase().indexOf(input.toLowerCase());
      ranges.add(Range(start: ix, end: ix + input.length));
    }

    return ranges;
  }
}
