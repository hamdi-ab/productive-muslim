import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/daos/habit_completions_dao.dart';
import 'package:productive_muslim/data/local/daos/habit_dao.dart';
import 'package:productive_muslim/data/mappers/habit_mapper.dart';
import 'package:productive_muslim/domain/models/habit.dart' as habit_model;
import 'package:productive_muslim/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl({
    required HabitDao habitDao,
    required HabitCompletionsDao habitCompletionsDao,
  }) : _habitDao = habitDao,
       _completionsDao = habitCompletionsDao;

  final HabitDao _habitDao;
  final HabitCompletionsDao _completionsDao;
  final _mapper = HabitMapper();

  @override
  Stream<List<habit_model.Habit>> watchActiveHabits() {
    return _habitDao.watchActiveHabits().map(
      (rows) => rows.map(_mapper.toDomain).toList(),
    );
  }

  @override
  Future<List<habit_model.Habit>> getActiveHabits() async {
    final rows = await _habitDao.getActiveHabits();
    return rows.map(_mapper.toDomain).toList();
  }

  @override
  Future<habit_model.Habit?> getHabitById(int id) async {
    final row = await _habitDao.getHabitById(id);
    return row == null ? null : _mapper.toDomain(row);
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
    return _habitDao.updateHabit(_mapper.toRow(habit));
  }

  @override
  Future<int> deactivateHabit(int id) {
    return _habitDao.deactivateHabit(id);
  }

  @override
  Future<void> toggleCompletion(int habitId, String date) async {
    final current = await _completionsDao.getCompletion(habitId, date);
    if (current == true) {
      await _completionsDao.removeCompletion(habitId, date);
    } else {
      await _completionsDao.logCompletion(habitId, date);
    }
  }

  @override
  Future<bool?> getCompletion(int habitId, String date) {
    return _completionsDao.getCompletion(habitId, date);
  }

  @override
  Future<Map<int, bool>> getCompletionsForDateMap(String date) {
    return _completionsDao.getCompletionsForDateMap(date);
  }

  @override
  Stream<Map<int, bool>> watchCompletionsForDate(String date) {
    return _completionsDao
        .watchCompletionsForDate(date)
        .map(
          (rows) => {for (final row in rows) row.habitId: row.completed == 1},
        );
  }

  @override
  Future<int> getStreak(int habitId) {
    return _completionsDao.getStreak(habitId);
  }

  @override
  Future<int> getOverallStreak() {
    return _completionsDao.getOverallStreak();
  }

  @override
  Stream<int> watchOverallStreak() {
    return _completionsDao.watchOverallStreak();
  }

  @override
  Future<Map<String, int>> getCompletionsCountByDate({int days = 84}) {
    return _completionsDao.getCompletionsCountByDate(days: days);
  }
}
