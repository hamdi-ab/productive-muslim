import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/features/habits/logic/habit_event.dart';
import 'package:productive_muslim/features/habits/logic/habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitRepository _repository;

  HabitBloc(this._repository) : super(const Initial()) {
    on<HabitLoaded>(_onLoaded);
    on<HabitCreated>(_onCreated);
    on<HabitToggled>(_onToggled);
    on<HabitDeleted>(_onDeleted);
  }

  Future<void> _onLoaded(HabitLoaded event, Emitter<HabitState> emit) async {
    emit(const Loading());
    try {
      final habits = await _repository.getActiveHabits();
      emit(Loaded(habits));
    } catch (e) {
      emit(Error(e.toString()));
    }
  }

  Future<void> _onCreated(HabitCreated event, Emitter<HabitState> emit) async {
    try {
      await _repository.insertHabit(event.habit);
      final habits = await _repository.getActiveHabits();
      emit(Loaded(habits));
    } catch (e) {
      emit(Error(e.toString()));
    }
  }

  Future<void> _onToggled(HabitToggled event, Emitter<HabitState> emit) async {
    // Toggle is handled at the completion level; this is a no-op for now
    final current = state;
    if (current is Loaded) {
      emit(Loaded(current.habits));
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
        emit(Loaded(updated));
      }
    } catch (e) {
      emit(Error(e.toString()));
    }
  }
}
