import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:productive_muslim/domain/models/intention_entry.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';
import 'package:productive_muslim/features/intentions/logic/intention_bloc.dart';
import 'package:productive_muslim/features/intentions/logic/intention_event.dart';
import 'package:productive_muslim/features/intentions/presentation/screens/intention_screen.dart';
import 'package:productive_muslim/features/intentions/presentation/widgets/intention_adhkar_bookend_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockIntentionRepository extends Mock implements IntentionRepository {}

void main() {
  late MockIntentionRepository mockRepository;

  setUp(() {
    mockRepository = MockIntentionRepository();
    registerFallbackValue(
      IntentionEntry(id: 0, date: '', title: '', createdAt: 0),
    );
    registerFallbackValue(IntentionEntriesLoaded(''));
  });

  final today = DateTime.now();
  final todayStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  final testEntries = [
    IntentionEntry(
      id: 1,
      date: todayStr,
      title: 'Pray Fajr on time',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ),
    IntentionEntry(
      id: 2,
      date: todayStr,
      title: 'Read 10 pages of Quran',
      statement: 'Increase my khushoo',
      completed: true,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ),
  ];

  Widget buildScreen() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: RepositoryProvider<IntentionRepository>.value(
        value: mockRepository,
        child: BlocProvider(
          create: (context) =>
              IntentionBloc(mockRepository)
                ..add(IntentionEntriesLoaded(todayStr)),
          child: const IntentionScreen(),
        ),
      ),
    );
  }

  testWidgets('shows empty state when no intentions', (tester) async {
    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('No intentions for today'), findsOneWidget);
  });

  testWidgets('displays today intentions list', (tester) async {
    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => testEntries);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Pray Fajr on time'), findsOneWidget);
    expect(find.text('Read 10 pages of Quran'), findsOneWidget);
  });

  testWidgets('shows statement subtitle when present', (tester) async {
    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => [testEntries[1]]);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Increase my khushoo'), findsOneWidget);
  });

  testWidgets('shows completed icon for completed entries', (tester) async {
    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => [testEntries[1]]);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('shows outline icon for incomplete entries', (tester) async {
    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => [testEntries[0]]);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('shows reflection card with progress', (tester) async {
    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => testEntries);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Reflection'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('FAB opens add intention dialog', (tester) async {
    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets(
    'preset chip populates intention title and statement in elevated dialog',
    (tester) async {
      when(() => mockRepository.getEntriesForDate(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Work as Worship'), findsWidgets);
      await tester.tap(find.text('Work as Worship').first);
      await tester.pumpAndSettle();

      expect(
        find.text('To excel in my work with Ihsan and honesty'),
        findsOneWidget,
      );
    },
  );

  testWidgets('renders Arabic locale correctly', (tester) async {
    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => [testEntries[0]]);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: RepositoryProvider<IntentionRepository>.value(
          value: mockRepository,
          child: BlocProvider(
            create: (context) =>
                IntentionBloc(mockRepository)
                  ..add(IntentionEntriesLoaded(todayStr)),
            child: const IntentionScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('يومية'), findsOneWidget);
    expect(find.text('نيات اليوم'), findsOneWidget);
  });

  testWidgets(
    'displays Dhikr recitation chip when intention is Dhikr-related',
    (tester) async {
      final dhikrEntry = IntentionEntry(
        id: 3,
        date: todayStr,
        title: 'Morning Adhkar & Duas',
        statement: 'Start day in Allahs protection',
        completed: false,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      when(() => mockRepository.getEntriesForDate(any()))
          .thenAnswer((_) async => [dhikrEntry]);

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Recite Dhikr Now'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_rounded), findsWidgets);
    },
  );

  testWidgets('displays Bookend Adhkar card in intention journal', (
    tester,
  ) async {
    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byType(IntentionAdhkarBookendCard),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();

    expect(find.byType(IntentionAdhkarBookendCard), findsOneWidget);
  });
}
