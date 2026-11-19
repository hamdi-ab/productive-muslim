import 'package:drift/drift.dart';

class AdhkarCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get collectionId => text()();
  TextColumn get date => text()();
  IntColumn get completedAt => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {collectionId, date},
  ];
}
