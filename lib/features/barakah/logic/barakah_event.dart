import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';

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

class BarakahDailyResponseLoaded extends BarakahEvent {
  final String date;
  BarakahDailyResponseLoaded(this.date);
}

class BarakahDailyResponseSaved extends BarakahEvent {
  const BarakahDailyResponseSaved();
}

class BarakahAnswerSelected extends BarakahEvent {
  final BarakahAnswer answer;
  BarakahAnswerSelected(this.answer);
}

class BarakahSourceToggled extends BarakahEvent {
  final String sourceId;
  BarakahSourceToggled(this.sourceId);
}

class BarakahNoteChanged extends BarakahEvent {
  final String note;
  BarakahNoteChanged(this.note);
}

class BarakahDailyResponseReceived extends BarakahEvent {
  final String date;
  final int generation;
  final BarakahDailyResponse? response;
  BarakahDailyResponseReceived(this.date, this.generation, this.response);
}

class BarakahDailyResponseFailed extends BarakahEvent {
  final String date;
  final int generation;
  BarakahDailyResponseFailed(this.date, this.generation);
}
