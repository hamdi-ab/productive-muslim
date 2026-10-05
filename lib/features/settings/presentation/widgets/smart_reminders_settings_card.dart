import 'package:flutter/material.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
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

class _SmartRemindersSettingsCardState
    extends State<SmartRemindersSettingsCard> {
  late bool _morning;
  late bool _evening;
  late bool _sleeping;
  late bool _fasting;
  late bool _qaylulah;
  late int _bedtimeHour;
  late int _bedtimeMinute;

  @override
  void initState() {
    super.initState();
    _loadValues();
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
    } else {
      _morning = true;
      _evening = true;
      _sleeping = true;
      _fasting = true;
      _qaylulah = false;
      _bedtimeHour = 22;
      _bedtimeMinute = 30;
    }
  }

  Future<void> _reschedule() async {
    if (!getIt.isRegistered<PrayerNotificationScheduler>()) return;
    final scheduler = getIt<PrayerNotificationScheduler>();
    final prayerService = getIt.isRegistered<PrayerTimeService>()
        ? getIt<PrayerTimeService>()
        : null;

    final position = await prayerService?.getCurrentPosition();
    if (!mounted) return;

    final now = DateTime.now();
    final times = position != null
        ? prayerService?.getPrayerTimes(position, date: now)
        : null;
    final tomorrowTimes = position != null
        ? prayerService?.getPrayerTimes(
            position,
            date: now.add(const Duration(days: 1)),
          )
        : null;

    final locale = Localizations.localeOf(context).languageCode;
    await scheduler.rescheduleAll(
      prayerTimes: times,
      tomorrowPrayerTimes: tomorrowTimes,
      locale: locale,
    );
  }

  Future<void> _toggleMorning(bool value) async {
    if (getIt.isRegistered<SettingsService>()) {
      await getIt<SettingsService>().setMorningAdhkarNotificationEnabled(value);
    }
    if (!mounted) return;
    setState(() => _morning = value);
    await _reschedule();
  }

  Future<void> _toggleEvening(bool value) async {
    if (getIt.isRegistered<SettingsService>()) {
      await getIt<SettingsService>().setEveningAdhkarNotificationEnabled(value);
    }
    if (!mounted) return;
    setState(() => _evening = value);
    await _reschedule();
  }

  Future<void> _toggleSleeping(bool value) async {
    if (getIt.isRegistered<SettingsService>()) {
      await getIt<SettingsService>().setSleepingAdhkarNotificationEnabled(
        value,
      );
    }
    if (!mounted) return;
    setState(() => _sleeping = value);
    await _reschedule();
  }

  Future<void> _toggleFasting(bool value) async {
    if (getIt.isRegistered<SettingsService>()) {
      await getIt<SettingsService>().setSunnahFastingNotificationEnabled(value);
    }
    if (!mounted) return;
    setState(() => _fasting = value);
    await _reschedule();
  }

  Future<void> _toggleQaylulah(bool value) async {
    if (getIt.isRegistered<SettingsService>()) {
      await getIt<SettingsService>().setQaylulahNotificationEnabled(value);
    }
    if (!mounted) return;
    setState(() => _qaylulah = value);
    await _reschedule();
  }

  Future<void> _pickBedtime(BuildContext context) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _bedtimeHour, minute: _bedtimeMinute),
    );
    if (!mounted) return;
    if (selected != null) {
      if (getIt.isRegistered<SettingsService>()) {
        await getIt<SettingsService>().setBedtimeReminderTime(
          hour: selected.hour,
          minute: selected.minute,
        );
      }
      if (!mounted) return;
      setState(() {
        _bedtimeHour = selected.hour;
        _bedtimeMinute = selected.minute;
      });
      await _reschedule();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bedtime = TimeOfDay(hour: _bedtimeHour, minute: _bedtimeMinute);

    return Column(
      children: [
        SwitchListTile(
          key: const Key('setting_morning_adhkar_toggle'),
          secondary: const Icon(
            Icons.wb_sunny_rounded,
            color: Color(0xFFF59E0B),
          ),
          title: Text(
            l10n.settingMorningAdhkar,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(l10n.settingMorningAdhkarDesc),
          value: _morning,
          onChanged: _toggleMorning,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SwitchListTile(
          key: const Key('setting_qaylulah_toggle'),
          secondary: const Icon(Icons.snooze_rounded, color: Color(0xFF10B981)),
          title: Text(
            l10n.settingQaylulah,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(l10n.settingQaylulahDesc),
          value: _qaylulah,
          onChanged: _toggleQaylulah,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SwitchListTile(
          key: const Key('setting_evening_adhkar_toggle'),
          secondary: const Icon(
            Icons.nights_stay_rounded,
            color: Color(0xFF6366F1),
          ),
          title: Text(
            l10n.settingEveningAdhkar,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(l10n.settingEveningAdhkarDesc),
          value: _evening,
          onChanged: _toggleEvening,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SwitchListTile(
          key: const Key('setting_sleeping_adhkar_toggle'),
          secondary: const Icon(
            Icons.bedtime_rounded,
            color: Color(0xFF8B5CF6),
          ),
          title: Text(
            l10n.settingBedtimeAdhkar,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(l10n.settingBedtimeAdhkarDesc),
          value: _sleeping,
          onChanged: _toggleSleeping,
        ),
        if (_sleeping) ...[
          const Divider(height: 1, indent: 56, endIndent: 16),
          ListTile(
            key: const Key('setting_bedtime_time_picker'),
            contentPadding: const EdgeInsets.only(left: 56, right: 16),
            title: Text(
              l10n.settingBedtimeTime,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
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
            onTap: () => _pickBedtime(context),
          ),
        ],
        const Divider(height: 1, indent: 16, endIndent: 16),
        SwitchListTile(
          key: const Key('setting_sunnah_fasting_toggle'),
          secondary: const Icon(
            Icons.restaurant_rounded,
            color: AppColors.secondary,
          ),
          title: Text(
            l10n.settingSunnahFasting,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(l10n.settingSunnahFastingDesc),
          value: _fasting,
          onChanged: _toggleFasting,
        ),
      ],
    );
  }
}
