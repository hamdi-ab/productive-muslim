import 'package:productive_muslim/domain/models/intention_entry.dart';

sealed class IntentionState {
  const IntentionState();

  const factory IntentionState.initial() = IntentionInitial;
  const factory IntentionState.loading() = IntentionLoading;
  const factory IntentionState.loaded(List<IntentionEntry> entries) =
      IntentionLoaded;
  const factory IntentionState.error(String message) = IntentionError;
}

class IntentionInitial extends IntentionState {
  const IntentionInitial();
}

class IntentionLoading extends IntentionState {
  const IntentionLoading();
}

class IntentionLoaded extends IntentionState {
  final List<IntentionEntry> entries;
  const IntentionLoaded(this.entries);
}

class IntentionError extends IntentionState {
  final String message;
  const IntentionError(this.message);
}
