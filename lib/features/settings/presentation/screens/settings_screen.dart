import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/adhan_notification_service.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/barakah_reminder.dart';
import 'package:productive_muslim/features/settings/logic/settings_bloc.dart';
import 'package:productive_muslim/features/settings/logic/settings_event.dart';
import 'package:productive_muslim/features/settings/logic/settings_state.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => SettingsBloc(getIt<BarakahReminderService>())
        ..add(
          SettingsLoaded(
            ReminderContent(
              title: l10n.barakahDailyTitle,
              body: l10n.barakahReminderBody,
            ),
          ),
        ),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final content = ReminderContent(
      title: l10n.barakahDailyTitle,
      body: l10n.barakahReminderBody,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            final interactive = state.supported && !state.pending;
            final time = TimeOfDay(hour: state.hour, minute: state.minute);
            final message = switch (state.failure) {
              ReminderFailure.permissionDenied => l10n.barakahReminderDenied,
              ReminderFailure.operationFailed => l10n.barakahReminderError,
              ReminderFailure.unavailable => l10n.barakahReminderUnsupported,
              null => null,
            };
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                SwitchListTile(
                  key: const Key('barakah_reminder_toggle'),
                  title: Text(l10n.barakahReminderLabel),
                  subtitle: Text(l10n.barakahReminderDescription),
                  value: state.enabled,
                  onChanged: interactive
                      ? (enabled) => context.read<SettingsBloc>().add(
                          ReminderToggled(enabled, content),
                        )
                      : null,
                ),
                ListTile(
                  key: const Key('barakah_reminder_time'),
                  title: Text(l10n.barakahReminderTime),
                  subtitle: Text(time.format(context)),
                  trailing: const Icon(Icons.schedule),
                  enabled: interactive,
                  onTap: interactive
                      ? () async {
                          final bloc = context.read<SettingsBloc>();
                          final selected = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (selected != null && !bloc.isClosed) {
                            bloc.add(
                              ReminderTimeChanged(
                                selected.hour,
                                selected.minute,
                                content,
                              ),
                            );
                          }
                        }
                      : null,
                ),
                if (!state.supported)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(l10n.barakahReminderUnsupported),
                  )
                else if (state.pending)
                  Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(l10n.barakahReminderPending),
                    ),
                  )
                else if (message != null)
                  Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(message),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xxl),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                _AdhanNotificationToggle(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdhanNotificationToggle extends StatefulWidget {
  @override
  State<_AdhanNotificationToggle> createState() =>
      _AdhanNotificationToggleState();
}

class _AdhanNotificationToggleState extends State<_AdhanNotificationToggle> {
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

    return SwitchListTile(
      title: Text(l10n.adhan),
      subtitle: Text(l10n.adhanNotificationsDescription),
      value: _enabled,
      onChanged: _toggle,
    );
  }
}
