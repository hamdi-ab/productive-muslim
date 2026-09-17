import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:productive_muslim/data/local/database/tables/barakah_daily_responses.dart';
import 'package:productive_muslim/data/local/database/tables/barakah_entries.dart';
import 'package:productive_muslim/data/local/database/tables/barakah_prompts.dart';
import 'package:productive_muslim/data/local/database/tables/habits.dart';
import 'package:productive_muslim/data/local/database/tables/intention_entries.dart';
import 'package:productive_muslim/data/local/database/tables/tasks.dart';
import 'package:productive_muslim/data/local/daos/barakah_dao.dart';
import 'package:productive_muslim/data/local/daos/habit_dao.dart';
import 'package:productive_muslim/data/local/daos/intention_dao.dart';
import 'package:productive_muslim/data/local/daos/task_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    BarakahEntries,
    BarakahPrompts,
    Habits,
    Tasks,
    IntentionEntries,
    BarakahDailyResponses,
  ],
  daos: [BarakahDao, HabitDao, TaskDao, IntentionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(barakahDailyResponses);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'productive_muslim.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
