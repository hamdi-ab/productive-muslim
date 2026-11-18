import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
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
      final all = repository.getAll();
      expect(all, isNotEmpty);
      expect(all.every((item) => item.contentVersion >= 1), isTrue);
    });

    test('returns general dhikr collection with authentic references', () {
      final generalItems = repository.getByCategory(DhikrCategory.general);
      expect(generalItems.length, equals(5));

      final subhanallah = generalItems.firstWhere(
        (i) => i.id == 'general_subhanallah_bihamdihi',
      );
      expect(subhanallah.reference, contains('Muslim 2692'));
      expect(subhanallah.targetCount, equals(100));

      final fourBeloved = generalItems.firstWhere(
        (i) => i.id == 'general_four_beloved_words',
      );
      expect(fourBeloved.reference, contains('Muslim 2137'));

      final istighfar = generalItems.firstWhere(
        (i) => i.id == 'general_istighfar',
      );
      expect(istighfar.reference, contains('Bukhari 6307'));
      expect(istighfar.targetCount, equals(70));
    });

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
