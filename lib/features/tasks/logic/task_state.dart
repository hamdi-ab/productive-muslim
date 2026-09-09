sealed class TaskState {
  const TaskState();

  const factory TaskState.initial() = Initial;
  const factory TaskState.loading() = Loading;
  const factory TaskState.loaded(List<Task> tasks) = Loaded;
  const factory TaskState.error(String message) = Error;
}

class Initial extends TaskState {
  const Initial();
}

class Loading extends TaskState {
  const Loading();
}

class Loaded extends TaskState {
  final List<Task> tasks;
  const Loaded(this.tasks);
}

class Error extends TaskState {
  final String message;
  const Error(this.message);
}