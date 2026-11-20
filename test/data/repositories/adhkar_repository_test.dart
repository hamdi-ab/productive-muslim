import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/local/daos/adhkar_dao.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/repositories/adhkar_repository_impl.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/adhkar_routine.dart';
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

    test('getById respects approval status and returns matching item only when approved or in review mode', () async {
      // When review mode is off, unapproved items return null through normal lookup
      expect(repository.getById('ayat_al_kursi'), isNull);
      expect(repository.getById('non_existent_id'), isNull);

      // Explicit includePendingReview returns the item
      expect(
        repository.getById('ayat_al_kursi', includePendingReview: true),
        isNotNull,
      );

      // When review mode is enabled, getById returns the item
      await repository.setReviewModeEnabled(true);
      expect(repository.getById('ayat_al_kursi'), isNotNull);

      await repository.setReviewModeEnabled(false);
      expect(repository.getById('ayat_al_kursi'), isNull);
    });

    test('review mode remains enabled after repository recreation using the same settings preferences', () async {
      // Initially review mode is disabled
      expect(repository.isReviewModeEnabled, isFalse);
      expect(settingsService.adhkarReviewModeEnabled, isFalse);

      // Enable review mode
      await repository.setReviewModeEnabled(true);
      expect(repository.isReviewModeEnabled, isTrue);
      expect(settingsService.adhkarReviewModeEnabled, isTrue);

      // Recreate repository with the same settingsService/preferences (simulating app restart)
      final recreatedRepo = AdhkarRepositoryImpl(
        adhkarDao: dao,
        settingsService: settingsService,
      );
      expect(recreatedRepo.isReviewModeEnabled, isTrue);
      expect(recreatedRepo.getAll().length, equals(AdhkarCatalog.all.length));

      // Disable review mode on recreated repo
      await recreatedRepo.setReviewModeEnabled(false);
      expect(recreatedRepo.isReviewModeEnabled, isFalse);
      expect(settingsService.adhkarReviewModeEnabled, isFalse);

      // Recreate repository again
      final secondRecreatedRepo = AdhkarRepositoryImpl(
        adhkarDao: dao,
        settingsService: settingsService,
      );
      expect(secondRecreatedRepo.isReviewModeEnabled, isFalse);
      expect(secondRecreatedRepo.getAll(), isEmpty);
    });
  });

  group('AdhkarRepository - Bookmarks', () {
    test('toggleBookmark toggles state, and bookmarks strictly filter unapproved items when review mode is off', () async {
      expect(await repository.isBookmarked('ayat_al_kursi'), isFalse);
      expect(await repository.getBookmarkedItems(), isEmpty);

      // Toggle bookmark while review mode is off
      await repository.toggleBookmark('ayat_al_kursi');

      // Unapproved item must NOT be reported as bookmarked in normal mode
      expect(await repository.isBookmarked('ayat_al_kursi'), isFalse);
      expect(await repository.getBookmarkedItems(), isEmpty);

      // However, in internal review mode or with includePendingReview, the bookmark is retained
      expect(
        await repository.isBookmarked(
          'ayat_al_kursi',
          includePendingReview: true,
        ),
        isTrue,
      );
      final reviewBookmarks = await repository.getBookmarkedItems(
        includePendingReview: true,
      );
      expect(reviewBookmarks.length, equals(1));
      expect(reviewBookmarks.first.id, equals('ayat_al_kursi'));

      // Turning on review mode exposes the bookmarked item
      await repository.setReviewModeEnabled(true);
      expect(await repository.isBookmarked('ayat_al_kursi'), isTrue);
      expect((await repository.getBookmarkedItems()).length, equals(1));

      // Turning off review mode hides it again immediately
      await repository.setReviewModeEnabled(false);
      expect(await repository.isBookmarked('ayat_al_kursi'), isFalse);
      expect(await repository.getBookmarkedItems(), isEmpty);

      // Untoggle bookmark
      await repository.toggleBookmark('ayat_al_kursi');
      expect(
        await repository.isBookmarked(
          'ayat_al_kursi',
          includePendingReview: true,
        ),
        isFalse,
      );
      expect(
        await repository.getBookmarkedItems(includePendingReview: true),
        isEmpty,
      );
    });

    test('watchBookmarkedItems and watchBookmarkedIds filter pending items when review mode is off', () async {
      await repository.toggleBookmark('ayat_al_kursi');

      // Streams with review mode off emit empty list for unapproved items
      expect(await repository.watchBookmarkedItems().first, isEmpty);
      expect(await repository.watchBookmarkedIds().first, isEmpty);

      // With includePendingReview: true, emissions include the item
      final reviewItems = await repository
          .watchBookmarkedItems(includePendingReview: true)
          .first;
      expect(reviewItems.map((i) => i.id), contains('ayat_al_kursi'));
      final reviewIds = await repository
          .watchBookmarkedIds(includePendingReview: true)
          .first;
      expect(reviewIds, contains('ayat_al_kursi'));
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

  group('AdhkarRepository - Personal Routines & Completions', () {
    test('creates, retrieves, and watches personal routines', () async {
      final now = DateTime.now();
      final routine = AdhkarRoutine(
        id: 'routine_1',
        name: 'Morning Focus Routine',
        itemIds: ['ayat_al_kursi', 'sayyid_al_istighfar'],
        preferredTime: '06:30',
        weekdays: [1, 2, 3, 4, 5],
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveRoutine(routine);

      final fetched = await repository.getRoutineById('routine_1');
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Morning Focus Routine'));
      expect(fetched.preferredTime, equals('06:30'));
      expect(fetched.weekdays, equals([1, 2, 3, 4, 5]));
      expect(fetched.itemIds, equals(['ayat_al_kursi', 'sayyid_al_istighfar']));

      final all = await repository.getRoutines();
      expect(all.length, equals(1));
      expect(all.first.id, equals('routine_1'));

      final emitted = await repository.watchRoutines().first;
      expect(emitted.length, equals(1));
    });

    test('preserves progress of unaffected items and safely repositions page index on edit', () async {
      final now = DateTime.now();
      final initialRoutine = AdhkarRoutine(
        id: 'routine_edit_test',
        name: 'Work Routine',
        itemIds: ['item_a', 'item_b', 'item_c'],
        createdAt: now,
        updatedAt: now,
      );
      await repository.saveRoutine(initialRoutine);

      // Simulate reading progress: user is on item_b (index 1), completed item_a (count 1), item_b (count 2)
      await repository.saveSession(
        collectionId: 'routine_routine_edit_test',
        lastPageIndex: 1,
        counts: {'item_a': 1, 'item_b': 2},
        isCompleted: false,
      );

      // Edit 1: Reorder items and remove item_b (the current index item)
      // New items: ['item_c', 'item_a', 'item_d']
      final updatedRoutine = initialRoutine.copyWith(
        itemIds: ['item_c', 'item_a', 'item_d'],
        updatedAt: now.add(const Duration(minutes: 5)),
      );

      await repository.updateRoutineWithProgressPreservation(updatedRoutine);

      // Verify updated routine saved
      final fetched = await repository.getRoutineById('routine_edit_test');
      expect(fetched!.itemIds, equals(['item_c', 'item_a', 'item_d']));

      // Verify session preservation:
      // item_a count must be retained, item_b count removed
      final session = await repository.getSession('routine_routine_edit_test');
      expect(session, isNotNull);
      expect(session!.counts.containsKey('item_a'), isTrue);
      expect(session.counts['item_a'], equals(1));
      expect(session.counts.containsKey('item_b'), isFalse);

      // Current page index was 1 (item_b which was removed).
      // Next forward item in old routine was item_c (index 2 in old routine).
      // In new routine ['item_c', 'item_a', 'item_d'], item_c is at index 0.
      expect(session.lastPageIndex, equals(0));
    });

    test('deleting a routine removes its configuration and session but retains completions', () async {
      final now = DateTime.now();
      const routineId = 'routine_del_test';
      final routine = AdhkarRoutine(
        id: routineId,
        name: 'Temporary Routine',
        itemIds: ['ayat_al_kursi'],
        createdAt: now,
        updatedAt: now,
      );
      await repository.saveRoutine(routine);

      // Session saved
      await repository.saveSession(
        collectionId: 'routine_$routineId',
        lastPageIndex: 0,
        counts: {'ayat_al_kursi': 1},
        isCompleted: true,
      );

      // Completion history recorded
      const date = '2026-11-19';
      await repository.recordRoutineCompletion(
        routineId: routineId,
        routineName: 'Temporary Routine',
        date: date,
      );

      expect(
        await repository.isRoutineCompletedToday(routineId, date: date),
        isTrue,
      );

      // Delete routine
      await repository.deleteRoutine(routineId);

      // Routine configuration deleted
      expect(await repository.getRoutineById(routineId), isNull);
      // Reading session cleared
      expect(await repository.getSession('routine_$routineId'), isNull);

      // Routine completion history is preserved!
      expect(
        await repository.isRoutineCompletedToday(routineId, date: date),
        isTrue,
      );
      final history = await repository.getRoutineCompletionHistory(
        routineId: routineId,
      );
      expect(history.length, equals(1));
      expect(history.first.routineName, equals('Temporary Routine'));
    });

    test(
      'records and queries routine completions by date and history',
      () async {
        const date1 = '2026-11-18';
        const date2 = '2026-11-19';

        await repository.recordRoutineCompletion(
          routineId: 'routine_a',
          routineName: 'Routine Alpha',
          date: date1,
        );
        await repository.recordRoutineCompletion(
          routineId: 'routine_b',
          routineName: 'Routine Beta',
          date: date2,
        );

        final date1Completions = await repository.getRoutineCompletionsForDate(
          date1,
        );
        expect(date1Completions.length, equals(1));
        expect(date1Completions.first.routineId, equals('routine_a'));

        final allHistory = await repository.getRoutineCompletionHistory();
        expect(allHistory.length, equals(2));

        final alphaHistory = await repository.getRoutineCompletionHistory(
          routineId: 'routine_a',
        );
        expect(alphaHistory.length, equals(1));
        expect(alphaHistory.first.routineName, equals('Routine Alpha'));
      },
    );
  });
}
