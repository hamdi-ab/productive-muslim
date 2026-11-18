import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/tables/barakah_daily_responses.dart';
import 'package:productive_muslim/data/local/database/tables/barakah_entries.dart';
import 'package:productive_muslim/data/local/database/tables/barakah_prompts.dart';
import 'package:productive_muslim/data/local/database/tables/habit_completions.dart';
import 'package:productive_muslim/data/local/database/tables/habits.dart';
import 'package:productive_muslim/data/local/database/tables/intention_entries.dart';
import 'package:productive_muslim/data/local/database/tables/muhasabah_entries.dart';
import 'package:productive_muslim/data/local/database/tables/tasks.dart';
import 'package:productive_muslim/data/local/daos/barakah_dao.dart';
import 'package:productive_muslim/data/local/daos/habit_dao.dart';
import 'package:productive_muslim/data/local/daos/habit_completions_dao.dart';
import 'package:productive_muslim/data/local/daos/intention_dao.dart';
import 'package:productive_muslim/data/local/daos/muhasabah_dao.dart';
import 'package:productive_muslim/data/local/daos/task_dao.dart';

import 'connection/web.dart'
    if (dart.library.io) 'connection/native.dart'
    as connection;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    BarakahEntries,
    BarakahPrompts,
    Habits,
    HabitCompletions,
    Tasks,
    IntentionEntries,
    BarakahDailyResponses,
    MuhasabahEntries,
  ],
  daos: [
    BarakahDao,
    HabitDao,
    HabitCompletionsDao,
    TaskDao,
    IntentionDao,
    MuhasabahDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.connect());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(barakahDailyResponses);
      }
      if (from < 3) {
        await m.createTable(habitCompletions);
      }
      if (from < 4) {
        await m.createTable(muhasabahEntries);
        final legacyRows = await customSelect(
          "SELECT date, reflection, created_at "
          "FROM intention_entries "
          "WHERE reflection IS NOT NULL AND trim(reflection) != ''",
          readsFrom: {intentionEntries},
        ).get();

        for (final row in legacyRows) {
          final reflection = row.read<String>('reflection');
          if (reflection.trim().isEmpty) continue;
          final date = row.read<String>('date');
          final createdAt = row.read<int>('created_at');

          await into(muhasabahEntries).insert(
            MuhasabahEntriesCompanion.insert(
              date: date,
              content: reflection.trim(),
              createdAt: Value(createdAt),
              updatedAt: Value(createdAt),
            ),
          );
        }
      }
    },
  );
}
