import 'package:drift/drift.dart';

class IntentionEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get title => text()();
  TextColumn get statement => text().nullable()();
  TextColumn get category => text().nullable()();
  IntColumn get completed => integer().withDefault(const Constant(0))();
  TextColumn get reflection => text().nullable()();
  IntColumn get createdAt => integer().withDefault(const Constant(0))();
}
