import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/database/tables/barakah_prompts.dart';
import 'package:productive_muslim/data/local/database/tables/barakah_entries.dart';

part 'barakah_dao.g.dart';

@DriftAccessor(tables: [BarakahPrompts, BarakahEntries])
class BarakahDao extends DatabaseAccessor<AppDatabase> with _$BarakahDaoMixin {
  BarakahDao(super.db);

  Stream<List<BarakahEntry>> watchEntriesForDate(String date) {
    return (select(barakahEntries)
          ..where((e) => e.date.equals(date))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .watch();
  }

  Future<List<BarakahEntry>> getEntriesForDate(String date) {
    return (select(barakahEntries)..where((e) => e.date.equals(date))).get();
  }

  Future<List<BarakahEntry>> getEntriesForRange(
    String startDate,
    String endDate,
  ) {
    return (select(
      barakahEntries,
    )..where((e) => e.date.isBetweenValues(startDate, endDate))).get();
  }

  Future<BarakahEntry?> getEntryById(int id) {
    return (select(
      barakahEntries,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertEntry(BarakahEntriesCompanion insert) {
    return into(barakahEntries).insert(insert);
  }

  Future<bool> updateEntry(BarakahEntry entry) {
    return update(barakahEntries).replace(entry);
  }

  Future<int> deleteEntry(int id) {
    return (delete(barakahEntries)..where((e) => e.id.equals(id))).go();
  }
}
