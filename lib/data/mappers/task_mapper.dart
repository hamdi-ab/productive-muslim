import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/mappers/domain_mapper.dart';
import 'package:productive_muslim/domain/models/task.dart' as task_model;

class TaskMapper implements DomainMapper<task_model.Task, Task> {
  @override
  task_model.Task toDomain(Task row) {
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

  @override
  Task toRow(task_model.Task task) {
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
}
