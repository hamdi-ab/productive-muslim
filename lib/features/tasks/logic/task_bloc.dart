import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/domain/models/task.dart';
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
        Task? toggledTask;
        for (final t in current.tasks) {
          if (t.id == event.taskId) {
            toggledTask = t;
            break;
          }
        }
        final updated = current.tasks
            .map(
              (t) => t.id == event.taskId
                  ? t.copyWith(completed: !t.completed)
                  : t,
            )
            .toList();
        emit(Loaded(updated));

        // Auto-create next occurrence for recurring tasks
        if (toggledTask != null &&
            !toggledTask.completed &&
            (toggledTask.repeatDaily || toggledTask.repeatWeekly)) {
          await _createNextOccurrence(toggledTask);
        }
      }
    } catch (e) {
      emit(Error(e.toString()));
    }
  }

  Future<void> _createNextOccurrence(Task task) async {
    final currentDate = DateTime.parse(task.date);
    DateTime nextDate;

    if (task.repeatDaily) {
      nextDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day + 1,
      );
    } else if (task.repeatWeekly) {
      nextDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day + 7,
      );
    } else {
      return;
    }

    final nextDateStr =
        '${nextDate.year}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.day.toString().padLeft(2, '0')}';

    // Check if a task with the same title already exists for the next date
    final existing = await _repository.getTasksForDate(nextDateStr);
    final alreadyExists = existing.any(
      (t) => t.title == task.title && t.active,
    );
    if (alreadyExists) return;

    final nextTask = Task(
      id: 0,
      title: task.title,
      lifeArea: task.lifeArea,
      startMinutes: task.startMinutes,
      endMinutes: task.endMinutes,
      date: nextDateStr,
      repeatDaily: task.repeatDaily,
      repeatWeekly: task.repeatWeekly,
      repeatDays: task.repeatDays,
      notes: task.notes,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _repository.insertTask(nextTask);
  }

  Future<void> _onDeleted(TaskDeleted event, Emitter<TaskState> emit) async {
    try {
      await _repository.deactivateTask(event.taskId);
      final current = state;
      if (current is Loaded) {
        final updated = current.tasks
            .where((t) => t.id != event.taskId)
            .toList();
        emit(Loaded(updated));
      }
    } catch (e) {
      emit(Error(e.toString()));
    }
  }
}
