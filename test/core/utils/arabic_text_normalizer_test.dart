import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/utils/arabic_text_normalizer.dart';

void main() {
  group('ArabicTextNormalizer', () {
    test('stripHarakat removes all tashkeel marks', () {
      const withTashkeel = 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ';
      expect(
        ArabicTextNormalizer.stripHarakat(withTashkeel),
        equals('سبحان الله وبحمده'),
      );
    });

    test('stripHarakat handles empty and plain strings', () {
      expect(ArabicTextNormalizer.stripHarakat(''), equals(''));
      expect(
        ArabicTextNormalizer.stripHarakat('سبحان الله'),
        equals('سبحان الله'),
      );
    });

    test('normalize unifies alif variants (أ إ آ ٱ -> ا)', () {
      expect(ArabicTextNormalizer.normalize('أستغفر'), equals('استغفر'));
      expect(ArabicTextNormalizer.normalize('إيمان'), equals('ايمان'));
      expect(ArabicTextNormalizer.normalize('آية'), equals('ايه'));
      expect(ArabicTextNormalizer.normalize('ٱلله'), equals('الله'));
    });

    test(
      'normalize unifies taa marbuta (ة -> ه) and alif maqsurah (ى -> ي)',
      () {
        expect(ArabicTextNormalizer.normalize('بركة'), equals('بركه'));
        expect(ArabicTextNormalizer.normalize('على'), equals('علي'));
        expect(ArabicTextNormalizer.normalize('الضحى'), equals('الضحي'));
      },
    );

    test('containsNormalized matches search query without harakat against catalog text with harakat', () {
      const catalogArabic =
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ';

      // Plain query without tashkeel
      expect(
        ArabicTextNormalizer.containsNormalized(catalogArabic, 'الله لا اله'),
        isTrue,
      );

      // Query with different Alif spelling
      expect(
        ArabicTextNormalizer.containsNormalized(catalogArabic, 'القيوم'),
        isTrue,
      );

      // Substring match
      expect(
        ArabicTextNormalizer.containsNormalized(catalogArabic, 'الحي'),
        isTrue,
      );

      // Unrelated query
      expect(
        ArabicTextNormalizer.containsNormalized(catalogArabic, 'تبارك'),
        isFalse,
      );
    });
  });
}
