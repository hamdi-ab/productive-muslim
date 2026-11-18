import 'package:drift/drift.dart';

@DataClassName('MuhasabahEntryRow')
class MuhasabahEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get promptId => text().nullable()();
  TextColumn get promptText => text().nullable()();
  TextColumn get content => text()();
  TextColumn get tags => text().nullable()();
  IntColumn get createdAt => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();
}
