import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/services.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/arabic_typography.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/arabic_typography_sheet.dart';
import 'package:productive_muslim/data/services/adhan_notification_service.dart';
import 'package:productive_muslim/data/services/backup_service.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/barakah_reminder.dart';
import 'package:productive_muslim/features/settings/logic/settings_bloc.dart';
import 'package:productive_muslim/features/settings/logic/settings_event.dart';
import 'package:productive_muslim/features/settings/logic/settings_state.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/smart_reminders_settings_card.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = ReminderContent(
      title: l10n.barakahDailyTitle,
      body: l10n.barakahReminderBody,
    );
    final contentWidget = BlocBuilder<SettingsBloc, SettingsState>(
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          children: [
            // Section 1: Preferences & Appearance
            _SectionTitle(
              icon: Icons.palette_rounded,
              title: l10n.preferencesTitle,
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: isDark
                  ? AppColors.darkSurfaceSubtle
                  : AppColors.surfaceSubtle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    _ThemeModeSelector(),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    _LocaleSelector(),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    _ArabicTypographyTile(),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    _HapticFeedbackToggle(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Section 2: Prayer Times & Location
            _SectionTitle(icon: Icons.mosque_rounded, title: l10n.prayerTimes),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: isDark
                  ? AppColors.darkSurfaceSubtle
                  : AppColors.surfaceSubtle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    const _LocationPermissionToggle(),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    _AdhanNotificationToggle(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Section 3: Smart Routine & Sunnah Reminders
            _SectionTitle(
              icon: Icons.wb_twilight_rounded,
              title: l10n.smartNotificationsTitle,
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: isDark
                  ? AppColors.darkSurfaceSubtle
                  : AppColors.surfaceSubtle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: SmartRemindersSettingsCard(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Section 4: Daily Barakah Reminders
            _SectionTitle(
              icon: Icons.auto_awesome_rounded,
              title: l10n.barakahDailyTitle,
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: isDark
                  ? AppColors.darkSurfaceSubtle
                  : AppColors.surfaceSubtle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    SwitchListTile(
                      key: const Key('barakah_reminder_toggle'),
                      secondary: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFF59E0B),
                      ),
                      title: Text(
                        l10n.barakahReminderLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(l10n.barakahReminderDescription),
                      value: state.enabled,
                      onChanged: interactive
                          ? (enabled) => context.read<SettingsBloc>().add(
                              ReminderToggled(enabled, content),
                            )
                          : null,
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    ListTile(
                      key: const Key('barakah_reminder_time'),
                      contentPadding: const EdgeInsets.only(
                        left: 56,
                        right: 16,
                      ),
                      title: Text(
                        l10n.barakahReminderTime,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        time.format(context),
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
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  time.format(context),
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
                  ],
                ),
              ),
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
            const SizedBox(height: AppSpacing.lg),

            // Section 5: Data Sovereignty & Local Backup
            _SectionTitle(
              icon: Icons.shield_rounded,
              title: l10n.backupRestoreTitle,
            ),
            const SizedBox(height: 8),
            const Card(elevation: 0, child: _BackupRestoreCard()),
            const SizedBox(height: AppSpacing.xl),

            // App Footer Info
            Center(
              child: Text(
                'Productive Muslim v1.0\nBuilt with intention',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        );
      },
    );

    return Scaffold(
      appBar: ProductiveAppBar(
        title: l10n.settings,
        subtitle: 'Preferences & Notifications',
        showBackButton: true,
      ),
      body: SafeArea(child: contentWidget),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPermissionToggle extends StatefulWidget {
  const _LocationPermissionToggle();

  @override
  State<_LocationPermissionToggle> createState() =>
      _LocationPermissionToggleState();
}

class _LocationPermissionToggleState extends State<_LocationPermissionToggle> {
  LocationPermission _permission = LocationPermission.denied;
  bool _serviceEnabled = false;
  bool _loading = false;
  String? _locationName;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      String? locName;
      if (getIt.isRegistered<PrayerTimeService>()) {
        locName = getIt<PrayerTimeService>().cachedLocationName;
      }
      if (mounted) {
        setState(() {
          _serviceEnabled = serviceEnabled;
          _permission = permission;
          _locationName = locName;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggle(bool value) async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      if (value) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please enable location services on your device.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          await _checkStatus();
          return;
        }

        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }

        if (perm == LocationPermission.deniedForever) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Location permission permanently denied. Open settings to grant.',
                ),
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: () => Geolocator.openAppSettings(),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (perm == LocationPermission.whileInUse ||
            perm == LocationPermission.always) {
          if (getIt.isRegistered<PrayerTimeService>()) {
            await getIt<PrayerTimeService>().getCurrentPosition();
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'To revoke location access, adjust permissions in device settings.',
              ),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => Geolocator.openAppSettings(),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        await _checkStatus();
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isGranted =
        _permission == LocationPermission.whileInUse ||
        _permission == LocationPermission.always;

    String subtitleText;
    if (isGranted) {
      subtitleText = _locationName != null && _locationName!.isNotEmpty
          ? '📍 $_locationName • Accurate prayer times active'
          : 'Active for accurate local prayer times & Qibla';
    } else if (!_serviceEnabled) {
      subtitleText = 'Location service disabled on device';
    } else if (_permission == LocationPermission.deniedForever) {
      subtitleText = 'Permission denied permanently. Tap to open settings';
    } else {
      subtitleText = l10n.onboardingPermissionBody;
    }

    return SwitchListTile(
      key: const Key('setting_location_permission_toggle'),
      secondary: Icon(
        isGranted ? Icons.location_on_rounded : Icons.location_off_rounded,
        color: isGranted ? AppColors.primary : Colors.grey,
      ),
      title: const Text(
        'Location Access',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitleText, style: const TextStyle(fontSize: 12)),
      value: isGranted,
      onChanged: _loading ? null : _toggle,
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
      key: const Key('setting_adhan_notification_toggle'),
      secondary: const Icon(Icons.mosque_rounded, color: AppColors.primary),
      title: Text(
        l10n.adhan,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(l10n.adhanNotificationsDescription),
      value: _enabled,
      onChanged: _toggle,
    );
  }
}

class _BackupRestoreCard extends StatelessWidget {
  const _BackupRestoreCard();

  Future<void> _exportBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (!getIt.isRegistered<BackupService>()) return;

    try {
      final jsonStr = await getIt<BackupService>().exportBackupToJson();
      await Clipboard.setData(ClipboardData(text: jsonStr));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.backupExportSuccess),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.backupExportError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showRestoreDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.restore_page_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(l10n.backupConfirmTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.backupConfirmMsg, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.backupRestorePasteHint,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(10),
              ),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.backupCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(l10n.backupConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final text = controller.text.trim();
      if (text.isEmpty) return;

      final success = await getIt<BackupService>().importBackupFromJson(text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? l10n.backupImportSuccess : l10n.backupImportError,
            ),
            backgroundColor: success ? AppColors.primary : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        ListTile(
          key: const Key('settings_export_backup'),
          leading: const Icon(Icons.download_rounded, color: AppColors.primary),
          title: Text(
            l10n.backupExportBtn,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(l10n.backupRestoreDesc),
          trailing: const Icon(Icons.copy_rounded, size: 20),
          onTap: () => _exportBackup(context),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        ListTile(
          key: const Key('settings_import_backup'),
          leading: const Icon(Icons.upload_rounded, color: AppColors.primary),
          title: Text(
            l10n.backupImportBtn,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _showRestoreDialog(context),
        ),
      ],
    );
  }
}

class _HapticFeedbackToggle extends StatefulWidget {
  const _HapticFeedbackToggle();

  @override
  State<_HapticFeedbackToggle> createState() => _HapticFeedbackToggleState();
}

class _HapticFeedbackToggleState extends State<_HapticFeedbackToggle> {
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

    return SwitchListTile(
      key: const Key('settings_haptic_feedback_toggle'),
      secondary: const Icon(Icons.vibration_rounded, color: AppColors.primary),
      title: Text(
        l10n.hapticFeedback,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(l10n.hapticFeedbackDesc),
      value: _enabled,
      onChanged: _toggle,
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = getIt.isRegistered<SettingsService>()
        ? getIt<SettingsService>()
        : null;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable:
          settings?.themeModeNotifier ?? ValueNotifier(ThemeMode.system),
      builder: (context, currentMode, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.palette_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.theme,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto_rounded, size: 18),
                      label: Text(l10n.system),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_rounded, size: 18),
                      label: Text(l10n.light),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_rounded, size: 18),
                      label: Text(l10n.dark),
                    ),
                  ],
                  selected: {currentMode},
                  onSelectionChanged: (newSelection) {
                    final selected = newSelection.first;
                    final modeString = switch (selected) {
                      ThemeMode.light => 'light',
                      ThemeMode.dark => 'dark',
                      ThemeMode.system => 'system',
                    };
                    settings?.setThemeMode(modeString);
                    AppHaptics.selectionClick();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LocaleSelector extends StatelessWidget {
  const _LocaleSelector();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = getIt.isRegistered<SettingsService>()
        ? getIt<SettingsService>()
        : null;

    return ValueListenableBuilder<Locale?>(
      valueListenable: settings?.localeNotifier ?? ValueNotifier<Locale?>(null),
      builder: (context, _, _) {
        final currentCode = settings?.localeCode ?? 'system';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.language_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.language,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment<String>(
                      value: 'system',
                      label: Text(l10n.languageSystem),
                    ),
                    const ButtonSegment<String>(
                      value: 'en',
                      label: Text('English'),
                    ),
                    const ButtonSegment<String>(
                      value: 'ar',
                      label: Text('العربية'),
                    ),
                  ],
                  selected: {currentCode},
                  onSelectionChanged: (newSelection) {
                    final selected = newSelection.first;
                    settings?.setLocaleCode(selected);
                    AppHaptics.selectionClick();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArabicTypographyTile extends StatelessWidget {
  const _ArabicTypographyTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final settings = getIt.isRegistered<SettingsService>()
        ? getIt<SettingsService>()
        : null;

    return ValueListenableBuilder<String>(
      valueListenable:
          settings?.arabicFontFamilyNotifier ?? ValueNotifier('amiri'),
      builder: (context, currentFontKey, _) {
        final fontOption = ArabicFontFamily.fromKey(currentFontKey);
        final label = isArabic ? fontOption.labelAr : fontOption.labelEn;

        return ListTile(
          key: const Key('settings_arabic_typography'),
          leading: const Icon(
            Icons.format_size_rounded,
            color: AppColors.primary,
          ),
          title: Text(
            l10n.adhkarTypography,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            l10n.typographyTitle,
            style: const TextStyle(fontSize: 12),
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
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.split('(').first.trim(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            AppHaptics.selectionClick();
            ArabicTypographySheet.show(context);
          },
        );
      },
    );
  }
}
