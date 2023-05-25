export 'types/range.dart';
export 'types/where.dart';

/// Used to define the priority of each column.
///
/// The bigger [int] it is, the more important it is.
typedef PriorityMap = Map<String, int>;

/// Type for the given elements map.
typedef Element = Map<String, dynamic>;

/// What a [Element] contains.
typedef Column = Map<String, dynamic>;
