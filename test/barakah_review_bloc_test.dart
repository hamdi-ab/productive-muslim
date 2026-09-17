import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_review_bloc.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_review_event.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_review_state.dart';

class MockReviewRepository extends Mock implements BarakahRepository {}

void main() {
  late MockReviewRepository repository;
  final now = DateTime(2026, 9, 17, 23, 59);
  final response = BarakahDailyResponse(
    date: '2026-09-14',
    promptId: 'good_intentions_v1',
    answer: BarakahAnswer.yes,
    sourceIds: ['good_intentions'],
    note: 'Saved',
    createdAt: 1,
    updatedAt: 1,
  );

  setUp(() => repository = MockReviewRepository());

  blocTest<BarakahReviewBloc, BarakahReviewState>(
    'loads current local week through inclusive repository range',
    build: () {
      when(() => repository.watchDailyResponsesForRange(any(), any()))
          .thenAnswer((_) => Stream.value([response]));
      return BarakahReviewBloc(repository, now: () => now);
    },
    act: (bloc) => bloc.add(const BarakahReviewWeekSelected(0)),
    expect: () => [
      isA<BarakahReviewLoading>().having(
        (s) => s.week.startDate,
        'Monday',
        '2026-09-14',
      ),
      isA<BarakahReviewLoaded>().having((s) => s.review.savedCount, 'saved', 1),
    ],
    verify: (_) => verify(
      () => repository.watchDailyResponsesForRange('2026-09-14', '2026-09-20'),
    ).called(1),
  );

  blocTest<BarakahReviewBloc, BarakahReviewState>(
    'rejects navigation into future weeks in the Bloc',
    build: () => BarakahReviewBloc(repository, now: () => now),
    act: (bloc) => bloc.add(const BarakahReviewWeekSelected(1)),
    expect: () => <BarakahReviewState>[],
    verify: (_) =>
        verifyNever(() => repository.watchDailyResponsesForRange(any(), any())),
  );

  blocTest<BarakahReviewBloc, BarakahReviewState>(
    'synchronous query failure is recoverable by retrying the same week',
    build: () {
      var attempts = 0;
      when(() => repository.watchDailyResponsesForRange(any(), any()))
          .thenAnswer((_) {
            if (attempts++ == 0) throw StateError('unavailable');
            return Stream.value([]);
          });
      return BarakahReviewBloc(repository, now: () => now);
    },
    act: (bloc) async {
      final failure = bloc.stream.firstWhere((s) => s is BarakahReviewFailure);
      bloc.add(const BarakahReviewWeekSelected(0));
      await failure;
      bloc.add(const BarakahReviewWeekSelected(0));
    },
    expect: () => [
      isA<BarakahReviewLoading>(),
      isA<BarakahReviewFailure>(),
      isA<BarakahReviewLoading>(),
      isA<BarakahReviewLoaded>().having((s) => s.review.savedCount, 'empty', 0),
    ],
  );

  test(
    'active subscription updates counts, handles stream errors and recovers',
    () async {
      final controller = StreamController<List<BarakahDailyResponse>>();
      when(() => repository.watchDailyResponsesForRange(any(), any()))
          .thenAnswer((_) => controller.stream);
      final bloc = BarakahReviewBloc(repository, now: () => now);
      addTearDown(controller.close);
      addTearDown(bloc.close);
      final loaded = bloc.stream.firstWhere((s) => s is BarakahReviewLoaded);
      bloc.add(const BarakahReviewWeekSelected(0));
      controller.add([]);
      await loaded;
      final updated = bloc.stream.firstWhere(
        (s) => s is BarakahReviewLoaded && s.review.savedCount == 1,
      );
      controller.add([response]);
      await updated;
      expect((bloc.state as BarakahReviewLoaded).review.sourceCounts, {
        'good_intentions': 1,
      });
      final failed = bloc.stream.firstWhere((s) => s is BarakahReviewFailure);
      controller.addError(StateError('stream unavailable'));
      await failed;
      final recovered = bloc.stream.firstWhere((s) => s is BarakahReviewLoaded);
      controller.add([]);
      await recovered;
      expect((bloc.state as BarakahReviewLoaded).review.sourceCounts, isEmpty);
      await bloc.close();
      expect(controller.hasListener, isFalse);
    },
  );

  test(
    'rapid navigation cancels old streams and ignores stale data and errors',
    () async {
      final cancellation = Completer<void>();
      final old = StreamController<List<BarakahDailyResponse>>(
        onCancel: () => cancellation.future,
      );
      final latest = StreamController<List<BarakahDailyResponse>>();
      when(
        () =>
            repository.watchDailyResponsesForRange('2026-09-14', '2026-09-20'),
      ).thenAnswer((_) => old.stream);
      when(
        () =>
            repository.watchDailyResponsesForRange('2026-08-31', '2026-09-06'),
      ).thenAnswer((_) => latest.stream);
      when(
        () =>
            repository.watchDailyResponsesForRange('2026-09-07', '2026-09-13'),
      ).thenAnswer((_) => const Stream.empty());
      final bloc = BarakahReviewBloc(repository, now: () => now);
      addTearDown(old.close);
      addTearDown(latest.close);
      addTearDown(bloc.close);
      final initial = bloc.stream.firstWhere((s) => s is BarakahReviewLoaded);
      bloc.add(const BarakahReviewWeekSelected(0));
      old.add([response]);
      await initial;
      final moved = bloc.stream.firstWhere(
        (s) => s.week.startDate == '2026-08-31',
      );
      bloc.add(const BarakahReviewWeekSelected(-1));
      bloc.add(const BarakahReviewWeekSelected(-1));
      await moved;
      expect(bloc.state, isA<BarakahReviewLoading>());
      final loaded = bloc.stream.firstWhere((s) => s is BarakahReviewLoaded);
      latest.add([]);
      await loaded;
      bloc.add(BarakahReviewResponsesReceived(1, [response]));
      bloc.add(const BarakahReviewFailed(1));
      final next = bloc.stream.firstWhere(
        (s) => s.week.startDate == '2026-09-07',
      );
      when(
        () =>
            repository.watchDailyResponsesForRange('2026-09-07', '2026-09-13'),
      ).thenAnswer((_) => Stream.value([]));
      bloc.add(const BarakahReviewWeekSelected(1));
      await next;
      expect(bloc.state.week.startDate, '2026-09-07');
      verify(
        () =>
            repository.watchDailyResponsesForRange('2026-09-07', '2026-09-13'),
      ).called(2);
      cancellation.complete();
    },
  );

  test('stale events cannot overwrite loaded week even after returning to same range', () async {
    when(() => repository.watchDailyResponsesForRange(any(), any()))
        .thenAnswer((_) => Stream.value([]));
    final bloc = BarakahReviewBloc(repository, now: () => now);
    addTearDown(bloc.close);
    for (final offset in [0, -1, 1]) {
      final loaded = bloc.stream.firstWhere((s) => s is BarakahReviewLoaded);
      bloc.add(BarakahReviewWeekSelected(offset));
      await loaded;
    }
    final emitted = <BarakahReviewState>[];
    final subscription = bloc.stream.listen(emitted.add);
    bloc.add(BarakahReviewResponsesReceived(1, [response]));
    bloc.add(const BarakahReviewFailed(1));
    await Future<void>.delayed(Duration.zero);
    expect(emitted, isEmpty);
    expect((bloc.state as BarakahReviewLoaded).review.savedCount, 0);
    expect(bloc.state.week.startDate, '2026-09-14');
    await subscription.cancel();
  });

  test('retry refreshes today after local calendar rollover', () async {
    var clock = DateTime(2026, 9, 20, 23, 59);
    when(() => repository.watchDailyResponsesForRange(any(), any()))
        .thenAnswer((_) => Stream.value([]));
    final bloc = BarakahReviewBloc(repository, now: () => clock);
    addTearDown(bloc.close);
    final loaded = bloc.stream.firstWhere((s) => s is BarakahReviewLoaded);
    bloc.add(const BarakahReviewWeekSelected(0));
    await loaded;
    expect(bloc.state.week.canGoNext, isFalse);
    clock = DateTime(2026, 9, 21);
    final refreshed = bloc.stream.firstWhere((s) => s is BarakahReviewLoaded);
    bloc.add(const BarakahReviewWeekSelected(0));
    await refreshed;
    expect(bloc.state.week.canGoNext, isTrue);
  });
}
