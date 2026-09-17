class BarakahReminder {
  const BarakahReminder({
    this.enabled = false,
    this.hour = 20,
    this.minute = 0,
  });

  final bool enabled;
  final int hour;
  final int minute;
}

class ReminderContent {
  const ReminderContent({required this.title, required this.body});

  final String title;
  final String body;
}

enum ReminderFailure { permissionDenied, unavailable, operationFailed }

class ReminderStatus {
  const ReminderStatus({
    required this.reminder,
    required this.supported,
    this.pending = false,
    this.failure,
  });

  final BarakahReminder reminder;
  final bool supported;
  final bool pending;
  final ReminderFailure? failure;
}
