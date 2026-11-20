import 'package:drift/drift.dart';

@DataClassName('AdhkarRoutineEntry')
class AdhkarRoutines extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get itemIdsJson => text()();
  TextColumn get preferredTime => text().nullable()();
  TextColumn get weekdaysJson => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get retiredItemIdsJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
