import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/database/tables/barakah_daily_responses.dart';
import 'package:productive_muslim/data/local/database/tables/barakah_prompts.dart';
import 'package:productive_muslim/data/local/database/tables/barakah_entries.dart';

part 'barakah_dao.g.dart';

@DriftAccessor(tables: [BarakahPrompts, BarakahEntries, BarakahDailyResponses])
class BarakahDao extends DatabaseAccessor<AppDatabase> with _$BarakahDaoMixin {
  BarakahDao(super.db);

  Stream<BarakahDailyResponseRow?> watchDailyResponse(String date) {
    return (select(
      barakahDailyResponses,
    )..where((r) => r.date.equals(date))).watchSingleOrNull();
  }

  Future<void> saveDailyResponse(BarakahDailyResponsesCompanion response) {
    return transaction(() async {
      final existing = await (select(
        barakahDailyResponses,
      )..where((r) => r.date.equals(response.date.value))).getSingleOrNull();
      if (existing != null && existing.promptId != response.promptId.value) {
        throw ArgumentError.value(
          response.promptId.value,
          'promptId',
          'The initial prompt cannot be changed',
        );
      }
      await into(barakahDailyResponses).insert(
        response,
        onConflict: DoUpdate(
          (_) => BarakahDailyResponsesCompanion(
            answer: response.answer,
            sourceIds: response.sourceIds,
            note: response.note,
            updatedAt: response.updatedAt,
          ),
        ),
      );
    });
  }

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
