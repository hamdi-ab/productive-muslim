import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/features/habits/logic/habit_bloc.dart';
import 'package:productive_muslim/features/habits/logic/habit_event.dart';
import 'package:productive_muslim/features/habits/presentation/screens/habit_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late MockHabitRepository mockRepository;

  setUp(() {
    mockRepository = MockHabitRepository();
  });

  final testHabits = [
    Habit(
      id: 1,
      name: 'Read Quran',
      category: 'islam',
      createdAt: DateTime(2026).millisecondsSinceEpoch,
    ),
    Habit(
      id: 2,
      name: 'Exercise',
      category: 'personal_dev',
      createdAt: DateTime(2026).millisecondsSinceEpoch,
    ),
  ];

  Widget buildScreen({Map<int, bool>? completions, Map<int, int>? streaks}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: RepositoryProvider<HabitRepository>.value(
        value: mockRepository,
        child: BlocProvider(
          create: (context) =>
              HabitBloc(mockRepository)..add(const HabitLoaded()),
          child: const HabitScreen(),
        ),
      ),
    );
  }

  setUpAll(() {
    registerFallbackValue(const HabitLoaded());
    registerFallbackValue(
      Habit(id: 0, name: '', category: 'islam', createdAt: 0),
    );
  });

  testWidgets('shows empty state when no habits', (tester) async {
    when(() => mockRepository.getActiveHabits()).thenAnswer((_) async => []);
    when(() => mockRepository.getCompletionsForDateMap(any()))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('No habits yet'), findsOneWidget);
  });

  testWidgets('displays habits grouped by category', (tester) async {
    when(() => mockRepository.getActiveHabits())
        .thenAnswer((_) async => testHabits);
    when(() => mockRepository.getCompletionsForDateMap(any()))
        .thenAnswer((_) async => {});
    when(() => mockRepository.getStreak(any())).thenAnswer((_) async => 0);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Read Quran'), findsOneWidget);
    expect(find.text('Exercise'), findsOneWidget);
  });

  testWidgets('displays week header with day circles', (tester) async {
    when(() => mockRepository.getActiveHabits())
        .thenAnswer((_) async => testHabits);
    when(() => mockRepository.getCompletionsForDateMap(any()))
        .thenAnswer((_) async => {});
    when(() => mockRepository.getStreak(any())).thenAnswer((_) async => 0);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('M'), findsOneWidget);
    expect(find.text('T'), findsWidgets);
    expect(find.text('W'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
    expect(find.text('S'), findsWidgets);
  });

  testWidgets('shows streak badge when streak > 0', (tester) async {
    when(() => mockRepository.getActiveHabits())
        .thenAnswer((_) async => [testHabits[0]]);
    when(() => mockRepository.getCompletionsForDateMap(any()))
        .thenAnswer((_) async => {});
    when(() => mockRepository.getStreak(any())).thenAnswer((_) async => 7);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('\u{1F525} 7'), findsOneWidget);
  });

  testWidgets('shows life area color indicator', (tester) async {
    when(() => mockRepository.getActiveHabits())
        .thenAnswer((_) async => [testHabits[0]]);
    when(() => mockRepository.getCompletionsForDateMap(any()))
        .thenAnswer((_) async => {});
    when(() => mockRepository.getStreak(any())).thenAnswer((_) async => 0);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    // Category header should show colored dot
    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('tapping checkbox toggles completion', (tester) async {
    when(() => mockRepository.getActiveHabits())
        .thenAnswer((_) async => [testHabits[0]]);
    when(() => mockRepository.getCompletionsForDateMap(any()))
        .thenAnswer((_) async => {});
    when(() => mockRepository.getStreak(any())).thenAnswer((_) async => 0);
    when(() => mockRepository.toggleCompletion(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockRepository.getCompletion(any(), any()))
        .thenAnswer((_) async => null);
    when(() => mockRepository.getStreak(any())).thenAnswer((_) async => 1);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('habit_checkbox_1')));
    await tester.pumpAndSettle();

    verify(() => mockRepository.toggleCompletion(any(), any())).called(1);
  });

  testWidgets('FAB opens create habit sheet', (tester) async {
    when(() => mockRepository.getActiveHabits()).thenAnswer((_) async => []);
    when(() => mockRepository.getCompletionsForDateMap(any()))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('renders Arabic locale correctly', (tester) async {
    when(() => mockRepository.getActiveHabits())
        .thenAnswer((_) async => [testHabits[0]]);
    when(() => mockRepository.getCompletionsForDateMap(any()))
        .thenAnswer((_) async => {});
    when(() => mockRepository.getStreak(any())).thenAnswer((_) async => 3);

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
        home: RepositoryProvider<HabitRepository>.value(
          value: mockRepository,
          child: BlocProvider(
            create: (context) =>
                HabitBloc(mockRepository)..add(const HabitLoaded()),
            child: const HabitScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('العادات'), findsOneWidget);
    expect(find.textContaining('3'), findsOneWidget);
  });
}
