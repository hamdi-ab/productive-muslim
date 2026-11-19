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

    test('DhikrStep models structured sub-steps with exact sequences and progression', () {
      const step1 = DhikrStep(
        id: 'step_1',
        titleEn: 'Step 1',
        titleAr: 'خطوة ١',
        arabic: 'سبحان الله',
        transliteration: 'SubhanAllah',
        translationEn: 'Glory be to Allah',
        translationAr: 'سبحان الله',
        targetCount: 3,
      );
      const step2 = DhikrStep(
        id: 'step_2',
        titleEn: 'Step 2',
        titleAr: 'خطوة ٢',
        arabic: 'الحمد لله',
        transliteration: 'Alhamdulillah',
        translationEn: 'Praise be to Allah',
        translationAr: 'الحمد لله',
        targetCount: 2,
      );

      const multiStepItem = DhikrItem(
        id: 'multi_step',
        category: DhikrCategory.general,
        titleEn: 'Multi-Step Dhikr',
        titleAr: 'ذكر مركب',
        arabic: 'سبحان الله والحمد لله',
        transliteration: 'SubhanAllah wal-hamdulillah',
        translationEn: 'Glory and praise',
        translationAr: 'تسبيح وتحميد',
        reference: 'Reference',
        virtue: 'Virtue',
        targetCount: 5,
        steps: [step1, step2],
      );

      expect(multiStepItem.hasSteps, isTrue);
      expect(multiStepItem.steps.length, equals(2));

      // At count 0 (beginning of Step 1)
      expect(multiStepItem.currentStepIndex(0), equals(0));
      expect(multiStepItem.currentStep(0)?.id, equals('step_1'));
      expect(multiStepItem.currentStepProgress(0), equals(0));

      // At count 2 (Step 1 in progress)
      expect(multiStepItem.currentStepIndex(2), equals(0));
      expect(multiStepItem.currentStepProgress(2), equals(2));

      // At count 3 (boundary: Step 1 completed, now start of Step 2)
      expect(multiStepItem.currentStepIndex(3), equals(1));
      expect(multiStepItem.currentStep(3)?.id, equals('step_2'));
      expect(multiStepItem.currentStepProgress(3), equals(0));

      // At count 4 (Step 2 in progress)
      expect(multiStepItem.currentStepIndex(4), equals(1));
      expect(multiStepItem.currentStepProgress(4), equals(1));

      // At count 5 (all complete)
      expect(multiStepItem.currentStepIndex(5), equals(1));
      expect(multiStepItem.currentStepProgress(5), equals(2));
    });
  });

  group('AdhkarCatalog', () {
    test('getByCategory defaults to includePendingReview: false and returns empty for unapproved items', () {
      final defaultMorning = AdhkarCatalog.getByCategory(DhikrCategory.morning);
      final defaultEvening = AdhkarCatalog.getByCategory(DhikrCategory.evening);
      final defaultPostPrayer = AdhkarCatalog.getByCategory(
        DhikrCategory.postPrayer,
      );

      // By default, unreviewed items are withheld from normal user reader
      expect(defaultMorning, isEmpty);
      expect(defaultEvening, isEmpty);
      expect(defaultPostPrayer, isEmpty);
    });

    test('provides items for review when includePendingReview is true', () {
      final morningAdhkar = AdhkarCatalog.getByCategory(
        DhikrCategory.morning,
        includePendingReview: true,
      );
      final eveningAdhkar = AdhkarCatalog.getByCategory(
        DhikrCategory.evening,
        includePendingReview: true,
      );
      final wakingAdhkar = AdhkarCatalog.getByCategory(
        DhikrCategory.wakingUp,
        includePendingReview: true,
      );
      final sleepingAdhkar = AdhkarCatalog.getByCategory(
        DhikrCategory.sleeping,
        includePendingReview: true,
      );
      final postPrayerAdhkar = AdhkarCatalog.getByCategory(
        DhikrCategory.postPrayer,
        includePendingReview: true,
      );
      final dailySunnah = AdhkarCatalog.getByCategory(
        DhikrCategory.dailySunnah,
        includePendingReview: true,
      );

      expect(morningAdhkar.isNotEmpty, true);
      expect(eveningAdhkar.isNotEmpty, true);
      expect(wakingAdhkar.isNotEmpty, true);
      expect(sleepingAdhkar.isNotEmpty, true);
      expect(postPrayerAdhkar.isNotEmpty, true);
      expect(dailySunnah.isNotEmpty, true);
    });

    test('multi-part recitations have structured sub-steps and correct target counts', () {
      // 1. Post-Salah Tasbih (33 / 33 / 33 + 1 = 100)
      final tasbih = AdhkarCatalog.getById(
        'post_salah_tasbih',
        includePendingReview: true,
      )!;
      expect(tasbih.hasSteps, isTrue);
      expect(tasbih.targetCount, equals(100));
      expect(tasbih.steps.length, equals(4));
      expect(tasbih.steps[0].id, equals('tasbih_subhanallah'));
      expect(tasbih.steps[0].targetCount, equals(33));
      expect(tasbih.steps[1].id, equals('tasbih_alhamdulillah'));
      expect(tasbih.steps[1].targetCount, equals(33));
      expect(tasbih.steps[2].id, equals('tasbih_allahu_akbar'));
      expect(tasbih.steps[2].targetCount, equals(33));
      expect(tasbih.steps[3].id, equals('tasbih_kalimah_tawheed'));
      expect(tasbih.steps[3].targetCount, equals(1));

      // 2. Post-Salah Astaghfirullah (3 + 1 = 4)
      final astaghfirullah = AdhkarCatalog.getById(
        'post_salah_astaghfirullah',
        includePendingReview: true,
      )!;
      expect(astaghfirullah.hasSteps, isTrue);
      expect(astaghfirullah.targetCount, equals(4));
      expect(astaghfirullah.steps.length, equals(2));
      expect(astaghfirullah.steps[0].id, equals('post_salah_istighfar_phrase'));
      expect(astaghfirullah.steps[0].targetCount, equals(3));
      expect(astaghfirullah.steps[1].id, equals('post_salah_antas_salam'));
      expect(astaghfirullah.steps[1].targetCount, equals(1));

      // 3. Bedtime Fatima Tasbih (33 / 33 / 34 = 100)
      final sleepTasbih = AdhkarCatalog.getById(
        'sleep_33_tasbih',
        includePendingReview: true,
      )!;
      expect(sleepTasbih.hasSteps, isTrue);
      expect(sleepTasbih.targetCount, equals(100));
      expect(sleepTasbih.steps.length, equals(3));
      expect(sleepTasbih.steps[0].targetCount, equals(33));
      expect(sleepTasbih.steps[1].targetCount, equals(33));
      expect(sleepTasbih.steps[2].targetCount, equals(34));
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

    test('getById excludes pending review content by default matching getByCategory', () {
      // By default, pending items return null through AdhkarCatalog.getById
      final defaultItem = AdhkarCatalog.getById('ayat_al_kursi');
      expect(defaultItem, isNull);

      // Explicitly including pending review resolves the item
      final reviewItem = AdhkarCatalog.getById(
        'ayat_al_kursi',
        includePendingReview: true,
      );
      expect(reviewItem, isNotNull);
      expect(reviewItem?.id, 'ayat_al_kursi');

      final nonExistent = AdhkarCatalog.getById(
        'unknown_dhikr_xyz',
        includePendingReview: true,
      );
      expect(nonExistent, isNull);
    });
  });
}
