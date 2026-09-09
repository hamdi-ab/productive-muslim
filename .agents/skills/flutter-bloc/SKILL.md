---
name: flutter-bloc
description: Use flutter_bloc for all feature state management in this app. Covers Bloc events (past-tense verbs), freezed states, BlocProvider placement, BlocBuilder/BlocListener/BlocConsumer usage, and bloc_test patterns. Use when creating a Bloc, adding state management to a feature, refactoring state logic, writing bloc tests, or debugging state issues. Trigger phrases: "create a bloc", "add state management", "bloc for [feature]", "bloc test", "state not updating", "emitting state".
package: flutter_bloc
aliases: [bloc, state-management, bloc-pattern]
sources: [chat, code]
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 09 Sep 2026 14:54:00 GMT
  versions:
    flutter_bloc: ^9.0.0
    flutter_bloc_test: ^9.1.0
    freezed: ^2.5.0
---

# BLoC State Management

This app uses the BLoC pattern via `flutter_bloc` for all feature state management. Every feature has its own Bloc. The UI observes state changes through `BlocBuilder`, `BlocListener`, or `BlocConsumer`.

## Core Rules

1. Every feature has exactly one Bloc.
2. Events are named as past-tense verbs (e.g., `TaskLoaded`, `TaskCreated`, `TaskToggled`).
3. States are immutable and use `freezed` sealed classes.
4. The Bloc class contains all business logic. The UI contains zero business logic.
5. Use `BlocProvider` at the feature level, not the app level.
6. Use `BlocBuilder` for UI state changes, `BlocListener` for one-time side effects (navigation, snackbars).
7. Use `BlocConsumer` only when you need both builder and listener in the same widget.
8. Never call `context.read<Bloc>()` inside `build()`. Use `context.watch<Bloc>()` or wrap the builder in `BlocBuilder`.
9. Never expose a Bloc's internal state outside the feature. Convert to domain models in the repository.
10. Test every Bloc with `bloc_test`.

## Project Structure

```text
lib/
├── features/
│   ├── tasks/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── task_repository.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── task.dart
│   │   │   └── repositories/
│   │   │       └── task_repository.dart
│   │   ├── logic/
│   │   │   ├── task_bloc.dart
│   │   │   ├── task_event.dart
│   │   │   └── task_state.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── task_screen.dart
│   │       └── widgets/
│   │           ├── task_list.dart
│   │           └── task_item.dart
```

## Event Pattern

```dart
// CORRECT — past-tense verbs
sealed class TaskEvent extends _$TaskEvent {
  const TaskEvent();
  factory TaskEvent.loaded(String date) => TaskLoaded(date);
  factory TaskEvent.created(Task task) => TaskCreated(task);
  factory TaskEvent.toggled(int taskId) => TaskToggled(taskId);
  factory TaskEvent.deleted(int taskId) => TaskDeleted(taskId);
}

// WRONG — imperative or noun form
class CreateTask extends TaskEvent {}      // WRONG — should be TaskCreated
class LoadTasks extends TaskEvent {}       // WRONG — should be TaskLoaded
class Task extends TaskEvent {}            // WRONG — confusing with model
```

## State Pattern

```dart
// CORRECT — freezed sealed class with all possible states
@freezed
class TaskState with _$TaskState {
  const factory TaskState.initial() = _Initial;
  const factory TaskState.loading() = _Loading;
  const factory TaskState.loaded(List<Task> tasks) = _Loaded;
  const factory TaskState.error(String message) = _Error;
}

// WRONG — using a single mutable state class
class TaskState {
  List<Task> tasks = [];
  bool isLoading = false;
  String? error;
}
```

## Bloc Implementation

```dart
// CORRECT
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _repository;

  TaskBloc(this._repository) : super(const TaskState.initial()) {
    on<TaskLoaded>(_onLoaded);
    on<TaskCreated>(_onCreated);
    on<TaskToggled>(_onToggled);
    on<TaskDeleted>(_onDeleted);
  }

  Future<void> _onLoaded(TaskLoaded event, Emitter<TaskState> emit) async {
    emit(const TaskState.loading());
    try {
      final tasks = await _repository.getTasksForDate(event.date);
      emit(TaskState.loaded(tasks));
    } catch (e) {
      emit(TaskState.error(e.toString()));
    }
  }

  Future<void> _onCreated(TaskCreated event, Emitter<TaskState> emit) async {
    try {
      await _repository.insertTask(event.task);
      final tasks = await _repository.getTasksForDate(event.task.date);
      emit(TaskState.loaded(tasks));
    } catch (e) {
      emit(TaskState.error(e.toString()));
    }
  }

  Future<void> _onToggled(TaskToggled event, Emitter<TaskState> emit) async {
    try {
      await _repository.toggleTask(event.taskId);
      final current = state;
      if (current is _Loaded) {
        final updated = current.tasks.map((t) {
          return t.id == event.taskId ? t.copyWith(completed: !t.completed) : t;
        }).toList();
        emit(TaskState.loaded(updated));
      }
    } catch (e) {
      emit(TaskState.error(e.toString()));
    }
  }
}
```

## UI Integration

```dart
// CORRECT — BlocProvider at feature level, BlocBuilder for state
class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc(context.read<TaskRepository>())..add(const TaskLoaded(today)),
      child: const TaskView(),
    );
  }
}

class TaskView extends StatelessWidget {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (tasks) => TaskList(tasks: tasks),
            error: (message) => Center(child: Text(message)),
          );
        },
      ),
    );
  }
}

// WRONG — calling context.read inside build
class WrongTaskView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TaskBloc>(); // WRONG — triggers on every build
    return BlocBuilder<TaskBloc, TaskState>(...);
  }
}

// CORRECT — BlocListener for one-time side effects
BlocListener<TaskBloc, TaskState>(
  listenWhen: (previous, current) => previous != current,
  listener: (context, state) {
    state.when(
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      ),
      orElse: () {},
    );
  },
  child: BlocBuilder<TaskBloc, TaskState>(...),
)
```

## Bloc Testing

```dart
// CORRECT
blocTest<TaskBloc, TaskState>(
  'emits [Loading, Loaded] when TaskLoaded succeeds',
  build: () {
    when(() => repository.getTasksForDate(any())).thenAnswer((_) async => [task]);
    return TaskBloc(repository);
  },
  act: (bloc) => bloc.add(const TaskLoaded('2025-09-09')),
  expect: () => [
    const TaskState.loading(),
    TaskState.loaded([task]),
  ],
);

blocTest<TaskBloc, TaskState>(
  'emits [Loading, Error] when TaskLoaded fails',
  build: () {
    when(() => repository.getTasksForDate(any())).thenThrow(Exception('db error'));
    return TaskBloc(repository);
  },
  act: (bloc) => bloc.add(const TaskLoaded('2025-09-09')),
  expect: () => [
    const TaskState.loading(),
    const TaskState.error('Exception: db error'),
  ],
);
```

## Dependency Injection

```dart
// CORRECT — provide Bloc at the feature level
BlocProvider<TaskBloc>(
  create: (context) => TaskBloc(
    context.read<TaskRepository>(),
  )..add(const TaskLoaded(today)),
  child: const TaskView(),
)

// WRONG — providing at app level for all features
MultiBlocProvider(
  providers: [
    BlocProvider<TaskBloc>(create: (_) => TaskBloc(...)), // WRONG — lazy, loaded even when not visible
    BlocProvider<HabitBloc>(create: (_) => HabitBloc(...)), // WRONG
  ],
  child: const App(),
)
```

## Event-to-Repository Contract

```dart
// Events never hold domain models directly — pass IDs and let the Bloc fetch
// CORRECT
factory TaskEvent.toggled(int taskId) => TaskToggled(taskId);

// WRONG — passing the full model through the event
factory TaskEvent.toggled(Task task) => TaskToggled(task); // WRONG
```
