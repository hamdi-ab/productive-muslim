import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/database/tables/habit_completions.dart';

part 'habit_completions_dao.g.dart';

@DriftAccessor(tables: [HabitCompletions])
class HabitCompletionsDao extends DatabaseAccessor<AppDatabase>
    with _$HabitCompletionsDaoMixin {
  HabitCompletionsDao(super.db);

  Future<void> logCompletion(int habitId, String date, {int completed = 1}) {
    return into(habitCompletions).insertOnConflictUpdate(
      HabitCompletionsCompanion.insert(
        habitId: habitId,
        date: date,
        completed: Value(completed),
      ),
    );
  }

  Future<void> removeCompletion(int habitId, String date) {
    return (delete(
      habitCompletions,
    )..where((c) => c.habitId.equals(habitId) & c.date.equals(date))).go();
  }

  Future<bool?> getCompletion(int habitId, String date) async {
    final row =
        await (select(habitCompletions)
              ..where((c) => c.habitId.equals(habitId) & c.date.equals(date)))
            .getSingleOrNull();
    return row?.completed == 1;
  }

  Future<List<HabitCompletion>> getCompletionsForDate(String date) {
    return (select(habitCompletions)..where((c) => c.date.equals(date))).get();
  }

  Stream<List<HabitCompletion>> watchCompletionsForDate(String date) {
    return (select(
      habitCompletions,
    )..where((c) => c.date.equals(date))).watch();
  }

  Future<int> getStreak(int habitId) async {
    final rows =
        await (select(habitCompletions)
              ..where((c) => c.habitId.equals(habitId) & c.completed.equals(1))
              ..orderBy([(c) => OrderingTerm.desc(c.date)]))
            .get();

    if (rows.isEmpty) return 0;

    int streak = 0;
    DateTime? expectedDate;

    for (final row in rows) {
      final rowDate = DateTime.parse(row.date);
      if (expectedDate == null) {
        final today = DateTime.now();
        final todayStr =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        final yesterday = today.subtract(const Duration(days: 1));
        final yesterdayStr =
            '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

        if (row.date != todayStr && row.date != yesterdayStr) break;
        expectedDate = rowDate;
        streak = 1;
      } else {
        final diff = expectedDate.difference(rowDate).inDays;
        if (diff == 1) {
          streak++;
          expectedDate = rowDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  Future<Map<int, bool>> getCompletionsForDateMap(String date) async {
    final rows = await getCompletionsForDate(date);
    return {for (final row in rows) row.habitId: row.completed == 1};
  }
}
