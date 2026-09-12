import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Hand-rolled database facade. No codegen — each DAO wraps the shared
/// connection and executes queries directly.
class AppDatabase {
  AppDatabase(QueryExecutor executor) : _executor = executor;

  final QueryExecutor _executor;

  QueryExecutor get executor => _executor;

  static Future<AppDatabase> open(String path) async {
    final connection = DatabaseConnection(
      NativeDatabase(
        File(path),
        logStatements: false,
      ),
    );
    final db = AppDatabase(connection.executor);
    await db._createTables();
    return db;
  }

  static AppDatabase inMemory() {
    final connection = DatabaseConnection(
      NativeDatabase.memory(),
    );
    return AppDatabase(connection.executor);
  }

  Future<void> _createTables() async {
    await _executor.runCustom(
      'CREATE TABLE IF NOT EXISTS tasks ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'title TEXT NOT NULL, '
      'life_area TEXT NOT NULL, '
      'start_time INTEGER, '
      'end_time INTEGER, '
      'date TEXT NOT NULL, '
      'repeat_daily INTEGER NOT NULL DEFAULT 0, '
      'repeat_weekly INTEGER NOT NULL DEFAULT 0, '
      'repeat_days TEXT, '
      'notes TEXT, '
      'completed INTEGER NOT NULL DEFAULT 0, '
      'completed_at INTEGER, '
      'created_at INTEGER NOT NULL DEFAULT 0, '
      'active INTEGER NOT NULL DEFAULT 1)',
    );

    await _executor.runCustom(
      'CREATE INDEX IF NOT EXISTS tasks_date_start ON tasks (date, start_time)',
    );

    await _executor.runCustom(
      'CREATE TABLE IF NOT EXISTS habits ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT NOT NULL, '
      'category TEXT NOT NULL, '
      'frequency TEXT NOT NULL DEFAULT \'daily\', '
      'target_days TEXT, '
      'reminder_enabled INTEGER NOT NULL DEFAULT 0, '
      'reminder_time INTEGER, '
      'active INTEGER NOT NULL DEFAULT 1, '
      'created_at INTEGER NOT NULL DEFAULT 0)',
    );

    await _executor.runCustom(
      'CREATE TABLE IF NOT EXISTS barakah_entries ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'date TEXT NOT NULL, '
      'source_ids TEXT NOT NULL, '
      'prompt_id TEXT, '
      'intensity INTEGER, '
      'note TEXT, '
      'skipped INTEGER NOT NULL DEFAULT 0, '
      'created_at INTEGER NOT NULL DEFAULT 0)',
    );

    await _executor.runCustom(
      'CREATE TABLE IF NOT EXISTS intention_entries ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'date TEXT NOT NULL, '
      'title TEXT NOT NULL, '
      'statement TEXT, '
      'category TEXT, '
      'completed INTEGER NOT NULL DEFAULT 0, '
      'reflection TEXT, '
      'created_at INTEGER NOT NULL DEFAULT 0)',
    );
  }
}