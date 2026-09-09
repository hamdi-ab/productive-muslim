---
name: flutter-apply-architecture-best-practices
description: Architects a Flutter application using the recommended layered approach (UI, Logic, Data) with BLoC state management. Use when structuring a new project or refactoring for scalability. THIS PROJECT USES BLOC — see flutter-bloc skill for Bloc conventions.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 09 Sep 2026 14:54:00 GMT
---

# Architecting Flutter Applications

## Contents
- [Architectural Layers](#architectural-layers)
- [Project Structure](#project-structure)
- [Workflow: Implementing a New Feature](#workflow-implementing-a-new-feature)
- [Examples](#examples)

## Important: This Project Uses BLoC

This project uses **flutter_bloc** for state management, not ChangeNotifier. ViewModels are replaced by Blocs. See the `flutter-bloc` skill for event naming, state patterns, BlocProvider placement, and bloc_test conventions.

## Architectural Layers

Enforce strict Separation of Concerns by dividing the application into distinct layers. Never mix UI rendering with business logic or data fetching.

### UI Layer (Presentation)
- **Views:** Write reusable, lean widgets. Restrict logic in Views to UI-specific operations (e.g., animations, layout constraints, simple routing). Pass all required data from the Bloc state.
- **Blocs:** Manage UI state and handle user interactions. Use freezed sealed classes for states and past-tense verbs for events. Expose state through BlocBuilder/BlocConsumer. Inject Repositories into Blocs via the constructor.

### Data Layer
Implement the Repository pattern to isolate data access logic and create a single source of truth.
*   **Services:** Create stateless classes to wrap external APIs (HTTP clients, local databases, platform plugins). Return raw API models or `Result` wrappers.
*   **Repositories:** Consume one or more Services. Transform raw API models into clean Domain Models. Handle caching, offline synchronization, and retry logic. Expose Domain Models to Blocs.

### Logic Layer (Domain - Optional)
*   **Use Cases:** Implement this layer only if the application contains complex business logic that clutters the Bloc, or if logic must be reused across multiple Blocs. Extract this logic into dedicated Use Case (interactor) classes that sit between Blocs and Repositories.

## Project Structure

Organize the codebase using a feature-first approach with clean architecture layers within each feature:

```text
lib/
├── core/
│   ├── di/
│   │   └── di.dart                    # get_it container setup
│   ├── theme/
│   │   └── app_theme.dart            # Light/dark theme, colors, typography
│   └── router/
│       └── app_router.dart           # GoRouter configuration
├── data/
│   ├── local/
│   │   ├── database/
│   │   │   ├── app_database.dart     # Drift database class
│   │   │   └── tables/               # Drift table definitions
│   │   └── daos/                     # Drift DAO classes
│   ├── models/
│   │   └── drift/                    # Generated Drift data classes
│   ├── repositories/
│   │   └── implementations/          # Repository implementations
│   └── services/                     # API clients, notification service
├── domain/
│   ├── models/                       # Clean domain models (freezed)
│   ├── repositories/                 # Repository interfaces
│   └── use_cases/                    # Optional business logic classes
└── features/
    ├── tasks/
    │   ├── logic/
    │   │   ├── task_bloc.dart
    │   │   ├── task_event.dart
    │   │   └── task_state.dart
    │   ├── presentation/
    │   │   ├── screens/
    │   │   │   └── task_screen.dart
    │   │   └── widgets/
    │   │       ├── task_list.dart
    │   │       └── task_item.dart
    │   └── data/
    │       └── repositories/
    │           └── task_repository_impl.dart
    ├── habits/
    ├── barakah/
    └── intentions/
```

## Workflow: Implementing a New Feature

Follow this sequential workflow when adding a new feature to the application. Copy the checklist to track progress.

### Task Progress
- [ ] **Step 1: Define Domain Models.** Create immutable data classes for the feature using `freezed`.
- [ ] **Step 2: Define Drift Tables.** Create table definitions in `data/local/database/tables/`.
- [ ] **Step 3: Create DAOs.** Create DAO classes for database access with reactive `watch()` queries.
- [ ] **Step 4: Implement Repository Interface.** Define the contract in `domain/repositories/`.
- [ ] **Step 5: Implement Repository.** Consume DAOs and return Domain Models in `data/repositories/`.
- [ ] **Step 6: Register in DI.** Add repository and DAO registrations in `core/di/`.
- [ ] **Step 7: Implement Bloc.** Create events (past-tense verbs), states (freezed), and Bloc class in `logic/`.
- [ ] **Step 8: Implement the View.** Create the UI widget. Use `BlocBuilder` for state, `BlocListener` for side effects.
- [ ] **Step 9: Register Bloc Factory.** Add Bloc factory registration in `core/di/`.
- [ ] **Step 10: Run Validator.** Execute unit tests for the Bloc, repository, and widget.

## Examples

### Data Layer: DAO and Repository

```dart
// 1. DAO (Drift data access)
@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> {
  TaskDao(super.db);

  Stream<List<Task>> watchTasksForDate(String date) {
    return (select(tasks)
          ..where((t) => t.date.equals(date))
          ..where((t) => t.active.equals(1))
          ..orderBy([(t) => OrderingTerm.asc(t.startMinutes)]))
        .watch();
  }

  Future<List<Task>> getTasksForDate(String date) {
    return (select(tasks)
          ..where((t) => t.date.equals(date))
          ..where((t) => t.active.equals(1)))
        .get();
  }
}

// 2. Repository Interface (domain layer)
abstract class TaskRepository {
  Stream<List<Task>> watchTasksForDate(String date);
  Future<List<Task>> getTasksForDate(String date);
  Future<int> insertTask(Task task);
  Future<void> toggleTask(int taskId);
}

// 3. Repository Implementation (data layer)
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required TaskDao taskDao}) : _taskDao = taskDao;

  final TaskDao _taskDao;

  @override
  Stream<List<Task>> watchTasksForDate(String date) {
    return _taskDao.watchTasksForDate(date);
  }

  @override
  Future<List<Task>> getTasksForDate(String date) {
    return _taskDao.getTasksForDate(date);
  }

  @override
  Future<int> insertTask(Task task) {
    return _taskDao.insertTask(task);
  }

  @override
  Future<void> toggleTask(int taskId) {
    return _taskDao.toggleTask(taskId);
  }
}
```

### Logic Layer: Bloc

```dart
// 4. Events (past-tense verbs)
sealed class TaskEvent extends _$TaskEvent {
  const TaskEvent();
  factory TaskEvent.loaded(String date) => TaskLoaded(date);
  factory TaskEvent.created(Task task) => TaskCreated(task);
  factory TaskEvent.toggled(int taskId) => TaskToggled(taskId);
  factory TaskEvent.deleted(int taskId) => TaskDeleted(taskId);
}

// 5. States (freezed sealed class)
@freezed
class TaskState with _$TaskState {
  const factory TaskState.initial() = _Initial;
  const factory TaskState.loading() = _Loading;
  const factory TaskState.loaded(List<Task> tasks) = _Loaded;
  const factory TaskState.error(String message) = _Error;
}

// 6. Bloc
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

  Future<void> _onDeleted(TaskDeleted event, Emitter<TaskState> emit) async {
    // Implementation
  }
}
```

### UI Layer: View

```dart
// 7. View (dumb UI component)
class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TaskBloc>()..add(const TaskLoaded(today)),
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
```

## Dependency Injection

```dart
// CORRECT — register in core/di/di.dart
getIt.registerLazySingleton<TaskRepository>(
  () => TaskRepositoryImpl(taskDao: getIt()),
);

getIt.registerFactory<TaskBloc>(
  () => TaskBloc(getIt()),
);

// CORRECT — access in widget
BlocProvider(
  create: (context) => getIt<TaskBloc>(),
  child: const TaskView(),
)

// WRONG — providing all Blocs at app level
MultiBlocProvider(
  providers: [
    BlocProvider<TaskBloc>(create: (_) => TaskBloc(...)), // WRONG — loaded even when not visible
  ],
  child: const App(),
)
```

## What This Skill Does Not Cover

- Bloc event/state patterns — see `flutter-bloc` skill
- Drift database setup — see `flutter-drift` skill
- GoRouter configuration — see `flutter-setup-declarative-routing` skill
- JSON serialization — see `flutter-implement-json-serialization` skill
