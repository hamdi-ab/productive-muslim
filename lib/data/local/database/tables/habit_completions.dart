import 'package:drift/drift.dart';

class HabitCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer()();
  TextColumn get date => text()();
  IntColumn get completed => integer().withDefault(const Constant(1))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {habitId, date},
  ];
}
