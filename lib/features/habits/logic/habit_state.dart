import 'package:productive_muslim/domain/models/habit.dart';

sealed class HabitState {
  const HabitState();

  const factory HabitState.initial() = Initial;
  const factory HabitState.loading() = Loading;
  const factory HabitState.loaded({
    required List<Habit> habits,
    required Map<int, bool> completions,
    required Map<int, int> streaks,
  }) = Loaded;
  const factory HabitState.error(String message) = Error;
}

class Initial extends HabitState {
  const Initial();
}

class Loading extends HabitState {
  const Loading();
}

class Loaded extends HabitState {
  final List<Habit> habits;
  final Map<int, bool> completions;
  final Map<int, int> streaks;
  const Loaded({
    required this.habits,
    required this.completions,
    required this.streaks,
  });
}

class Error extends HabitState {
  final String message;
  const Error(this.message);
}
