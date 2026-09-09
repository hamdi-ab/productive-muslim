import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/database/tables/tasks.dart';
import 'package:productive_muslim/data/local/daos/task_dao.dart';
import 'package:productive_muslim/data/models/task.dart' as task_model;
import 'package:productive_muslim/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required TaskDao taskDao}) : _taskDao = taskDao;

  final TaskDao _taskDao;

  @override
  Stream<List<task_model.Task>> watchTasksForDate(String date) {
    return _taskDao.watchTasksForDate(date);
  }

  @override
  Future<List<task_model.Task>> getTasksForDate(String date) {
    return _taskDao.getTasksForDate(date);
  }

  @override
  Future<List<task_model.Task>> getTasksForRange(String startDate, String endDate) {
    return _taskDao.getTasksForRange(startDate, endDate);
  }

  @override
  Future<task_model.Task?> getTaskById(int id) {
    return _taskDao.getTaskById(id);
  }

  @override
  Future<int> insertTask(task_model.Task task) {
    return _taskDao.insertTask(TasksCompanion(
      title: Value(task.title),
      lifeArea: Value(task.lifeArea),
      startMinutes: Value(task.startMinutes),
      endMinutes: Value(task.endMinutes),
      date: Value(task.date),
      repeatDaily: Value(task.repeatDaily),
      repeatWeekly: Value(task.repeatWeekly),
      repeatDays: Value(task.repeatDays),
      notes: Value(task.notes),
      createdAt: Value(task.createdAt),
    ));
  }

  @override
  Future<bool> updateTask(task_model.Task task) {
    return _taskDao.updateTask(task);
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