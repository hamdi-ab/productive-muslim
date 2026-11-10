import 'package:productive_muslim/domain/models/habit.dart';

abstract class HabitRepository {
  Stream<List<Habit>> watchActiveHabits();
  Future<List<Habit>> getActiveHabits();
  Future<Habit?> getHabitById(int id);
  Future<int> insertHabit(Habit habit);
  Future<bool> updateHabit(Habit habit);
  Future<int> deactivateHabit(int id);

  Future<void> toggleCompletion(int habitId, String date);
  Future<bool?> getCompletion(int habitId, String date);
  Future<Map<int, bool>> getCompletionsForDateMap(String date);
  Stream<Map<int, bool>> watchCompletionsForDate(String date);
  Future<int> getStreak(int habitId);
  Future<int> getOverallStreak();
  Stream<int> watchOverallStreak();
  Future<Map<String, int>> getCompletionsCountByDate({int days = 84});
}
