---
name: flutter-drift
description: Use Drift (SQLite) for all structured local data in this Flutter app. Covers table definitions, DAOs, reactive queries, migrations, and database initialization. Use when creating, modifying, or querying local persistence for tasks, habits, barakah entries, intentions, or user preferences.
aliases: [drift, sqlite, local-database]
sources: [chat, code]
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 09 Sep 2026 14:54:00 GMT
---

# Drift Database for The Productive Muslim App

This app uses Drift (SQLite) for all structured local data and SharedPreferences for simple user preferences only. All domain entities — tasks, habits, barakah entries, intentions — are stored in Drift tables.

## Core Rules

1. Every data domain gets its own table with a typed Drift `Table` class.
2. Use Drift code generation (`build_runner`) for all table definitions, DAOs, and the database class. Never write raw SQL unless a migration requires it.
3. Expose data through DAO classes, not directly from the database class.
4. Use reactive `Stream` queries for any data the UI needs to observe.
5. All timestamps are stored as `Integer` (epoch milliseconds), never as Dart `DateTime` in the database.
6. All dates are stored as ISO-8601 `Text` (`YYYY-MM-DD`), never as Dart `DateTime`.
7. Every table includes `created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')*1000)`.
8. Soft deletes only — never `DELETE` rows. Use `active INTEGER DEFAULT 1` and filter by it.
9. Index every column used in `WHERE`, `ORDER BY`, or `JOIN` clauses.
10. Run `dart run build_runner build --delete-conflicting-outputs` after any schema change.

## Project Structure

```text
lib/
├── data/
│   ├── local/
│   │   ├── database/
│   │   │   ├── app_database.dart          # Database class, migrations
│   │   │   └── tables/
│   │   │       ├── tasks.dart
│   │   │       ├── habits.dart
│   │   │       ├── habit_completions.dart
│   │   │       ├── barakah_prompts.dart
│   │   │       ├── barakah_entries.dart
│   │   │       ├── intentions.dart
│   │   │       └── user_preferences.dart
│   │   └── daos/
│   │       ├── task_dao.dart
│   │       ├── habit_dao.dart
│   │       ├── barakah_dao.dart
│   │       ├── intention_dao.dart
│   │       └── preference_dao.dart
│   └── models/
│       └── drift/
│           ├── task.dart
│           ├── habit.dart
│           └── ...
```

## Table Definition Rules

```dart
// CORRECT
@DataClassName('Task')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get lifeArea => text().withLength(min: 1, max: 20)();
  IntColumn get startMinutes => integer().nullable()();
  IntColumn get endMinutes => integer().nullable()();
  TextColumn get date => text()();
  IntColumn get repeatDaily => integer().withDefault(const Constant(0))();
  IntColumn get completed => integer().withDefault(const Constant(0))();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get createdAt => integer().withDefault(const Constant(0))();
  IntColumn get active => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// WRONG — never use DateTime columns
class WrongTable extends Table {
  DateTimeColumn get createdAt => dateTime()(); // WRONG
}

// WRONG — never store dates as integers without ISO format
IntColumn get wrongDate => integer()(); // WRONG for dates
```

## DAO Patterns

```dart
// CORRECT
@DriftAccessor(tables: [Tasks, HabitCompletions])
class TaskDao extends DatabaseAccessor<AppDatabase> {
  TaskDao(super.db);

  // Reactive stream for today's tasks
  Stream<List<Task>> watchTasksForDate(String date) {
    return (select(tasks)
          ..where((t) => t.date.equals(date))
          ..where((t) => t.active.equals(1))
          ..orderBy([(t) => OrderingTerm.asc(t.startMinutes)]))
        .watch();
  }

  // Simple query
  Future<List<Task>> getTasksForDate(String date) {
    return (select(tasks)
          ..where((t) => t.date.equals(date))
          ..where((t) => t.active.equals(1)))
        .get();
  }

  // Insert
  Future<int> insertTask(TasksCompanion insert) {
    return into(tasks).insert(insert);
  }

  // Update
  Future<bool> updateTask(Task task) {
    return update(tasks).replace(task);
  }

  // Soft delete
  Future<int> deactivateTask(int id) {
    return (update(tasks)..where((t) => t.id.equals(id)))
        .write(const TasksCompanion(active: Value(0)));
  }
}
```

## Database Initialization

```dart
// CORRECT
@DriftDatabase(tables: [Tasks, Habits, HabitCompletions, BarakahPrompts, BarakahEntries, Intentions, UserPreferences], daos: [TaskDao, HabitDao, BarakahDao, IntentionDao, PreferenceDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle schema migrations here
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'productive_muslim.db'));
    return NativeDatabase(file);
  });
}
```

## Migration Example

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) async {
    await m.createAll();
  },
  onUpgrade: (Migrator m, int from, int to) async {
    if (from < 2) {
      await m.addColumn(tasks, tasks.notes);
    }
    if (from < 3) {
      await m.addColumn(habits, habits.reminderTime);
    }
  },
);
```

## Reactive Queries in Widgets

```dart
// CORRECT — use StreamBuilder with Drift watch()
StreamBuilder<List<Task>>(
  stream: context.read<TaskDao>().watchTasksForDate(today),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return TaskList(tasks: snapshot.data!);
    }
    return const CircularProgressIndicator();
  },
)
```

## What This Skill Does Not Cover

- Raw SQL migrations (only use when Drift's migration DSL cannot express the change)
- Web database (Drift web uses sql.js; not a V1 target)
- Database encryption (use SQLCipher if needed; not in V1 scope)
