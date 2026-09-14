import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService({required SharedPreferences prefs}) : _prefs = prefs;

  SettingsService._empty() : _prefs = null;

  factory SettingsService.empty() => SettingsService._empty();

  final SharedPreferences? _prefs;

  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _userNameKey = 'user_name';
  static const _userIntentionKey = 'user_intention';

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
}
