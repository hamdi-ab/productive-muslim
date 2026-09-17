import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/models/barakah_prompt.dart';

sealed class BarakahState {
  const BarakahState({this.daily});

  final BarakahDailyDraft? daily;

  const factory BarakahState.initial() = Initial;
  const factory BarakahState.loading() = Loading;
  const factory BarakahState.loaded(List<BarakahEntry> entries) = Loaded;
  const factory BarakahState.error(String message) = Error;

  BarakahState withDaily(BarakahDailyDraft draft) => switch (this) {
    Initial() => Initial(daily: draft),
    Loading() => Loading(daily: draft),
    Loaded(:final entries) => Loaded(entries, daily: draft),
    Error(:final message) => Error(message, daily: draft),
  };
}

class Initial extends BarakahState {
  const Initial({super.daily});
}

class Loading extends BarakahState {
  const Loading({super.daily});
}

class Loaded extends BarakahState {
  final List<BarakahEntry> entries;
  const Loaded(this.entries, {super.daily});
}

class Error extends BarakahState {
  final String message;
  const Error(this.message, {super.daily});
}

class BarakahDailyDraft {
  BarakahDailyDraft({
    required this.date,
    required this.prompt,
    this.response,
    this.answer,
    List<String> sourceIds = const [],
    this.note = '',
    this.loading = false,
    this.saving = false,
    this.saved = false,
    this.failure = false,
    this.dirty = false,
  }) : sourceIds = List.unmodifiable(sourceIds);

  final String date;
  final BarakahPrompt prompt;
  final BarakahDailyResponse? response;
  final BarakahAnswer? answer;
  final List<String> sourceIds;
  final String note;
  final bool loading;
  final bool saving;
  final bool saved;
  final bool failure;
  final bool dirty;

  bool get allowsSources =>
      answer == BarakahAnswer.yes || answer == BarakahAnswer.somewhat;

  BarakahDailyDraft copyWith({
    BarakahDailyResponse? response,
    BarakahAnswer? answer,
    List<String>? sourceIds,
    String? note,
    bool? loading,
    bool? saving,
    bool? saved,
    bool? failure,
    bool? dirty,
  }) => BarakahDailyDraft(
    date: date,
    prompt: prompt,
    response: response ?? this.response,
    answer: answer ?? this.answer,
    sourceIds: sourceIds ?? this.sourceIds,
    note: note ?? this.note,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    failure: failure ?? this.failure,
    dirty: dirty ?? this.dirty,
  );
}
