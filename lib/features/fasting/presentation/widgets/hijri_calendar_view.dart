import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class HijriCalendarView extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;
  final VoidCallback? onTargetToggled;

  const HijriCalendarView({
    super.key,
    this.onDateSelected,
    this.onTargetToggled,
  });

  @override
  State<HijriCalendarView> createState() => _HijriCalendarViewState();
}

class _HijriCalendarViewState extends State<HijriCalendarView> {
  DateTime _currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime _selectedDate = DateTime.now();

  void _prevMonth() {
    AppHaptics.lightImpact();
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    AppHaptics.lightImpact();
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    AppHaptics.lightImpact();
    setState(() {
      final now = DateTime.now();
      _currentMonth = DateTime(now.year, now.month, 1);
      _selectedDate = now;
    });
  }

  SettingsService _getSettings() {
    try {
      return getIt<SettingsService>();
    } catch (_) {
      return SettingsService.empty();
    }
  }

  void _showDayDetails(BuildContext context, HijriDateInfo info) {
    AppHaptics.selectionClick();
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final dateStr = DateFormat('yyyy-MM-dd').format(info.gregorianDate);
    final settings = _getSettings();
    bool isFasting = settings.isSunnahFastingTarget(dateStr);

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? info.formatAr() : info.formatEn(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat.yMMMMEEEEd(isArabic ? 'ar' : 'en')
                              .format(info.gregorianDate),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (info.isWhiteDay)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.brightness_2_rounded,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.whiteDayBadge,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (info.isArafah)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Text(
                          'Arafah',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (info.isAshura)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Ashura',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                if (info.isProhibited)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isArabic
                                ? 'يحرم الصيام في يوم العيد وأيام التشريق'
                                : 'Fasting is prohibited on Eid & Tashriq days',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (info.isSunnahFastingDay)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.eco_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            info.isArafah
                                ? (isArabic ? 'صيام يوم عرفة' : 'Day of Arafah')
                                : (info.isAshura
                                      ? (isArabic
                                            ? 'صيام يوم عاشوراء'
                                            : 'Day of Ashura')
                                      : (info.isWhiteDay
                                            ? l10n.whiteDaysDesc
                                            : l10n.mondayThursdaySunnah)),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                if (!info.isProhibited)
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: Icon(
                            isFasting
                                ? Icons.check_circle_rounded
                                : Icons.water_drop_outlined,
                          ),
                          label: Text(
                            isFasting
                                ? l10n.fastingTodayActive
                                : l10n.fastingIntendAction,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: isFasting
                                ? AppColors.secondary
                                : AppColors.primary,
                            foregroundColor: isFasting
                                ? Colors.black87
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            AppHaptics.mediumImpact();
                            await settings.toggleSunnahFastingTarget(dateStr);
                            if (ctx.mounted) {
                              setSheetState(() => isFasting = !isFasting);
                            }
                            if (mounted) {
                              setState(() {});
                            }
                            widget.onTargetToggled?.call();
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.fastingLoggedSuccess),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final hijriService = getIt.isRegistered<HijriService>()
        ? getIt<HijriService>()
        : HijriService();

    final monthDays = hijriService.getMonthDays(_currentMonth);
    final firstDayWeekday = _currentMonth.weekday; // 1 = Monday, 7 = Sunday
    final leadingEmptyCount = (firstDayWeekday - 1) % 7;

    final firstHijri = monthDays.isNotEmpty ? monthDays.first : null;
    final lastHijri = monthDays.isNotEmpty ? monthDays.last : null;

    final String hijriMonthHeader;
    if (firstHijri != null && lastHijri != null) {
      if (firstHijri.hMonth == lastHijri.hMonth) {
        hijriMonthHeader = isArabic
            ? '${firstHijri.monthNameAr} ${firstHijri.hYear} هـ'
            : '${firstHijri.monthNameEn} ${firstHijri.hYear} AH';
      } else {
        hijriMonthHeader = isArabic
            ? '${firstHijri.monthNameAr} / ${lastHijri.monthNameAr} ${lastHijri.hYear} هـ'
            : '${firstHijri.monthNameEn} / ${lastHijri.monthNameEn} ${lastHijri.hYear} AH';
      }
    } else {
      hijriMonthHeader = '';
    }

    final gregorianHeader = DateFormat.yMMMM(isArabic ? 'ar' : 'en')
        .format(_currentMonth);
    final weekdayLabels = isArabic
        ? ['إثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت', 'أحد']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final settings = _getSettings();

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Month Name & Navigation
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hijriMonthHeader,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      gregorianHeader,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: _prevMonth,
                tooltip: l10n.prevMonthTooltip,
              ),
              IconButton(
                icon: const Icon(Icons.today_rounded, size: 20),
                onPressed: _goToToday,
                tooltip: l10n.todayTooltip,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: _nextMonth,
                tooltip: l10n.nextMonthTooltip,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Weekday Column Titles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayLabels.map((lbl) {
              return Expanded(
                child: Center(
                  child: Text(
                    lbl,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // Calendar Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingEmptyCount + monthDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              if (index < leadingEmptyCount) {
                return const SizedBox.shrink();
              }
              final dayIndex = index - leadingEmptyCount;
              final info = monthDays[dayIndex];
              final date = info.gregorianDate;
              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              final isToday = DateUtils.isSameDay(date, DateTime.now());
              final isSelected = DateUtils.isSameDay(date, _selectedDate);
              final isFasted = settings.isSunnahFastingTarget(dateStr);

              Color? bgColor;
              Border? border;

              if (isToday) {
                border = Border.all(color: AppColors.primary, width: 2);
              }

              if (isFasted) {
                bgColor = AppColors.secondary.withValues(alpha: 0.25);
              } else if (info.isWhiteDay) {
                bgColor = Colors.amber.withValues(alpha: 0.15);
              } else if (info.isMondayOrThursday) {
                bgColor = AppColors.primary.withValues(alpha: 0.08);
              }

              return InkWell(
                onTap: () {
                  setState(() => _selectedDate = date);
                  widget.onDateSelected?.call(date);
                  _showDayDetails(context, info);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: border,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 1,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Gregorian Day
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isToday || isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 1),
                          // Hijri Day with indicator
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (info.isWhiteDay) ...[
                                const Icon(
                                  Icons.brightness_2_rounded,
                                  size: 8,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 1),
                              ],
                              Text(
                                '${info.hDay}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: info.isWhiteDay
                                      ? Colors.amber[800]
                                      : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          if (isFasted)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegendItem(
                color: Colors.amber.withValues(alpha: 0.3),
                icon: Icons.brightness_2_rounded,
                iconColor: Colors.amber,
                label: l10n.whiteDaysLabel,
              ),
              _buildLegendItem(
                color: AppColors.primary.withValues(alpha: 0.15),
                label: l10n.mondayThursdaySunnah,
              ),
              _buildLegendItem(
                color: AppColors.secondary.withValues(alpha: 0.35),
                dotColor: AppColors.secondary,
                label: l10n.fastingTodayActive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    IconData? icon,
    Color? iconColor,
    Color? dotColor,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: icon != null
              ? Icon(icon, size: 9, color: iconColor)
              : (dotColor != null
                    ? Center(
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
