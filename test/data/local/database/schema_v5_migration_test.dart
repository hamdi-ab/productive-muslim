import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';

/// Test database simulating Schema Version 4 (before Adhkar tables were added)
class _VersionFourDatabase extends AppDatabase {
  _VersionFourDatabase(super.e) : super.forTesting();

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      for (final table in allTables) {
        if (table.actualTableName != 'adhkar_bookmarks' &&
            table.actualTableName != 'adhkar_sessions' &&
            table.actualTableName != 'adhkar_completions') {
          await m.createTable(table);
        }
      }
    },
  );
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('schema_v5_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'migrates schema version 4 to version 5 creating adhkar tables cleanly',
    () async {
      final dbFile = File('${tempDir.path}/test_v4_to_v5.sqlite');

      // 1. Initialize DB at Schema Version 4
      final v4Db = _VersionFourDatabase(NativeDatabase(dbFile));

      // Seed v4 data
      await v4Db
          .into(v4Db.tasks)
          .insert(
            Task(
              id: 1,
              title: 'Complete Fajr',
              lifeArea: 'Spiritual',
              date: '2026-11-18',
              repeatDaily: 1,
              repeatWeekly: 0,
              completed: 1,
              createdAt: 1700000000000,
              active: 1,
            ),
          );

      await v4Db
          .into(v4Db.habits)
          .insert(
            const Habit(
              id: 1,
              name: 'Morning Adhkar Routine',
              category: 'Spiritual',
              frequency: 'daily',
              reminderEnabled: 1,
              active: 1,
              createdAt: 1700000000000,
            ),
          );

      await v4Db.close();

      // 2. Open DB with AppDatabase (Schema Version 5) -> triggers onUpgrade(from: 4, to: 5)
      final v5Db = AppDatabase.forTesting(NativeDatabase(dbFile));
      try {
        // Verify v4 data is preserved
        final tasks = await v5Db.select(v5Db.tasks).get();
        expect(tasks.length, equals(1));
        expect(tasks.first.title, equals('Complete Fajr'));

        final habits = await v5Db.select(v5Db.habits).get();
        expect(habits.length, equals(1));
        expect(habits.first.name, equals('Morning Adhkar Routine'));

        // Verify AdhkarDao bookmarks work
        await v5Db.adhkarDao.addBookmark('ayat_al_kursi');
        expect(await v5Db.adhkarDao.isBookmarked('ayat_al_kursi'), isTrue);
        expect(await v5Db.adhkarDao.isBookmarked('unknown_id'), isFalse);
        final bookmarks = await v5Db.adhkarDao.getBookmarkedDhikrIds();
        expect(bookmarks, contains('ayat_al_kursi'));

        await v5Db.adhkarDao.removeBookmark('ayat_al_kursi');
        expect(await v5Db.adhkarDao.isBookmarked('ayat_al_kursi'), isFalse);

        // Verify AdhkarDao sessions work
        await v5Db.adhkarDao.saveSession(
          collectionId: 'morning',
          lastPageIndex: 3,
          countsJson: '{"ayat_al_kursi": 1, "sayyid_al_istighfar": 1}',
          lastAccessedAt: 1700000050000,
          isCompleted: false,
        );

        final session = await v5Db.adhkarDao.getSession('morning');
        expect(session, isNotNull);
        expect(session!.collectionId, equals('morning'));
        expect(session.lastPageIndex, equals(3));
        expect(session.isCompleted, isFalse);

        // Verify AdhkarDao completions work
        await v5Db.adhkarDao.logCollectionCompletion(
          collectionId: 'morning',
          date: '2026-11-18',
          completedAt: 1700000060000,
        );

        expect(
          await v5Db.adhkarDao.isCollectionCompletedOnDate(
            'morning',
            '2026-11-18',
          ),
          isTrue,
        );
        expect(
          await v5Db.adhkarDao.isCollectionCompletedOnDate(
            'morning',
            '2026-11-19',
          ),
          isFalse,
        );

        // Verify session clear does not erase completion history
        await v5Db.adhkarDao.clearSession('morning');
        expect(await v5Db.adhkarDao.getSession('morning'), isNull);
        expect(
          await v5Db.adhkarDao.isCollectionCompletedOnDate(
            'morning',
            '2026-11-18',
          ),
          isTrue,
        );
      } finally {
        await v5Db.close();
      }
    },
  );
}
