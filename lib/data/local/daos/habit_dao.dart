import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/domain/models/habit.dart';

class HabitDao {
  HabitDao(this._db);

  final AppDatabase _db;

  static Habit _fromRow(Map<String, Object?> row) => Habit(
        id: row['id'] as int,
        name: row['name'] as String,
        category: row['category'] as String,
        frequency: row['frequency'] as String,
        targetDays: row['target_days'] as String?,
        reminderEnabled: (row['reminder_enabled'] as int?) == 1,
        reminderTime: row['reminder_time'] as int?,
        active: (row['active'] as int?) == 1,
        createdAt: row['created_at'] as int,
      );

  Stream<List<Habit>> watchActiveHabits() {
    return Stream.fromFuture(getActiveHabits());
  }

  Future<List<Habit>> getActiveHabits() async {
    final rows = await _db.executor.runSelect(
      'SELECT * FROM habits WHERE active = 1',
      [],
    );
    return rows.map(_fromRow).toList();
  }

  Future<Habit?> getHabitById(int id) async {
    final rows = await _db.executor.runSelect(
      'SELECT * FROM habits WHERE id = ?',
      [id],
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<int> insertHabit(Habit habit) {
    return _db.executor.runInsert(
      'INSERT INTO habits (name, category, frequency, target_days, reminder_enabled, reminder_time, active, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        habit.name,
        habit.category,
        habit.frequency,
        habit.targetDays,
        habit.reminderEnabled,
        habit.reminderTime,
        habit.active,
        habit.createdAt,
      ],
    );
  }

  Future<bool> updateHabit(Habit habit) async {
    await _db.executor.runInsert(
      'INSERT OR REPLACE INTO habits (id, name, category, frequency, target_days, reminder_enabled, reminder_time, active, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        habit.id,
        habit.name,
        habit.category,
        habit.frequency,
        habit.targetDays,
        habit.reminderEnabled,
        habit.reminderTime,
        habit.active,
        habit.createdAt,
      ],
    );
    return true;
  }

  Future<int> deactivateHabit(int id) {
    return _db.executor.runUpdate(
      'UPDATE habits SET active = 0 WHERE id = ?',
      [id],
    );
  }
}