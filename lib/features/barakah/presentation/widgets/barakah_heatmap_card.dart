import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/app_typography_extension.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

String _locDigits(BuildContext context, String value) {
  if (Localizations.localeOf(context).languageCode != 'ar') return value;
  return value.replaceAllMapped(
    RegExp('[0-9]'),
    (match) => String.fromCharCode(0x0660 + int.parse(match[0]!)),
  );
}

/// A 12-week GitHub-style activity contribution heatmap for Barakah and habits
class BarakahHeatmapCard extends StatelessWidget {
  final Map<String, int> activityByDate;
  final DateTime? referenceDate;

  const BarakahHeatmapCard({
    super.key,
    this.activityByDate = const {},
    this.referenceDate,
  });

  Color _getCellColor(int score, bool isDark) {
    if (score <= 0) {
      return isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.05);
    }
    if (score == 1) return const Color(0xFF86EFAC); // Light green
    if (score <= 3) return const Color(0xFF4ADE80); // Medium green
    if (score <= 5) return const Color(0xFF22C55E); // Deep green
    return const Color(0xFF10B981); // Peak Barakah emerald
  }

  String _formatDateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final now = referenceDate ?? DateTime.now();
    // End date is Sunday of the current week
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    final daysToSunday = 7 - currentWeekday;
    final endSunday = DateTime(now.year, now.month, now.day + daysToSunday);

    // 12 weeks = 84 days total
    const totalWeeks = 12;
    const totalDays = totalWeeks * 7;
    final startMonday = DateTime(
      endSunday.year,
      endSunday.month,
      endSunday.day - (totalDays - 1),
    );

    int activeDays = 0;
    final List<List<DateTime>> weeks = [];

    for (int w = 0; w < totalWeeks; w++) {
      final List<DateTime> weekDays = [];
      for (int d = 0; d < 7; d++) {
        final date = DateTime(
          startMonday.year,
          startMonday.month,
          startMonday.day + (w * 7) + d,
        );
        weekDays.add(date);
        final dateKey = _formatDateKey(date);
        final score = activityByDate[dateKey] ?? 0;
        if (score > 0 && !date.isAfter(now)) {
          activeDays++;
        }
      }
      weeks.add(weekDays);
    }

    final weekdayLabels = isAr
        ? ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.3)
              : AppColors.secondary.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F4C3A) : Colors.black).withValues(
              alpha: isDark ? 0.3 : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Spiritual Alignment (7-Day Matrix matching Stitch)
          _buildWeeklySpiritualAlignment(context, isDark, isAr, now),
          const SizedBox(height: AppSpacing.md),
          Divider(
            color: isDark
                ? AppColors.secondary.withValues(alpha: 0.2)
                : AppColors.secondary.withValues(alpha: 0.12),
            thickness: 0.8,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        l10n.heatmapTitle,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  _locDigits(context, l10n.heatmapActiveDays(activeDays, 84)),
                  style: TextStyle(
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.heatmapSubtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Heatmap Grid: Rows = Days (Mon-Sun), Columns = Weeks
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekday labels column
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 6),
                child: Column(
                  children: List.generate(7, (d) {
                    // Show only alternate weekday labels for clean layout
                    final showLabel = d == 0 || d == 2 || d == 4 || d == 6;
                    return Container(
                      height: 14,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      alignment: Alignment.center,
                      child: Text(
                        showLabel ? weekdayLabels[d] : '',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Heatmap grid columns
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: isAr,
                  child: Row(
                    children: List.generate(weeks.length, (wIdx) {
                      final week = weeks[wIdx];
                      return Column(
                        children: List.generate(week.length, (dIdx) {
                          final date = week[dIdx];
                          final isFuture = date.isAfter(now);
                          final dateKey = _formatDateKey(date);
                          final score = isFuture
                              ? 0
                              : (activityByDate[dateKey] ?? 0);

                          return Tooltip(
                            message: isFuture
                                ? dateKey
                                : '$dateKey • ${l10n.heatmapScoreLabel(score)}',
                            child: Container(
                              width: 14,
                              height: 14,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isFuture
                                    ? (isDark
                                          ? Colors.white.withValues(alpha: 0.02)
                                          : Colors.black.withValues(
                                              alpha: 0.02,
                                            ))
                                    : _getCellColor(score, isDark),
                                borderRadius: BorderRadius.circular(3),
                                border: isFuture
                                    ? Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.04,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.03,
                                              ),
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Legend Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n.heatmapLess,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 4),
              ...[0, 1, 2, 4, 6].map(
                (lvl) => Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _getCellColor(lvl, isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.heatmapMore,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySpiritualAlignment(
    BuildContext context,
    bool isDark,
    bool isAr,
    DateTime now,
  ) {
    final dayNamesAr = {
      DateTime.monday: 'إث',
      DateTime.tuesday: 'ثل',
      DateTime.wednesday: 'أر',
      DateTime.thursday: 'خم',
      DateTime.friday: 'جمعة',
      DateTime.saturday: 'سبت',
      DateTime.sunday: 'أحد',
    };
    final dayNamesEn = {
      DateTime.monday: 'Mon',
      DateTime.tuesday: 'Tue',
      DateTime.wednesday: 'Wed',
      DateTime.thursday: 'Thu',
      DateTime.friday: 'Fri',
      DateTime.saturday: 'Sat',
      DateTime.sunday: 'Sun',
    };

    final List<(String, String, IconData?, bool, bool)> days = [];
    for (int offset = 6; offset >= 0; offset--) {
      final date = DateTime(now.year, now.month, now.day - offset);
      final isToday = offset == 0;
      final isJumuah = date.weekday == DateTime.friday;
      final isThursday = date.weekday == DateTime.thursday;
      final dateKey = _formatDateKey(date);
      final count = activityByDate[dateKey] ?? 0;

      final int scoreVal;
      final IconData? icon;
      if (count <= 0) {
        scoreVal = isToday ? (activityByDate.isNotEmpty ? 60 : 0) : 0;
        icon = null;
      } else if (count == 1) {
        scoreVal = 70;
        icon = Icons.check_rounded;
      } else {
        scoreVal = (75 + count * 8).clamp(0, 100);
        icon = isJumuah
            ? Icons.hotel_class_rounded
            : (isThursday ? Icons.star_rounded : Icons.check_rounded);
      }

      final label = isToday
          ? (isAr ? 'اليوم' : 'Today')
          : (isAr
                ? (dayNamesAr[date.weekday] ?? '')
                : (dayNamesEn[date.weekday] ?? ''));

      final scoreStr = isAr
          ? '${_locDigits(context, '$scoreVal')}٪'
          : '$scoreVal%';
      days.add((label, scoreStr, icon, isJumuah, isToday));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_view_week_rounded,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isAr
                          ? 'المحاذاة الروحية الأسبوعية'
                          : 'Weekly Spiritual Alignment',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryDark.withValues(alpha: 0.35)
                    : AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Text(
                isAr ? 'آخر ٧ أيام' : 'Last 7 Days',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.secondary : AppColors.secondaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 7-Day Matrix Tiles
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: days.map((dayData) {
              final (label, score, icon, isJumuah, isToday) = dayData;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Day Label
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: (isJumuah || isToday)
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isJumuah
                            ? AppColors.secondary
                            : isToday
                            ? const Color(0xFF4EDEA3)
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Tile
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: isJumuah
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFE9C349),
                                      Color(0xFF4EDEA3),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isJumuah
                                ? null
                                : isToday
                                ? const Color(0xFF4EDEA3)
                                : (isDark
                                          ? const Color(0xFF0F4C3A)
                                          : const Color(0xFF1B6B52))
                                      .withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isJumuah
                                  ? const Color(0xFFFFE088)
                                  : isToday
                                  ? const Color(0xFFB4EFD6)
                                  : AppColors.primaryLight.withValues(
                                      alpha: 0.25,
                                    ),
                              width: isToday || isJumuah ? 1.5 : 0.8,
                            ),
                            boxShadow: (isToday || isJumuah)
                                ? [
                                    BoxShadow(
                                      color:
                                          (isJumuah
                                                  ? AppColors.secondary
                                                  : const Color(0xFF4EDEA3))
                                              .withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _locDigits(context, score),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: (isJumuah || isToday)
                                  ? const Color(0xFF06100D)
                                  : Colors.white,
                            ),
                          ),
                        ),

                        // Jumu'ah Crown Indicator Dot
                        if (isJumuah)
                          Positioned(
                            top: -3,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Status Indicator (Icon or Live)
                    if (isToday)
                      Text(
                        isAr ? 'مباشر' : 'Live',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4EDEA3),
                        ),
                      )
                    else if (icon != null)
                      Icon(
                        icon,
                        size: 12,
                        color: isJumuah
                            ? AppColors.secondary
                            : const Color(0xFF4EDEA3),
                      )
                    else
                      const SizedBox(height: 12),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Caption Footer Row matching Stitch
        Container(
          padding: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                width: 0.8,
              ),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isAr ? '٥/٧ أيام التدفق الإيماني' : '5/7 Peak Flow Days',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.bolt_rounded,
                  size: 14,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 3),
                Text(
                  isAr
                      ? 'دفعة الجمعة نشطة (+١٨٪)'
                      : "Jumu'ah Boost Active (+18%)",
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
