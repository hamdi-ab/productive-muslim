import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/domain/models/barakah_reminder.dart';
import 'package:productive_muslim/features/settings/logic/settings_bloc.dart';
import 'package:productive_muslim/features/settings/logic/settings_event.dart';
import 'package:productive_muslim/features/settings/logic/settings_state.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/settings_adhan_notification_tile.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/settings_arabic_typography_tile.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/settings_background_painter.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/settings_backup_restore_card.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/settings_barakah_reminder_card.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/settings_haptic_feedback_tile.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/settings_hero_card.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/settings_locale_selector.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/settings_location_permission_tile.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/settings_section_title.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/settings_theme_mode_selector.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/smart_reminders_settings_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Top-level settings screen providing the SettingsBloc and orchestrating
/// the preferences, prayer synchronization, and offline sovereignty modules.
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

/// Scrollable settings view organizing application preferences into clean,
/// modular cards with ambient sacred visual accents.
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
    final cardBorder = isDark
        ? const Color(0x2610B981)
        : const Color(0x1A0F4C3A);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B1512)
          : const Color(0xFFF8FAF9),
      appBar: ProductiveAppBar(
        title: l10n.settings,
        subtitle: l10n.preferencesTitle,
        showBackButton: true,
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Subtle Islamic Geometric Watermark Lattice
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: SettingsIslamicLatticeBackgroundPainter(
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),

                // Celestial Ambient Glow Auras matching Stitch Luxury System
                Positioned(
                  top: -60,
                  left: MediaQuery.of(context).size.width / 2 - 120,
                  child: IgnorePointer(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(
                              alpha: isDark ? 0.22 : 0.08,
                            ),
                            AppColors.primary.withValues(
                              alpha: isDark ? 0.05 : 0.02,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: -40,
                  child: IgnorePointer(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.secondary.withValues(
                              alpha: isDark ? 0.12 : 0.06,
                            ),
                            AppColors.secondary.withValues(
                              alpha: isDark ? 0.02 : 0.01,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Settings Feed
                ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  children: [
                    // Bismillah Ribbon Pill
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceSubtle
                                : AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.secondary.withValues(alpha: 0.35)
                                  : AppColors.borderLight,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'amiri',
                                  fontSize: 13,
                                  color: AppColors.secondaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'PREFERENCES & INTEGRATION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Hero Overview Card
                    const SettingsHeroCard(),
                    const SizedBox(height: AppSpacing.md),

                    // Section 1: Preferences & Appearance
                    SettingsSectionTitle(
                      icon: Icons.palette_rounded,
                      title: l10n.preferencesTitle,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: cardBorder, width: 1.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          children: [
                            const SettingsThemeModeSelector(),
                            Divider(
                              height: 1,
                              indent: 56,
                              endIndent: 16,
                              color: dividerColor,
                            ),
                            const SettingsLocaleSelector(),
                            Divider(
                              height: 1,
                              indent: 56,
                              endIndent: 16,
                              color: dividerColor,
                            ),
                            const SettingsArabicTypographyTile(),
                            Divider(
                              height: 1,
                              indent: 56,
                              endIndent: 16,
                              color: dividerColor,
                            ),
                            const SettingsHapticFeedbackTile(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section 2: Prayer Times & Location
                    SettingsSectionTitle(
                      icon: Icons.mosque_rounded,
                      title: l10n.prayerTimes,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: cardBorder, width: 1.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          children: [
                            const SettingsLocationPermissionTile(),
                            Divider(
                              height: 1,
                              indent: 56,
                              endIndent: 16,
                              color: dividerColor,
                            ),
                            const SettingsAdhanNotificationTile(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section 3: Smart Routine & Sunnah Reminders
                    SettingsSectionTitle(
                      icon: Icons.wb_twilight_rounded,
                      title: l10n.smartNotificationsTitle,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: cardBorder, width: 1.2),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: SmartRemindersSettingsCard(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section 4: Daily Barakah Reminders
                    SettingsSectionTitle(
                      icon: Icons.auto_awesome_rounded,
                      title: l10n.barakahDailyTitle,
                    ),
                    const SizedBox(height: 8),
                    SettingsBarakahReminderCard(state: state, content: content),
                    const SizedBox(height: AppSpacing.lg),

                    // Section 5: Data Sovereignty & Local Backup
                    SettingsSectionTitle(
                      icon: Icons.shield_rounded,
                      title: l10n.backupRestoreTitle,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: cardBorder, width: 1.2),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: SettingsBackupRestoreCard(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // App Footer Info
                    _buildAppFooter(context, isDark),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppFooter(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? AppColors.darkSurfaceSubtle
                : AppColors.surfaceSubtle,
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
          child: const Icon(
            Icons.star_rounded,
            size: 18,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Productive Muslim v1.0\nBuilt with Intention & Barakah',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : Colors.black54,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'All data stored locally on your device',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
      ],
    );
  }
}
