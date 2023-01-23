/// Creates regex from a list of keywords.
///
/// Provides static functions rather than instancing a new [RegexHelper] object
/// when need it.
class RegexHelper {
  /// Returns a regex [String] matching with all the words from the [keywords].
  static String all({required List<String> keywords}) {
    String regex = r'(';

    for (var keyword in keywords) {
      regex += '(?=.*$keyword)';
    }

    return regex + r'.*)';
  }

  /// Returns a regex [String] matching with any word from the [keywords].
  static String any({required List<String> keywords}) {
    String regex = r'(';

    for (var keyword in keywords) {
      regex += keyword;
      if (keyword != keywords.last) {
        regex += r'|';
      }
    }

    return regex + r')';
  }
}
