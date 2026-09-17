import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_prompt.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_bloc.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_event.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockBarakahRepository extends Mock implements BarakahRepository {}

void main() {
  final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final prompt = BarakahPrompt.forDate(date);
  final saved = BarakahDailyResponse(
    date: date,
    promptId: prompt.id,
    answer: BarakahAnswer.somewhat,
    sourceIds: prompt.sourceIds,
    note: 'A quiet moment',
    createdAt: 1,
    updatedAt: 2,
  );

  setUpAll(() => registerFallbackValue(saved));

  Future<void> pumpScreen(
    WidgetTester tester,
    BarakahRepository repository, {
    Locale locale = const Locale('en'),
    Size size = const Size(800, 1600),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RepositoryProvider<BarakahRepository>.value(
        value: repository,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const BarakahScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  MockBarakahRepository repositoryWith(BarakahDailyResponse? response) {
    final repository = MockBarakahRepository();
    when(() => repository.getEntriesForDate(any())).thenAnswer((_) async => []);
    when(() => repository.watchDailyResponse(any()))
        .thenAnswer((_) => Stream.value(response));
    when(() => repository.saveDailyResponse(any())).thenAnswer((_) async {});
    return repository;
  }

  test('daily Bloc persists edits through the repository contract', () async {
    final repository = repositoryWith(saved);
    final bloc = BarakahBloc(repository);
    addTearDown(bloc.close);
    final restored = bloc.stream.firstWhere(
      (state) => state.daily?.saved == true,
    );
    bloc.add(BarakahDailyResponseLoaded(date));
    await restored;
    expect(bloc.state.daily!.response, same(saved));
    final selected = bloc.stream.firstWhere(
      (state) => state.daily?.answer == BarakahAnswer.no,
    );
    bloc.add(BarakahAnswerSelected(BarakahAnswer.no));
    await selected;
    final persisted = bloc.stream.firstWhere(
      (state) => state.daily?.saved == true,
    );
    bloc.add(const BarakahDailyResponseSaved());
    await persisted;
    final response =
        verify(() => repository.saveDailyResponse(captureAny())).captured.single
            as BarakahDailyResponse;
    expect(response.date, date);
    expect(response.createdAt, saved.createdAt);
    expect(response.answer, BarakahAnswer.no);
    expect(response.sourceIds, isEmpty);
  });

  testWidgets('restores the saved response and edits the same date', (
    tester,
  ) async {
    final repository = repositoryWith(saved);
    await pumpScreen(tester, repository);
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const Key('daily-answer-somewhat')))
          .selected,
      isTrue,
    );
    expect(find.text('A quiet moment'), findsOneWidget);
    expect(find.byKey(Key('daily-prompt-${prompt.id}')), findsOneWidget);
    await tester.tap(find.byKey(const Key('daily-answer-no')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(Key('daily-source-${prompt.sourceIds.first}')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('daily-save')));
    await tester.pumpAndSettle();
    final response =
        verify(() => repository.saveDailyResponse(captureAny())).captured.single
            as BarakahDailyResponse;
    expect(response.date, date);
    expect(response.promptId, prompt.id);
    expect(response.createdAt, 1);
    expect(response.answer, BarakahAnswer.no);
    expect(response.sourceIds, isEmpty);
    expect(response.note, saved.note);
    expect(
      find.text('Response saved. You can edit it anytime.'),
      findsOneWidget,
    );
  });
}
