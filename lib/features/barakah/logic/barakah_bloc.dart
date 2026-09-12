import 'package:bloc/bloc.dart';

import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_event.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_state.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';

class BarakahBloc extends Bloc<BarakahEvent, BarakahState> {
  final BarakahRepository _repository;

  BarakahBloc(this._repository) : super(const Initial()) {
    on<BarakahLoaded>(_onLoaded);
    on<BarakahLogged>(_onLogged);
    on<BarakahSkipped>(_onSkipped);
    on<BarakahDeleted>(_onDeleted);
  }

  Future<void> _onLoaded(
    BarakahLoaded event,
    Emitter<BarakahState> emit,
  ) async {
    emit(const Loading());
    try {
      final entries = await _repository.getEntriesForDate(event.date);
      emit(Loaded(entries));
    } catch (e) {
      emit(Error(e.toString()));
    }
  }

  Future<void> _onLogged(
    BarakahLogged event,
    Emitter<BarakahState> emit,
  ) async {
    try {
      await _repository.insertEntry(event.entry);
      final entries = await _repository.getEntriesForDate(event.entry.date);
      emit(Loaded(entries));
    } catch (e) {
      emit(Error(e.toString()));
    }
  }

  Future<void> _onSkipped(
    BarakahSkipped event,
    Emitter<BarakahState> emit,
  ) async {
    try {
      final entry = BarakahEntry(
        id: 0,
        date: event.date,
        sourceIds: const [],
        skipped: true,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _repository.insertEntry(entry);
      final entries = await _repository.getEntriesForDate(event.date);
      emit(Loaded(entries));
    } catch (e) {
      emit(Error(e.toString()));
    }
  }

  Future<void> _onDeleted(
    BarakahDeleted event,
    Emitter<BarakahState> emit,
  ) async {
    try {
      await _repository.deleteEntry(event.entryId);
      final current = state;
      if (current is Loaded) {
        final updated = current.entries
            .where((e) => e.id != event.entryId)
            .toList();
        emit(Loaded(updated));
      }
    } catch (e) {
      emit(Error(e.toString()));
    }
  }
}
