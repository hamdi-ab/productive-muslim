import 'package:productive_muslim/domain/models/habit.dart';

sealed class HabitState {
  const HabitState();

  const factory HabitState.initial() = HabitInitial;
  const factory HabitState.loading() = HabitLoading;
  const factory HabitState.loaded(List<Habit> habits) = HabitLoaded;
  const factory HabitState.error(String message) = HabitError;
}

class HabitInitial extends HabitState {
  const HabitInitial();
}

class HabitLoading extends HabitState {
  const HabitLoading();
}

class HabitLoaded extends HabitState {
  final List<Habit> habits;
  const HabitLoaded(this.habits);
}

class HabitError extends HabitState {
  final String message;
  const HabitError(this.message);
}