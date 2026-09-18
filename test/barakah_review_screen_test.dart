import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/theme/app_theme.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_review_screen.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockWeeklyRepository extends Mock implements BarakahRepository {}

void main() {
  late MockWeeklyRepository repository;
  final now = DateTime(2026, 9, 17, 12);

  BarakahDailyResponse response(
    String date,
    BarakahAnswer answer, {
    String promptId = 'quran_v1',
    List<String> sources = const [],
    String? note,
  }) => BarakahDailyResponse(
    date: date,
    promptId: promptId,
    answer: answer,
    sourceIds: sources,
    note: note,
    createdAt: 1,
    updatedAt: 2,
  );

  setUp(() {
    repository = MockWeeklyRepository();
    when(() => repository.watchDailyResponsesForRange(any(), any()))
        .thenAnswer((_) => Stream.value([]));
  });

  Future<void> pumpReview(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Widget? home,
    double textScale = 1,
    bool dark = false,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RepositoryProvider<BarakahRepository>.value(
        value: repository,
        child: MaterialApp(
          locale: locale,
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: home ?? BarakahReviewScreen(now: () => now),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> reveal(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        240,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('review-list')),
              matching: find.byType(Scrollable),
            )
            .first,
      );

  testWidgets(
    'current week has zero counts, empty guidance and no future navigation',
    (tester) async {
      await pumpReview(tester);
      await tester.pumpAndSettle();
      expect(find.text('Sep 14, 2026 – Sep 20, 2026'), findsOneWidget);
      expect(find.text('Yes: 0'), findsOneWidget);
      expect(find.text('No: 0'), findsOneWidget);
      expect(find.text('Skipped: 0'), findsOneWidget);
      expect(find.textContaining('No daily responses saved'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('review-next')))
            .onPressed,
        isNull,
      );
      await reveal(tester, find.byKey(const Key('review-day-2026-09-20')));
      expect(find.text('Upcoming day'), findsWidgets);
      expect(find.textContaining('missed'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'browses saved prompts, every answer, notes and safe unknown IDs read-only',
    (tester) async {
      when(() => repository.watchDailyResponsesForRange(any(), any()))
          .thenAnswer(
            (_) => Stream.value([
              response(
                '2026-09-14',
                BarakahAnswer.yes,
                sources: ['quran', 'quran'],
                note: 'Monday note',
              ),
              response(
                '2026-09-15',
                BarakahAnswer.somewhat,
                promptId: 'retired_v0',
                sources: ['retired_source'],
                note: 'Historical note',
              ),
              response(
                '2026-09-16',
                BarakahAnswer.no,
                sources: ['ignored'],
                note: 'No answer note',
              ),
              response(
                '2026-09-17',
                BarakahAnswer.skip,
                sources: ['ignored'],
                note: 'Skip note',
              ),
            ]),
          );
      await pumpReview(tester);
      await tester.pumpAndSettle();
      for (final label in [
        'Yes: 1',
        'Somewhat: 1',
        'No: 1',
        'Skipped: 1',
        'Quran: 1',
        'Source of barakah: 1',
      ]) {
        await reveal(tester, find.text(label));
        expect(find.text(label), findsOneWidget);
      }
      expect(find.byKey(const Key('review-source-ignored')), findsNothing);
      for (final note in [
        'Monday note',
        'Historical note',
        'No answer note',
        'Skip note',
      ]) {
        await reveal(tester, find.text(note));
        expect(find.text(note), findsOneWidget);
      }
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'previous and next navigate with empty weeks and distinguish missing from skip',
    (tester) async {
      when(
        () =>
            repository.watchDailyResponsesForRange('2026-09-07', '2026-09-13'),
      ).thenAnswer(
        (_) => Stream.value([
          response('2026-09-07', BarakahAnswer.skip, note: 'Past skip'),
        ]),
      );
      await pumpReview(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('review-previous')));
      await tester.pumpAndSettle();
      verify(
        () =>
            repository.watchDailyResponsesForRange('2026-09-07', '2026-09-13'),
      ).called(1);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Sep 7, 2026 – Sep 13, 2026'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('review-next')))
            .onPressed,
        isNotNull,
      );
      await reveal(tester, find.text('Past skip'));
      expect(find.text('Skipped'), findsOneWidget);
      await reveal(tester, find.byKey(const Key('review-day-2026-09-08')));
      expect(find.text('No saved response'), findsWidgets);
      expect(find.text('Upcoming day'), findsNothing);
      await tester.tap(find.byKey(const Key('review-next')));
      await tester.pumpAndSettle();
      expect(find.textContaining('No daily responses saved'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('review-next')))
            .onPressed,
        isNull,
      );
      verify(
        () =>
            repository.watchDailyResponsesForRange('2026-09-14', '2026-09-20'),
      ).called(2);
    },
  );

  testWidgets(
    'loading, error and retry keep selected week and recover to data',
    (tester) async {
      final pending = StreamController<List<BarakahDailyResponse>>();
      addTearDown(pending.close);
      var attempts = 0;
      when(() => repository.watchDailyResponsesForRange(any(), any()))
          .thenAnswer((_) {
            return attempts++ == 0 ? pending.stream : Stream.value([]);
          });
      await pumpReview(tester);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      pending.addError(StateError('private database error'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          "This week's reflections could not be loaded. Please try again.",
        ),
        findsOneWidget,
      );
      expect(find.textContaining('private database'), findsNothing);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No daily responses saved'), findsOneWidget);
      expect(find.text('Sep 14, 2026 – Sep 20, 2026'), findsOneWidget);
      verify(
        () =>
            repository.watchDailyResponsesForRange('2026-09-14', '2026-09-20'),
      ).called(2);
    },
  );

  testWidgets(
    'reactive saved changes refresh counts and notes without reopening',
    (tester) async {
      final updates = StreamController<List<BarakahDailyResponse>>();
      addTearDown(updates.close);
      when(() => repository.watchDailyResponsesForRange(any(), any()))
          .thenAnswer((_) => updates.stream);
      await pumpReview(tester);
      updates.add([
        response(
          '2026-09-14',
          BarakahAnswer.yes,
          sources: ['quran'],
          note: 'Before',
        ),
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Yes: 1'), findsOneWidget);
      updates.add([response('2026-09-14', BarakahAnswer.no, note: 'After')]);
      await tester.pumpAndSettle();
      expect(find.text('Yes: 0'), findsOneWidget);
      expect(find.text('No: 1'), findsOneWidget);
      expect(find.byKey(const Key('review-source-quran')), findsNothing);
      await reveal(tester, find.text('After'));
      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    },
  );

  testWidgets(
    'Arabic dates, labels, counts and RTL navigation fit narrow large-text dark UI',
    (tester) async {
      when(() => repository.watchDailyResponsesForRange(any(), any()))
          .thenAnswer(
            (_) => Stream.value([
              response(
                '2026-09-14',
                BarakahAnswer.yes,
                sources: ['quran'],
                note: 'ملاحظة محفوظة',
              ),
            ]),
          );
      await pumpReview(
        tester,
        locale: const Locale('ar'),
        textScale: 1.5,
        dark: true,
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byKey(const Key('review-range')));
      final l10n = AppLocalizations.of(context)!;
      expect(Directionality.of(context), ui.TextDirection.rtl);
      expect(
        find.text(
          l10n.barakahWeeklyRange(
            DateFormat.yMMMd('ar').format(DateTime(2026, 9, 14)),
            DateFormat.yMMMd('ar').format(DateTime(2026, 9, 20)),
          ),
        ),
        findsOneWidget,
      );
      expect(
        tester.getCenter(find.byKey(const Key('review-previous'))).dx,
        greaterThan(tester.getCenter(find.byKey(const Key('review-next'))).dx),
      );
      await reveal(tester, find.byKey(const Key('review-count-yes')));
      expect(find.text('نعم: ١'), findsOneWidget);
      await reveal(tester, find.byKey(const Key('review-source-quran')));
      expect(find.text('القرآن: ١'), findsOneWidget);
      await reveal(tester, find.text('ملاحظة محفوظة'));
      expect(find.text('هل خصصت وقتًا للقرآن اليوم؟'), findsOneWidget);
      expect(find.text('ملاحظة محفوظة'), findsOneWidget);
      await tester.tap(find.byKey(const Key('review-previous')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('review-next')))
            .onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'review is reachable from Barakah and back preserves unsaved daily draft',
    (tester) async {
      when(() => repository.getEntriesForDate(any()))
          .thenAnswer((_) async => []);
      when(() => repository.watchDailyResponse(any()))
          .thenAnswer((_) => Stream.value(null));
      await pumpReview(tester, home: const BarakahScreen(date: '2026-09-17'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('daily-answer-no')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('daily-note')),
        'Unsaved draft',
      );
      await tester.tap(find.byKey(const Key('open-review')));
      await tester.pumpAndSettle();
      expect(find.byType(BarakahReviewScreen), findsOneWidget);
      expect(find.text('Weekly reflection review'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Unsaved draft'), findsOneWidget);
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const Key('daily-answer-no')))
            .selected,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
