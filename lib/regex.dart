/// Creates regex from a list of keywords.
///
/// Provides static functions rather than instancing a new [RegexHelper] object
/// when need it.
class RegexHelper {
  /// Returns a regex [String] matching with all the words from the [keywords].
  static String all({
    required List<String> keywords,
    bool searchWords = false,
  }) {
    String regex = r'(';

    for (var keyword in keywords) {
      if (searchWords) {
        // The word is in the string.
        keyword = r'\b' + keyword + r'\b';
      }

      regex += '(?=.*$keyword)';
    }

    return regex + r'.*)';
  }

  /// Returns a regex [String] matching with any word from the [keywords].
  ///
  /// Set [searchWords] `true` for a word search instead of keyword's
  /// characters search.
  static String any({
    required List<String> keywords,
    bool searchWords = false,
  }) {
    String regex = r'(';

    for (var keyword in keywords) {
      if (searchWords) {
        // The word is in the string.
        regex += r'\b' + keyword + r'\b';
      } else {
        // Keyword's characters are in the string.
        regex += keyword;
      }

      if (keyword != keywords.last) {
        regex += r'|';
      }
    }

    return regex + r')';
  }
}
