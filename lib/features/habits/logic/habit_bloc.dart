import 'package:bloc/bloc.dart';

import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/features/habits/logic/habit_event.dart';
import 'package:productive_muslim/features/habits/logic/habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitRepository _repository;

  HabitBloc(this._repository) : super(const HabitInitial()) {
    on<HabitEntriesLoaded>(_onLoaded);
    on<HabitCreated>(_onCreated);
    on<HabitToggled>(_onToggled);
    on<HabitDeleted>(_onDeleted);
  }

  Future<void> _onLoaded(HabitEntriesLoaded event, Emitter<HabitState> emit) async {
    emit(const HabitLoading());
    try {
      final habits = await _repository.getActiveHabits();
      emit(HabitLoaded(habits));
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onCreated(HabitCreated event, Emitter<HabitState> emit) async {
    try {
      await _repository.insertHabit(event.habit);
      final habits = await _repository.getActiveHabits();
      emit(HabitLoaded(habits));
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onToggled(HabitToggled event, Emitter<HabitState> emit) async {
    final current = state;
    if (current is HabitLoaded) {
      emit(HabitLoaded(current.habits));
    }
  }

  Future<void> _onDeleted(HabitDeleted event, Emitter<HabitState> emit) async {
    try {
      await _repository.deactivateHabit(event.habitId);
      final current = state;
      if (current is HabitLoaded) {
        final updated = current.habits.where((h) => h.id != event.habitId).toList();
        emit(HabitLoaded(updated));
      }
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }
}