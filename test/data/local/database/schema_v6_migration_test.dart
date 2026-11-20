import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';

/// Test database simulating Schema Version 5 (before Adhkar routine tables were added)
class _VersionFiveDatabase extends AppDatabase {
  _VersionFiveDatabase(super.e) : super.forTesting();

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      for (final table in allTables) {
        if (table.actualTableName != 'adhkar_routines' &&
            table.actualTableName != 'adhkar_routine_completions') {
          await m.createTable(table);
        }
      }
    },
  );
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('schema_v6_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'migrates schema version 5 to version 6 creating routine tables cleanly',
    () async {
      final dbFile = File('${tempDir.path}/test_v5_to_v6.sqlite');

      // 1. Initialize DB at Schema Version 5
      final v5Db = _VersionFiveDatabase(NativeDatabase(dbFile));

      // Seed v5 data (tasks, habits, bookmarks, sessions, completions)
      await v5Db
          .into(v5Db.tasks)
          .insert(
            Task(
              id: 1,
              title: 'Read morning adhkar',
              lifeArea: 'Spiritual',
              date: '2026-11-19',
              repeatDaily: 1,
              repeatWeekly: 0,
              completed: 1,
              createdAt: 1700000000000,
              active: 1,
            ),
          );

      await v5Db
          .into(v5Db.habits)
          .insert(
            const Habit(
              id: 1,
              name: 'Daily Dhikr Habit',
              category: 'Spiritual',
              frequency: 'daily',
              reminderEnabled: 1,
              active: 1,
              createdAt: 1700000000000,
            ),
          );

      await v5Db.adhkarDao.addBookmark('ayat_al_kursi');
      await v5Db.adhkarDao.saveSession(
        collectionId: 'morning',
        lastPageIndex: 2,
        countsJson: '{"ayat_al_kursi": 1}',
        lastAccessedAt: 1700000010000,
        isCompleted: false,
      );
      await v5Db.adhkarDao.logCollectionCompletion(
        collectionId: 'morning',
        date: '2026-11-19',
        completedAt: 1700000020000,
      );

      await v5Db.close();

      // 2. Open DB with AppDatabase (Schema Version 6) -> triggers onUpgrade(from: 5, to: 6)
      final v6Db = AppDatabase.forTesting(NativeDatabase(dbFile));
      try {
        // Verify v5 data is preserved
        final tasks = await v6Db.select(v6Db.tasks).get();
        expect(tasks.length, equals(1));
        expect(tasks.first.title, equals('Read morning adhkar'));

        final habits = await v6Db.select(v6Db.habits).get();
        expect(habits.length, equals(1));
        expect(habits.first.name, equals('Daily Dhikr Habit'));

        expect(await v6Db.adhkarDao.isBookmarked('ayat_al_kursi'), isTrue);

        final session = await v6Db.adhkarDao.getSession('morning');
        expect(session, isNotNull);
        expect(session!.collectionId, equals('morning'));
        expect(session.lastPageIndex, equals(2));

        expect(
          await v6Db.adhkarDao.isCollectionCompletedOnDate(
            'morning',
            '2026-11-19',
          ),
          isTrue,
        );

        // Verify v6 Adhkar routines table operations
        await v6Db.adhkarDao.saveRoutine(
          id: 'routine-1',
          name: 'My Morning Calm',
          itemIdsJson: '["ayat_al_kursi", "sayyid_al_istighfar"]',
          preferredTime: '06:30',
          weekdaysJson: '[1, 2, 3, 4, 5]',
          createdAt: 1700000030000,
          updatedAt: 1700000030000,
        );

        final routine = await v6Db.adhkarDao.getRoutine('routine-1');
        expect(routine, isNotNull);
        expect(routine!.name, equals('My Morning Calm'));
        expect(routine.preferredTime, equals('06:30'));
        expect(
          routine.itemIdsJson,
          equals('["ayat_al_kursi", "sayyid_al_istighfar"]'),
        );

        final routines = await v6Db.adhkarDao.getAllRoutines();
        expect(routines.length, equals(1));

        // Verify v6 Adhkar routine completions table operations
        await v6Db.adhkarDao.logRoutineCompletion(
          routineId: 'routine-1',
          routineName: 'My Morning Calm',
          date: '2026-11-19',
          completedAt: 1700000040000,
        );

        expect(
          await v6Db.adhkarDao.isRoutineCompletedOnDate(
            'routine-1',
            '2026-11-19',
          ),
          isTrue,
        );
        expect(
          await v6Db.adhkarDao.isRoutineCompletedOnDate(
            'routine-1',
            '2026-11-20',
          ),
          isFalse,
        );

        final routineCompletions = await v6Db.adhkarDao
            .getRoutineCompletionsForDate('2026-11-19');
        expect(routineCompletions.length, equals(1));
        expect(routineCompletions.first.routineId, equals('routine-1'));

        // Verify routine deletion clears unfinished session but preserves completions
        await v6Db.adhkarDao.saveSession(
          collectionId: 'routine_routine-1',
          lastPageIndex: 1,
          countsJson: '{"ayat_al_kursi": 1}',
          lastAccessedAt: 1700000045000,
          isCompleted: false,
        );
        expect(await v6Db.adhkarDao.getSession('routine_routine-1'), isNotNull);

        await v6Db.adhkarDao.deleteRoutine('routine-1');
        expect(await v6Db.adhkarDao.getRoutine('routine-1'), isNull);
        expect(await v6Db.adhkarDao.getSession('routine_routine-1'), isNull);

        // Completion record survives routine deletion
        expect(
          await v6Db.adhkarDao.isRoutineCompletedOnDate(
            'routine-1',
            '2026-11-19',
          ),
          isTrue,
        );
      } finally {
        await v6Db.close();
      }
    },
  );
}
