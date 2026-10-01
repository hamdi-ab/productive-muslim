import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/data/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppHaptics Tests', () {
    late SettingsService settingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService(prefs: prefs);

      if (getIt.isRegistered<SettingsService>()) {
        getIt.unregister<SettingsService>();
      }
      getIt.registerSingleton<SettingsService>(settingsService);
    });

    tearDown(() {
      if (getIt.isRegistered<SettingsService>()) {
        getIt.unregister<SettingsService>();
      }
    });

    test('isEnabled is true by default', () {
      expect(AppHaptics.isEnabled, isTrue);
    });

    test('isEnabled reflects SettingsService value when disabled', () async {
      await settingsService.setHapticFeedbackEnabled(false);
      expect(AppHaptics.isEnabled, isFalse);
    });

    test(
      'methods execute without error regardless of enabled status',
      () async {
        await AppHaptics.lightImpact();
        await AppHaptics.mediumImpact();
        await AppHaptics.heavyImpact();
        await AppHaptics.selectionClick();
        await AppHaptics.vibrate();

        await settingsService.setHapticFeedbackEnabled(false);
        await AppHaptics.lightImpact();
        await AppHaptics.mediumImpact();
        await AppHaptics.heavyImpact();
        await AppHaptics.selectionClick();
        await AppHaptics.vibrate();
      },
    );
  });
}
