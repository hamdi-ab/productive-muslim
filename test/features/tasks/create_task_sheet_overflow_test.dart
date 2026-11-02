import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/tasks/logic/task_bloc.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/create_task_sheet.dart';

import '../../helpers/overflow_test_helper.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTaskRepository mockTaskRepo;

  setUp(() {
    mockTaskRepo = MockTaskRepository();
    when(() => mockTaskRepo.watchTasksForDate(any()))
        .thenAnswer((_) => Stream.value([]));
  });

  Widget buildSubject() {
    return RepositoryProvider<TaskRepository>.value(
      value: mockTaskRepo,
      child: BlocProvider(
        create: (_) => TaskBloc(mockTaskRepo),
        child: const SizedBox(
          height: 750,
          child: CreateTaskSheet(date: '2026-09-17'),
        ),
      ),
    );
  }

  group('CreateTaskSheet RTL and Text Scale Resilience', () {
    testWidgets(
      'CreateTaskSheet has zero overflow at 1.5x scale in Arabic RTL',
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
      'CreateTaskSheet has zero overflow in light mode at 1.5x scale in English',
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
      'CreateTaskSheet has zero overflow in dark mode at 1.5x scale in English',
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
