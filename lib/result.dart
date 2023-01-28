import 'package:sherlock/types.dart';

class Result {
  Element element;
  int importance;

  Result({required this.element, required this.importance});
}

extension UnwrapResults on List<Result> {
  /// Unwraps a list of [Result] to a list of [Element].
  List<Element> unwrap() => map((e) => e.element).toList();
}
