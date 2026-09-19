import 'package:productive_muslim/domain/models/habit.dart';

sealed class HabitEvent {
  const HabitEvent();

  factory HabitEvent.loaded() = HabitLoaded;
  factory HabitEvent.created(Habit habit) = HabitCreated;
  factory HabitEvent.completionToggled(int habitId) = HabitCompletionToggled;
  factory HabitEvent.deleted(int habitId) = HabitDeleted;
}

class HabitLoaded extends HabitEvent {
  const HabitLoaded();
}

class HabitCreated extends HabitEvent {
  final Habit habit;
  HabitCreated(this.habit);
}

class HabitCompletionToggled extends HabitEvent {
  final int habitId;
  HabitCompletionToggled(this.habitId);
}

class HabitDeleted extends HabitEvent {
  final int habitId;
  HabitDeleted(this.habitId);
}
