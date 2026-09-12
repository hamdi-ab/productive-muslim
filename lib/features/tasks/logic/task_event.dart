import 'package:productive_muslim/domain/models/task.dart';

sealed class TaskEvent {
  const TaskEvent();

  factory TaskEvent.loaded(String date) = TaskEntriesLoaded;
  factory TaskEvent.created(Task task) = TaskCreated;
  factory TaskEvent.toggled(int taskId) = TaskToggled;
  factory TaskEvent.deleted(int taskId) = TaskDeleted;
}

class TaskEntriesLoaded extends TaskEvent {
  final String date;
  TaskEntriesLoaded(this.date);
}

class TaskCreated extends TaskEvent {
  final Task task;
  TaskCreated(this.task);
}

class TaskToggled extends TaskEvent {
  final int taskId;
  TaskToggled(this.taskId);
}

class TaskDeleted extends TaskEvent {
  final int taskId;
  TaskDeleted(this.taskId);
}