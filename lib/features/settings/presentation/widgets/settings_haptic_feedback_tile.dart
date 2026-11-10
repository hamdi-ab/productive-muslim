import 'package:flutter/material.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Switch tile allowing users to enable or disable tactile haptic responses across the application.
class SettingsHapticFeedbackTile extends StatefulWidget {
  const SettingsHapticFeedbackTile({super.key});

  @override
  State<SettingsHapticFeedbackTile> createState() =>
      _SettingsHapticFeedbackTileState();
}

class _SettingsHapticFeedbackTileState
    extends State<SettingsHapticFeedbackTile> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<SettingsService>()) {
      _enabled = getIt<SettingsService>().hapticFeedbackEnabled;
    }
  }

  Future<void> _toggle(bool value) async {
    if (getIt.isRegistered<SettingsService>()) {
      await getIt<SettingsService>().setHapticFeedbackEnabled(value);
    }
    setState(() => _enabled = value);
    if (value) {
      AppHaptics.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SwitchListTile(
      key: const Key('settings_haptic_feedback_toggle'),
      activeThumbColor: AppColors.secondary,
      activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.vibration_rounded,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        l10n.hapticFeedback,
        style: const TextStyle(fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        l10n.hapticFeedbackDesc,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white60 : Colors.black54,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      value: _enabled,
      onChanged: _toggle,
    );
  }
}
