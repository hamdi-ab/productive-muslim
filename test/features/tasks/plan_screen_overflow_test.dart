import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/plan_screen.dart';

import '../../helpers/overflow_test_helper.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTaskRepository mockTaskRepo;
  late MockHabitRepository mockHabitRepo;

  final sampleTasks = [
    Task(
      id: 1,
      title: 'Deep Work: Finalize Project Architecture',
      lifeArea: 'work',
      startMinutes: 330,
      endMinutes: 510,
      date: '2026-09-17',
      completed: true,
      createdAt: 0,
    ),
    Task(
      id: 2,
      title: 'Strategy Review & Standup with Executive Team',
      lifeArea: 'work',
      startMinutes: 690,
      endMinutes: 780,
      date: '2026-09-17',
      completed: false,
      createdAt: 1,
    ),
    Task(
      id: 3,
      title: 'Review Weekly Spiritual Goals in Journal',
      lifeArea: 'spiritual',
      date: '2026-09-17',
      completed: false,
      createdAt: 2,
    ),
  ];

  setUp(() {
    mockTaskRepo = MockTaskRepository();
    mockHabitRepo = MockHabitRepository();

    when(() => mockTaskRepo.watchTasksForDate(any()))
        .thenAnswer((_) => Stream.value(sampleTasks));
    when(() => mockTaskRepo.getTasksForDate(any()))
        .thenAnswer((_) async => sampleTasks);

    when(() => mockHabitRepo.watchActiveHabits())
        .thenAnswer((_) => Stream.value(<Habit>[]));
    when(() => mockHabitRepo.watchCompletionsForDate(any()))
        .thenAnswer((_) => Stream.value(<int, bool>{}));
    when(() => mockHabitRepo.getCompletionsForDateMap(any()))
        .thenAnswer((_) async => <int, bool>{});
    when(() => mockHabitRepo.getStreak(any())).thenAnswer((_) async => 0);
    when(() => mockHabitRepo.getOverallStreak()).thenAnswer((_) async => 0);
    when(() => mockHabitRepo.watchOverallStreak())
        .thenAnswer((_) => Stream.value(0));
  });

  Widget buildSubject({PlanTab initialTab = PlanTab.tasks}) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TaskRepository>.value(value: mockTaskRepo),
        RepositoryProvider<HabitRepository>.value(value: mockHabitRepo),
      ],
      child: const SizedBox(height: 850, child: PlanScreen()),
    );
  }

  group('PlanScreen RTL and Text Scale Resilience', () {
    testWidgets('PlanScreen has zero overflow at 1.5x scale in Arabic RTL', (
      tester,
    ) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('ar'),
        textScale: 1.5,
        isDark: true,
        screenSize: const Size(360, 780),
      );
    });

    testWidgets(
      'PlanScreen has zero overflow in light mode at 1.5x scale in English',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: buildSubject(),
          locale: const Locale('en'),
          textScale: 1.5,
          isDark: false,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'PlanScreen has zero overflow in dark mode at 1.5x scale in English',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: buildSubject(),
          locale: const Locale('en'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );
      },
    );
  });
}
