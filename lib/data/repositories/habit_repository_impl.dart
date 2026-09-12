import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/daos/habit_dao.dart';
import 'package:productive_muslim/domain/models/habit.dart' as habit_model;
import 'package:productive_muslim/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl({required HabitDao habitDao}) : _habitDao = habitDao;

  final HabitDao _habitDao;

  @override
  Stream<List<habit_model.Habit>> watchActiveHabits() {
    return _habitDao.watchActiveHabits();
  }

  @override
  Future<List<habit_model.Habit>> getActiveHabits() {
    return _habitDao.getActiveHabits();
  }

  @override
  Future<habit_model.Habit?> getHabitById(int id) {
    return _habitDao.getHabitById(id);
  }

  @override
  Future<int> insertHabit(habit_model.Habit habit) {
    return _habitDao.insertHabit(
      HabitsCompanion(
        name: Value(habit.name),
        category: Value(habit.category),
        frequency: Value(habit.frequency),
        targetDays: Value(habit.targetDays),
        reminderEnabled: Value(habit.reminderEnabled),
        reminderTime: Value(habit.reminderTime),
        createdAt: Value(habit.createdAt),
      ),
    );
  }

  @override
  Future<bool> updateHabit(habit_model.Habit habit) {
    return _habitDao.updateHabit(habit);
  }

  @override
  Future<int> deactivateHabit(int id) {
    return _habitDao.deactivateHabit(id);
  }
}
