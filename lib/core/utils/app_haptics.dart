import 'package:flutter/services.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';

/// Centralized haptic feedback controller that respects the global user preference.
abstract final class AppHaptics {
  static bool get isEnabled {
    try {
      if (getIt.isRegistered<SettingsService>()) {
        return getIt<SettingsService>().hapticFeedbackEnabled;
      }
    } catch (_) {}
    return true;
  }

  /// Subtle touch feedback for regular buttons, chips, and list interactions.
  static Future<void> lightImpact() async {
    if (isEnabled) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Distinct touch feedback for toggles, milestones, and medium events.
  static Future<void> mediumImpact() async {
    if (isEnabled) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Strong tactile response for goal completions, daily targets, and set finishes.
  static Future<void> heavyImpact() async {
    if (isEnabled) {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Discrete click feedback for tab bar selection, sliders, and picker wheels.
  static Future<void> selectionClick() async {
    if (isEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  /// Standard system vibration.
  static Future<void> vibrate() async {
    if (isEnabled) {
      await HapticFeedback.vibrate();
    }
  }
}
