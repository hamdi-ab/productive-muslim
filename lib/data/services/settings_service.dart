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
}
