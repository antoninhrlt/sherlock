import 'dart:math';

/// The Levenshtein algorithm implementation.
///
/// Returns the calculated *distance*.
///
/// ## Links
/// - https://en.wikipedia.org/wiki/Levenshtein_distance
/// - https://en.wikipedia.org/wiki/Levenshtein_distance#Iterative_with_full_matrix
int levenshtein({required String a, required String b}) {
  // Both strings are equal.
  if (a == b) {
    return 0;
  }

  // String `a` or `b` is empty, the distance will be the number of characters
  // of the other string.
  if (a.isEmpty) {
    return b.length;
  } else if (b.isEmpty) {
    return a.length;
  }

  // For all `i` and `j`: `distances[i][j]` will hold the distance between the
  // first `i` characters of `a` and the first `j` characters of `b`.
  var distances = List.generate(a.length + 1, (i) {
    var row = List.generate(b.length + 1, (j) => j);
    row[0] = i;
    return row;
  });

  for (int j = 1; j < b.length; j += 1) {
    for (int i = 1; i < a.length; i += 1) {
      // Substitution cost.
      int cost = 1;

      // The character is the same in both strings.
      if (a[i - 1] == b[j - 1]) {
        cost = 0;
      }

      distances[i][j] = min(
        // deletion
        distances[i - 1][j] + 1,
        min(
          // insertion
          distances[i][j - 1] + 1,
          // substitution
          distances[i - 1][j - 1] + cost,
        ),
      );
    }
  }

  return distances[a.length - 1][b.length - 1];
}
