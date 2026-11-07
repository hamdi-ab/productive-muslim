import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';

/// Interactive date navigator strip showing current day, Hijri date, prayer bounds, and quick date jumping.
class PlanDateNavigator extends StatelessWidget {
  final DateTime selectedDate;
  final bool isDark;
  final ValueChanged<int> onDateOffsetChanged;
  final VoidCallback onGoToToday;
  final VoidCallback onPickDate;

  const PlanDateNavigator({
    super.key,
    required this.selectedDate,
    required this.isDark,
    required this.onDateOffsetChanged,
    required this.onGoToToday,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
    final locale = Localizations.localeOf(context).toString();
    final isAr = locale.startsWith('ar');

    String hijriText = '';
    if (getIt.isRegistered<HijriService>()) {
      final hijri = getIt<HijriService>().getHijriDate(selectedDate);
      hijriText = isAr
          ? '${hijri.hDay} ${hijri.monthNameAr} ${hijri.hYear} هـ'
          : '${hijri.hDay} ${hijri.monthNameEn} ${hijri.hYear} AH';
    }

    String prayerTimesBounds = '';
    if (getIt.isRegistered<PrayerTimeService>()) {
      final prayerService = getIt<PrayerTimeService>();
      if (prayerService.cachedPrayerTimes != null) {
        final pt = prayerService.cachedPrayerTimes!;
        final fajrStr =
            '${pt.fajr.hour.toString().padLeft(2, '0')}:${pt.fajr.minute.toString().padLeft(2, '0')}';
        final sunsetStr =
            '${pt.maghrib.hour.toString().padLeft(2, '0')}:${pt.maghrib.minute.toString().padLeft(2, '0')}';
        prayerTimesBounds = isAr
            ? 'الفجر $fajrStr • المغرب $sunsetStr'
            : 'Fajr $fajrStr • Sunset $sunsetStr';
      }
    }

    final datePattern = isAr ? 'EEEE، d MMMM yyyy' : 'EEEE, d MMM yyyy';
    final dateDisplay = DateFormat(datePattern, locale).format(selectedDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141E1A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? const Color(0xFF404944).withValues(alpha: 0.4)
                : AppColors.primary.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? const Color(0xFF0F4C3A) : Colors.black)
                  .withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Previous Day Chevron
            AppPressable(
              onTap: () => onDateOffsetChanged(-1),
              pressedScale: 0.88,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAr
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  size: 22,
                  color: isDark
                      ? const Color(0xFFDAE5E0)
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Center (Tappable Date Selector)
            Expanded(
              child: AppPressable(
                onTap: onPickDate,
                pressedScale: 0.98,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 15,
                          color: Color(0xFFE9C349),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            dateDisplay,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFDAE5E0)
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF004D33)
                                  .withValues(alpha: isDark ? 0.6 : 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF4EDEA3)
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isAr ? 'اليوم' : 'Today',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4EDEA3),
                              ),
                            ),
                          )
                        else
                          AppPressable(
                            onTap: onGoToToday,
                            pressedScale: 0.9,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9C349)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE9C349)
                                      .withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                isAr ? 'اليوم' : 'Today',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE9C349),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hijriText.isNotEmpty) ...[
                              Text(
                                hijriText,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE9C349),
                                ),
                              ),
                              if (prayerTimesBounds.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '•',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                            ],
                            if (prayerTimesBounds.isNotEmpty)
                              Text(
                                prayerTimesBounds,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isDark
                                      ? const Color(0xFFBFC9C3)
                                      : AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Next Day Chevron
            AppPressable(
              onTap: () => onDateOffsetChanged(1),
              pressedScale: 0.88,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAr
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  size: 22,
                  color: isDark
                      ? const Color(0xFFDAE5E0)
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
