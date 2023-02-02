import 'package:diacritic/diacritic.dart' as diacritic;

/// Settings about string normalization.
class NormalizationSettings {
  /// The actual settings being a map with the settings id and their boolean
  /// value to known if this type of normalization has to be done or not.
  final Map<String, bool?> settings;

  /// Values `true` are the settings that will be applied to the strings.
  /// For example, if [normalizeCase] is `true`, it will be case-insensitive.
  ///
  /// Setting [normalizeCase] is used to transform any uppercased string into a
  /// lowercased string.
  ///
  /// Setting [normalizeCaseType] is used to transform any camelCased string or
  /// snake_cased string into a normal string, without case type.
  /// See [Normalize.normalizeCaseType] to know more about it.
  ///
  /// Setting [removeDiacritics] is used to remove the diacritics (accents and
  /// other additional symbol on the characters).
  NormalizationSettings({
    bool? normalizeCase,
    bool? normalizeCaseType,
    bool? removeDiacritics,
  }) : settings = {
          'case': normalizeCase,
          'caseType': normalizeCaseType,
          'diacritics': removeDiacritics
        };

  /// The defaults settings for normalizing.
  /// ```dart
  /// NormalizeSettings(
  ///     normalizeCase: true,
  ///     normalizeCaseType: false,
  ///     removeDiacritics: true,
  /// );
  /// ```
  const NormalizationSettings.defaults()
      : settings = const {
          'case': true,
          'caseType': false,
          'diacritics': true,
        };

  /// Updates the settings from another [NormalizationSettings] object [source].
  ///
  /// Null elements of [source] stands for not changing the values.
  void updateFrom(NormalizationSettings source) {
    for (var id in ['case', 'caseType', 'diacritics']) {
      // Does not change because the given source's value is null.
      if (source[id] == null) {
        continue;
      }

      // Updates setting from [source].
      settings[id] = source[id];
    }
  }

  /// The defaults normalizing settings for a perfect match between strings.
  /// ```dart
  /// NormalizeSettings(
  ///     normalizeCase: false,
  ///     normalizeCaseType: false,
  ///     removeDiacritics: false,
  /// );
  /// ```
  NormalizationSettings.matching()
      : settings = {
          'case': false,
          'caseType': false,
          'diacritics': false,
        };

  /// Changes the case sensitivity.
  ///
  /// If [caseSensitive] is `true`, the case setting will be set on `false`.
  /// If [caseSensitive] is `false`, the case setting will be set on `true`.
  set caseSensitivity(bool caseSensitivity) {
    settings['case'] = !caseSensitivity;
  }

  bool get caseSensitivity => !(this['case'] ?? false);

  /// Gets a setting from [settings] from its [id].
  ///
  /// Throws an error when the [id] is not corresponding to a valid setting.
  bool? operator [](String id) {
    if (!settings.containsKey(id)) {
      throw '$id is not a valid setting';
    }

    return settings[id];
  }

  /// Returns [settings] into [String].
  @override
  String toString() {
    return settings.toString();
  }
}

/// Extends [String] with a normalizing function.
extension Normalize on String {
  /// Normalizes a string following the given [settings].
  String normalize(NormalizationSettings settings) {
    String normalized = this;

    // Normalizes the case type, but keep the case (upper or lower)
    if (settings['caseType'] ?? false) {
      normalized = normalized.normalizeCaseType();
    }

    // Lowercases the string.
    if (settings['case'] ?? false) {
      normalized = normalized.toLowerCase();
    }

    // Removes the diacritics.
    if (settings['diacritics'] ?? false) {
      normalized = normalized.removeDiacritics();
    }

    return normalized;
  }

  /// Normalizes the case whether it is snake case or camel case. Conserves the
  /// case (upper or lower).
  ///
  /// Examples :
  ///   fooBar -> foo bar
  ///   FooBar -> Foo bar
  ///   foo_bar -> foo bar
  ///   fooBar_baz -> foo bar baz
  ///   FooBar_baz -> Foo bar baz
  String normalizeCaseType() {
    String normalized = this;

    normalized = normalized.normalizeCamelCase();
    normalized = normalized.normalizeSnakeCase();

    return normalized;
  }

  /// Removes the diacritics of a string thanks to the [diacritic] package.
  String removeDiacritics() => diacritic.removeDiacritics(this);

  /// Returns the string being a camel-cased string changed into a normal case.
  /// Example : `'helloWorld'` -> `'hello world'`.
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
      normalized =
          normalized.replaceRange(i, i + 1, ' ${normalized[i].toLowerCase()}');
      // ...foo bar...
      // Result !
    }

    return normalized;
  }

  /// Returns the string being a snake-cased string changed into a normal case.
  /// Example : `'hello_world'` -> `'hello world'`.
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
