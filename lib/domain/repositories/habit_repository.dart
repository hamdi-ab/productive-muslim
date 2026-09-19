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
  Future<int> getStreak(int habitId);
}
