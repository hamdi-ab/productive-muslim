import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/database/tables/muhasabah_entries.dart';

part 'muhasabah_dao.g.dart';

@DriftAccessor(tables: [MuhasabahEntries])
class MuhasabahDao extends DatabaseAccessor<AppDatabase>
    with _$MuhasabahDaoMixin {
  MuhasabahDao(super.db);

  Stream<List<MuhasabahEntryRow>> watchEntriesForDate(String date) {
    return (select(muhasabahEntries)
          ..where((e) => e.date.equals(date))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .watch();
  }

  Future<List<MuhasabahEntryRow>> getEntriesForDate(String date) async {
    return (select(muhasabahEntries)
          ..where((e) => e.date.equals(date))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();
  }

  Future<List<MuhasabahEntryRow>> getEntriesForRange(
    String startDate,
    String endDate,
  ) async {
    return (select(
      muhasabahEntries,
    )..where((e) => e.date.isBetweenValues(startDate, endDate))).get();
  }

  Future<MuhasabahEntryRow?> getEntryById(int id) async {
    return (select(
      muhasabahEntries,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertEntry(MuhasabahEntriesCompanion insert) {
    return into(muhasabahEntries).insert(insert);
  }

  Future<bool> updateEntry(MuhasabahEntryRow entry) {
    return update(muhasabahEntries).replace(entry);
  }

  Future<int> deleteEntry(int id) {
    return (delete(muhasabahEntries)..where((e) => e.id.equals(id))).go();
  }
}
