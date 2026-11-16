import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/profile/presentation/screens/profile_screen.dart';

import '../../helpers/overflow_test_helper.dart';

class _MockBarakahRepository extends Mock implements BarakahRepository {}

class _MockHabitRepository extends Mock implements HabitRepository {}

class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late _MockBarakahRepository mockRepository;
  late _MockHabitRepository mockHabitRepository;
  late _MockTaskRepository mockTaskRepository;

  setUp(() {
    mockRepository = _MockBarakahRepository();
    registerFallbackValue(
      const BarakahEntry(id: 0, date: '', sourceIds: [], createdAt: 0),
    );

    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => []);

    mockHabitRepository = _MockHabitRepository();
    when(() => mockHabitRepository.watchOverallStreak())
        .thenAnswer((_) => Stream.value(14));
    when(() => mockHabitRepository.getOverallStreak())
        .thenAnswer((_) async => 14);
    when(() => mockHabitRepository.getLongestStreak())
        .thenAnswer((_) async => 21);
    when(() => mockHabitRepository.getLifetimeCompletionsCount())
        .thenAnswer((_) async => 85);
    when(
      () => mockHabitRepository.getCompletionsCountByDate(
        days: any(named: 'days'),
      ),
    ).thenAnswer((_) async => {});

    mockTaskRepository = _MockTaskRepository();
    when(() => mockTaskRepository.getLifetimeCompletedTasksCount())
        .thenAnswer((_) async => 42);

    if (getIt.isRegistered<HabitRepository>()) {
      getIt.unregister<HabitRepository>();
    }
    getIt.registerSingleton<HabitRepository>(mockHabitRepository);

    if (getIt.isRegistered<TaskRepository>()) {
      getIt.unregister<TaskRepository>();
    }
    getIt.registerSingleton<TaskRepository>(mockTaskRepository);

    if (!getIt.isRegistered<SettingsService>()) {
      getIt.registerSingleton<SettingsService>(SettingsService.empty());
    }
  });

  tearDown(() {
    if (getIt.isRegistered<HabitRepository>()) {
      getIt.unregister<HabitRepository>();
    }
    if (getIt.isRegistered<TaskRepository>()) {
      getIt.unregister<TaskRepository>();
    }
  });

  Widget buildSubject() {
    return RepositoryProvider<BarakahRepository>.value(
      value: mockRepository,
      child: const ProfileScreen(),
    );
  }

  group('ProfileScreen - Overflow & Text-Scale Resilience', () {
    testWidgets('no overflow at 1.0x text scale (LTR)', (tester) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('en'),
        textScale: 1.0,
        wrapInScrollView: false,
      );
    });

    testWidgets('no overflow at 1.5x text scale (LTR)', (tester) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('en'),
        textScale: 1.5,
        wrapInScrollView: false,
      );
    });

    testWidgets('no overflow at 1.5x text scale (RTL Arabic)', (tester) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('ar'),
        textScale: 1.5,
        wrapInScrollView: false,
      );
    });
  });
}
