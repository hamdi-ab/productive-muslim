import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) =>
          PrayerTimesBloc(getIt<PrayerTimeService>())
            ..add(const PrayerTimesLoaded()),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1512) : null,
        appBar: hasParentScaffold
            ? null
            : ProductiveAppBar(title: l10n.prayerTimes, showBackButton: true),
        body: Stack(
          children: [
            // Ambient Sacred Glow Backdrops matching Stitch Design
            Positioned(
              top: -80,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondary.withValues(
                          alpha: isDark ? 0.12 : 0.08,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: -60,
              child: IgnorePointer(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(
                          alpha: isDark ? 0.14 : 0.08,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
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
                  PrayerTimesLocationRequired() => _LocationRequired(
                    l10n: l10n,
                  ),
                  PrayerTimesError(:final message) => _ErrorState(
                    message: message,
                  ),
                };
              },
            ),
          ],
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
          // Frosted Capsule Segmented Switcher (Stitch design specification)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F1A16)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isDark
                      ? AppColors.secondary.withValues(alpha: 0.25)
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
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? AppColors.secondary.withValues(alpha: 0.4)
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
                        const Icon(Icons.wb_twilight_rounded, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.qiblaTabTimes,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                        Flexible(
                          child: Text(
                            l10n.qiblaTabCompass,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
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
    final now = DateTime.now();

    final fajrTime = (prayerTimes.fajr as DateTime).toLocal();
    final sunriseTime = (prayerTimes.sunrise as DateTime).toLocal();
    final dhuhrTime = (prayerTimes.dhuhr as DateTime).toLocal();
    final asrTime = (prayerTimes.asr as DateTime).toLocal();
    final maghribTime = (prayerTimes.maghrib as DateTime).toLocal();
    final ishaTime = (prayerTimes.isha as DateTime).toLocal();
    final isAfterIsha = now.isAfter(ishaTime);

    final entries = [
      (
        'Fajr',
        l10n.fajr,
        'الفجر',
        Icons.wb_twilight_rounded,
        fajrTime,
        isAr ? 'ركعتان فريضة' : 'Imsak passed • 2 Rakat Fardh',
        now.isAfter(fajrTime),
        null,
      ),
      (
        'Sunrise',
        l10n.sunrise,
        'الشروق',
        Icons.wb_sunny_rounded,
        sunriseTime,
        isAr ? 'شروق الشمس • وقت الإشراق' : 'Sunrise (Shuruq) • Ishraq window',
        now.isAfter(sunriseTime),
        null,
      ),
      (
        'Dhuhr',
        l10n.dhuhr,
        'الظهر',
        Icons.light_mode_rounded,
        dhuhrTime,
        isAr ? '٤ ركعات فريضة' : 'Midday zenith • 4 Rakat Fardh',
        now.isAfter(dhuhrTime),
        null,
      ),
      (
        'Asr',
        l10n.asr,
        'العصر',
        Icons.brightness_5_rounded,
        asrTime,
        isAr ? '٤ ركعات فريضة' : 'Hanafi / Shafi\'i aligned • 4 Rakat',
        now.isAfter(asrTime),
        null,
      ),
      (
        'Maghrib',
        l10n.maghrib,
        'المغرب',
        Icons.nights_stay_rounded,
        maghribTime,
        isAr ? '٣ ركعات فريضة • وقت الإفطار' : 'Iftar time • 3 Rakat Fardh',
        now.isAfter(maghribTime),
        isAr ? 'وقت الإفطار' : 'Iftar Time',
      ),
      (
        'Isha',
        l10n.isha,
        'العشاء',
        Icons.dark_mode_rounded,
        ishaTime,
        isAr ? '٤ ركعات فريضة • يليه القيام' : 'Followed by Qiyam & Tahajjud',
        now.isAfter(ishaTime),
        isAr ? 'قيام الليل' : 'Qiyam Ahead',
      ),
    ];

    final hasLocation = locationName != null && locationName!.isNotEmpty;
    final lat = (prayerTimes.coordinates.latitude as double).toStringAsFixed(2);
    final lng = (prayerTimes.coordinates.longitude as double).toStringAsFixed(
      2,
    );
    final maxPillWidth = MediaQuery.sizeOf(context).width - 64;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          children: [
            // 1. Astrological & Location Header (Stitch Design)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 13,
                                color: AppColors.secondary.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              l10n.prayerTimes,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F261E)
                              : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.35),
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
                                fontSize: 11,
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
                  const SizedBox(height: 6),
                  // Location Pill & Calculation Method Row (Overflow-proof with Wrap)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (hasLocation)
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxPillWidth),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF141E1A)
                                  : AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 13,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    locationName!,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '($lat°, $lng°)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxPillWidth),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF141E1A)
                                : AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  isAr
                                      ? 'أم القرى / رابطة العالم'
                                      : 'MWL Aligned',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.tune_rounded,
                                size: 11,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 2),

            // 2. Celestial Solar Dial Card
            SolarPrayerDial(prayerTimes: prayerTimes, nextPrayer: nextPrayer),

            const SizedBox(height: AppSpacing.sm),

            // 3. Timetable Section Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md + 2,
                vertical: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isAr ? 'جدول الصلوات اليومي' : 'Daily Timetable',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    isAr ? 'توقيت محلي دقيق' : 'High Precision',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // 4. Prayer Stack Tiles
            ...entries.map((entry) {
              final (
                key,
                name,
                arabicName,
                icon,
                time,
                subtitle,
                isPassed,
                tag,
              ) = entry;
              final isAstronomical = key.toLowerCase() == 'sunrise';
              final isNext =
                  !isAfterIsha &&
                  (key.toLowerCase() == nextPrayer.toLowerCase());
              return _PrayerTile(
                name: name,
                arabicName: arabicName,
                icon: icon,
                subtitle: subtitle,
                time: timeFormat.format(time),
                isNext: isNext,
                isPassed: isPassed && !isNext,
                isAstronomical: isAstronomical,
                tag: tag,
              );
            }),

            if (isAfterIsha) ...[
              const SizedBox(height: 6),
              _PrayerTile(
                name: '${l10n.fajr} (${isAr ? "غداً" : "Tomorrow"})',
                arabicName: 'الفجر',
                icon: Icons.wb_twilight_rounded,
                subtitle: isAr
                    ? 'صلاة الفجر القادمة بمشيئة الله • غداً'
                    : 'Upcoming Dawn Prayer • Tomorrow',
                time: timeFormat.format(fajrTime.add(const Duration(days: 1))),
                isNext: true,
                isPassed: false,
                isAstronomical: false,
                tag: isAr ? 'غداً' : 'Tomorrow',
              ),
            ],

            const SizedBox(height: AppSpacing.lg),
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
  final bool isPassed;
  final bool isAstronomical;
  final String? tag;

  const _PrayerTile({
    required this.name,
    required this.arabicName,
    required this.icon,
    required this.subtitle,
    required this.time,
    required this.isNext,
    required this.isPassed,
    this.isAstronomical = false,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    Color cardColor;
    Color borderColor;
    if (isNext) {
      cardColor = isDark
          ? const Color(0xFF132A22)
          : AppColors.primary.withValues(alpha: 0.12);
      borderColor = isDark ? AppColors.secondary : AppColors.primary;
    } else if (isPassed) {
      cardColor = isDark
          ? const Color(0xFF0F1815).withValues(alpha: 0.6)
          : Colors.grey.shade50.withValues(alpha: 0.8);
      borderColor = isDark
          ? AppColors.borderDark.withValues(alpha: 0.4)
          : AppColors.borderLight.withValues(alpha: 0.5);
    } else {
      cardColor = isDark
          ? AppColors.darkSurface.withValues(alpha: 0.75)
          : Colors.white.withValues(alpha: 0.75);
      borderColor = isDark
          ? AppColors.borderDark
          : AppColors.borderLight.withValues(alpha: 0.6);
    }

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
        color: cardColor,
        borderColor: borderColor,
        child: Row(
          children: [
            // Status Icon Indicator
            Container(
              padding: const EdgeInsets.all(7.5),
              decoration: BoxDecoration(
                color: isNext
                    ? (isDark
                          ? AppColors.secondary.withValues(alpha: 0.22)
                          : AppColors.primary.withValues(alpha: 0.18))
                    : (isPassed && !isAstronomical)
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : (isDark
                          ? AppColors.darkSurfaceSubtle
                          : AppColors.surfaceSubtle),
                shape: BoxShape.circle,
                border: isNext
                    ? Border.all(
                        color: isDark ? AppColors.secondary : AppColors.primary,
                        width: 1.2,
                      )
                    : (isPassed && !isAstronomical)
                    ? Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        width: 0.8,
                      )
                    : (isPassed && isAstronomical)
                    ? Border.all(
                        color: isDark
                            ? AppColors.borderDark.withValues(alpha: 0.4)
                            : AppColors.borderLight.withValues(alpha: 0.5),
                        width: 0.8,
                      )
                    : null,
              ),
              child: Icon(
                (isPassed && !isAstronomical) ? Icons.check_rounded : icon,
                size: 16,
                color: isNext
                    ? (isDark ? AppColors.secondary : AppColors.primary)
                    : (isPassed && !isAstronomical)
                    ? const Color(0xFF10B981)
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 10),
            // Prayer Details: Name, Arabic script, Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    runSpacing: 2,
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
                              : isPassed
                              ? (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary)
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary),
                        ),
                      ),
                      if (!isAr)
                        Text(
                          arabicName,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 12,
                            color: isNext
                                ? AppColors.secondary.withValues(alpha: 0.85)
                                : (isDark
                                      ? AppColors.secondary.withValues(
                                          alpha: 0.6,
                                        )
                                      : AppColors.textSecondary.withValues(
                                          alpha: 0.7,
                                        )),
                          ),
                        ),
                      if (isPassed && !isAstronomical)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.25),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            isAr ? 'انقضى' : 'Past',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      if (tag != null && !isPassed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            tag!,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.secondary
                                  : AppColors.secondaryDark,
                            ),
                          ),
                        ),
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isNext)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2.5,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 4),
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
                fontSize: 14,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                color: isNext
                    ? (isDark ? AppColors.secondary : AppColors.primary)
                    : isPassed
                    ? (isDark
                          ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
                          : AppColors.textSecondary.withValues(alpha: 0.7))
                    : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isNext
                  ? Icons.notifications_active_rounded
                  : (isPassed && !isAstronomical)
                  ? Icons.check_circle_outline_rounded
                  : isAstronomical
                  ? Icons.wb_sunny_outlined
                  : Icons.notifications_none_rounded,
              size: 15,
              color: isNext
                  ? (isDark ? AppColors.secondary : AppColors.primary)
                  : (isPassed && !isAstronomical)
                  ? const Color(0xFF10B981).withValues(alpha: 0.6)
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.08),
                border: Border.all(
                  color: isDark
                      ? const Color(0x3310B981)
                      : AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.location_off_outlined,
                size: 40,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.onboardingPermissionDeniedBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (kIsWeb)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? 'ملاحظة للمتصفح: اضغط على أيقونة القفل أو الإعدادات في شريط العنوان للسماح بالموقع.'
                      : 'Web Tip: Click the padlock or settings icon in your browser address bar to allow location.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    AppHaptics.selectionClick();
                    if (!kIsWeb) {
                      Geolocator.openAppSettings();
                    } else {
                      final isAr =
                          Localizations.localeOf(context).languageCode == 'ar';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAr
                                ? 'يرجى السماح بالوصول للموقع عبر أيقونة القفل أو الإعدادات في شريط عنوان المتصفح ثم الضغط على إعادة المحاولة.'
                                : 'Please allow location in your browser site settings (address bar icon) and click Retry.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  label: Text(l10n.onboardingPermissionOpenSettings),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    AppHaptics.mediumImpact();
                    context.read<PrayerTimesBloc>().add(
                      const PrayerTimesLoaded(),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.onboardingPermissionRetry),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
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
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                AppHaptics.mediumImpact();
                context.read<PrayerTimesBloc>().add(const PrayerTimesLoaded());
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.retry),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
