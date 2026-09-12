// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intention_dao.dart';

// ignore_for_file: type=lint
mixin _$IntentionDaoMixin on DatabaseAccessor<AppDatabase> {
  $IntentionEntriesTable get intentionEntries =>
      attachedDatabase.intentionEntries;
  IntentionDaoManager get managers => IntentionDaoManager(this);
}

class IntentionDaoManager {
  final _$IntentionDaoMixin _db;
  IntentionDaoManager(this._db);
  $$IntentionEntriesTableTableManager get intentionEntries =>
      $$IntentionEntriesTableTableManager(
        _db.attachedDatabase,
        _db.intentionEntries,
      );
}
