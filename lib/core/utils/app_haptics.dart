import 'package:flutter/services.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';

/// Centralized haptic feedback controller that respects the global user preference.
abstract final class AppHaptics {
  static const _channel = MethodChannel('productive_muslim/haptics');

  static bool get isEnabled {
    try {
      if (getIt.isRegistered<SettingsService>()) {
        return getIt<SettingsService>().hapticFeedbackEnabled;
      }
    } catch (_) {}
    return true;
  }

  static Future<void> _vibrateNative({
    String type = 'click',
    int duration = 30,
    int? amplitude,
  }) async {
    try {
      await _channel.invokeMethod<bool>('vibrate', {
        'type': type,
        'duration': duration,
        'amplitude': ?amplitude,
      });
    } catch (_) {}
  }

  /// Subtle touch feedback for regular buttons, chips, and list interactions.
  static Future<void> lightImpact() async {
    if (isEnabled) {
      await HapticFeedback.selectionClick();
      await _vibrateNative(type: 'click', duration: 30);
    }
  }

  /// Distinct touch feedback for toggles, milestones, and medium events.
  static Future<void> mediumImpact() async {
    if (isEnabled) {
      await HapticFeedback.mediumImpact();
      await _vibrateNative(type: 'click', duration: 55);
    }
  }

  /// Strong tactile response for goal completions, daily targets, and set finishes.
  static Future<void> heavyImpact() async {
    if (isEnabled) {
      await HapticFeedback.heavyImpact();
      await _vibrateNative(type: 'heavy', duration: 90);
    }
  }

  /// Discrete click feedback for tab bar selection, sliders, and picker wheels.
  static Future<void> selectionClick() async {
    if (isEnabled) {
      await HapticFeedback.selectionClick();
      await _vibrateNative(type: 'tick', duration: 20);
    }
  }

  /// Standard system vibration.
  static Future<void> vibrate() async {
    if (isEnabled) {
      await HapticFeedback.vibrate();
      await _vibrateNative(type: 'click', duration: 40);
    }
  }
}
