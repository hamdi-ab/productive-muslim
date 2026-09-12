import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/database/tables/intention_entries.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart'
    as intention_model;

part 'intention_dao.g.dart';

@DriftAccessor(tables: [IntentionEntries])
class IntentionDao extends DatabaseAccessor<AppDatabase>
    with _$IntentionDaoMixin {
  IntentionDao(super.db);

  intention_model.IntentionEntry _toDomain(IntentionEntry row) {
    return intention_model.IntentionEntry(
      id: row.id,
      date: row.date,
      title: row.title,
      statement: row.statement,
      category: row.category,
      completed: row.completed == 1,
      reflection: row.reflection,
      createdAt: row.createdAt,
    );
  }

  Stream<List<intention_model.IntentionEntry>> watchEntriesForDate(
    String date,
  ) {
    return (select(intentionEntries)
          ..where((e) => e.date.equals(date))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  Future<List<intention_model.IntentionEntry>> getEntriesForDate(
    String date,
  ) async {
    final rows =
        await (select(intentionEntries)
              ..where((e) => e.date.equals(date))
              ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
            .get();
    return rows.map(_toDomain).toList();
  }

  Future<List<intention_model.IntentionEntry>> getEntriesForRange(
    String startDate,
    String endDate,
  ) async {
    final rows = await (select(
      intentionEntries,
    )..where((e) => e.date.isBetweenValues(startDate, endDate))).get();
    return rows.map(_toDomain).toList();
  }

  Future<intention_model.IntentionEntry?> getEntryById(int id) async {
    final row = await (select(
      intentionEntries,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Future<int> insertEntry(intention_model.IntentionEntry entry) {
    return into(intentionEntries).insert(
      IntentionEntriesCompanion.insert(
        date: entry.date,
        title: entry.title,
        statement: Value(entry.statement),
        category: Value(entry.category),
        completed: Value(entry.completed ? 1 : 0),
        reflection: Value(entry.reflection),
        createdAt: Value(entry.createdAt),
      ),
    );
  }

  Future<bool> updateEntry(intention_model.IntentionEntry entry) {
    return update(intentionEntries).replace(
      IntentionEntry(
        id: entry.id,
        date: entry.date,
        title: entry.title,
        statement: entry.statement,
        category: entry.category,
        completed: entry.completed ? 1 : 0,
        reflection: entry.reflection,
        createdAt: entry.createdAt,
      ),
    );
  }

  Future<int> deleteEntry(int id) {
    return (delete(intentionEntries)..where((e) => e.id.equals(id))).go();
  }
}
