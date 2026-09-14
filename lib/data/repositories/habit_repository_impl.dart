import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/daos/habit_dao.dart';
import 'package:productive_muslim/data/mappers/habit_mapper.dart';
import 'package:productive_muslim/domain/models/habit.dart' as habit_model;
import 'package:productive_muslim/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl({required HabitDao habitDao}) : _habitDao = habitDao;

  final HabitDao _habitDao;
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
}
