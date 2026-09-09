abstract class HabitRepository {
  Stream<List<Habit>> watchActiveHabits();
  Future<List<Habit>> getActiveHabits();
  Future<Habit?> getHabitById(int id);
  Future<int> insertHabit(Habit habit);
  Future<bool> updateHabit(Habit habit);
  Future<int> deactivateHabit(int id);
}