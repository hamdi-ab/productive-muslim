import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/database/tables/intention_entries.dart';

part 'intention_dao.g.dart';

@DriftAccessor(tables: [IntentionEntries])
class IntentionDao extends DatabaseAccessor<AppDatabase>
    with _$IntentionDaoMixin {
  IntentionDao(super.db);

  Stream<List<IntentionEntry>> watchEntriesForDate(String date) {
    return (select(intentionEntries)
          ..where((e) => e.date.equals(date))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .watch();
  }

  Future<List<IntentionEntry>> getEntriesForDate(String date) async {
    return (select(intentionEntries)
          ..where((e) => e.date.equals(date))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();
  }

  Future<List<IntentionEntry>> getEntriesForRange(
    String startDate,
    String endDate,
  ) async {
    return (select(
      intentionEntries,
    )..where((e) => e.date.isBetweenValues(startDate, endDate))).get();
  }

  Future<IntentionEntry?> getEntryById(int id) async {
    return (select(
      intentionEntries,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertEntry(IntentionEntriesCompanion insert) {
    return into(intentionEntries).insert(insert);
  }

  Future<bool> updateEntry(IntentionEntry entry) {
    return update(intentionEntries).replace(entry);
  }

  Future<int> deleteEntry(int id) {
    return (delete(intentionEntries)..where((e) => e.id.equals(id))).go();
  }
}
