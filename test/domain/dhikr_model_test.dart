import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';

void main() {
  group('DhikrCategory and DhikrItem Domain Model', () {
    test(
      'DhikrCategory contains all standard Islamic remembrance categories',
      () {
        expect(
          DhikrCategory.values,
          containsAll([
            DhikrCategory.morning,
            DhikrCategory.evening,
            DhikrCategory.wakingUp,
            DhikrCategory.sleeping,
            DhikrCategory.postPrayer,
            DhikrCategory.dailySunnah,
          ]),
        );
      },
    );

    test(
      'DhikrItem instantiates with correct fields and repetition targets',
      () {
        const dhikr = DhikrItem(
          id: 'ayat_al_kursi',
          category: DhikrCategory.morning,
          titleEn: 'Ayat al-Kursi',
          titleAr: 'آية الكرسي',
          arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
          transliteration: 'Allahu la ilaha illa Huwa, Al-Hayyul-Qayyum...',
          translationEn:
              'Allah! There is no deity except Him, the Ever-Living...',
          translationAr: 'الله لا إله إلا هو الحي القيوم...',
          reference: 'Surah Al-Baqarah 2:255',
          virtue: 'Whoever recites it in the morning will be protected from jinn until evening.',
          targetCount: 1,
          order: 1,
        );

        expect(dhikr.id, 'ayat_al_kursi');
        expect(dhikr.category, DhikrCategory.morning);
        expect(dhikr.targetCount, 1);
        expect(dhikr.reference, contains('2:255'));
      },
    );
  });

  group('AdhkarCatalog', () {
    test('provides authentic items for each essential category', () {
      final morningAdhkar = AdhkarCatalog.getByCategory(DhikrCategory.morning);
      final eveningAdhkar = AdhkarCatalog.getByCategory(DhikrCategory.evening);
      final wakingAdhkar = AdhkarCatalog.getByCategory(DhikrCategory.wakingUp);
      final sleepingAdhkar = AdhkarCatalog.getByCategory(
        DhikrCategory.sleeping,
      );
      final postPrayerAdhkar = AdhkarCatalog.getByCategory(
        DhikrCategory.postPrayer,
      );
      final dailySunnah = AdhkarCatalog.getByCategory(
        DhikrCategory.dailySunnah,
      );

      expect(morningAdhkar.isNotEmpty, true);
      expect(eveningAdhkar.isNotEmpty, true);
      expect(wakingAdhkar.isNotEmpty, true);
      expect(sleepingAdhkar.isNotEmpty, true);
      expect(postPrayerAdhkar.isNotEmpty, true);
      expect(dailySunnah.isNotEmpty, true);
    });

    test(
      'all catalog items contain non-empty Arabic, translation, and references',
      () {
        final allItems = AdhkarCatalog.all;
        expect(allItems.length, greaterThanOrEqualTo(15));

        for (final item in allItems) {
          expect(item.id.isNotEmpty, true);
          expect(item.arabic.isNotEmpty, true);
          expect(item.transliteration.isNotEmpty, true);
          expect(item.translationEn.isNotEmpty, true);
          expect(item.reference.isNotEmpty, true);
          expect(item.targetCount, greaterThanOrEqualTo(1));
        }
      },
    );

    test('getById returns matching item or null for unknown ID', () {
      final item = AdhkarCatalog.getById('ayat_al_kursi');
      expect(item, isNotNull);
      expect(item?.id, 'ayat_al_kursi');

      final nonExistent = AdhkarCatalog.getById('unknown_dhikr_xyz');
      expect(nonExistent, isNull);
    });
  });
}
