---
name: flutter-di-getit
description: Configure get_it as the dependency injection container for this Flutter app. Covers service locator setup, registration patterns, lazy vs eager loading, and scope management. Use when wiring up repositories, data sources, or any cross-cutting dependency.
package: get_it
aliases: [getit, di, service-locator, dependency-injection]
sources: [chat, code]
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 09 Sep 2026 14:54:00 GMT
  versions:
    get_it: ^7.6.0
---

# Dependency Injection with get_it

This app uses `get_it` as the service locator for dependency injection. All repositories, data sources, and external services are registered in the container and accessed through it.

## Core Rules

1. Use `get_it` only in the data layer and above. Never inject a repository or data source directly into a widget.
2. Register all dependencies in a single `di.dart` file under `lib/core/di/`.
3. Use lazy registration (`getIt.registerLazySingleton`) for everything unless you have a specific reason for eager registration.
4. Use factory registration (`getIt.registerFactory`) for objects that must be created fresh each time (e.g., Blocs).
5. Never register UI widgets or Blocs in the container. Register only data-layer dependencies.
6. Access the container through `getIt<Type>()` or extension methods, never directly.
7. Keep the container setup code pure — no async initialization in registration. Use a separate `init()` function for async setup.

## Project Structure

```text
lib/
├── core/
│   ├── di/
│   │   ├── di.dart                    # Container setup and exports
│   │   ├── repositories/
│   │   │   ├── task_repository_module.dart
│   │   │   ├── habit_repository_module.dart
│   │   │   ├── barakah_repository_module.dart
│   │   │   └── intention_repository_module.dart
│   │   └── data_sources/
│   │       ├── local/
│   │       │   └── local_data_source_module.dart
│   │       └── remote/
│   │           └── remote_data_source_module.dart
```

## Container Setup

```dart
// CORRECT — lib/core/di/di.dart
import 'package:get_it/get_it.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'repositories/task_repository_module.dart';
import 'repositories/habit_repository_module.dart';

final getIt = GetIt.instance;

Future<void> setupDi() async {
  // Database — singleton, created eagerly
  final database = await AppDatabase._openConnection();
  getIt.registerSingleton<AppDatabase>(database);

  // Repositories — lazy singletons
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(getIt()),
  );

  // External services — lazy singletons
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationServiceImpl(),
  );
}

// WRONG — putting registration in main.dart
void main() {
  getIt.registerSingleton<AppDatabase>(AppDatabase()); // WRONG — scattered registrations
  runApp(const App());
}
```

## Repository Registration Pattern

```dart
// CORRECT — module pattern for each repository domain
// lib/core/di/repositories/task_repository_module.dart
import 'package:get_it/get_it.dart';
import 'package:productive_muslim/data/local/daos/task_dao.dart';
import 'package:productive_muslim/data/repositories/task_repository_impl.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';

void setupTaskRepository(GetIt getIt) {
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      taskDao: getIt(),
    ),
  );
}

// WRONG — registering implementation instead of interface
getIt.registerLazySingleton<TaskRepositoryImpl>(...); // WRONG
```

## Bloc Factory Registration

```dart
// CORRECT — factories for Blocs
getIt.registerFactory<TaskBloc>(
  () => TaskBloc(
    getIt<TaskRepository>(),
  ),
);

// WRONG — singleton for Bloc
getIt.registerSingleton<TaskBloc>(TaskBloc(...)); // WRONG — Blocs must be recreated
```

## Accessing Dependencies

```dart
// CORRECT — extension method or direct getIt call
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

// CORRECT — inside a Bloc or repository
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _repository;

  TaskBloc(this._repository) : super(const TaskState.initial()) {
    // ...
  }
}

// WRONG — accessing in widget build method
@override
Widget build(BuildContext context) {
  final repository = getIt<TaskRepository>(); // WRONG — bypasses Bloc
  final tasks = await repository.getTasksForDate(today); // WRONG — async in build
  return TaskList(tasks: tasks);
}
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _repository;

  TaskBloc(this._repository) : super(const TaskState.initial()) {
    // ...
  }
}

// WRONG — accessing in widget build method
@override
Widget build(BuildContext context) {
  final repository = getIt<TaskRepository>(); // WRONG — bypasses Bloc
  final tasks = await repository.getTasksForDate(today); // WRONG — async in build
  return TaskList(tasks: tasks);
}
```

## Async Initialization

```dart
// CORRECT — separate init function for async setup
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDi();
  runApp(const App());
}

Future<void> setupDi() async {
  // Async operations only here
  final database = await AppDatabase._openConnection();
  getIt.registerSingleton<AppDatabase>(database);

  // Sync registrations after async setup
  _registerRepositories();
  _registerBlocs();
  _registerServices();
}

// WRONG — async in registration
getIt.registerSingletonAsync<AppDatabase>(() async {
  return await AppDatabase._openConnection();
}); // WRONG — use registerSingleton with async init instead
```

## Scope Management (Future)

```dart
// For future scope management (e.g., per-feature scopes)
final taskScope = GetIt.instance.createChildScope();

void disposeTaskScope() {
  GetIt.instance.dropScope(taskScope);
}
```

## What This Skill Does Not Cover

- Riverpod or Provider — this app uses get_it exclusively
- Service locator anti-pattern debates — get_it is the chosen solution; use it correctly within this project
- Dynamic service loading — all services are known at compile time
