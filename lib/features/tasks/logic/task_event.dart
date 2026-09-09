sealed class TaskEvent {
  const TaskEvent();

  factory TaskEvent.loaded(String date) = TaskLoaded;
  factory TaskEvent.created(Task task) = TaskCreated;
  factory TaskEvent.toggled(int taskId) = TaskToggled;
  factory TaskEvent.deleted(int taskId) = TaskDeleted;
}

class TaskLoaded extends TaskEvent {
  final String date;
  TaskLoaded(this.date);
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