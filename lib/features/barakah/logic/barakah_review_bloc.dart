import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_weekly_review.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_review_event.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_review_state.dart';

class BarakahReviewBloc extends Bloc<BarakahReviewEvent, BarakahReviewState> {
  BarakahReviewBloc(BarakahRepository repository, {DateTime Function()? now})
    : this._(repository, now ?? DateTime.now);

  BarakahReviewBloc._(this._repository, this._now)
    : super(BarakahReviewState.loading(_currentWeek(_now))) {
    on<BarakahReviewWeekSelected>(_onWeekSelected);
    on<BarakahReviewResponsesReceived>((event, emit) {
      if (event.generation != _generation) return;
      emit(
        BarakahReviewState.loaded(
          state.week,
          BarakahWeeklyReview(state.week, event.responses),
        ),
      );
    });
    on<BarakahReviewFailed>((event, emit) {
      if (event.generation != _generation) return;
      emit(BarakahReviewState.failure(state.week));
    });
  }

  final BarakahRepository _repository;
  final DateTime Function() _now;
  StreamSubscription<List<BarakahDailyResponse>>? _subscription;
  int _generation = 0;

  static BarakahReviewWeek _currentWeek(DateTime Function() now) {
    final today = now();
    return BarakahReviewWeek.forDate(today, now: today);
  }

  Future<void> _onWeekSelected(
    BarakahReviewWeekSelected event,
    Emitter<BarakahReviewState> emit,
  ) async {
    final week = BarakahReviewWeek.forDate(
      state.week.day(event.offset * 7),
      now: _now(),
    );
    if (week.start.isAfter(week.today)) return;
    final generation = ++_generation;
    emit(BarakahReviewState.loading(week));
    try {
      unawaited(_subscription?.cancel().catchError((Object _) {}));
      _subscription = _repository
          .watchDailyResponsesForRange(week.startDate, week.endDate)
          .listen(
            (responses) {
              if (!isClosed) {
                add(BarakahReviewResponsesReceived(generation, responses));
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!isClosed) add(BarakahReviewFailed(generation));
            },
          );
    } catch (_) {
      if (!isClosed && generation == _generation) {
        emit(BarakahReviewState.failure(week));
      }
    }
  }

  @override
  Future<void> close() async {
    ++_generation;
    await _subscription?.cancel();
    return super.close();
  }
}
