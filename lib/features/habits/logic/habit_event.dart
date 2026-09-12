import 'package:productive_muslim/domain/models/habit.dart';

sealed class HabitEvent {
  const HabitEvent();

  factory HabitEvent.loaded() = HabitLoaded;
  factory HabitEvent.created(Habit habit) = HabitCreated;
  factory HabitEvent.toggled(int habitId) = HabitToggled;
  factory HabitEvent.deleted(int habitId) = HabitDeleted;
}

class HabitLoaded extends HabitEvent {
  const HabitLoaded();
}

class HabitCreated extends HabitEvent {
  final Habit habit;
  HabitCreated(this.habit);
}

class HabitToggled extends HabitEvent {
  final int habitId;
  HabitToggled(this.habitId);
}

class HabitDeleted extends HabitEvent {
  final int habitId;
  HabitDeleted(this.habitId);
}
