import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/database/tables/habits.dart';

part 'habit_dao.g.dart';

@DriftAccessor(tables: [Habits])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.db);

  Stream<List<Habit>> watchActiveHabits() {
    return (select(habits)
          ..where((h) => h.active.equals(1))
          ..orderBy([(h) => OrderingTerm.asc(h.name)]))
        .watch();
  }

  Future<List<Habit>> getActiveHabits() {
    return (select(habits)..where((h) => h.active.equals(1))).get();
  }

  Future<Habit?> getHabitById(int id) {
    return (select(habits)..where((h) => h.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertHabit(HabitsCompanion insert) {
    return into(habits).insert(insert);
  }

  Future<bool> updateHabit(Habit habit) {
    return update(habits).replace(habit);
  }

  Future<int> deactivateHabit(int id) {
    return (update(habits)..where((h) => h.id.equals(id))).write(
      const HabitsCompanion(active: Value(0)),
    );
  }
}
