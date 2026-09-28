import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/focus/presentation/screens/focus_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class FakeTaskRepository implements TaskRepository {
  List<Task> tasks = [];

  @override
  Stream<List<Task>> watchTasksForDate(String date) => Stream.value(tasks);

  @override
  Future<List<Task>> getTasksForDate(String date) async => tasks;

  @override
  Future<List<Task>> getTasksForRange(String start, String end) async => tasks;

  @override
  Future<Task?> getTaskById(int id) async =>
      tasks.where((t) => t.id == id).firstOrNull;

  @override
  Future<int> insertTask(Task task) async {
    tasks.add(task);
    return 1;
  }

  @override
  Future<bool> updateTask(Task task) async => true;

  @override
  Future<int> toggleTask(int id) async => 1;

  @override
  Future<int> deactivateTask(int id) async => 1;
}

void main() {
  setUp(() {
    if (!getIt.isRegistered<SettingsService>()) {
      getIt.registerSingleton<SettingsService>(SettingsService.empty());
    }
  });

  Widget buildSubject({TaskRepository? taskRepo, Task? initialTask}) {
    return RepositoryProvider<TaskRepository>.value(
      value: taskRepo ?? FakeTaskRepository(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FocusScreen(initialTask: initialTask),
      ),
    );
  }

  testWidgets(
    'renders focus screen with Niyyah banner and 25 min default timer',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('25:00'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(4));
    },
  );

  testWidgets('selecting 15m preset changes timer to 15:00', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('15 min'));
    await tester.pumpAndSettle();

    expect(find.text('15:00'), findsOneWidget);
  });

  testWidgets(
    'tapping start toggles timer to running state with pause button',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final playBtn = find.byIcon(Icons.play_arrow_rounded);
      await tester.ensureVisible(playBtn);
      await tester.tap(playBtn);
      await tester.pump();

      expect(find.text('In Flow...'), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    },
  );
}
