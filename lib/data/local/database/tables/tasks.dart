import 'package:drift/drift.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get lifeArea => text()();
  IntColumn get startMinutes => integer().nullable()();
  IntColumn get endMinutes => integer().nullable()();
  TextColumn get date => text()();
  IntColumn get repeatDaily => integer().withDefault(const Constant(0))();
  IntColumn get repeatWeekly => integer().withDefault(const Constant(0))();
  TextColumn get repeatDays => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get completed => integer().withDefault(const Constant(0))();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get createdAt => integer().withDefault(const Constant(0))();
  IntColumn get active => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}