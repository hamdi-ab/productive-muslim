import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/features/prayer_times/presentation/widgets/prayer_location_header.dart';
import 'package:productive_muslim/features/prayer_times/presentation/widgets/prayer_tile.dart';
import 'package:productive_muslim/features/prayer_times/presentation/widgets/solar_prayer_dial.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Scrollable timetable view orchestrating the location header, celestial dial,
/// and prayer schedule tiles.
class PrayerTimesListView extends StatelessWidget {
  final dynamic prayerTimes;
  final String nextPrayer;
  final String? locationName;

  const PrayerTimesListView({
    super.key,
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          children: [
            // 1. Astrological & Location Header (Stitch Design)
            PrayerLocationHeader(
              prayerTimes: prayerTimes,
              locationName: locationName,
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
              return PrayerTile(
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
              PrayerTile(
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
