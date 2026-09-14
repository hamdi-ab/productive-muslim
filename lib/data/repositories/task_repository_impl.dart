import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/daos/task_dao.dart';
import 'package:productive_muslim/data/mappers/task_mapper.dart';
import 'package:productive_muslim/domain/models/task.dart' as task_model;
import 'package:productive_muslim/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required TaskDao taskDao}) : _taskDao = taskDao;

  final TaskDao _taskDao;
  final _mapper = TaskMapper();

  @override
  Stream<List<task_model.Task>> watchTasksForDate(String date) {
    return _taskDao
        .watchTasksForDate(date)
        .map((rows) => rows.map(_mapper.toDomain).toList());
  }

  @override
  Future<List<task_model.Task>> getTasksForDate(String date) async {
    final rows = await _taskDao.getTasksForDate(date);
    return rows.map(_mapper.toDomain).toList();
  }

  @override
  Future<List<task_model.Task>> getTasksForRange(
    String startDate,
    String endDate,
  ) async {
    final rows = await _taskDao.getTasksForRange(startDate, endDate);
    return rows.map(_mapper.toDomain).toList();
  }

  @override
  Future<task_model.Task?> getTaskById(int id) async {
    final row = await _taskDao.getTaskById(id);
    return row == null ? null : _mapper.toDomain(row);
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
    return _taskDao.updateTask(_mapper.toRow(task));
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
