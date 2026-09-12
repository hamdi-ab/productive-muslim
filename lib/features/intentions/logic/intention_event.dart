import 'package:productive_muslim/domain/models/intention_entry.dart';

sealed class IntentionEvent {
  const IntentionEvent();

  factory IntentionEvent.loaded(String date) = IntentionEntriesLoaded;
  factory IntentionEvent.created(IntentionEntry entry) = IntentionCreated;
  factory IntentionEvent.toggled(IntentionEntry entry) = IntentionToggled;
  factory IntentionEvent.deleted(int entryId) = IntentionDeleted;
  factory IntentionEvent.reflectionSaved(int entryId, String reflection) = IntentionReflectionSaved;
}

class IntentionEntriesLoaded extends IntentionEvent {
  final String date;
  IntentionEntriesLoaded(this.date);
}

class IntentionCreated extends IntentionEvent {
  final IntentionEntry entry;
  IntentionCreated(this.entry);
}

class IntentionToggled extends IntentionEvent {
  final IntentionEntry entry;
  IntentionToggled(this.entry);
}

class IntentionDeleted extends IntentionEvent {
  final int entryId;
  IntentionDeleted(this.entryId);
}

class IntentionReflectionSaved extends IntentionEvent {
  final int entryId;
  final String reflection;
  IntentionReflectionSaved(this.entryId, this.reflection);
}