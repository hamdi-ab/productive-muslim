import 'package:productive_muslim/data/local/daos/task_dao.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required TaskDao taskDao}) : _taskDao = taskDao;

  final TaskDao _taskDao;

  @override
  Stream<List<Task>> watchTasksForDate(String date) {
    return _taskDao.watchTasksForDate(date);
  }

  @override
  Future<List<Task>> getTasksForDate(String date) {
    return _taskDao.getTasksForDate(date);
  }

  @override
  Future<List<Task>> getTasksForRange(String startDate, String endDate) {
    return _taskDao.getTasksForRange(startDate, endDate);
  }

  @override
  Future<Task?> getTaskById(int id) {
    return _taskDao.getTaskById(id);
  }

  @override
  Future<int> insertTask(Task task) {
    return _taskDao.insertTask(task);
  }

  @override
  Future<bool> updateTask(Task task) {
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