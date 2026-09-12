sealed class HabitState {
  const HabitState();

  const factory HabitState.initial() = Initial;
  const factory HabitState.loading() = Loading;
  const factory HabitState.loaded(List<Habit> habits) = Loaded;
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
  const Loaded(this.habits);
}

class Error extends HabitState {
  final String message;
  const Error(this.message);
}
