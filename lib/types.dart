/// Used to define the importance of each column.
///
/// The bigger [int] it is, the more important it is.
typedef PriorityMap = Map<String, int>;

/// Type for the given elements map.
typedef Element = Map<String, dynamic>;

/// What a [Element] contains.
typedef Column = Map<String, dynamic>;

/// Type for the [where] parameter.
class Where extends StringOrList<String> {
  const Where({where = '*'}) : super(value: where);

  bool get isGlobal => super.value == '*';

  /// Gets a list of the specified columns.
  ///
  /// Used for the smart search function requiring its [where] parameter to be
  /// `'*'` or multiple specified columns.
  List<String> get columns {
    assert(!isGlobal);
    if (super.value.runtimeType != List<String>) {
      throw 'when the `where` parameter is of type `String`, it must be \'*\', otherwise it must be of type `List<String>`';
    }
    return super.value;
  }
}

/// Wraps a dynamic value into a [ListOrString] object that requires the [value]
/// to be either a [String] or a [List] of [T].
class StringOrList<T> {
  final dynamic value;

  const StringOrList({required this.value});

  /// Throws an exception when [value] has a wrong type.
  void checkValidity() {
    /// Must be of type [List<T>] or [String].
    if ((value.runtimeType != List<T>) && (value.runtimeType != String)) {
      throw '$value is not a list nor a string';
    }
  }
}
