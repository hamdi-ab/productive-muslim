import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/mappers/domain_mapper.dart';
import 'package:productive_muslim/domain/models/habit.dart' as habit_model;

class HabitMapper implements DomainMapper<habit_model.Habit, Habit> {
  @override
  habit_model.Habit toDomain(Habit row) {
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

  @override
  Habit toRow(habit_model.Habit habit) {
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
}
