import 'package:productive_muslim/domain/models/barakah_entry.dart';

sealed class BarakahEvent {
  const BarakahEvent();

  factory BarakahEvent.loaded(String date) = BarakahLoaded;
  factory BarakahEvent.logged(BarakahEntry entry) = BarakahLogged;
  factory BarakahEvent.skipped(String date) = BarakahSkipped;
  factory BarakahEvent.deleted(int entryId) = BarakahDeleted;
}

class BarakahLoaded extends BarakahEvent {
  final String date;
  BarakahLoaded(this.date);
}

class BarakahLogged extends BarakahEvent {
  final BarakahEntry entry;
  BarakahLogged(this.entry);
}

class BarakahSkipped extends BarakahEvent {
  final String date;
  BarakahSkipped(this.date);
}

class BarakahDeleted extends BarakahEvent {
  final int entryId;
  BarakahDeleted(this.entryId);
}
