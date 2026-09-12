import 'package:drift/drift.dart';

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get frequency => text().withDefault(const Constant('daily'))();
  TextColumn get targetDays => text().nullable()();
  IntColumn get reminderEnabled => integer().withDefault(const Constant(0))();
  IntColumn get reminderTime => integer().nullable()();
  IntColumn get active => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer().withDefault(const Constant(0))();
}
