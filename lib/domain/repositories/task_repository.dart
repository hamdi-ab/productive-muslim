import 'package:productive_muslim/domain/models/task.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchTasksForDate(String date);
  Future<List<Task>> getTasksForDate(String date);
  Future<List<Task>> getTasksForRange(String startDate, String endDate);
  Future<Task?> getTaskById(int id);
  Future<int> insertTask(Task task);
  Future<bool> updateTask(Task task);
  Future<int> toggleTask(int id);
  Future<int> deactivateTask(int id);
}