import 'package:drift/drift.dart';

class AdhkarSessions extends Table {
  TextColumn get collectionId => text()();
  IntColumn get lastPageIndex => integer().withDefault(const Constant(0))();
  TextColumn get countsJson => text().withDefault(const Constant('{}'))();
  IntColumn get lastAccessedAt => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {collectionId};
}
