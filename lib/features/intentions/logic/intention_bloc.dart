import 'package:bloc/bloc.dart';

import 'package:productive_muslim/domain/repositories/intention_repository.dart';
import 'package:productive_muslim/features/intentions/logic/intention_event.dart';
import 'package:productive_muslim/features/intentions/logic/intention_state.dart';

class IntentionBloc extends Bloc<IntentionEvent, IntentionState> {
  final IntentionRepository _repository;

  IntentionBloc(this._repository) : super(const IntentionInitial()) {
    on<IntentionEntriesLoaded>(_onLoaded);
    on<IntentionCreated>(_onCreated);
    on<IntentionToggled>(_onToggled);
    on<IntentionDeleted>(_onDeleted);
    on<IntentionReflectionSaved>(_onReflectionSaved);
  }

  Future<void> _onLoaded(
    IntentionEntriesLoaded event,
    Emitter<IntentionState> emit,
  ) async {
    emit(const IntentionLoading());
    try {
      final entries = await _repository.getEntriesForDate(event.date);
      emit(IntentionLoaded(entries));
    } catch (e) {
      emit(IntentionError(e.toString()));
    }
  }

  Future<void> _onCreated(
    IntentionCreated event,
    Emitter<IntentionState> emit,
  ) async {
    try {
      await _repository.insertEntry(event.entry);
      final entries = await _repository.getEntriesForDate(event.entry.date);
      emit(IntentionLoaded(entries));
    } catch (e) {
      emit(IntentionError(e.toString()));
    }
  }

  Future<void> _onToggled(
    IntentionToggled event,
    Emitter<IntentionState> emit,
  ) async {
    try {
      await _repository.updateEntry(
        event.entry.copyWith(completed: !event.entry.completed),
      );
      final entries = await _repository.getEntriesForDate(event.entry.date);
      emit(IntentionLoaded(entries));
    } catch (e) {
      emit(IntentionError(e.toString()));
    }
  }

  Future<void> _onDeleted(
    IntentionDeleted event,
    Emitter<IntentionState> emit,
  ) async {
    try {
      await _repository.deleteEntry(event.entryId);
      final current = state;
      if (current is IntentionLoaded) {
        final updated = current.entries
            .where((e) => e.id != event.entryId)
            .toList();
        emit(IntentionLoaded(updated));
      }
    } catch (e) {
      emit(IntentionError(e.toString()));
    }
  }

  Future<void> _onReflectionSaved(
    IntentionReflectionSaved event,
    Emitter<IntentionState> emit,
  ) async {
    try {
      final entry = await _repository.getEntryById(event.entryId);
      if (entry != null) {
        await _repository.updateEntry(
          entry.copyWith(reflection: event.reflection),
        );
      }
      final current = state;
      if (current is IntentionLoaded) {
        emit(IntentionLoaded(current.entries));
      }
    } catch (e) {
      emit(IntentionError(e.toString()));
    }
  }
}
