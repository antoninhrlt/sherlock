import 'package:diacritic/diacritic.dart' as diacritic;

/// Settings for strings normalization.
///
/// Mainly used by the [Normalize] extension for [String]s.
class NormalizationSettings {
  /// Whether the case must be normalized (to lower case). It means transforming all uppercased characters to lowercased
  /// characters.
  final bool normalizeCase;

  /// Whether the case type must be normalized (to a classic case). It means transform *camelCase* or *snake_case* to
  /// *normal case*.
  final bool normalizeCaseType;

  /// Whether the diacritics must be removed of the strings. It means removing all the accents and other added symbols
  /// from the letters.
  final bool removeDiacritics;

  /// Creates settings for strings normalization.
  ///
  /// If a setting is not specified, it will be false by default.
  const NormalizationSettings({
    this.normalizeCase = false,
    this.normalizeCaseType = false,
    this.removeDiacritics = false,
  });

  /// The defaults settings for normalizing strings
  ///
  /// - The case is normalized
  /// - The case type is not normalized
  /// - The diacritics are removed
  const NormalizationSettings.defaults()
      : normalizeCase = true,
        normalizeCaseType = false,
        removeDiacritics = true;

  /// The defaults settings to normalize nothing. Can be used to test matching strings.
  ///
  /// - The case is normalized
  /// - The case type is not normalized
  /// - The diacritics are removed
  const NormalizationSettings.matching()
      : normalizeCase = false,
        normalizeCaseType = false,
        removeDiacritics = false;

  /// Creates a new [NormalizationSettings] object same as [object].
  NormalizationSettings.from(NormalizationSettings object)
      : normalizeCase = object.normalizeCase,
        normalizeCaseType = object.normalizeCaseType,
        removeDiacritics = object.removeDiacritics;

  /// Returns whether not the case is normalized.
  bool get caseSensitivity => !normalizeCase;
}

/// Extends [String] with a function to normalize it.
extension Normalize on String {
  /// Normalizes a string following the given normalization [settings].
  String normalize(NormalizationSettings settings) {
    String normalized = this;

    // Normalizes the case type, but keep the case (upper or lower)
    if (settings.normalizeCaseType) {
      normalized = normalized.normalizeCaseType();
    }

    // Lowercases the string.
    if (settings.normalizeCase) {
      normalized = normalized.toLowerCase();
    }

    // Removes the diacritics.
    if (settings.removeDiacritics) {
      normalized = normalized.removeDiacritics();
    }

    return normalized;
  }

  /// Normalizes the case whether it is *snake_case* or *camelCase*. Conserves the
  /// case (upper or lower).
  ///
  /// ## Examples
  /// - fooBar -> foo bar
  /// - FooBar -> Foo bar
  /// - foo_bar -> foo bar
  /// - fooBar_baz -> foo bar baz
  /// - FooBar_baz -> Foo bar baz
  String normalizeCaseType() {
    String normalized = this;

    normalized = normalized.normalizeCamelCase();
    normalized = normalized.normalizeSnakeCase();

    return normalized;
  }

  /// Removes the diacritics of a string thanks to the [diacritic] package.
  String removeDiacritics() => diacritic.removeDiacritics(this);

  /// Transforms a string in camel case to normal case.
  ///
  /// ## Example
  /// `'helloWorld'` -> `'hello world'`.
  String normalizeCamelCase() {
    String normalized = this;

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
      var c = normalized[i].removeDiacritics().toLowerCase().codeUnitAt(0);
      bool isInAlphabet = c > 96 && c < 123;

      if (!isInAlphabet || normalized[i].toUpperCase() != normalized[i]) {
        continue;
      }

      // ...fooBar...
      //       ^
      // Camel case found !
      normalized = normalized.replaceRange(i, i + 1, ' ${normalized[i].toLowerCase()}');
      // ...foo bar...
      // Result !
    }

    return normalized;
  }

  /// Transforms a string in snake case to normal case.
  ///
  /// ## Example
  /// `'hello_world'` -> `'hello world'`.
  String normalizeSnakeCase() {
    String normalized = this;

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
}
