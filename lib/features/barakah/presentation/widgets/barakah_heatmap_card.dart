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
    return const Color(0xFF15803D); // Peak Barakah emerald
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
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        l10n.heatmapTitle,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _locDigits(context, l10n.heatmapActiveDays(activeDays, 84)),
                  style: const TextStyle(
                    color: AppColors.primary,
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
}
