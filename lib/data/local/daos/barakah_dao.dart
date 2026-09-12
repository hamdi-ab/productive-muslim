import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';

class BarakahDao {
  BarakahDao(this._db);

  final AppDatabase _db;

  static BarakahEntry _fromRow(Map<String, Object?> row) => BarakahEntry(
        id: row['id'] as int,
        date: row['date'] as String,
        sourceIds: (row['source_ids'] as String)
            .split(',')
            .where((s) => s.isNotEmpty)
            .toList(),
        promptId: row['prompt_id'] as String?,
        intensity: row['intensity'] as int?,
        note: row['note'] as String?,
        skipped: (row['skipped'] as int?) == 1,
        createdAt: row['created_at'] as int,
      );

  Stream<List<BarakahEntry>> watchEntriesForDate(String date) {
    return Stream.fromFuture(getEntriesForDate(date));
  }

  Future<List<BarakahEntry>> getEntriesForDate(String date) async {
    final rows = await _db.executor.runSelect(
      'SELECT * FROM barakah_entries WHERE date = ?',
      [date],
    );
    return rows.map(_fromRow).toList();
  }

  Future<List<BarakahEntry>> getEntriesForRange(
    String startDate,
    String endDate,
  ) async {
    final rows = await _db.executor.runSelect(
      'SELECT * FROM barakah_entries WHERE date BETWEEN ? AND ?',
      [startDate, endDate],
    );
    return rows.map(_fromRow).toList();
  }

  Future<BarakahEntry?> getEntryById(int id) async {
    final rows = await _db.executor.runSelect(
      'SELECT * FROM barakah_entries WHERE id = ?',
      [id],
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<int> insertEntry(BarakahEntry entry) {
    return _db.executor.runInsert(
      'INSERT INTO barakah_entries (date, source_ids, prompt_id, intensity, note, skipped, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        entry.date,
        entry.sourceIds.join(','),
        entry.promptId,
        entry.intensity,
        entry.note,
        entry.skipped,
        entry.createdAt,
      ],
    );
  }

  Future<bool> updateEntry(BarakahEntry entry) async {
    await _db.executor.runInsert(
      'INSERT OR REPLACE INTO barakah_entries (id, date, source_ids, prompt_id, intensity, note, skipped, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        entry.id,
        entry.date,
        entry.sourceIds.join(','),
        entry.promptId,
        entry.intensity,
        entry.note,
        entry.skipped,
        entry.createdAt,
      ],
    );
    return true;
  }

  Future<int> deleteEntry(int id) {
    return _db.executor.runDelete(
      'DELETE FROM barakah_entries WHERE id = ?',
      [id],
    );
  }
}