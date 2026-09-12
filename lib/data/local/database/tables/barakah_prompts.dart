import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';

class BarakahPrompts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sourceIds => text()();
  TextColumn get question => text()();
  IntColumn get active => integer().withDefault(const Constant(1))();
  IntColumn get displayOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
