import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/domain/models/task.dart';

class TaskDao {
  TaskDao(this._db);

  final AppDatabase _db;

  static Task _fromRow(Map<String, Object?> row) => Task(
        id: row['id'] as int,
        title: row['title'] as String,
        lifeArea: row['life_area'] as String,
        startMinutes: row['start_time'] as int?,
        endMinutes: row['end_time'] as int?,
        date: row['date'] as String,
        repeatDaily: (row['repeat_daily'] as int?) == 1,
        repeatWeekly: (row['repeat_weekly'] as int?) == 1,
        repeatDays: row['repeat_days'] as String?,
        notes: row['notes'] as String?,
        completed: (row['completed'] as int?) == 1,
        completedAt: row['completed_at'] as int?,
        createdAt: row['created_at'] as int,
        active: (row['active'] as int?) == 1,
      );

  Stream<List<Task>> watchTasksForDate(String date) {
    return Stream.fromFuture(getTasksForDate(date));
  }

  Future<List<Task>> getTasksForDate(String date) async {
    final rows = await _db.executor.runSelect(
      'SELECT * FROM tasks WHERE date = ? AND active = 1 ORDER BY start_time ASC',
      [date],
    );
    return rows.map(_fromRow).toList();
  }

  Future<List<Task>> getTasksForRange(String startDate, String endDate) async {
    final rows = await _db.executor.runSelect(
      'SELECT * FROM tasks WHERE date BETWEEN ? AND ? AND active = 1',
      [startDate, endDate],
    );
    return rows.map(_fromRow).toList();
  }

  Future<Task?> getTaskById(int id) async {
    final rows = await _db.executor.runSelect(
      'SELECT * FROM tasks WHERE id = ?',
      [id],
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<int> insertTask(Task task) {
    return _db.executor.runInsert(
      'INSERT INTO tasks (title, life_area, start_time, end_time, date, repeat_daily, repeat_weekly, repeat_days, notes, completed, completed_at, created_at, active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        task.title,
        task.lifeArea,
        task.startMinutes,
        task.endMinutes,
        task.date,
        task.repeatDaily,
        task.repeatWeekly,
        task.repeatDays,
        task.notes,
        task.completed,
        task.completedAt,
        task.createdAt,
        task.active,
      ],
    );
  }

  Future<bool> updateTask(Task task) async {
    await _db.executor.runInsert(
      'INSERT OR REPLACE INTO tasks (id, title, life_area, start_time, end_time, date, repeat_daily, repeat_weekly, repeat_days, notes, completed, completed_at, created_at, active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        task.id,
        task.title,
        task.lifeArea,
        task.startMinutes,
        task.endMinutes,
        task.date,
        task.repeatDaily,
        task.repeatWeekly,
        task.repeatDays,
        task.notes,
        task.completed,
        task.completedAt,
        task.createdAt,
        task.active,
      ],
    );
    return true;
  }

  Future<int> toggleTask(int id) {
    return _db.executor.runUpdate(
      'UPDATE tasks SET completed = 1, completed_at = 0 WHERE id = ?',
      [id],
    );
  }

  Future<int> deactivateTask(int id) {
    return _db.executor.runUpdate(
      'UPDATE tasks SET active = 0 WHERE id = ?',
      [id],
    );
  }
}