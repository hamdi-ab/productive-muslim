import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/data/services/prayer_notification_scheduler.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Modal bottom sheet for configuring opt-in Morning and Evening Adhkar reminders.
/// Reminders are disabled by default, peaceful, offline, and non-judgmental.
class AdhkarRemindersSheet extends StatefulWidget {
  const AdhkarRemindersSheet({super.key});

  @override
  State<AdhkarRemindersSheet> createState() => _AdhkarRemindersSheetState();
}

class _AdhkarRemindersSheetState extends State<AdhkarRemindersSheet> {
  SettingsService? get _settingsService =>
      getIt.isRegistered<SettingsService>() ? getIt<SettingsService>() : null;

  PrayerNotificationScheduler? get _scheduler =>
      getIt.isRegistered<PrayerNotificationScheduler>()
      ? getIt<PrayerNotificationScheduler>()
      : null;

  late bool _globalEnabled;
  late bool _morningEnabled;
  late int _morningHour;
  late int _morningMinute;
  late bool _eveningEnabled;
  late int _eveningHour;
  late int _eveningMinute;
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    _loadState();
    _checkPermission();
  }

  void _loadState() {
    final s = _settingsService;
    if (s != null) {
      _globalEnabled = s.adhkarRemindersGlobalEnabled;
      _morningEnabled = s.morningAdhkarNotificationEnabled;
      _morningHour = s.morningAdhkarReminderHour;
      _morningMinute = s.morningAdhkarReminderMinute;
      _eveningEnabled = s.eveningAdhkarNotificationEnabled;
      _eveningHour = s.eveningAdhkarReminderHour;
      _eveningMinute = s.eveningAdhkarReminderMinute;
    } else {
      _globalEnabled = true;
      _morningEnabled = false;
      _morningHour = 7;
      _morningMinute = 0;
      _eveningEnabled = false;
      _eveningHour = 18;
      _eveningMinute = 0;
    }
  }

  Future<void> _checkPermission() async {
    if (_scheduler != null) {
      final permitted = await _scheduler!.hasPermission();
      if (mounted) {
        setState(() => _hasPermission = permitted);
      }
    }
  }

  Future<void> _requestPermission() async {
    AppHaptics.selectionClick();
    if (_scheduler != null) {
      final granted = await _scheduler!.requestPermission();
      if (mounted) {
        setState(() => _hasPermission = granted);
      }
      if (granted) {
        await _reschedule();
      }
    }
  }

  Future<void> _reschedule() async {
    if (_scheduler == null) return;
    final locale = Localizations.localeOf(context).languageCode;
    await _scheduler!.rescheduleAdhkarReminders(locale: locale);
  }

  void _showErrorSnackBar() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('adhkar_reminder_error_snackbar'),
        content: Text(l10n.adhkarReminderScheduleError),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _toggleGlobal(bool value) async {
    AppHaptics.selectionClick();
    final prev = _globalEnabled;
    setState(() => _globalEnabled = value);

    if (value && !_hasPermission) {
      await _requestPermission();
    }

    try {
      if (_settingsService != null) {
        await _settingsService!.setAdhkarRemindersGlobalEnabled(value);
      }
      await _reschedule();
    } catch (_) {
      if (mounted) {
        setState(() => _globalEnabled = prev);
        await _settingsService?.setAdhkarRemindersGlobalEnabled(prev);
        _showErrorSnackBar();
      }
    }
  }

  Future<void> _toggleMorning(bool value) async {
    AppHaptics.selectionClick();
    final prev = _morningEnabled;
    setState(() => _morningEnabled = value);

    if (value && !_hasPermission) {
      await _requestPermission();
    }

    try {
      if (_settingsService != null) {
        await _settingsService!.setMorningAdhkarNotificationEnabled(value);
      }
      await _reschedule();
    } catch (_) {
      if (mounted) {
        setState(() => _morningEnabled = prev);
        await _settingsService?.setMorningAdhkarNotificationEnabled(prev);
        _showErrorSnackBar();
      }
    }
  }

  Future<void> _pickMorningTime() async {
    AppHaptics.selectionClick();
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _morningHour, minute: _morningMinute),
    );
    if (!mounted || selected == null) return;

    final prevHour = _morningHour;
    final prevMinute = _morningMinute;

    setState(() {
      _morningHour = selected.hour;
      _morningMinute = selected.minute;
    });

    try {
      if (_settingsService != null) {
        await _settingsService!.setMorningAdhkarReminderTime(
          hour: selected.hour,
          minute: selected.minute,
        );
      }
      if (_morningEnabled && _globalEnabled) {
        await _reschedule();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _morningHour = prevHour;
          _morningMinute = prevMinute;
        });
        await _settingsService?.setMorningAdhkarReminderTime(
          hour: prevHour,
          minute: prevMinute,
        );
        _showErrorSnackBar();
      }
    }
  }

  Future<void> _toggleEvening(bool value) async {
    AppHaptics.selectionClick();
    final prev = _eveningEnabled;
    setState(() => _eveningEnabled = value);

    if (value && !_hasPermission) {
      await _requestPermission();
    }

    try {
      if (_settingsService != null) {
        await _settingsService!.setEveningAdhkarNotificationEnabled(value);
      }
      await _reschedule();
    } catch (_) {
      if (mounted) {
        setState(() => _eveningEnabled = prev);
        await _settingsService?.setEveningAdhkarNotificationEnabled(prev);
        _showErrorSnackBar();
      }
    }
  }

  Future<void> _pickEveningTime() async {
    AppHaptics.selectionClick();
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _eveningHour, minute: _eveningMinute),
    );
    if (!mounted || selected == null) return;

    final prevHour = _eveningHour;
    final prevMinute = _eveningMinute;

    setState(() {
      _eveningHour = selected.hour;
      _eveningMinute = selected.minute;
    });

    try {
      if (_settingsService != null) {
        await _settingsService!.setEveningAdhkarReminderTime(
          hour: selected.hour,
          minute: selected.minute,
        );
      }
      if (_eveningEnabled && _globalEnabled) {
        await _reschedule();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _eveningHour = prevHour;
          _eveningMinute = prevMinute;
        });
        await _settingsService?.setEveningAdhkarReminderTime(
          hour: prevHour,
          minute: prevMinute,
        );
        _showErrorSnackBar();
      }
    }
  }

  String _formatTime(int hour, int minute) {
    final tod = TimeOfDay(hour: hour, minute: minute);
    return tod.format(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title and Subtitle
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.adhkarRemindersTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.adhkarRemindersSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Permission Warning Banner (if permission not granted)
              if (!_hasPermission) ...[
                _buildPermissionWarningCard(l10n, isDark: isDark),
                const SizedBox(height: AppSpacing.md),
              ],

              // Master Global Switch Card
              _buildGlobalToggleCard(l10n, isDark: isDark),
              const SizedBox(height: AppSpacing.md),

              // Morning Adhkar Card
              _buildReminderCard(
                title: l10n.adhkarMorning,
                desc: l10n.adhkarMorningReminderDesc,
                icon: Icons.wb_sunny_outlined,
                iconColor: const Color(0xFFEAB308),
                cardKey: const Key('adhkar_morning_reminder_card'),
                toggleKey: const Key('adhkar_morning_reminder_toggle'),
                timePickerKey: const Key('adhkar_morning_time_picker_button'),
                enabled: _morningEnabled,
                globalEnabled: _globalEnabled,
                hour: _morningHour,
                minute: _morningMinute,
                onToggle: _toggleMorning,
                onPickTime: _pickMorningTime,
                l10n: l10n,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.md),

              // Evening Adhkar Card
              _buildReminderCard(
                title: l10n.adhkarEvening,
                desc: l10n.adhkarEveningReminderDesc,
                icon: Icons.nights_stay_outlined,
                iconColor: const Color(0xFF6366F1),
                cardKey: const Key('adhkar_evening_reminder_card'),
                toggleKey: const Key('adhkar_evening_reminder_toggle'),
                timePickerKey: const Key('adhkar_evening_time_picker_button'),
                enabled: _eveningEnabled,
                globalEnabled: _globalEnabled,
                hour: _eveningHour,
                minute: _eveningMinute,
                onToggle: _toggleEvening,
                onPickTime: _pickEveningTime,
                l10n: l10n,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.md),

              // Peaceful, Gentle Notice
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryLight.withValues(alpha: 0.08)
                      : AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.spa_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.adhkarRemindersPeacefulNotice,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionWarningCard(
    AppLocalizations l10n, {
    required bool isDark,
  }) {
    return Container(
      key: const Key('adhkar_reminders_permission_warning'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_off_outlined,
                color: Color(0xFFB45309),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.adhkarRemindersPermissionRequired,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFFB45309),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.adhkarRemindersPermissionDesc,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            key: const Key('adhkar_reminders_grant_permission_button'),
            onPressed: _requestPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.adhkarRemindersGrantPermission,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalToggleCard(AppLocalizations l10n, {required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.adhkarRemindersGlobalLabel,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.adhkarRemindersGlobalDesc,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            key: const Key('adhkar_reminders_global_toggle'),
            value: _globalEnabled,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            onChanged: _toggleGlobal,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color iconColor,
    required Key cardKey,
    required Key toggleKey,
    required Key timePickerKey,
    required bool enabled,
    required bool globalEnabled,
    required int hour,
    required int minute,
    required ValueChanged<bool> onToggle,
    required VoidCallback onPickTime,
    required AppLocalizations l10n,
    required bool isDark,
  }) {
    final isEffectivelyActive = globalEnabled && enabled;

    return Container(
      key: cardKey,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                key: toggleKey,
                value: enabled,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                onChanged: globalEnabled ? onToggle : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.adhkarReminderSetTime,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: OutlinedButton.icon(
                  key: timePickerKey,
                  onPressed: globalEnabled ? onPickTime : null,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: Text(
                    _formatTime(hour, minute),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: isEffectivelyActive
                        ? AppColors.primary
                        : (isDark ? Colors.white70 : Colors.black87),
                    side: BorderSide(
                      color: isEffectivelyActive
                          ? AppColors.primary
                          : (isDark ? Colors.white24 : Colors.black12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
