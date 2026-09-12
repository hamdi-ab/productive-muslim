import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/daos/task_dao.dart';
import 'package:productive_muslim/domain/models/task.dart' as task_model;
import 'package:productive_muslim/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required TaskDao taskDao}) : _taskDao = taskDao;

  final TaskDao _taskDao;

  task_model.Task _toDomain(Task row) {
    return task_model.Task(
      id: row.id,
      title: row.title,
      lifeArea: row.lifeArea,
      startMinutes: row.startMinutes,
      endMinutes: row.endMinutes,
      date: row.date,
      repeatDaily: row.repeatDaily == 1,
      repeatWeekly: row.repeatWeekly == 1,
      repeatDays: row.repeatDays,
      notes: row.notes,
      completed: row.completed == 1,
      completedAt: row.completedAt,
      createdAt: row.createdAt,
      active: row.active == 1,
    );
  }

  Task _toDrift(task_model.Task task) {
    return Task(
      id: task.id,
      title: task.title,
      lifeArea: task.lifeArea,
      startMinutes: task.startMinutes,
      endMinutes: task.endMinutes,
      date: task.date,
      repeatDaily: task.repeatDaily ? 1 : 0,
      repeatWeekly: task.repeatWeekly ? 1 : 0,
      repeatDays: task.repeatDays,
      notes: task.notes,
      completed: task.completed ? 1 : 0,
      completedAt: task.completedAt,
      createdAt: task.createdAt,
      active: task.active ? 1 : 0,
    );
  }

  @override
  Stream<List<task_model.Task>> watchTasksForDate(String date) {
    return _taskDao
        .watchTasksForDate(date)
        .map((tasks) => tasks.map(_toDomain).toList());
  }

  @override
  Future<List<task_model.Task>> getTasksForDate(String date) async {
    final tasks = await _taskDao.getTasksForDate(date);
    return tasks.map(_toDomain).toList();
  }

  @override
  Future<List<task_model.Task>> getTasksForRange(
    String startDate,
    String endDate,
  ) async {
    final tasks = await _taskDao.getTasksForRange(startDate, endDate);
    return tasks.map(_toDomain).toList();
  }

  @override
  Future<task_model.Task?> getTaskById(int id) async {
    final task = await _taskDao.getTaskById(id);
    return task == null ? null : _toDomain(task);
  }

  @override
  Future<int> insertTask(task_model.Task task) {
    return _taskDao.insertTask(
      TasksCompanion.insert(
        title: task.title,
        lifeArea: task.lifeArea,
        startMinutes: Value(task.startMinutes),
        endMinutes: Value(task.endMinutes),
        date: task.date,
        repeatDaily: Value(task.repeatDaily ? 1 : 0),
        repeatWeekly: Value(task.repeatWeekly ? 1 : 0),
        repeatDays: Value(task.repeatDays),
        notes: Value(task.notes),
        completed: Value(task.completed ? 1 : 0),
        completedAt: Value(task.completedAt),
        createdAt: Value(task.createdAt),
        active: Value(task.active ? 1 : 0),
      ),
    );
  }

  @override
  Future<bool> updateTask(task_model.Task task) {
    return _taskDao.updateTask(_toDrift(task));
  }

  @override
  Future<int> toggleTask(int id) {
    return _taskDao.toggleTask(id);
  }

  @override
  Future<int> deactivateTask(int id) {
    return _taskDao.deactivateTask(id);
  }
}
