import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/daos/habit_dao.dart';
import 'package:productive_muslim/domain/models/habit.dart' as habit_model;
import 'package:productive_muslim/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl({required HabitDao habitDao}) : _habitDao = habitDao;

  final HabitDao _habitDao;

  habit_model.Habit _toDomain(Habit row) {
    return habit_model.Habit(
      id: row.id,
      name: row.name,
      category: row.category,
      frequency: row.frequency,
      targetDays: row.targetDays,
      reminderEnabled: row.reminderEnabled == 1,
      reminderTime: row.reminderTime,
      active: row.active == 1,
      createdAt: row.createdAt,
    );
  }

  Habit _toDrift(habit_model.Habit habit) {
    return Habit(
      id: habit.id,
      name: habit.name,
      category: habit.category,
      frequency: habit.frequency,
      targetDays: habit.targetDays,
      reminderEnabled: habit.reminderEnabled ? 1 : 0,
      reminderTime: habit.reminderTime,
      active: habit.active ? 1 : 0,
      createdAt: habit.createdAt,
    );
  }

  @override
  Stream<List<habit_model.Habit>> watchActiveHabits() {
    return _habitDao.watchActiveHabits().map(
      (habits) => habits.map(_toDomain).toList(),
    );
  }

  @override
  Future<List<habit_model.Habit>> getActiveHabits() async {
    final habits = await _habitDao.getActiveHabits();
    return habits.map(_toDomain).toList();
  }

  @override
  Future<habit_model.Habit?> getHabitById(int id) async {
    final habit = await _habitDao.getHabitById(id);
    return habit == null ? null : _toDomain(habit);
  }

  @override
  Future<int> insertHabit(habit_model.Habit habit) {
    return _habitDao.insertHabit(
      HabitsCompanion.insert(
        name: habit.name,
        category: habit.category,
        frequency: Value(habit.frequency),
        targetDays: Value(habit.targetDays),
        reminderEnabled: Value(habit.reminderEnabled ? 1 : 0),
        reminderTime: Value(habit.reminderTime),
        active: Value(habit.active ? 1 : 0),
        createdAt: Value(habit.createdAt),
      ),
    );
  }

  @override
  Future<bool> updateHabit(habit_model.Habit habit) {
    return _habitDao.updateHabit(_toDrift(habit));
  }

  @override
  Future<int> deactivateHabit(int id) {
    return _habitDao.deactivateHabit(id);
  }
}
