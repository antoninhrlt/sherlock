/// Extends [String] with a normalizing function.
extension Normalize on String {
  /// Returns the string normalized.
  ///
  /// Either the string's case is snake case or camel case, it will be changed
  /// to a normal case.
  String normalize() {
    String normalized = this;
    normalized = normalizeSnakeCase(normalized);
    normalized = normalizeCamelCase(normalized);
    return normalized;
  }

  /// Returns the string normalized.
  String get normalized => normalize();
}

/// Returns [toNormalize] being a snake-cased string changed into a normal case.
/// Example : `'hello_world'` -> `'hello world'`.
String normalizeSnakeCase(String toNormalize) {
  String normalized = toNormalize;

  for (int i = 0; i < normalized.length; i += 1) {
    // Cannot access to [i - 1] when `i == 0`.
    //
    // ...foo bar...
    //       ^^
    // It's the beginning of a new word.
    if (i == 0 || normalized[i - 1] == ' ') {
      continue;
    }

    // ...foobar...
    //       ^ ^
    // Not snake case.
    if (normalized[i] != '_' || i == normalized.length - 1) {
      continue;
    }

    // ...foo_bar...
    //       ^
    // Snake case found !
    normalized = normalized.replaceRange(i, i + 1, ' ');

    // ...foo bar...
    // Result !
  }

  return normalized;
}

/// Returns [toNormalize] being a camel-cased string changed into a normal case.
/// Example : `'helloWorld'` -> `'hello world'`.
String normalizeCamelCase(String toNormalize) {
  String normalized = toNormalize;

  for (int i = 0; i < normalized.length; i += 1) {
    // Cannot access to [i - 1] when `i == 0`.
    //
    // ...foo bar...
    //       ^^
    // It's the beginning of a new word.
    if (i == 0 || normalized[i - 1] == ' ') {
      continue;
    }

    // ...foobar...
    //       ^
    // Not camel case.
    if (normalized[i].toUpperCase() != normalized[i]) {
      continue;
    }

    // ...fooBar...
    //       ^
    // Camel case found !
    normalized =
        normalized.replaceRange(i, i + 1, ' ${normalized[i].toLowerCase()}');
    // ...foo bar...
    // Result !
  }

  return normalized;
}
