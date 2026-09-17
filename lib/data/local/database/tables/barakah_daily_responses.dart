import 'package:drift/drift.dart';

@DataClassName('BarakahDailyResponseRow')
class BarakahDailyResponses extends Table {
  TextColumn get date => text()();
  TextColumn get promptId => text()();
  TextColumn get answer => text()();
  TextColumn get sourceIds => text()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer().withDefault(
    const CustomExpression<int>("(strftime('%s','now') * 1000)"),
  )();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {date};
}
