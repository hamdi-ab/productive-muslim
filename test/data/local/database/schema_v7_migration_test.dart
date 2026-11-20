import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';

/// Test database simulating Schema Version 6 (before Adhkar Tasbih table was added)
class _VersionSixDatabase extends AppDatabase {
  _VersionSixDatabase(super.e) : super.forTesting();

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      for (final table in allTables) {
        if (table.actualTableName != 'adhkar_tasbih') {
          await m.createTable(table);
        }
      }
    },
  );
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('schema_v7_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('migrates schema version 6 to version 7 creating tasbih table cleanly', () async {
    final dbFile = File('${tempDir.path}/test_v6_to_v7.sqlite');

    // 1. Initialize DB at Schema Version 6
    final v6Db = _VersionSixDatabase(NativeDatabase(dbFile));

    // Seed v6 data (tasks, habits, bookmarks, sessions, completions, routines)
    await v6Db
        .into(v6Db.tasks)
        .insert(
          Task(
            id: 1,
            title: 'Read morning adhkar',
            lifeArea: 'Spiritual',
            date: '2026-11-20',
            repeatDaily: 1,
            repeatWeekly: 0,
            completed: 1,
            createdAt: 1700000000000,
            active: 1,
          ),
        );

    await v6Db
        .into(v6Db.habits)
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

    await v6Db.adhkarDao.addBookmark('ayat_al_kursi');

    await v6Db.adhkarDao.saveSession(
      collectionId: 'morning',
      lastPageIndex: 2,
      countsJson: '{"subhanallah": 33}',
      lastAccessedAt: 1700000000000,
    );

    await v6Db.adhkarDao.logCollectionCompletion(
      collectionId: 'morning',
      date: '2026-11-20',
      completedAt: 1700000000000,
    );

    await v6Db.adhkarDao.saveRoutine(
      id: 'routine_1',
      name: 'My Morning Calm',
      itemIdsJson: '["item1", "item2"]',
      preferredTime: '06:30',
      weekdaysJson: '[1, 2, 3]',
      createdAt: 1700000000000,
      updatedAt: 1700000000000,
    );

    await v6Db.adhkarDao.logRoutineCompletion(
      routineId: 'routine_1',
      routineName: 'My Morning Calm',
      date: '2026-11-20',
      completedAt: 1700000000000,
    );

    // Verify v6 records exist
    final tasksBefore = await v6Db.select(v6Db.tasks).get();
    expect(tasksBefore.length, 1);
    final routinesBefore = await v6Db.adhkarDao.getAllRoutines();
    expect(routinesBefore.length, 1);

    await v6Db.close();

    // 2. Open DB with production AppDatabase (Schema Version 7)
    final v7Db = AppDatabase.forTesting(NativeDatabase(dbFile));

    // Trigger schema upgrade via basic query
    final tasksAfter = await v7Db.select(v7Db.tasks).get();
    expect(tasksAfter.length, 1);
    expect(tasksAfter.first.title, 'Read morning adhkar');

    final habitsAfter = await v7Db.select(v7Db.habits).get();
    expect(habitsAfter.length, 1);

    final bookmarksAfter = await v7Db.adhkarDao.getBookmarkedDhikrIds();
    expect(bookmarksAfter, contains('ayat_al_kursi'));

    final sessionAfter = await v7Db.adhkarDao.getSession('morning');
    expect(sessionAfter, isNotNull);
    expect(sessionAfter!.countsJson, '{"subhanallah": 33}');

    final isCompleted = await v7Db.adhkarDao.isCollectionCompletedOnDate(
      'morning',
      '2026-11-20',
    );
    expect(isCompleted, isTrue);

    final routinesAfter = await v7Db.adhkarDao.getAllRoutines();
    expect(routinesAfter.length, 1);
    expect(routinesAfter.first.name, 'My Morning Calm');

    // Verify adhkar_tasbih table is created and operational
    final initialTasbih = await v7Db.adhkarDao.getTasbihState();
    expect(initialTasbih, isNull);

    await v7Db.adhkarDao.saveTasbihState(
      currentCount: 33,
      targetCount: 100,
      dhikrId: 'ayat_al_kursi',
      updatedAt: 1700000005000,
    );

    final loadedTasbih = await v7Db.adhkarDao.getTasbihState();
    expect(loadedTasbih, isNotNull);
    expect(loadedTasbih!.currentCount, 33);
    expect(loadedTasbih.targetCount, 100);
    expect(loadedTasbih.dhikrId, 'ayat_al_kursi');

    await v7Db.close();
  });
}
