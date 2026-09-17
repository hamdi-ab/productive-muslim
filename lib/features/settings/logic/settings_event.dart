import 'package:productive_muslim/domain/models/barakah_reminder.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

final class SettingsLoaded extends SettingsEvent {
  const SettingsLoaded(this.content);
  final ReminderContent content;
}

final class ReminderToggled extends SettingsEvent {
  const ReminderToggled(this.enabled, this.content);
  final bool enabled;
  final ReminderContent content;
}

final class ReminderTimeChanged extends SettingsEvent {
  const ReminderTimeChanged(this.hour, this.minute, this.content);
  final int hour;
  final int minute;
  final ReminderContent content;
}

final class ReminderStatusChanged extends SettingsEvent {
  const ReminderStatusChanged(this.status);
  final ReminderStatus status;
}
