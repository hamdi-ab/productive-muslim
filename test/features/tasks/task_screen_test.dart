import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/tasks/logic/task_bloc.dart';
import 'package:productive_muslim/features/tasks/logic/task_event.dart';
import 'package:productive_muslim/features/tasks/logic/task_state.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/task_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class FakeTaskRepository implements TaskRepository {
  List<Task> _tasks = [];

  void setTasks(List<Task> tasks) => _tasks = tasks;

  @override
  Stream<List<Task>> watchTasksForDate(String date) =>
      Stream.value(_tasks.where((t) => t.date == date && t.active).toList());

  @override
  Future<List<Task>> getTasksForDate(String date) async =>
      _tasks.where((t) => t.date == date && t.active).toList();

  @override
  Future<List<Task>> getTasksForRange(String start, String end) async => _tasks
      .where((t) => t.date.compareTo(start) >= 0 && t.date.compareTo(end) <= 0)
      .toList();

  @override
  Future<Task?> getTaskById(int id) async =>
      _tasks.firstWhere((t) => t.id == id);

  @override
  Future<int> insertTask(Task task) async {
    final newTask = task.copyWith(id: _tasks.length + 1);
    _tasks.add(newTask);
    return newTask.id;
  }

  @override
  Future<bool> updateTask(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) _tasks[idx] = task;
    return true;
  }

  @override
  Future<int> toggleTask(int id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _tasks[idx] = _tasks[idx].copyWith(
        completed: !_tasks[idx].completed,
        completedAt: !_tasks[idx].completed
            ? DateTime.now().millisecondsSinceEpoch
            : null,
      );
    }
    return 1;
  }

  @override
  Future<int> deactivateTask(int id) async {
    _tasks.removeWhere((t) => t.id == id);
    return 1;
  }
}

void main() {
  late FakeTaskRepository repo;

  setUp(() {
    repo = FakeTaskRepository();
  });

  Widget buildScreen() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RepositoryProvider<TaskRepository>(
        create: (_) => repo,
        child: BlocProvider(
          create: (ctx) =>
              TaskBloc(ctx.read<TaskRepository>())
                ..add(TaskLoaded('2026-09-19')),
          child: const TaskScreen(),
        ),
      ),
    );
  }

  testWidgets('shows empty state when no tasks', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('No tasks today'), findsOneWidget);
  });

  testWidgets('shows task when loaded', (tester) async {
    repo.setTasks([
      Task(
        id: 1,
        title: 'Fajr reflection',
        lifeArea: 'islam',
        startMinutes: 360,
        endMinutes: 420,
        date: '2026-09-19',
        createdAt: 0,
      ),
    ]);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Fajr reflection'), findsOneWidget);
  });

  testWidgets('groups scheduled tasks under Scheduled section', (tester) async {
    repo.setTasks([
      Task(
        id: 1,
        title: 'Morning task',
        lifeArea: 'islam',
        startMinutes: 360,
        endMinutes: 420,
        date: '2026-09-19',
        createdAt: 0,
      ),
    ]);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('SCHEDULED'), findsOneWidget);
  });

  testWidgets('groups tasks without time under No time set', (tester) async {
    repo.setTasks([
      Task(
        id: 1,
        title: 'Quick task',
        lifeArea: 'work',
        date: '2026-09-19',
        createdAt: 0,
      ),
    ]);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('NO TIME SET'), findsOneWidget);
  });

  testWidgets('shows life area indicator', (tester) async {
    repo.setTasks([
      Task(
        id: 1,
        title: 'Work task',
        lifeArea: 'work',
        date: '2026-09-19',
        createdAt: 0,
      ),
    ]);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Work task'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('shows time range for scheduled tasks', (tester) async {
    repo.setTasks([
      Task(
        id: 1,
        title: 'Timed task',
        lifeArea: 'islam',
        startMinutes: 540,
        endMinutes: 600,
        date: '2026-09-19',
        createdAt: 0,
      ),
    ]);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('09:00 – 10:00'), findsOneWidget);
  });

  testWidgets('FAB opens create task sheet', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // title + notes
  });

  testWidgets('toggle completes task', (tester) async {
    repo.setTasks([
      Task(
        id: 1,
        title: 'Test task',
        lifeArea: 'islam',
        date: '2026-09-19',
        createdAt: 0,
      ),
    ]);

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.check_circle_outline));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('renders in Arabic locale', (tester) async {
    repo.setTasks([
      Task(
        id: 1,
        title: 'Fajr',
        lifeArea: 'islam',
        date: '2026-09-19',
        createdAt: 0,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RepositoryProvider<TaskRepository>(
          create: (_) => repo,
          child: BlocProvider(
            create: (ctx) =>
                TaskBloc(ctx.read<TaskRepository>())
                  ..add(TaskLoaded('2026-09-19')),
            child: const TaskScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fajr'), findsOneWidget);
  });
}
