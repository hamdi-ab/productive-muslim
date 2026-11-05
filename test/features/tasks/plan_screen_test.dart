import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/plan_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late MockTaskRepository mockTaskRepo;
  late MockHabitRepository mockHabitRepo;

  setUp(() {
    mockTaskRepo = MockTaskRepository();
    mockHabitRepo = MockHabitRepository();

    when(() => mockTaskRepo.watchTasksForDate(any()))
        .thenAnswer((_) => Stream.value(<Task>[]));

    when(() => mockHabitRepo.watchActiveHabits())
        .thenAnswer((_) => Stream.value(<Habit>[]));

    when(() => mockHabitRepo.getCompletionsForDateMap(any()))
        .thenAnswer((_) async => <int, bool>{});

    when(() => mockHabitRepo.getStreak(any())).thenAnswer((_) async => 0);
  });

  Widget buildSubject({PlanTab initialTab = PlanTab.tasks}) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TaskRepository>.value(value: mockTaskRepo),
        RepositoryProvider<HabitRepository>.value(value: mockHabitRepo),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlanScreen(initialTab: initialTab),
      ),
    );
  }

  testWidgets('renders Plan screen with Tasks and Habits tab pills', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Habits'), findsWidgets);
    expect(find.text('New Task'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('switching to Habits tab updates view and FAB label', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Tap habits pill
    final habitsTab = find.text('Habits').first;
    await tester.tap(habitsTab);
    await tester.pumpAndSettle();

    expect(find.text('New Habit'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
