import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/tasks/logic/task_event.dart';
import 'package:productive_muslim/features/tasks/logic/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _repository;

  TaskBloc(this._repository) : super(const Initial()) {
    on<TaskLoaded>(_onLoaded);
    on<TaskCreated>(_onCreated);
    on<TaskToggled>(_onToggled);
    on<TaskDeleted>(_onDeleted);
  }

  Future<void> _onLoaded(TaskLoaded event, Emitter<TaskState> emit) async {
    emit(const Loading());
    try {
      final tasks = await _repository.getTasksForDate(event.date);
      emit(Loaded(tasks));
    } catch (e) {
      emit(Error(e.toString()));
    }
  }

  Future<void> _onCreated(TaskCreated event, Emitter<TaskState> emit) async {
    try {
      await _repository.insertTask(event.task);
      final tasks = await _repository.getTasksForDate(event.task.date);
      emit(Loaded(tasks));
    } catch (e) {
      emit(Error(e.toString()));
    }
  }

  Future<void> _onToggled(TaskToggled event, Emitter<TaskState> emit) async {
    try {
      await _repository.toggleTask(event.taskId);
      final current = state;
      if (current is Loaded) {
        final updated = current.tasks
            .map((t) => t.id == event.taskId
                ? t.copyWith(completed: !t.completed)
                : t)
            .toList();
        emit(Loaded(updated));
      }
    } catch (e) {
      emit(Error(e.toString()));
    }
  }

  Future<void> _onDeleted(TaskDeleted event, Emitter<TaskState> emit) async {
    try {
      await _repository.deactivateTask(event.taskId);
      final current = state;
      if (current is Loaded) {
        final updated = current.tasks.where((t) => t.id != event.taskId).toList();
        emit(Loaded(updated));
      }
    } catch (e) {
      emit(Error(e.toString()));
    }
  }
}
