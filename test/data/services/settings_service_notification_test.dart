import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsService settingsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);
  });

  group('SettingsService Smart Notification Preferences', () {
    test('defaults are opt-in (disabled) for morning/evening adhkar and enabled for others', () {
      expect(settingsService.morningAdhkarNotificationEnabled, isFalse);
      expect(settingsService.eveningAdhkarNotificationEnabled, isFalse);
      expect(settingsService.adhkarRemindersGlobalEnabled, isTrue);
      expect(settingsService.morningAdhkarReminderHour, equals(7));
      expect(settingsService.morningAdhkarReminderMinute, equals(0));
      expect(settingsService.eveningAdhkarReminderHour, equals(18));
      expect(settingsService.eveningAdhkarReminderMinute, equals(0));
      expect(settingsService.sleepingAdhkarNotificationEnabled, isTrue);
      expect(settingsService.sunnahFastingNotificationEnabled, isTrue);
      expect(settingsService.qaylulahNotificationEnabled, isFalse);
      expect(settingsService.bedtimeReminderHour, equals(22));
      expect(settingsService.bedtimeReminderMinute, equals(30));
    });

    test('can toggle preferences and persist', () async {
      await settingsService.setMorningAdhkarNotificationEnabled(true);
      expect(settingsService.morningAdhkarNotificationEnabled, isTrue);

      await settingsService.setEveningAdhkarNotificationEnabled(true);
      expect(settingsService.eveningAdhkarNotificationEnabled, isTrue);

      await settingsService.setAdhkarRemindersGlobalEnabled(false);
      expect(settingsService.adhkarRemindersGlobalEnabled, isFalse);

      await settingsService.setMorningAdhkarReminderTime(hour: 6, minute: 30);
      expect(settingsService.morningAdhkarReminderHour, equals(6));
      expect(settingsService.morningAdhkarReminderMinute, equals(30));

      await settingsService.setEveningAdhkarReminderTime(hour: 17, minute: 45);
      expect(settingsService.eveningAdhkarReminderHour, equals(17));
      expect(settingsService.eveningAdhkarReminderMinute, equals(45));

      await settingsService.setSleepingAdhkarNotificationEnabled(false);
      expect(settingsService.sleepingAdhkarNotificationEnabled, isFalse);

      await settingsService.setSunnahFastingNotificationEnabled(false);
      expect(settingsService.sunnahFastingNotificationEnabled, isFalse);

      await settingsService.setQaylulahNotificationEnabled(true);
      expect(settingsService.qaylulahNotificationEnabled, isTrue);

      await settingsService.setBedtimeReminderTime(hour: 23, minute: 15);
      expect(settingsService.bedtimeReminderHour, equals(23));
      expect(settingsService.bedtimeReminderMinute, equals(15));
    });
  });
}
