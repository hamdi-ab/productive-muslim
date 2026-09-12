import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart';

class IntentionDao {
  IntentionDao(this._db);

  final AppDatabase _db;

  static IntentionEntry _fromRow(Map<String, Object?> row) =>
      IntentionEntry(
        id: row['id'] as int,
        date: row['date'] as String,
        title: row['title'] as String,
        statement: row['statement'] as String?,
        category: row['category'] as String?,
        completed: (row['completed'] as int?) == 1,
        reflection: row['reflection'] as String?,
        createdAt: row['created_at'] as int,
      );

  Stream<List<IntentionEntry>> watchEntriesForDate(String date) {
    return Stream.fromFuture(getEntriesForDate(date));
  }

  Future<List<IntentionEntry>> getEntriesForDate(String date) async {
    final rows = await _db.executor.runSelect(
      'SELECT * FROM intention_entries WHERE date = ?',
      [date],
    );
    return rows.map(_fromRow).toList();
  }

  Future<List<IntentionEntry>> getEntriesForRange(
    String startDate,
    String endDate,
  ) async {
    final rows = await _db.executor.runSelect(
      'SELECT * FROM intention_entries WHERE date BETWEEN ? AND ?',
      [startDate, endDate],
    );
    return rows.map(_fromRow).toList();
  }

  Future<IntentionEntry?> getEntryById(int id) async {
    final rows = await _db.executor.runSelect(
      'SELECT * FROM intention_entries WHERE id = ?',
      [id],
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<int> insertEntry(IntentionEntry entry) {
    return _db.executor.runInsert(
      'INSERT INTO intention_entries (date, title, statement, category, completed, reflection, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        entry.date,
        entry.title,
        entry.statement,
        entry.category,
        entry.completed,
        entry.reflection,
        entry.createdAt,
      ],
    );
  }

  Future<bool> updateEntry(IntentionEntry entry) async {
    await _db.executor.runInsert(
      'INSERT OR REPLACE INTO intention_entries (id, date, title, statement, category, completed, reflection, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        entry.id,
        entry.date,
        entry.title,
        entry.statement,
        entry.category,
        entry.completed,
        entry.reflection,
        entry.createdAt,
      ],
    );
    return true;
  }

  Future<int> deleteEntry(int id) {
    return _db.executor.runDelete(
      'DELETE FROM intention_entries WHERE id = ?',
      [id],
    );
  }
}