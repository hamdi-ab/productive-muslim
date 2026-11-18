import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';

/// Test database simulating Schema Version 3 (before MuhasabahEntries was added)
class _VersionThreeDatabase extends AppDatabase {
  _VersionThreeDatabase(super.e) : super.forTesting();

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      for (final table in allTables) {
        if (table.actualTableName != 'muhasabah_entries') {
          await m.createTable(table);
        }
      }
    },
  );
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('schema_v4_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('migrates legacy reflections from intention_entries into muhasabah_entries safely', () async {
    final dbFile = File('${tempDir.path}/test_v3_to_v4.sqlite');

    // 1. Initialize DB at Schema Version 3
    final v3Db = _VersionThreeDatabase(NativeDatabase(dbFile));

    // Seed v3 intention records
    await v3Db
        .into(v3Db.intentionEntries)
        .insert(
          IntentionEntriesCompanion.insert(
            date: '2026-11-15',
            title: 'Lead team standup with patience',
            statement: const Value('Work as worship'),
            category: const Value('work'),
            completed: const Value(1),
            reflection: const Value(
              'Felt Barakah in my speech today and noticed calm in the team.',
            ),
            createdAt: const Value(1700000000000),
          ),
        );

    // Record without reflection
    await v3Db
        .into(v3Db.intentionEntries)
        .insert(
          IntentionEntriesCompanion.insert(
            date: '2026-11-16',
            title: 'Pray Fajr on time',
            statement: const Value('Strengthen morning routine'),
            category: const Value('worship'),
            completed: const Value(1),
            reflection: const Value(null),
            createdAt: const Value(1700000010000),
          ),
        );

    // Record with whitespace-only reflection
    await v3Db
        .into(v3Db.intentionEntries)
        .insert(
          IntentionEntriesCompanion.insert(
            date: '2026-11-17',
            title: 'Call parents before Maghrib',
            statement: const Value('Family kinship'),
            category: const Value('family'),
            completed: const Value(0),
            reflection: const Value('   \n\t  '),
            createdAt: const Value(1700000020000),
          ),
        );

    // Record with another valid reflection
    await v3Db
        .into(v3Db.intentionEntries)
        .insert(
          IntentionEntriesCompanion.insert(
            date: '2026-11-18',
            title: 'Deep focus on code architecture',
            statement: const Value('Excellence (Ihsan)'),
            category: const Value('work'),
            completed: const Value(1),
            reflection: const Value(
              'Grateful for clarity and energy after Dhuhr.',
            ),
            createdAt: const Value(1700000030000),
          ),
        );

    await v3Db.close();

    // 2. Open DB with AppDatabase (Schema Version 4) -> Triggers onUpgrade(from: 3, to: 4)
    final v4Db = AppDatabase.forTesting(NativeDatabase(dbFile));
    try {
      // Verify intention_entries are 100% preserved
      final intentions = await v4Db.select(v4Db.intentionEntries).get();
      expect(intentions.length, equals(4));
      expect(intentions[0].title, equals('Lead team standup with patience'));
      expect(intentions[1].title, equals('Pray Fajr on time'));
      expect(intentions[2].title, equals('Call parents before Maghrib'));
      expect(intentions[3].title, equals('Deep focus on code architecture'));

      // Verify muhasabah_entries were created and migrated
      final reflections = await v4Db.select(v4Db.muhasabahEntries).get();
      expect(reflections.length, equals(2));

      final first = reflections.firstWhere((r) => r.date == '2026-11-15');
      expect(
        first.content,
        equals('Felt Barakah in my speech today and noticed calm in the team.'),
      );
      expect(first.createdAt, equals(1700000000000));
      expect(first.updatedAt, equals(1700000000000));
      expect(first.promptId, isNull);

      final second = reflections.firstWhere((r) => r.date == '2026-11-18');
      expect(
        second.content,
        equals('Grateful for clarity and energy after Dhuhr.'),
      );
      expect(second.createdAt, equals(1700000030000));

      // Whitespace and null reflections were not created
      expect(reflections.any((r) => r.date == '2026-11-16'), isFalse);
      expect(reflections.any((r) => r.date == '2026-11-17'), isFalse);

      // 3. Verify new insertions work seamlessly on MuhasabahDao
      await v4Db.muhasabahDao.insertEntry(
        MuhasabahEntriesCompanion.insert(
          date: '2026-11-18',
          promptId: const Value('blessing_noticed'),
          promptText: const Value('What blessing did you notice today?'),
          content: 'Noticed the ease in navigating between tasks.',
          tags: const Value('#Shukr,#Ihsan'),
          createdAt: const Value(1700000040000),
          updatedAt: const Value(1700000040000),
        ),
      );

      final dayReflections = await v4Db.muhasabahDao.getEntriesForDate(
        '2026-11-18',
      );
      expect(dayReflections.length, equals(2));
    } finally {
      await v4Db.close();
    }
  });
}
