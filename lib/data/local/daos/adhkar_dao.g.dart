// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adhkar_dao.dart';

// ignore_for_file: type=lint
mixin _$AdhkarDaoMixin on DatabaseAccessor<AppDatabase> {
  $AdhkarBookmarksTable get adhkarBookmarks => attachedDatabase.adhkarBookmarks;
  $AdhkarSessionsTable get adhkarSessions => attachedDatabase.adhkarSessions;
  $AdhkarCompletionsTable get adhkarCompletions =>
      attachedDatabase.adhkarCompletions;
  $AdhkarRoutinesTable get adhkarRoutines => attachedDatabase.adhkarRoutines;
  $AdhkarRoutineCompletionsTable get adhkarRoutineCompletions =>
      attachedDatabase.adhkarRoutineCompletions;
  AdhkarDaoManager get managers => AdhkarDaoManager(this);
}

class AdhkarDaoManager {
  final _$AdhkarDaoMixin _db;
  AdhkarDaoManager(this._db);
  $$AdhkarBookmarksTableTableManager get adhkarBookmarks =>
      $$AdhkarBookmarksTableTableManager(
        _db.attachedDatabase,
        _db.adhkarBookmarks,
      );
  $$AdhkarSessionsTableTableManager get adhkarSessions =>
      $$AdhkarSessionsTableTableManager(
        _db.attachedDatabase,
        _db.adhkarSessions,
      );
  $$AdhkarCompletionsTableTableManager get adhkarCompletions =>
      $$AdhkarCompletionsTableTableManager(
        _db.attachedDatabase,
        _db.adhkarCompletions,
      );
  $$AdhkarRoutinesTableTableManager get adhkarRoutines =>
      $$AdhkarRoutinesTableTableManager(
        _db.attachedDatabase,
        _db.adhkarRoutines,
      );
  $$AdhkarRoutineCompletionsTableTableManager get adhkarRoutineCompletions =>
      $$AdhkarRoutineCompletionsTableTableManager(
        _db.attachedDatabase,
        _db.adhkarRoutineCompletions,
      );
}
