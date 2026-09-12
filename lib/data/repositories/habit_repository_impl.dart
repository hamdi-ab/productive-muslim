import 'package:productive_muslim/data/local/daos/habit_dao.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl({required HabitDao habitDao})
      : _habitDao = habitDao;

  final HabitDao _habitDao;

  @override
  Stream<List<Habit>> watchActiveHabits() {
    return _habitDao.watchActiveHabits();
  }

  @override
  Future<List<Habit>> getActiveHabits() {
    return _habitDao.getActiveHabits();
  }

  @override
  Future<Habit?> getHabitById(int id) {
    return _habitDao.getHabitById(id);
  }

  @override
  Future<int> insertHabit(Habit habit) {
    return _habitDao.insertHabit(habit);
  }

  @override
  Future<bool> updateHabit(Habit habit) {
    return _habitDao.updateHabit(habit);
  }

  @override
  Future<int> deactivateHabit(int id) {
    return _habitDao.deactivateHabit(id);
  }
}