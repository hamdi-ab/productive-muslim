import 'package:productive_muslim/domain/models/barakah_reminder.dart';

abstract interface class BarakahReminderScheduler {
  bool get supported;
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<bool> hasPermission();
  Future<void> schedule(BarakahReminder reminder, ReminderContent content);
  Future<void> cancel();
}
