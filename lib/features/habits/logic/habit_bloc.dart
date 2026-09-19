import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/features/habits/logic/habit_event.dart';
import 'package:productive_muslim/features/habits/logic/habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitRepository _repository;

  HabitBloc(this._repository) : super(const Initial()) {
    on<HabitLoaded>(_onLoaded);
    on<HabitCreated>(_onCreated);
    on<HabitCompletionToggled>(_onCompletionToggled);
    on<HabitDeleted>(_onDeleted);
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _onLoaded(HabitLoaded event, Emitter<HabitState> emit) async {
    emit(const Loading());
    try {
      final habits = await _repository.getActiveHabits();
      final completions = await _repository.getCompletionsForDateMap(
        _todayString(),
      );
      final streaks = <int, int>{};
      for (final habit in habits) {
        streaks[habit.id] = await _repository.getStreak(habit.id);
      }
      emit(Loaded(habits: habits, completions: completions, streaks: streaks));
    } catch (e) {
      emit(Error(e.toString()));
    }
  }

  Future<void> _onCreated(HabitCreated event, Emitter<HabitState> emit) async {
    try {
      await _repository.insertHabit(event.habit);
      final habits = await _repository.getActiveHabits();
      final completions = await _repository.getCompletionsForDateMap(
        _todayString(),
      );
      final streaks = <int, int>{};
      for (final habit in habits) {
        streaks[habit.id] = await _repository.getStreak(habit.id);
      }
      emit(Loaded(habits: habits, completions: completions, streaks: streaks));
    } catch (e) {
      emit(Error(e.toString()));
    }
  }

  Future<void> _onCompletionToggled(
    HabitCompletionToggled event,
    Emitter<HabitState> emit,
  ) async {
    try {
      await _repository.toggleCompletion(event.habitId, _todayString());
      final current = state;
      if (current is Loaded) {
        final newCompletions = Map<int, bool>.from(current.completions);
        newCompletions[event.habitId] =
            !(newCompletions[event.habitId] ?? false);
        final streak = await _repository.getStreak(event.habitId);
        final newStreaks = Map<int, int>.from(current.streaks);
        newStreaks[event.habitId] = streak;
        emit(
          Loaded(
            habits: current.habits,
            completions: newCompletions,
            streaks: newStreaks,
          ),
        );
      }
    } catch (e) {
      emit(Error(e.toString()));
    }
  }

  Future<void> _onDeleted(HabitDeleted event, Emitter<HabitState> emit) async {
    try {
      await _repository.deactivateHabit(event.habitId);
      final current = state;
      if (current is Loaded) {
        final updated = current.habits
            .where((h) => h.id != event.habitId)
            .toList();
        final newCompletions = Map<int, bool>.from(current.completions)
          ..remove(event.habitId);
        final newStreaks = Map<int, int>.from(current.streaks)
          ..remove(event.habitId);
        emit(
          Loaded(
            habits: updated,
            completions: newCompletions,
            streaks: newStreaks,
          ),
        );
      }
    } catch (e) {
      emit(Error(e.toString()));
    }
  }
}
