import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/local/daos/adhkar_dao.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/repositories/adhkar_repository_impl.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late AdhkarDao dao;
  late SettingsService settingsService;
  late AdhkarRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);

    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = AdhkarDao(db);
    repository = AdhkarRepositoryImpl(
      adhkarDao: dao,
      settingsService: settingsService,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('AdhkarRepository - Catalog', () {
    test('returns catalog version and verified items', () {
      expect(repository.catalogVersion, equals(1));
      final all = repository.getAll(includePendingReview: true);
      expect(all, isNotEmpty);
      expect(all.every((item) => item.contentVersion >= 1), isTrue);
    });

    test('excludes pending review items by default and reveals them in review mode', () async {
      // Normal reader path: unreviewed items are not exposed
      expect(repository.isReviewModeEnabled, isFalse);
      expect(repository.getByCategory(DhikrCategory.morning), isEmpty);
      expect(repository.getByCategory(DhikrCategory.general), isEmpty);
      expect(repository.getAll(), isEmpty);

      // Explicit parameter overrides review mode
      expect(
        repository.getByCategory(
          DhikrCategory.general,
          includePendingReview: true,
        ),
        isNotEmpty,
      );

      // Enabling editorial review mode
      await repository.setReviewModeEnabled(true);
      expect(repository.isReviewModeEnabled, isTrue);
      expect(repository.getByCategory(DhikrCategory.morning), isNotEmpty);
      expect(repository.getByCategory(DhikrCategory.general).length, equals(5));
    });

    test('marks general dhikr items as pending review and distinguishes prescribed counts', () {
      final generalItems = repository.getByCategory(
        DhikrCategory.general,
        includePendingReview: true,
      );
      expect(generalItems.length, equals(5));

      // All 5 General Dhikr items must be pending editorial review
      expect(
        generalItems.every(
          (i) => i.reviewStatus == ContentReviewStatus.pendingReview,
        ),
        isTrue,
      );
      expect(generalItems.every((i) => i.isPendingReview), isTrue);
      expect(generalItems.every((i) => !i.isApproved), isTrue);

      final subhanallah = generalItems.firstWhere(
        (i) => i.id == 'general_subhanallah_bihamdihi',
      );
      expect(subhanallah.reference, contains('Muslim 2692'));
      expect(subhanallah.targetCount, equals(100));
      // Source specifies 100
      expect(subhanallah.isCountPrescribed, isTrue);

      final fourBeloved = generalItems.firstWhere(
        (i) => i.id == 'general_four_beloved_words',
      );
      expect(fourBeloved.reference, contains('Muslim 2137'));
      // 33 is an app target, not Hadith-prescribed
      expect(fourBeloved.isCountPrescribed, isFalse);

      final istighfar = generalItems.firstWhere(
        (i) => i.id == 'general_istighfar',
      );
      expect(istighfar.reference, contains('Bukhari 6307'));
      expect(istighfar.targetCount, equals(70));
      // 70 is an app target, not a user-facing prescription
      expect(istighfar.isCountPrescribed, isFalse);

      final laHawla = generalItems.firstWhere(
        (i) => i.id == 'general_la_hawla',
      );
      expect(laHawla.isCountPrescribed, isFalse);

      final salawat = generalItems.firstWhere((i) => i.id == 'general_salawat');
      expect(salawat.isCountPrescribed, isFalse);
    });

    test(
      'all catalog items remain pending review until editorial sign-off',
      () {
        final all = repository.getAll(includePendingReview: true);
        expect(
          all.every((i) => i.reviewStatus == ContentReviewStatus.pendingReview),
          isTrue,
        );
        expect(all.every((i) => i.isPendingReview), isTrue);
        expect(all.every((i) => !i.isApproved), isTrue);
      },
    );

    test('getById returns matching item or null', () {
      expect(repository.getById('ayat_al_kursi'), isNotNull);
      expect(repository.getById('non_existent_id'), isNull);
    });
  });

  group('AdhkarRepository - Bookmarks', () {
    test('toggleBookmark toggles state and updates streams', () async {
      expect(await repository.isBookmarked('ayat_al_kursi'), isFalse);
      expect(await repository.getBookmarkedItems(), isEmpty);

      await repository.toggleBookmark('ayat_al_kursi');
      expect(await repository.isBookmarked('ayat_al_kursi'), isTrue);

      final bookmarkedItems = await repository.getBookmarkedItems();
      expect(bookmarkedItems.length, equals(1));
      expect(bookmarkedItems.first.id, equals('ayat_al_kursi'));

      await repository.toggleBookmark('ayat_al_kursi');
      expect(await repository.isBookmarked('ayat_al_kursi'), isFalse);
      expect(await repository.getBookmarkedItems(), isEmpty);
    });
  });

  group('AdhkarRepository - Sessions & Resumability', () {
    test('saveSession, getSession, and clearSession work correctly', () async {
      expect(await repository.getSession('morning'), isNull);

      await repository.saveSession(
        collectionId: 'morning',
        lastPageIndex: 2,
        counts: {'ayat_al_kursi': 1, 'sayyid_al_istighfar': 1},
        isCompleted: false,
      );

      final session = await repository.getSession('morning');
      expect(session, isNotNull);
      expect(session!.collectionId, equals('morning'));
      expect(session.lastPageIndex, equals(2));
      expect(session.counts['ayat_al_kursi'], equals(1));
      expect(session.isCompleted, isFalse);

      await repository.clearSession('morning');
      expect(await repository.getSession('morning'), isNull);
    });

    test(
      'migrates legacy SharedPreferences progress into database session',
      () async {
        final today = DateTime.now().toIso8601String().substring(0, 10);
        await settingsService.setDhikrCount(today, 'sayyid_al_istighfar', 1);

        // DB has no session yet
        final session = await repository.getSession('morning');
        expect(session, isNotNull);
        expect(session!.counts['sayyid_al_istighfar'], equals(1));

        // Verify it was persisted to database
        final dbRow = await dao.getSession('morning');
        expect(dbRow, isNotNull);
        expect(dbRow!.countsJson, contains('sayyid_al_istighfar'));
      },
    );

    test('canonicalizes waking-up category into morning collection during SharedPreferences migration', () async {
      final prefs = settingsService.prefs!;
      final today = DateTime.now().toIso8601String().substring(0, 10);

      // Simulate legacy SharedPreferences storage where waking-up items were tracked
      await prefs.setInt('adhkar_count_${today}_wake_up_1', 1);
      await prefs.setInt('adhkar_count_${today}_wake_up_2', 1);

      // Run migration
      await repository.migrateFromSharedPreferencesIfNeeded(prefs);

      // Waking-up counts must be preserved in the canonical 'morning' session
      final morningSession = await repository.getSession('morning');
      expect(morningSession, isNotNull);
      expect(morningSession!.counts['wake_up_1'], equals(1));
      expect(morningSession.counts['wake_up_2'], equals(1));

      // getSession('wakingUp') should also route to canonical morning session
      final wakingSession = await repository.getSession('wakingUp');
      expect(wakingSession, isNotNull);
      expect(wakingSession!.counts['wake_up_1'], equals(1));

      // Morning completed count should include the 2 waking-up items in review mode
      await repository.setReviewModeEnabled(true);
      final completedMorningCount = await repository.getCategoryCompletedCount(
        DhikrCategory.morning,
      );
      expect(completedMorningCount, equals(2));

      // Legacy keys should be cleared and migration flag set
      expect(prefs.getBool('adhkar_migrated_to_drift_v1'), isTrue);
      expect(prefs.getInt('adhkar_count_${today}_wake_up_1'), isNull);
    });

    test('migrates legacy full morning completion (including waking-up) to canonical morning completion', () async {
      final prefs = settingsService.prefs!;
      final today = DateTime.now().toIso8601String().substring(0, 10);

      // Reset migration flag to simulate another upgrade scenario
      await prefs.remove('adhkar_migrated_to_drift_v1');

      // Legacy full morning completion includes wakingUp and morning items
      final allMorningIds = AdhkarCatalog.getByCategory(
        DhikrCategory.morning,
        includePendingReview: true,
      ).map((i) => i.id).toList();
      await prefs.setStringList('adhkar_done_$today', allMorningIds);

      await repository.migrateFromSharedPreferencesIfNeeded(prefs);

      // Morning session is completed
      final session = await repository.getSession('morning');
      expect(session, isNotNull);
      expect(session!.isCompleted, isTrue);
      expect(session.counts['wake_up_1'], equals(1));
      expect(session.counts['wake_up_2'], equals(1));

      // Morning daily completion recorded in AdhkarCompletions table
      expect(await repository.isCollectionCompletedToday('morning'), isTrue);
      expect(await repository.isCollectionCompletedToday('wakingUp'), isTrue);

      final completedIds = await repository.getCompletedCollectionIdsForDate(
        today,
      );
      expect(completedIds, contains('morning'));
    });

    test('getCategoryCompletedCount and watchCategoryCompletedCount compute live progress in review mode', () async {
      await repository.setReviewModeEnabled(true);
      expect(
        await repository.getCategoryCompletedCount(DhikrCategory.postPrayer),
        equals(0),
      );

      await repository.saveSession(
        collectionId: DhikrCategory.postPrayer.name,
        lastPageIndex: 0,
        counts: {'post_salah_astaghfirullah': 4},
        isCompleted: false,
      );

      expect(
        await repository.getCategoryCompletedCount(DhikrCategory.postPrayer),
        equals(1),
      );

      final streamValue = await repository
          .watchCategoryCompletedCount(DhikrCategory.postPrayer)
          .first;
      expect(streamValue, equals(1));
    });
  });

  group('AdhkarRepository - Daily Completions & History', () {
    test('records and checks daily completion without deleting history on session reset', () async {
      const collection = 'morning';
      const date = '2026-11-18';

      expect(
        await repository.isCollectionCompletedToday(collection, date: date),
        isFalse,
      );

      await repository.recordCollectionCompletion(collection, date: date);

      expect(
        await repository.isCollectionCompletedToday(collection, date: date),
        isTrue,
      );

      final completedIds = await repository.getCompletedCollectionIdsForDate(
        date,
      );
      expect(completedIds, contains('morning'));

      // Session reset / clear does NOT delete daily completion history
      await repository.saveSession(
        collectionId: collection,
        lastPageIndex: 0,
        counts: {},
        isCompleted: false,
      );
      expect(
        await repository.isCollectionCompletedToday(collection, date: date),
        isTrue,
      );

      // Explicit removal works
      await repository.removeCollectionCompletion(collection, date: date);
      expect(
        await repository.isCollectionCompletedToday(collection, date: date),
        isFalse,
      );
    });
  });
}
