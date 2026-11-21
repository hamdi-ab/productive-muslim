import 'package:drift/drift.dart';

@DataClassName('AdhkarTasbihEntry')
class AdhkarTasbih extends Table {
  TextColumn get id => text()(); // e.g. 'default'
  IntColumn get currentCount => integer().withDefault(const Constant(0))();
  IntColumn get targetCount => integer().nullable()();
  TextColumn get dhikrId => text().nullable()();
  TextColumn get customLabel => text().nullable()();
  IntColumn get lastCount => integer().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
