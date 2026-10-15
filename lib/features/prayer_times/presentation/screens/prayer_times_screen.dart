import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_bloc.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_event.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_state.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

import 'package:productive_muslim/features/prayer_times/presentation/widgets/qibla_compass_view.dart';
import 'package:productive_muslim/features/prayer_times/presentation/widgets/solar_prayer_dial.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasParentScaffold = Scaffold.maybeOf(context) != null;

    return BlocProvider(
      create: (_) =>
          PrayerTimesBloc(getIt<PrayerTimeService>())
            ..add(const PrayerTimesLoaded()),
      child: Scaffold(
        appBar: hasParentScaffold
            ? null
            : ProductiveAppBar(title: l10n.prayerTimes, showBackButton: true),
        body: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
          builder: (context, state) {
            return switch (state) {
              PrayerTimesInitial() || PrayerTimesLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              PrayerTimesData(
                :final prayerTimes,
                :final nextPrayer,
                :final locationName,
              ) =>
                _PrayerTimesTabs(
                  prayerTimes: prayerTimes,
                  nextPrayer: nextPrayer,
                  locationName: locationName,
                ),
              PrayerTimesLocationRequired() => _LocationRequired(l10n: l10n),
              PrayerTimesError(:final message) => _ErrorState(message: message),
            };
          },
        ),
      ),
    );
  }
}

class _PrayerTimesTabs extends StatelessWidget {
  final dynamic prayerTimes;
  final String nextPrayer;
  final String? locationName;

  const _PrayerTimesTabs({
    required this.prayerTimes,
    required this.nextPrayer,
    this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Container(
              height: 46,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F1A16)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? AppColors.secondary.withValues(alpha: 0.2)
                      : AppColors.borderLight,
                  width: 0.8,
                ),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF0F4C3A), Color(0xFF13221C)]
                        : const [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(
                    color: isDark
                        ? AppColors.secondary.withValues(alpha: 0.35)
                        : AppColors.primary.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.secondary : AppColors.primary)
                          .withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: isDark ? AppColors.secondary : Colors.white,
                unselectedLabelColor: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          l10n.qiblaTabTimes,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.explore_rounded, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          l10n.qiblaTabCompass,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _PrayerTimesList(
                  prayerTimes: prayerTimes,
                  nextPrayer: nextPrayer,
                  locationName: locationName,
                ),
                QiblaCompassView(
                  latitude: prayerTimes.coordinates.latitude as double,
                  longitude: prayerTimes.coordinates.longitude as double,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimesList extends StatelessWidget {
  final dynamic prayerTimes;
  final String nextPrayer;
  final String? locationName;

  const _PrayerTimesList({
    required this.prayerTimes,
    required this.nextPrayer,
    this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final timeFormat = DateFormat.jm();

    final entries = [
      (
        'Fajr',
        l10n.fajr,
        'الفجر',
        Icons.wb_twilight_rounded,
        (prayerTimes.fajr as DateTime).toLocal(),
        isAr ? 'ركعتان فريضة' : '2 Rakat Fardh',
      ),
      (
        'Sunrise',
        l10n.sunrise,
        'الشروق',
        Icons.wb_sunny_rounded,
        (prayerTimes.sunrise as DateTime).toLocal(),
        isAr ? 'شروق الشمس • وقت الإشراق' : 'Shuruq • Ishraq window',
      ),
      (
        'Dhuhr',
        l10n.dhuhr,
        'الظهر',
        Icons.light_mode_rounded,
        (prayerTimes.dhuhr as DateTime).toLocal(),
        isAr ? '٤ ركعات فريضة' : '4 Rakat Fardh',
      ),
      (
        'Asr',
        l10n.asr,
        'العصر',
        Icons.brightness_5_rounded,
        (prayerTimes.asr as DateTime).toLocal(),
        isAr ? '٤ ركعات فريضة' : '4 Rakat Fardh',
      ),
      (
        'Maghrib',
        l10n.maghrib,
        'المغرب',
        Icons.nights_stay_rounded,
        (prayerTimes.maghrib as DateTime).toLocal(),
        isAr ? '٣ ركعات فريضة' : '3 Rakat Fardh',
      ),
      (
        'Isha',
        l10n.isha,
        'العشاء',
        Icons.dark_mode_rounded,
        (prayerTimes.isha as DateTime).toLocal(),
        isAr ? '٤ ركعات فريضة' : '4 Rakat Fardh',
      ),
    ];

    final hasLocation = locationName != null && locationName!.isNotEmpty;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 12,
                          color: AppColors.secondary.withValues(alpha: 0.85),
                        ),
                      ),
                      if (hasLocation)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              locationName!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceSubtle
                          : AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isAr ? 'متزامن تلقائياً' : 'Auto-Synced',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SolarPrayerDial(prayerTimes: prayerTimes, nextPrayer: nextPrayer),
            const SizedBox(height: AppSpacing.xs),
            ...entries.map((entry) {
              final (key, name, arabicName, icon, time, subtitle) = entry;
              final isNext = key.toLowerCase() == nextPrayer.toLowerCase();
              return _PrayerTile(
                name: name,
                arabicName: arabicName,
                icon: icon,
                subtitle: subtitle,
                time: timeFormat.format(time),
                isNext: isNext,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  final String name;
  final String arabicName;
  final IconData icon;
  final String subtitle;
  final String time;
  final bool isNext;

  const _PrayerTile({
    required this.name,
    required this.arabicName,
    required this.icon,
    required this.subtitle,
    required this.time,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 3.5,
      ),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        borderRadius: 18,
        blur: 15,
        color: isNext
            ? (isDark
                  ? const Color(0xFF13221C).withValues(alpha: 0.9)
                  : AppColors.primary.withValues(alpha: 0.12))
            : (isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.7)),
        borderColor: isNext
            ? (isDark ? AppColors.secondary : AppColors.primary)
            : (isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight.withValues(alpha: 0.6)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7.5),
              decoration: BoxDecoration(
                color: isNext
                    ? (isDark
                          ? AppColors.secondary.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.15))
                    : (isDark
                          ? AppColors.darkSurfaceSubtle
                          : AppColors.surfaceSubtle),
                shape: BoxShape.circle,
                border: isNext
                    ? Border.all(
                        color: isDark ? AppColors.secondary : AppColors.primary,
                        width: 1,
                      )
                    : null,
              ),
              child: Icon(
                icon,
                size: 17,
                color: isNext
                    ? (isDark ? AppColors.secondary : AppColors.primary)
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isNext
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isNext
                              ? (isDark
                                    ? AppColors.secondary
                                    : AppColors.primary)
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary),
                        ),
                      ),
                      if (!isAr) ...[
                        const SizedBox(width: 6),
                        Text(
                          arabicName,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 12,
                            color: isDark
                                ? AppColors.secondary.withValues(alpha: 0.7)
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isNext)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7.5,
                  vertical: 3,
                ),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            Text(
              time,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                color: isNext
                    ? (isDark ? AppColors.secondary : AppColors.primary)
                    : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              isNext
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              size: 15,
              color: isNext
                  ? (isDark ? AppColors.secondary : AppColors.primary)
                  : (isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.4)
                        : AppColors.textSecondary.withValues(alpha: 0.4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationRequired extends StatelessWidget {
  final AppLocalizations l10n;
  const _LocationRequired({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.onboardingPermissionDeniedBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
