import 'package:productive_muslim/domain/models/task.dart';

sealed class TaskState {
  const TaskState();

  const factory TaskState.initial() = TaskInitial;
  const factory TaskState.loading() = TaskLoading;
  const factory TaskState.loaded(List<Task> tasks) = TaskLoaded;
  const factory TaskState.error(String message) = TaskError;
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  const TaskLoaded(this.tasks);
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
}