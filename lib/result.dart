import 'package:sherlock/types.dart';

/// Contains the element which is the research finding and its priority in order
/// to sort it later.
class Result {
  /// The research finding.
  Element element;

  /// The priority of the result for sorting.
  int priority;

  /// Creates a [Result] from an element and its priority.
  Result({required this.element, required this.priority});
}

extension SortResults on List<Result> {
  /// Gets the results sorted by their priority.
  ///
  /// Should not be confounded with the [List.sort] function !
  List<Result> sorted() => this..sort((a, b) => -a.priority.compareTo(b.priority));
}

extension UnwrapResults on List<Result> {
  /// Unwraps a list of [Result] to a list of [Element].
  List<Element> unwrap() => map((e) => e.element).toList();
}

extension RemoveDuplicates on List<Result> {
  /// Removes all the duplicated results in order to keep only one unique result
  /// by element.
  List<Result> removeDuplicates() {
    List<Result> newResults = [];

    for (Result result in this) {
      for (Element e in newResults.map((e) => e.element)) {
        if (e == result.element) {
          break;
        }
      }

      newResults.add(result);
    }

    return newResults;
  }
}
