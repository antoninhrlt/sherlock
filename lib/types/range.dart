/// A simple structure for ranges. Convertible to [List].
class Range {
  final int start;
  final int end;

  /// Creates a new [Range] between [start] and [end].
  Range({
    required this.start,
    required this.end,
  });

  /// Transforms the [Range] object into a [List] of two elements ([start] and [end]).
  List<int> toList() {
    return [start, end];
  }

  @override
  String toString() {
    return toList().toString();
  }
}
