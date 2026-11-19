/// Utility for normalizing Arabic text for accurate, diacritic-insensitive
/// offline search matching.
///
/// Strips tashkeel (harakat), tatweel, and normalizes common spelling
/// variations (such as alif with hamza, taa marbuta, and alif maqsurah)
/// without altering the original sacred text stored in the catalog.
class ArabicTextNormalizer {
  ArabicTextNormalizer._();

  /// Regex pattern matching all standard Arabic diacritics (tashkeel/harakat):
  /// - Fathah (\u064E), Dammah (\u064F), Kasrah (\u0650), Sukun (\u0652)
  /// - Shaddah (\u0651), Fathatan (\u064B), Dammatan (\u064C), Kasratan (\u064D)
  /// - Dagger Alif (\u0670), Maddah (\u0653), Hamza Above (\u0654), Hamza Below (\u0655)
  /// - Tatweel / Kashida (\u0640)
  static final RegExp _tashkeelRegex = RegExp(
    r'[\u064B-\u0655\u0670\u0640]',
    unicode: true,
  );

  /// Strips all vowel marks and diacritics from Arabic text.
  static String stripHarakat(String input) {
    if (input.isEmpty) return input;
    return input.replaceAll(_tashkeelRegex, '');
  }

  /// Normalizes Arabic text for flexible search matching:
  /// 1. Strips all tashkeel and tatweel.
  /// 2. Normalizes Alif variants [أ, إ, آ, ٱ] to bare Alif [ا].
  /// 3. Normalizes Taa Marbutah [ة] to Haa [ه].
  /// 4. Normalizes Alif Maqsurah [ى] to Yaa [ي].
  /// 5. Trims and collapses multiple spaces into a single space.
  static String normalize(String input) {
    if (input.isEmpty) return input;

    var text = stripHarakat(input);

    // Normalize Alif variants
    text = text.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // Normalize Taa Marbutah to Haa
    text = text.replaceAll('ة', 'ه');

    // Normalize Alif Maqsurah to Yaa
    text = text.replaceAll('ى', 'ي');

    // Collapse multiple whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text.toLowerCase();
  }

  /// Returns true if [source] contains [query] using normalized Arabic matching.
  static bool containsNormalized(String source, String query) {
    final normalizedSource = normalize(source);
    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) return true;
    return normalizedSource.contains(normalizedQuery);
  }
}
