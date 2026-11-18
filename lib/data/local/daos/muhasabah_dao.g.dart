// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muhasabah_dao.dart';

// ignore_for_file: type=lint
mixin _$MuhasabahDaoMixin on DatabaseAccessor<AppDatabase> {
  $MuhasabahEntriesTable get muhasabahEntries =>
      attachedDatabase.muhasabahEntries;
  MuhasabahDaoManager get managers => MuhasabahDaoManager(this);
}

class MuhasabahDaoManager {
  final _$MuhasabahDaoMixin _db;
  MuhasabahDaoManager(this._db);
  $$MuhasabahEntriesTableTableManager get muhasabahEntries =>
      $$MuhasabahEntriesTableTableManager(
        _db.attachedDatabase,
        _db.muhasabahEntries,
      );
}
