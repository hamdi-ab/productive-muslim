import 'package:drift/drift.dart';

class AdhkarBookmarks extends Table {
  TextColumn get dhikrId => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {dhikrId};
}
