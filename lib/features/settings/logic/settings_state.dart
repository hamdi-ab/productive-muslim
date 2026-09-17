import 'package:flutter/foundation.dart';
import 'package:productive_muslim/domain/models/barakah_reminder.dart';

@immutable
final class SettingsState {
  const SettingsState(this.status);

  final ReminderStatus status;
  bool get enabled => status.reminder.enabled;
  int get hour => status.reminder.hour;
  int get minute => status.reminder.minute;
  bool get pending => status.pending;
  bool get supported => status.supported;
  ReminderFailure? get failure => status.failure;
}
