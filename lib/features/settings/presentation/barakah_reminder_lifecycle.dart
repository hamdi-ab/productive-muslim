import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/data/services/prayer_notification_scheduler.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/domain/models/barakah_reminder.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class BarakahReminderLifecycle extends StatefulWidget {
  const BarakahReminderLifecycle({
    super.key,
    required this.service,
    required this.child,
  });

  final BarakahReminderService service;
  final Widget child;

  @override
  State<BarakahReminderLifecycle> createState() =>
      _BarakahReminderLifecycleState();
}

class _BarakahReminderLifecycleState extends State<BarakahReminderLifecycle>
    with WidgetsBindingObserver {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_locale != locale) {
      _locale = locale;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reconcile();
      });
    }
  }

  void _reconcile() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    unawaited(
      widget.service.reconcile(
        ReminderContent(
          title: l10n.barakahDailyTitle,
          body: l10n.barakahReminderBody,
        ),
      ),
    );

    if (getIt.isRegistered<PrayerNotificationScheduler>()) {
      final scheduler = getIt<PrayerNotificationScheduler>();
      final prayerService = getIt.isRegistered<PrayerTimeService>()
          ? getIt<PrayerTimeService>()
          : null;
      unawaited(() async {
        final position = prayerService?.getCachedOrSavedPosition();
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
            locale: _locale?.languageCode,
          );
        } else {
          await scheduler.rescheduleLocationIndependentReminders(
            locale: _locale?.languageCode,
          );
        }
      }());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reconcile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
