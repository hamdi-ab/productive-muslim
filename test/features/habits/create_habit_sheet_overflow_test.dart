import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/features/habits/logic/habit_bloc.dart';
import 'package:productive_muslim/features/habits/presentation/screens/create_habit_sheet.dart';

import '../../helpers/overflow_test_helper.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHabitRepository mockHabitRepo;

  setUp(() {
    mockHabitRepo = MockHabitRepository();
    when(() => mockHabitRepo.getActiveHabits()).thenAnswer((_) async => []);
    when(() => mockHabitRepo.getCompletionsForDateMap(any()))
        .thenAnswer((_) async => {});
  });

  Widget buildSubject() {
    return RepositoryProvider<HabitRepository>.value(
      value: mockHabitRepo,
      child: BlocProvider(
        create: (_) => HabitBloc(mockHabitRepo),
        child: const SizedBox(height: 750, child: CreateHabitSheet()),
      ),
    );
  }

  group('CreateHabitSheet RTL and Text Scale Resilience', () {
    testWidgets(
      'CreateHabitSheet has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: buildSubject(),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'CreateHabitSheet has zero overflow in light mode at 1.5x scale in English',
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
      'CreateHabitSheet has zero overflow in dark mode at 1.5x scale in English',
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
