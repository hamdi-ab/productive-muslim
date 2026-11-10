import 'package:flutter/material.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/data/services/adhan_notification_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Settings tile for toggling automatic Adhan and Iqamah notifications.
class SettingsAdhanNotificationTile extends StatefulWidget {
  const SettingsAdhanNotificationTile({super.key});

  @override
  State<SettingsAdhanNotificationTile> createState() =>
      _SettingsAdhanNotificationTileState();
}

class _SettingsAdhanNotificationTileState
    extends State<SettingsAdhanNotificationTile> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<SettingsService>()) {
      _enabled = getIt<SettingsService>().adhanNotificationsEnabled;
    }
  }

  Future<void> _toggle(bool value) async {
    if (!getIt.isRegistered<SettingsService>()) return;
    if (!getIt.isRegistered<AdhanNotificationService>()) return;
    if (!getIt.isRegistered<PrayerTimeService>()) return;

    final settings = getIt<SettingsService>();
    final adhanService = getIt<AdhanNotificationService>();
    final prayerService = getIt<PrayerTimeService>();

    if (value) {
      final granted = await adhanService.requestPermission();
      if (!granted) return;
    }

    await settings.setAdhanNotificationsEnabled(value);

    if (value) {
      final position = await prayerService.getCurrentPosition();
      if (position != null) {
        final times = prayerService.getPrayerTimes(position);
        if (times != null) {
          await adhanService.initialize();
          await adhanService.schedulePrayerNotifications(
            fajr: times.fajr,
            dhuhr: times.dhuhr,
            asr: times.asr,
            maghrib: times.maghrib,
            isha: times.isha,
          );
        }
      }
    } else {
      await adhanService.cancelAll();
    }

    if (mounted) {
      setState(() => _enabled = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SwitchListTile(
      key: const Key('setting_adhan_notification_toggle'),
      activeThumbColor: AppColors.secondary,
      activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.mosque_rounded,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        l10n.adhan,
        style: const TextStyle(fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        l10n.adhanNotificationsDescription,
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
