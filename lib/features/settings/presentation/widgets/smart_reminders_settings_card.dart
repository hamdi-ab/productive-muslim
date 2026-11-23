import 'package:flutter/material.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/data/services/prayer_notification_scheduler.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Card with granular controls for Solar-Anchored Adhkar and Sunnah routine reminders.
class SmartRemindersSettingsCard extends StatefulWidget {
  const SmartRemindersSettingsCard({super.key});

  @override
  State<SmartRemindersSettingsCard> createState() =>
      _SmartRemindersSettingsCardState();
}

class _SmartRemindersSettingsCardState extends State<SmartRemindersSettingsCard>
    with WidgetsBindingObserver {
  late bool _morning;
  late bool _evening;
  late bool _sleeping;
  late bool _fasting;
  late bool _qaylulah;
  late int _bedtimeHour;
  late int _bedtimeMinute;
  late int _morningHour;
  late int _morningMinute;
  late int _eveningHour;
  late int _eveningMinute;
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadValues();
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  void _loadValues() {
    if (getIt.isRegistered<SettingsService>()) {
      final s = getIt<SettingsService>();
      _morning = s.morningAdhkarNotificationEnabled;
      _evening = s.eveningAdhkarNotificationEnabled;
      _sleeping = s.sleepingAdhkarNotificationEnabled;
      _fasting = s.sunnahFastingNotificationEnabled;
      _qaylulah = s.qaylulahNotificationEnabled;
      _bedtimeHour = s.bedtimeReminderHour;
      _bedtimeMinute = s.bedtimeReminderMinute;
      _morningHour = s.morningAdhkarReminderHour;
      _morningMinute = s.morningAdhkarReminderMinute;
      _eveningHour = s.eveningAdhkarReminderHour;
      _eveningMinute = s.eveningAdhkarReminderMinute;
    } else {
      _morning = false;
      _evening = false;
      _sleeping = true;
      _fasting = true;
      _qaylulah = false;
      _bedtimeHour = 22;
      _bedtimeMinute = 30;
      _morningHour = 7;
      _morningMinute = 0;
      _eveningHour = 18;
      _eveningMinute = 0;
    }
  }

  Future<void> _checkPermission() async {
    if (getIt.isRegistered<PrayerNotificationScheduler>()) {
      final permitted = await getIt<PrayerNotificationScheduler>()
          .hasPermission();
      if (mounted) {
        final wasNotPermitted = !_hasPermission;
        setState(() => _hasPermission = permitted);
        if (permitted && wasNotPermitted) {
          await _reschedule();
        }
      }
    }
  }

  Future<bool> _requestPermission() async {
    AppHaptics.selectionClick();
    if (getIt.isRegistered<PrayerNotificationScheduler>()) {
      final granted = await getIt<PrayerNotificationScheduler>()
          .requestPermission();
      if (mounted) {
        setState(() => _hasPermission = granted);
      }
      if (granted) {
        await _reschedule();
      }
      return granted;
    }
    return false;
  }

  void _showErrorSnackBar() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('smart_reminders_error_snackbar'),
        content: Text(l10n.adhkarReminderScheduleError),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPermissionDeniedSnackBar() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('smart_reminders_permission_snackbar'),
        content: Text(l10n.adhkarRemindersPermissionDesc),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _reschedule() async {
    if (!getIt.isRegistered<PrayerNotificationScheduler>()) return;
    final scheduler = getIt<PrayerNotificationScheduler>();
    final prayerService = getIt.isRegistered<PrayerTimeService>()
        ? getIt<PrayerTimeService>()
        : null;

    final position = prayerService?.getCachedOrSavedPosition();
    if (!mounted) return;

    final locale = Localizations.localeOf(context).languageCode;
    if (position != null) {
      final now = DateTime.now();
      final times = prayerService?.getPrayerTimes(position, date: now);
      final tomorrowTimes = prayerService?.getPrayerTimes(
        position,
        date: now.add(const Duration(days: 1)),
      );
      await scheduler.rescheduleAll(
        prayerTimes: times,
        tomorrowPrayerTimes: tomorrowTimes,
        locale: locale,
      );
    } else {
      await scheduler.rescheduleLocationIndependentReminders(locale: locale);
    }
  }

  Future<void> _toggleMorning(bool value) async {
    AppHaptics.selectionClick();
    final prev = _morning;

    if (value && !_hasPermission) {
      final granted = await _requestPermission();
      if (!granted) {
        _showPermissionDeniedSnackBar();
      }
    }

    setState(() => _morning = value);

    try {
      if (getIt.isRegistered<SettingsService>()) {
        await getIt<SettingsService>().setMorningAdhkarNotificationEnabled(
          value,
        );
      }
      await _reschedule();
    } catch (_) {
      if (mounted) {
        setState(() => _morning = prev);
        if (getIt.isRegistered<SettingsService>()) {
          await getIt<SettingsService>().setMorningAdhkarNotificationEnabled(
            prev,
          );
        }
        _showErrorSnackBar();
      }
    }
  }

  Future<void> _toggleEvening(bool value) async {
    AppHaptics.selectionClick();
    final prev = _evening;

    if (value && !_hasPermission) {
      final granted = await _requestPermission();
      if (!granted) {
        _showPermissionDeniedSnackBar();
      }
    }

    setState(() => _evening = value);

    try {
      if (getIt.isRegistered<SettingsService>()) {
        await getIt<SettingsService>().setEveningAdhkarNotificationEnabled(
          value,
        );
      }
      await _reschedule();
    } catch (_) {
      if (mounted) {
        setState(() => _evening = prev);
        if (getIt.isRegistered<SettingsService>()) {
          await getIt<SettingsService>().setEveningAdhkarNotificationEnabled(
            prev,
          );
        }
        _showErrorSnackBar();
      }
    }
  }

  Future<void> _toggleSleeping(bool value) async {
    AppHaptics.selectionClick();
    final prev = _sleeping;

    if (value && !_hasPermission) {
      final granted = await _requestPermission();
      if (!granted) {
        _showPermissionDeniedSnackBar();
      }
    }

    setState(() => _sleeping = value);

    try {
      if (getIt.isRegistered<SettingsService>()) {
        await getIt<SettingsService>().setSleepingAdhkarNotificationEnabled(
          value,
        );
      }
      await _reschedule();
    } catch (_) {
      if (mounted) {
        setState(() => _sleeping = prev);
        if (getIt.isRegistered<SettingsService>()) {
          await getIt<SettingsService>().setSleepingAdhkarNotificationEnabled(
            prev,
          );
        }
        _showErrorSnackBar();
      }
    }
  }

  Future<void> _toggleFasting(bool value) async {
    AppHaptics.selectionClick();
    final prev = _fasting;

    if (value && !_hasPermission) {
      final granted = await _requestPermission();
      if (!granted) {
        _showPermissionDeniedSnackBar();
      }
    }

    setState(() => _fasting = value);

    try {
      if (getIt.isRegistered<SettingsService>()) {
        await getIt<SettingsService>().setSunnahFastingNotificationEnabled(
          value,
        );
      }
      await _reschedule();
    } catch (_) {
      if (mounted) {
        setState(() => _fasting = prev);
        if (getIt.isRegistered<SettingsService>()) {
          await getIt<SettingsService>().setSunnahFastingNotificationEnabled(
            prev,
          );
        }
        _showErrorSnackBar();
      }
    }
  }

  Future<void> _toggleQaylulah(bool value) async {
    AppHaptics.selectionClick();
    final prev = _qaylulah;

    if (value && !_hasPermission) {
      final granted = await _requestPermission();
      if (!granted) {
        _showPermissionDeniedSnackBar();
      }
    }

    setState(() => _qaylulah = value);

    try {
      if (getIt.isRegistered<SettingsService>()) {
        await getIt<SettingsService>().setQaylulahNotificationEnabled(value);
      }
      await _reschedule();
    } catch (_) {
      if (mounted) {
        setState(() => _qaylulah = prev);
        if (getIt.isRegistered<SettingsService>()) {
          await getIt<SettingsService>().setQaylulahNotificationEnabled(prev);
        }
        _showErrorSnackBar();
      }
    }
  }

  Future<void> _pickBedtime(BuildContext context) async {
    AppHaptics.selectionClick();
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _bedtimeHour, minute: _bedtimeMinute),
    );
    if (!mounted || selected == null) return;
    final prevHour = _bedtimeHour;
    final prevMinute = _bedtimeMinute;

    setState(() {
      _bedtimeHour = selected.hour;
      _bedtimeMinute = selected.minute;
    });

    try {
      if (getIt.isRegistered<SettingsService>()) {
        await getIt<SettingsService>().setBedtimeReminderTime(
          hour: selected.hour,
          minute: selected.minute,
        );
      }
      if (_sleeping) {
        await _reschedule();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _bedtimeHour = prevHour;
          _bedtimeMinute = prevMinute;
        });
        if (getIt.isRegistered<SettingsService>()) {
          await getIt<SettingsService>().setBedtimeReminderTime(
            hour: prevHour,
            minute: prevMinute,
          );
        }
        _showErrorSnackBar();
      }
    }
  }

  Future<void> _pickMorningTime(BuildContext context) async {
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
      if (getIt.isRegistered<SettingsService>()) {
        await getIt<SettingsService>().setMorningAdhkarReminderTime(
          hour: selected.hour,
          minute: selected.minute,
        );
      }
      if (_morning) {
        await _reschedule();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _morningHour = prevHour;
          _morningMinute = prevMinute;
        });
        if (getIt.isRegistered<SettingsService>()) {
          await getIt<SettingsService>().setMorningAdhkarReminderTime(
            hour: prevHour,
            minute: prevMinute,
          );
        }
        _showErrorSnackBar();
      }
    }
  }

  Future<void> _pickEveningTime(BuildContext context) async {
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
      if (getIt.isRegistered<SettingsService>()) {
        await getIt<SettingsService>().setEveningAdhkarReminderTime(
          hour: selected.hour,
          minute: selected.minute,
        );
      }
      if (_evening) {
        await _reschedule();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _eveningHour = prevHour;
          _eveningMinute = prevMinute;
        });
        if (getIt.isRegistered<SettingsService>()) {
          await getIt<SettingsService>().setEveningAdhkarReminderTime(
            hour: prevHour,
            minute: prevMinute,
          );
        }
        _showErrorSnackBar();
      }
    }
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildPermissionWarningCard(
    AppLocalizations l10n, {
    required bool isDark,
  }) {
    return Container(
      key: const Key('smart_reminders_permission_warning'),
      padding: const EdgeInsets.all(12),
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
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            key: const Key('smart_reminders_grant_permission_button'),
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
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryPendingBadge(AppLocalizations l10n, {required Key key}) {
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            size: 14,
            color: Color(0xFFB45309),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.adhkarRemindersDeliveryPending,
              key: key,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFFB45309),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final morningTime = TimeOfDay(hour: _morningHour, minute: _morningMinute);
    final eveningTime = TimeOfDay(hour: _eveningHour, minute: _eveningMinute);
    final bedtime = TimeOfDay(hour: _bedtimeHour, minute: _bedtimeMinute);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);

    return Column(
      children: [
        if (!_hasPermission) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _buildPermissionWarningCard(l10n, isDark: isDark),
          ),
        ],
        SwitchListTile(
          key: const Key('setting_morning_adhkar_toggle'),
          activeThumbColor: AppColors.secondary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          secondary: _buildIconContainer(
            Icons.wb_sunny_rounded,
            const Color(0xFFF59E0B),
          ),
          title: Text(
            l10n.settingMorningAdhkar,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            l10n.settingMorningAdhkarDesc,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          value: _morning,
          onChanged: _toggleMorning,
        ),
        if (_morning && !_hasPermission) ...[
          _buildDeliveryPendingBadge(
            l10n,
            key: const Key('setting_morning_delivery_pending_badge'),
          ),
        ],
        if (_morning) ...[
          Divider(height: 1, indent: 56, endIndent: 16, color: dividerColor),
          ListTile(
            key: const Key('setting_morning_time_picker'),
            contentPadding: const EdgeInsets.only(left: 56, right: 16),
            title: Text(
              l10n.adhkarReminderSetTime,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        morningTime.format(context),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () => _pickMorningTime(context),
          ),
        ],
        Divider(height: 1, indent: 56, endIndent: 16, color: dividerColor),
        SwitchListTile(
          key: const Key('setting_qaylulah_toggle'),
          activeThumbColor: AppColors.secondary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          secondary: _buildIconContainer(
            Icons.snooze_rounded,
            const Color(0xFF10B981),
          ),
          title: Text(
            l10n.settingQaylulah,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            l10n.settingQaylulahDesc,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          value: _qaylulah,
          onChanged: _toggleQaylulah,
        ),
        if (_qaylulah && !_hasPermission) ...[
          _buildDeliveryPendingBadge(
            l10n,
            key: const Key('setting_qaylulah_delivery_pending_badge'),
          ),
        ],
        Divider(height: 1, indent: 56, endIndent: 16, color: dividerColor),
        SwitchListTile(
          key: const Key('setting_evening_adhkar_toggle'),
          activeThumbColor: AppColors.secondary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          secondary: _buildIconContainer(
            Icons.nights_stay_rounded,
            const Color(0xFF6366F1),
          ),
          title: Text(
            l10n.settingEveningAdhkar,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            l10n.settingEveningAdhkarDesc,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          value: _evening,
          onChanged: _toggleEvening,
        ),
        if (_evening && !_hasPermission) ...[
          _buildDeliveryPendingBadge(
            l10n,
            key: const Key('setting_evening_delivery_pending_badge'),
          ),
        ],
        if (_evening) ...[
          Divider(height: 1, indent: 56, endIndent: 16, color: dividerColor),
          ListTile(
            key: const Key('setting_evening_time_picker'),
            contentPadding: const EdgeInsets.only(left: 56, right: 16),
            title: Text(
              l10n.adhkarReminderSetTime,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        eveningTime.format(context),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () => _pickEveningTime(context),
          ),
        ],
        Divider(height: 1, indent: 56, endIndent: 16, color: dividerColor),
        SwitchListTile(
          key: const Key('setting_sleeping_adhkar_toggle'),
          activeThumbColor: AppColors.secondary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          secondary: _buildIconContainer(
            Icons.bedtime_rounded,
            const Color(0xFF8B5CF6),
          ),
          title: Text(
            l10n.settingBedtimeAdhkar,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            l10n.settingBedtimeAdhkarDesc,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          value: _sleeping,
          onChanged: _toggleSleeping,
        ),
        if (_sleeping && !_hasPermission) ...[
          _buildDeliveryPendingBadge(
            l10n,
            key: const Key('setting_sleeping_delivery_pending_badge'),
          ),
        ],
        if (_sleeping) ...[
          Divider(height: 1, indent: 56, endIndent: 16, color: dividerColor),
          ListTile(
            key: const Key('setting_bedtime_time_picker'),
            contentPadding: const EdgeInsets.only(left: 56, right: 16),
            title: Text(
              l10n.settingBedtimeTime,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        bedtime.format(context),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () => _pickBedtime(context),
          ),
        ],
        Divider(height: 1, indent: 56, endIndent: 16, color: dividerColor),
        SwitchListTile(
          key: const Key('setting_sunnah_fasting_toggle'),
          activeThumbColor: AppColors.secondary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          secondary: _buildIconContainer(
            Icons.restaurant_rounded,
            AppColors.secondary,
          ),
          title: Text(
            l10n.settingSunnahFasting,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            l10n.settingSunnahFastingDesc,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          value: _fasting,
          onChanged: _toggleFasting,
        ),
        if (_fasting && !_hasPermission) ...[
          _buildDeliveryPendingBadge(
            l10n,
            key: const Key('setting_fasting_delivery_pending_badge'),
          ),
        ],
      ],
    );
  }
}
