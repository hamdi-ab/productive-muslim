// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barakah_dao.dart';

// ignore_for_file: type=lint
mixin _$BarakahDaoMixin on DatabaseAccessor<AppDatabase> {
  $BarakahPromptsTable get barakahPrompts => attachedDatabase.barakahPrompts;
  $BarakahEntriesTable get barakahEntries => attachedDatabase.barakahEntries;
  $BarakahDailyResponsesTable get barakahDailyResponses =>
      attachedDatabase.barakahDailyResponses;
  BarakahDaoManager get managers => BarakahDaoManager(this);
}

class BarakahDaoManager {
  final _$BarakahDaoMixin _db;
  BarakahDaoManager(this._db);
  $$BarakahPromptsTableTableManager get barakahPrompts =>
      $$BarakahPromptsTableTableManager(
        _db.attachedDatabase,
        _db.barakahPrompts,
      );
  $$BarakahEntriesTableTableManager get barakahEntries =>
      $$BarakahEntriesTableTableManager(
        _db.attachedDatabase,
        _db.barakahEntries,
      );
  $$BarakahDailyResponsesTableTableManager get barakahDailyResponses =>
      $$BarakahDailyResponsesTableTableManager(
        _db.attachedDatabase,
        _db.barakahDailyResponses,
      );
}
