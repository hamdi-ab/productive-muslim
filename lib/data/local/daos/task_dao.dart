import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/database/tables/tasks.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Stream<List<Task>> watchTasksForDate(String date) {
    return (select(tasks)
          ..where((t) => t.date.equals(date))
          ..where((t) => t.active.equals(1))
          ..orderBy([(t) => OrderingTerm.asc(t.startMinutes)]))
        .watch();
  }

  Future<List<Task>> getTasksForDate(String date) {
    return (select(tasks)
          ..where((t) => t.date.equals(date))
          ..where((t) => t.active.equals(1))
          ..orderBy([(t) => OrderingTerm.asc(t.startMinutes)]))
        .get();
  }

  Future<List<Task>> getTasksForRange(String startDate, String endDate) {
    return (select(tasks)
          ..where((t) => t.date.isBetweenValues(startDate, endDate))
          ..where((t) => t.active.equals(1)))
        .get();
  }

  Future<Task?> getTaskById(int id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertTask(TasksCompanion insert) {
    return into(tasks).insert(insert);
  }

  Future<bool> updateTask(Task task) {
    return update(tasks).replace(task);
  }

  Future<int> toggleTask(int id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(completed: Value(1), completedAt: Value(0)),
    );
  }

  Future<int> deactivateTask(int id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(active: Value(0)),
    );
  }

  Future<int> getLifetimeCompletedTasksCount() async {
    final rows = await (select(
      tasks,
    )..where((t) => t.completed.equals(1))).get();
    return rows.length;
  }
}
