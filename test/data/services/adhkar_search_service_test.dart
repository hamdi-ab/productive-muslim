import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/data/services/adhkar_search_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';

class MockAdhkarRepository extends Mock implements AdhkarRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(DhikrCategory.morning);
  });

  late MockAdhkarRepository mockRepo;
  late AdhkarSearchService service;

  final approvedItem1 = DhikrItem(
    id: 'appr_1',
    category: DhikrCategory.morning,
    titleEn: 'Morning Light',
    titleAr: 'نور الصباح',
    arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    transliteration: 'Alhamdu lillahi Rabbil-Alamin',
    translationEn: 'Praise be to Allah, Lord of the worlds',
    translationAr: 'الحمد لله رب العالمين',
    reference: 'Al-Fatiha 1:2',
    virtue: 'Opening praise',
    reviewStatus: ContentReviewStatus.approved,
  );

  final approvedItem2 = DhikrItem(
    id: 'appr_2',
    category: DhikrCategory.general,
    titleEn: 'Seeking Forgiveness',
    titleAr: 'طلب المغفرة',
    arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    transliteration: 'Astaghfirullah wa atubu ilayh',
    translationEn: 'I seek the forgiveness of Allah and turn to Him',
    translationAr: 'أستغفر الله وأتوب إليه',
    reference: 'Sahih al-Bukhari 6307',
    virtue: 'Forgiveness',
    reviewStatus: ContentReviewStatus.approved,
  );

  final pendingReviewItem = DhikrItem(
    id: 'pending_1',
    category: DhikrCategory.morning,
    titleEn: 'Draft Unreviewed Remembrance',
    titleAr: 'ذكر قيد المراجعة',
    arabic: 'سُبْحَانَ اللَّهِ الْعَظِيمِ',
    transliteration: 'SubhanAllahil-Adhim',
    translationEn: 'Glory be to Allah the Magnificent',
    translationAr: 'سبحان الله العظيم',
    reference: 'Draft 101',
    virtue: 'Draft virtue',
    reviewStatus: ContentReviewStatus.pendingReview,
  );

  final multiStepItem = DhikrItem(
    id: 'post_salah_tasbih',
    category: DhikrCategory.postPrayer,
    titleEn: 'Post-Salah Tasbih',
    titleAr: 'تسبيح دبر الصلاة',
    arabic: 'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَاللَّهُ أَكْبَرُ',
    transliteration: 'SubhanAllah, Alhamdulillah, Allahu Akbar',
    translationEn:
        'Glory be to Allah, Praise be to Allah, Allah is the Greatest',
    translationAr: 'سبحان الله، والحمد لله، والله أكبر',
    reference: 'Sahih Muslim 597',
    virtue: 'Expiation of sins',
    reviewStatus: ContentReviewStatus.approved,
    steps: const [
      DhikrStep(
        id: 'tasbih_subhanallah',
        titleEn: 'SubhanAllah',
        titleAr: 'سبحان الله',
        arabic: 'سُبْحَانَ اللَّهِ',
        transliteration: 'SubhanAllah',
        translationEn: 'Glory be to Allah',
        translationAr: 'سبحان الله',
        targetCount: 33,
      ),
      DhikrStep(
        id: 'tasbih_alhamdulillah',
        titleEn: 'Alhamdulillah',
        titleAr: 'الحمد لله',
        arabic: 'الْحَمْدُ لِلَّهِ',
        transliteration: 'Alhamdulillah',
        translationEn: 'Praise be to Allah',
        translationAr: 'الحمد لله',
        targetCount: 33,
      ),
    ],
  );

  final pendingSleepItem = DhikrItem(
    id: 'pending_sleep_1',
    category: DhikrCategory.sleeping,
    titleEn: 'Draft Bedtime Supplication',
    titleAr: 'دعاء النوم قيد المراجعة',
    arabic: 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي',
    transliteration: "Bismika Rabbi wada'tu janbi",
    translationEn: 'In Your name my Lord I lie down',
    translationAr: 'باسمك ربي وضعت جنبي',
    reference: 'Sahih al-Bukhari 6320',
    virtue: 'Bedtime',
    reviewStatus: ContentReviewStatus.pendingReview,
  );

  setUp(() {
    mockRepo = MockAdhkarRepository();
    service = AdhkarSearchService(repository: mockRepo);

    when(
      () => mockRepo.getAll(
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenAnswer((invocation) {
      final include =
          invocation.namedArguments[#includePendingReview] as bool? ?? false;
      return include
          ? [
              approvedItem1,
              approvedItem2,
              pendingReviewItem,
              multiStepItem,
              pendingSleepItem,
            ]
          : [approvedItem1, approvedItem2, multiStepItem];
    });

    when(
      () => mockRepo.getByCategory(
        any(),
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenAnswer((invocation) {
      final category = invocation.positionalArguments[0] as DhikrCategory;
      final include =
          invocation.namedArguments[#includePendingReview] as bool? ?? false;
      final allItems = include
          ? [
              approvedItem1,
              approvedItem2,
              pendingReviewItem,
              multiStepItem,
              pendingSleepItem,
            ]
          : [approvedItem1, approvedItem2, multiStepItem];
      return allItems.where((d) => d.category == category).toList();
    });
  });

  group('AdhkarSearchService Offline Search', () {
    test('matches title in English and Arabic', () {
      final resultsEn = service.search(query: 'Morning Light');
      expect(resultsEn.length, equals(1));
      expect(resultsEn.first.item.id, equals('appr_1'));

      final resultsAr = service.search(query: 'المغفرة');
      expect(resultsAr.length, equals(1));
      expect(resultsAr.first.item.id, equals('appr_2'));
    });

    test(
      'matches Arabic text without tashkeel against catalog text with tashkeel',
      () {
        // Query without tashkeel
        final results = service.search(query: 'الحمد لله');
        expect(results.any((r) => r.item.id == 'appr_1'), isTrue);

        final resultsIstighfar = service.search(query: 'استغفر الله');
        expect(resultsIstighfar.any((r) => r.item.id == 'appr_2'), isTrue);
      },
    );

    test('matches English translation and transliteration', () {
      final resultsTrans = service.search(query: 'forgiveness of Allah');
      expect(resultsTrans.any((r) => r.item.id == 'appr_2'), isTrue);

      final resultsTranslit = service.search(query: 'Astaghfirullah');
      expect(resultsTranslit.any((r) => r.item.id == 'appr_2'), isTrue);
    });

    test('matches sub-step titles and phrases in multi-part adhkar', () {
      final results = service.search(query: 'Alhamdulillah');
      expect(results.any((r) => r.item.id == 'post_salah_tasbih'), isTrue);
    });

    test('filters search results by Collection (category)', () {
      final resultsMorning = service.search(
        query: 'Allah',
        collection: DhikrCategory.morning,
      );
      expect(
        resultsMorning.every((r) => r.item.category == DhikrCategory.morning),
        isTrue,
      );
    });

    test('filters search results by Subject', () {
      final results = service.search(
        query: 'Praise',
        subject: DhikrSubject.gratitude,
      );
      expect(results.isNotEmpty, isTrue);
    });

    test('empty query returns all items in current filter', () {
      final results = service.search(query: '');
      expect(
        results.length,
        equals(3),
      ); // approvedItem1, approvedItem2, multiStepItem
    });

    test('unmatched query returns empty list with zero errors', () {
      final results = service.search(query: 'NonExistentRemembranceXYZ');
      expect(results, isEmpty);
    });

    test(
      'CRITICAL: strictly excludes pending review content in normal search',
      () {
        final results = service.search(query: 'Glory be to Allah');
        // pending_1 matches 'Glory be to Allah the Magnificent', but must be excluded!
        expect(results.any((r) => r.item.id == 'pending_1'), isFalse);
      },
    );

    test('includes pending review content only when review mode is explicitly true', () {
      final results = service.search(
        query: 'Glory be to Allah',
        includePendingReview: true,
      );
      expect(results.any((r) => r.item.id == 'pending_1'), isTrue);
    });

    test('searchCollections matches English titles and aliases', () {
      final morning = service.searchCollections(query: 'Morning');
      expect(morning.length, equals(1));
      expect(morning.first.category, equals(DhikrCategory.morning));
      expect(morning.first.itemCount, equals(1)); // only approvedItem1

      final salah = service.searchCollections(query: 'Salah');
      expect(salah.length, equals(1));
      expect(salah.first.category, equals(DhikrCategory.postPrayer));
      expect(salah.first.itemCount, equals(1)); // multiStepItem
    });

    test('searchCollections matches Arabic normalized titles and aliases', () {
      final results = service.searchCollections(query: 'الصباح');
      expect(results.length, equals(1));
      expect(results.first.category, equals(DhikrCategory.morning));

      final afterSalah = service.searchCollections(query: 'بعد الصلاة');
      expect(afterSalah.length, equals(1));
      expect(afterSalah.first.category, equals(DhikrCategory.postPrayer));
    });

    test('searchCollections strictly excludes collections with 0 approved items in normal search', () {
      // Bedtime only has pendingSleepItem in mockRepo
      final bedtimeNormal = service.searchCollections(query: 'Bedtime');
      expect(bedtimeNormal, isEmpty);

      final bedtimeReview = service.searchCollections(
        query: 'Bedtime',
        includePendingReview: true,
      );
      expect(bedtimeReview.length, equals(1));
      expect(bedtimeReview.first.category, equals(DhikrCategory.sleeping));
      expect(bedtimeReview.first.itemCount, equals(1));
    });

    test('unifiedSearch returns matched collections alongside items', () {
      final unified = service.unifiedSearch(query: 'Morning');
      expect(unified.collections.length, equals(1));
      expect(unified.collections.first.category, equals(DhikrCategory.morning));
      expect(unified.items.length, equals(1));
      expect(unified.items.first.item.id, equals('appr_1'));
      expect(unified.totalCount, equals(2));
      expect(unified.isNotEmpty, isTrue);
    });

    test('unifiedSearch returns empty container for unmatched query', () {
      final unified = service.unifiedSearch(query: 'UnknownXYZ123');
      expect(unified.isEmpty, isTrue);
      expect(unified.collections, isEmpty);
      expect(unified.items, isEmpty);
      expect(unified.totalCount, equals(0));
    });
  });
}
