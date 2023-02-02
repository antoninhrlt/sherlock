import 'package:sherlock/types.dart';

class Result {
  Element element;
  int priority;

  Result({required this.element, required this.priority});
}

/// Sorts a list of [unsortedResults].
List<Result> sortResults({required List<Result> unsortedResults}) {
  /// Gets the results sorted by their priority.
  return unsortedResults..sort((a, b) => -a.priority.compareTo(b.priority));
}

extension UnwrapResults on List<Result> {
  /// Unwraps a list of [Result] to a list of [Element].
  List<Element> unwrap() => map((e) => e.element).toList();
}
