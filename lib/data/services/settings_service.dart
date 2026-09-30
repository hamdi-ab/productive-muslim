import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService({required SharedPreferences prefs}) : _prefs = prefs;

  SettingsService._empty() : _prefs = null;

  factory SettingsService.empty() => SettingsService._empty();

  final SharedPreferences? _prefs;

  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _userNameKey = 'user_name';
  static const _userIntentionKey = 'user_intention';
  static const _selectedQualitiesKey = 'selected_qualities';
  static const _barakahReminderKey = 'barakah_reminder';
  static const _locationPermissionKey = 'location_permission';
  static const _adhanNotificationsKey = 'adhan_notifications';
  static const _totalFocusMinutesKey = 'total_focus_minutes';
  static const _sunnahFastingTargetKey = 'sunnah_fasting_target';

  ({bool enabled, int hour, int minute}) get barakahReminder {
    final values = _prefs?.getStringList(_barakahReminderKey);
    if (values == null || values.length != 3) {
      return (enabled: false, hour: 20, minute: 0);
    }
    final hour = int.tryParse(values[1]);
    final minute = int.tryParse(values[2]);
    if (hour == null ||
        hour < 0 ||
        hour > 23 ||
        minute == null ||
        minute < 0 ||
        minute > 59 ||
        (values[0] != 'true' && values[0] != 'false')) {
      return (enabled: false, hour: 20, minute: 0);
    }
    return (enabled: values[0] == 'true', hour: hour, minute: minute);
  }

  Future<void> setBarakahReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    RangeError.checkValueInInterval(hour, 0, 23, 'hour');
    RangeError.checkValueInInterval(minute, 0, 59, 'minute');
    final saved = await _prefs?.setStringList(_barakahReminderKey, [
      '$enabled',
      '$hour',
      '$minute',
    ]);
    if (saved != true) throw StateError('Reminder settings were not saved');
  }

  bool get onboardingCompleted =>
      _prefs?.getBool(_onboardingCompletedKey) ?? false;

  Future<void> setOnboardingCompleted() async =>
      _prefs?.setBool(_onboardingCompletedKey, true);

  String? get userName => _prefs?.getString(_userNameKey);

  Future<void> setUserName(String name) async =>
      _prefs?.setString(_userNameKey, name);

  String? get userIntention => _prefs?.getString(_userIntentionKey);

  Future<void> setUserIntention(String intention) async =>
      _prefs?.setString(_userIntentionKey, intention);

  List<String> get selectedQualities =>
      _prefs?.getStringList(_selectedQualitiesKey) ?? [];

  Future<void> setSelectedQualities(List<String> qualities) async =>
      _prefs?.setStringList(_selectedQualitiesKey, qualities);

  /// Location permission state: 'granted', 'denied', 'denied_forever', or null (not yet requested)
  String? get locationPermission => _prefs?.getString(_locationPermissionKey);

  Future<void> setLocationPermission(String permission) async =>
      _prefs?.setString(_locationPermissionKey, permission);

  bool get adhanNotificationsEnabled =>
      _prefs?.getBool(_adhanNotificationsKey) ?? false;

  Future<void> setAdhanNotificationsEnabled(bool enabled) async =>
      _prefs?.setBool(_adhanNotificationsKey, enabled);

  int get totalFocusMinutes => _prefs?.getInt(_totalFocusMinutesKey) ?? 0;

  Future<void> addFocusMinutes(int minutes) async {
    final current = totalFocusMinutes;
    await _prefs?.setInt(_totalFocusMinutesKey, current + minutes);
  }

  bool isSunnahFastingTarget(String date) {
    final list = _prefs?.getStringList(_sunnahFastingTargetKey) ?? [];
    return list.contains(date);
  }

  Future<void> toggleSunnahFastingTarget(String date) async {
    final list = List<String>.from(
      _prefs?.getStringList(_sunnahFastingTargetKey) ?? [],
    );
    if (list.contains(date)) {
      list.remove(date);
    } else {
      list.add(date);
    }
    await _prefs?.setStringList(_sunnahFastingTargetKey, list);
  }

  ({int physical, int spiritual, int mental}) getDailyEnergy(String date) {
    final p = _prefs?.getInt('energy_p_$date') ?? 3;
    final s = _prefs?.getInt('energy_s_$date') ?? 3;
    final m = _prefs?.getInt('energy_m_$date') ?? 3;
    return (physical: p, spiritual: s, mental: m);
  }

  Future<void> setDailyEnergy({
    required String date,
    required int physical,
    required int spiritual,
    required int mental,
  }) async {
    await _prefs?.setInt('energy_p_$date', physical);
    await _prefs?.setInt('energy_s_$date', spiritual);
    await _prefs?.setInt('energy_m_$date', mental);
  }

  List<String> getCompletedDhikrIds(String date) {
    return _prefs?.getStringList('adhkar_done_$date') ?? [];
  }

  Future<void> addCompletedDhikr(String date, String dhikrId) async {
    final list = List<String>.from(
      _prefs?.getStringList('adhkar_done_$date') ?? [],
    );
    if (!list.contains(dhikrId)) {
      list.add(dhikrId);
      await _prefs?.setStringList('adhkar_done_$date', list);
    }
  }

  bool get adhkarHapticsEnabled =>
      _prefs?.getBool('adhkar_haptics_enabled') ?? true;

  Future<void> setAdhkarHapticsEnabled(bool enabled) async =>
      _prefs?.setBool('adhkar_haptics_enabled', enabled);

  // Smart Reminders & Notifications
  bool get morningAdhkarNotificationEnabled =>
      _prefs?.getBool('notif_morning_adhkar') ?? true;

  Future<void> setMorningAdhkarNotificationEnabled(bool enabled) async =>
      _prefs?.setBool('notif_morning_adhkar', enabled);

  bool get eveningAdhkarNotificationEnabled =>
      _prefs?.getBool('notif_evening_adhkar') ?? true;

  Future<void> setEveningAdhkarNotificationEnabled(bool enabled) async =>
      _prefs?.setBool('notif_evening_adhkar', enabled);

  bool get sleepingAdhkarNotificationEnabled =>
      _prefs?.getBool('notif_sleeping_adhkar') ?? true;

  Future<void> setSleepingAdhkarNotificationEnabled(bool enabled) async =>
      _prefs?.setBool('notif_sleeping_adhkar', enabled);

  bool get sunnahFastingNotificationEnabled =>
      _prefs?.getBool('notif_sunnah_fasting') ?? true;

  Future<void> setSunnahFastingNotificationEnabled(bool enabled) async =>
      _prefs?.setBool('notif_sunnah_fasting', enabled);

  bool get qaylulahNotificationEnabled =>
      _prefs?.getBool('notif_qaylulah') ?? false;

  Future<void> setQaylulahNotificationEnabled(bool enabled) async =>
      _prefs?.setBool('notif_qaylulah', enabled);

  int get bedtimeReminderHour => _prefs?.getInt('bedtime_reminder_hour') ?? 22;

  int get bedtimeReminderMinute =>
      _prefs?.getInt('bedtime_reminder_minute') ?? 30;

  Future<void> setBedtimeReminderTime({
    required int hour,
    required int minute,
  }) async {
    RangeError.checkValueInInterval(hour, 0, 23, 'hour');
    RangeError.checkValueInInterval(minute, 0, 59, 'minute');
    await _prefs?.setInt('bedtime_reminder_hour', hour);
    await _prefs?.setInt('bedtime_reminder_minute', minute);
  }

  Map<String, dynamic> exportSettings() {
    if (_prefs == null) return {};
    final map = <String, dynamic>{};
    for (final key in _prefs.getKeys()) {
      map[key] = _prefs.get(key);
    }
    return map;
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    if (_prefs == null) return;

    // Validate all values first — throw on unsupported types (null, maps,
    // etc.) so BackupService can detect failure inside the transaction and
    // roll back the database changes together with the settings write.
    for (final entry in settings.entries) {
      final val = entry.value;
      if (val == null ||
          val is Map ||
          (val is! bool &&
              val is! int &&
              val is! double &&
              val is! String &&
              val is! List)) {
        throw ArgumentError(
          'importSettings: unsupported value type for key "${entry.key}": '
          '${val.runtimeType}',
        );
      }
    }

    await _prefs.clear();
    for (final entry in settings.entries) {
      final val = entry.value;
      if (val is bool) {
        await _prefs.setBool(entry.key, val);
      } else if (val is int) {
        await _prefs.setInt(entry.key, val);
      } else if (val is double) {
        await _prefs.setDouble(entry.key, val);
      } else if (val is String) {
        await _prefs.setString(entry.key, val);
      } else if (val is List) {
        await _prefs.setStringList(
          entry.key,
          val.map((e) => e.toString()).toList(),
        );
      }
    }
  }
}
