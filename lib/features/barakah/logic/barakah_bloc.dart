import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_prompt.dart';

import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_event.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_state.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';

class BarakahBloc extends Bloc<BarakahEvent, BarakahState> {
  final BarakahRepository _repository;
  StreamSubscription<BarakahDailyResponse?>? _dailySubscription;
  int _dailyGeneration = 0;

  BarakahBloc(this._repository) : super(const Initial()) {
    on<BarakahLoaded>(_onLoaded);
    on<BarakahLogged>(_onLogged);
    on<BarakahSkipped>(_onSkipped);
    on<BarakahDeleted>(_onDeleted);
    on<BarakahDailyResponseLoaded>(_onDailyLoaded);
    on<BarakahDailyResponseReceived>(_onDailyReceived);
    on<BarakahDailyResponseFailed>((event, emit) {
      final daily = state.daily;
      if (daily == null ||
          event.generation != _dailyGeneration ||
          event.date != daily.date) {
        return;
      }
      emit(state.withDaily(daily.copyWith(loading: false, failure: true)));
    });
    on<BarakahAnswerSelected>((event, emit) {
      final daily = state.daily;
      if (daily == null || daily.loading || daily.saving) return;
      final allowsSources =
          event.answer == BarakahAnswer.yes ||
          event.answer == BarakahAnswer.somewhat;
      emit(
        state.withDaily(
          daily.copyWith(
            answer: event.answer,
            sourceIds: allowsSources ? daily.sourceIds : [],
            dirty: true,
            saved: false,
            failure: false,
          ),
        ),
      );
    });
    on<BarakahSourceToggled>((event, emit) {
      final daily = state.daily;
      if (daily == null ||
          daily.loading ||
          daily.saving ||
          !daily.allowsSources ||
          !daily.prompt.sourceIds.contains(event.sourceId)) {
        return;
      }
      final sources = [...daily.sourceIds];
      if (!sources.remove(event.sourceId)) {
        sources.add(event.sourceId);
      }
      emit(
        state.withDaily(
          daily.copyWith(
            sourceIds: sources,
            dirty: true,
            saved: false,
            failure: false,
          ),
        ),
      );
    });
    on<BarakahNoteChanged>((event, emit) {
      final daily = state.daily;
      if (daily == null || daily.loading || daily.saving) return;
      emit(
        state.withDaily(
          daily.copyWith(
            note: event.note.characters.take(280).toString(),
            dirty: true,
            saved: false,
            failure: false,
          ),
        ),
      );
    });
    on<BarakahDailyResponseSaved>(_onDailySaved);
  }

  Future<void> _onDailyLoaded(
    BarakahDailyResponseLoaded event,
    Emitter<BarakahState> emit,
  ) async {
    final generation = ++_dailyGeneration;
    emit(
      state.withDaily(
        BarakahDailyDraft(
          date: event.date,
          prompt: BarakahPrompt.forDate(event.date),
          loading: true,
        ),
      ),
    );
    await _dailySubscription?.cancel();
    if (isClosed || generation != _dailyGeneration) return;
    try {
      _dailySubscription = _repository
          .watchDailyResponse(event.date)
          .listen(
            (response) {
              if (!isClosed) {
                add(
                  BarakahDailyResponseReceived(
                    event.date,
                    generation,
                    response,
                  ),
                );
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!isClosed) {
                add(BarakahDailyResponseFailed(event.date, generation));
              }
            },
          );
    } catch (_) {
      emit(
        state.withDaily(state.daily!.copyWith(loading: false, failure: true)),
      );
    }
  }

  void _onDailyReceived(
    BarakahDailyResponseReceived event,
    Emitter<BarakahState> emit,
  ) {
    final daily = state.daily;
    if (daily == null ||
        event.generation != _dailyGeneration ||
        event.date != daily.date ||
        daily.saving) {
      return;
    }
    final response = event.response;
    if (daily.dirty) {
      emit(state.withDaily(daily.copyWith(response: response)));
      return;
    }
    final prompt = response == null
        ? BarakahPrompt.forDate(event.date)
        : BarakahPrompt.all.firstWhere(
            (prompt) => prompt.id == response.promptId,
            orElse: () => BarakahPrompt.forDate(event.date),
          );
    emit(
      state.withDaily(
        BarakahDailyDraft(
          date: event.date,
          prompt: prompt,
          response: response,
          answer: response?.answer,
          sourceIds: response?.sourceIds ?? [],
          note: response?.note ?? '',
          saved: response != null,
        ),
      ),
    );
  }

  Future<void> _onDailySaved(
    BarakahDailyResponseSaved event,
    Emitter<BarakahState> emit,
  ) async {
    final daily = state.daily;
    if (daily == null ||
        daily.loading ||
        daily.saving ||
        daily.answer == null) {
      return;
    }
    final generation = _dailyGeneration;
    final now = DateTime.now().millisecondsSinceEpoch;
    final response = BarakahDailyResponse(
      date: daily.date,
      promptId: daily.prompt.id,
      answer: daily.answer!,
      sourceIds: daily.allowsSources ? daily.sourceIds : [],
      note: daily.note.isEmpty ? null : daily.note,
      createdAt: daily.response?.createdAt ?? now,
      updatedAt: now,
    );
    emit(
      state.withDaily(
        daily.copyWith(saving: true, saved: false, failure: false),
      ),
    );
    try {
      await _repository.saveDailyResponse(response);
      if (generation != _dailyGeneration) return;
      emit(
        state.withDaily(
          daily.copyWith(
            response: response,
            saving: false,
            saved: true,
            dirty: false,
            failure: false,
          ),
        ),
      );
    } catch (_) {
      if (generation != _dailyGeneration) return;
      emit(
        state.withDaily(
          daily.copyWith(saving: false, saved: false, failure: true),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    ++_dailyGeneration;
    await _dailySubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoaded(
    BarakahLoaded event,
    Emitter<BarakahState> emit,
  ) async {
    emit(Loading(daily: state.daily));
    try {
      final entries = await _repository.getEntriesForDate(event.date);
      emit(Loaded(entries, daily: state.daily));
    } catch (e) {
      emit(Error(e.toString(), daily: state.daily));
    }
  }

  Future<void> _onLogged(
    BarakahLogged event,
    Emitter<BarakahState> emit,
  ) async {
    try {
      await _repository.insertEntry(event.entry);
      final entries = await _repository.getEntriesForDate(event.entry.date);
      emit(Loaded(entries, daily: state.daily));
    } catch (e) {
      emit(Error(e.toString(), daily: state.daily));
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
      emit(Loaded(entries, daily: state.daily));
    } catch (e) {
      emit(Error(e.toString(), daily: state.daily));
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
        emit(Loaded(updated, daily: state.daily));
      }
    } catch (e) {
      emit(Error(e.toString(), daily: state.daily));
    }
  }
}
