import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';

class BarakahEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get sourceIds => text()();
  TextColumn get promptId => text().nullable()();
  IntColumn get intensity => integer().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get skipped => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}