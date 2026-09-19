// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_completions_dao.dart';

// ignore_for_file: type=lint
mixin _$HabitCompletionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $HabitCompletionsTable get habitCompletions =>
      attachedDatabase.habitCompletions;
  HabitCompletionsDaoManager get managers => HabitCompletionsDaoManager(this);
}

class HabitCompletionsDaoManager {
  final _$HabitCompletionsDaoMixin _db;
  HabitCompletionsDaoManager(this._db);
  $$HabitCompletionsTableTableManager get habitCompletions =>
      $$HabitCompletionsTableTableManager(
        _db.attachedDatabase,
        _db.habitCompletions,
      );
}
