import 'package:drift/drift.dart';

@DataClassName('AdhkarRoutineCompletionEntry')
class AdhkarRoutineCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get routineId => text()();
  TextColumn get routineName => text()();
  TextColumn get date => text()();
  IntColumn get completedAt => integer()();
}
