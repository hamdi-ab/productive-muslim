import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/pulsing_glow.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

String _toArabicDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], arabic[i]);
  }
  return input;
}

/// Rich interactive bottom sheet presenting the user's sacred consistency streak (Istiqamah),
/// historical milestones, weekly momentum, and Sunnah spiritual reflections.
class IstiqamahStreakSheet extends StatelessWidget {
  const IstiqamahStreakSheet({super.key});

  static Future<void> show(BuildContext context) {
    AppHaptics.lightImpact();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const IstiqamahStreakSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final habitRepo = getIt.isRegistered<HabitRepository>()
        ? getIt<HabitRepository>()
        : null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1B15) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark
              ? const Color(0xFFE9C349).withValues(alpha: 0.35)
              : const Color(0xFFD4AF37).withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<int>(
              stream: habitRepo?.watchOverallStreak() ?? Stream.value(0),
              initialData: 0,
              builder: (context, streakSnapshot) {
                final streak = streakSnapshot.data ?? 0;

                return StreamBuilder<Map<String, int>>(
                  stream:
                      habitRepo?.watchCompletionsCountByDate(days: 14) ??
                      Stream.value(const {}),
                  initialData: const {},
                  builder: (context, countsSnapshot) {
                    final activityByDate = countsSnapshot.data ?? const {};

                    return StreamBuilder<List<Habit>>(
                      stream:
                          habitRepo?.watchActiveHabits() ??
                          Stream.value(const []),
                      initialData: const [],
                      builder: (context, habitsSnapshot) {
                        final activeHabits = habitsSnapshot.data ?? const [];
                        final totalHabits = activeHabits.length;

                        return StreamBuilder<Map<int, bool>>(
                          stream:
                              habitRepo?.watchCompletionsForDate(todayStr) ??
                              Stream.value(const {}),
                          initialData: const {},
                          builder: (context, todayCompletionsSnapshot) {
                            final todayCompletions =
                                todayCompletionsSnapshot.data ?? const {};
                            final completedTodayCount = todayCompletions.values
                                .where((v) => v)
                                .length;
                            final isSecuredToday = completedTodayCount > 0;

                            return FutureBuilder<int>(
                              future:
                                  habitRepo?.getLongestStreak() ??
                                  Future.value(streak),
                              initialData: streak,
                              builder: (context, longestSnapshot) {
                                final longestStreak =
                                    longestSnapshot.data ?? streak;

                                return ListView(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.md,
                                    AppSpacing.xs,
                                    AppSpacing.md,
                                    AppSpacing.lg,
                                  ),
                                  children: [
                                    // 1. Bismillah Sacred Purpose Header
                                    _buildBismillahPill(isDark, isAr),
                                    const SizedBox(height: AppSpacing.sm),

                                    // 2. Hero Flame Streak Card
                                    _buildHeroFlameCard(
                                      context,
                                      streak: streak,
                                      isSecuredToday: isSecuredToday,
                                      isDark: isDark,
                                      isAr: isAr,
                                      l10n: l10n,
                                    ),
                                    const SizedBox(height: AppSpacing.md),

                                    // 3. Quick 3-Metric Stats Row
                                    _buildMetricTrio(
                                      streak: streak,
                                      longestStreak: longestStreak,
                                      completedTodayCount: completedTodayCount,
                                      totalHabits: totalHabits,
                                      isDark: isDark,
                                      isAr: isAr,
                                    ),
                                    const SizedBox(height: AppSpacing.md),

                                    // 4. Weekly 7-Day Consistency Track
                                    _buildWeeklyTrackCard(
                                      now: now,
                                      activityByDate: activityByDate,
                                      isDark: isDark,
                                      isAr: isAr,
                                    ),
                                    const SizedBox(height: AppSpacing.md),

                                    // 5. Prophetic Hadith Banner
                                    _buildHadithBanner(isDark, isAr),
                                    const SizedBox(height: AppSpacing.md),

                                    // 6. Istiqamah Milestone Ladder
                                    _buildMilestoneLadder(
                                      streak: streak,
                                      isDark: isDark,
                                      isAr: isAr,
                                    ),
                                    const SizedBox(height: AppSpacing.lg),

                                    // 7. Primary Action Button
                                    _buildActionButton(context, isDark, isAr),
                                    const SizedBox(height: AppSpacing.sm),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillahPill(bool isDark, bool isAr) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF142820) : const Color(0xFFF1F7F4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0xFFE9C349).withValues(alpha: 0.3)
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
                isAr
                    ? 'مَنْهَجُ الِاسْتِقَامَةِ'
                    : 'SACRED CONSISTENCY (ISTIQAMAH)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white70 : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroFlameCard(
    BuildContext context, {
    required int streak,
    required bool isSecuredToday,
    required bool isDark,
    required bool isAr,
    required AppLocalizations l10n,
  }) {
    final streakDigits = isAr ? _toArabicDigits('$streak') : '$streak';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF162E24), const Color(0xFF0F1E17)]
              : [const Color(0xFFFEF3C7), const Color(0xFFFFFBEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.4 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706)
                .withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          PulsingGlow(
            animate: streak >= 3,
            minScale: 0.94,
            maxScale: 1.06,
            duration: const Duration(milliseconds: 1400),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                size: 46,
                color: Color(0xFFD97706),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Streak Count Number
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                streakDigits,
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isAr ? 'يوم استقامة' : 'Days Streak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : const Color(0xFF92400E),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Status Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isSecuredToday
                  ? (isDark
                        ? const Color(0xFF10B981).withValues(alpha: 0.2)
                        : const Color(0xFFD1FAE5))
                  : (isDark
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                        : const Color(0xFFFEF3C7)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSecuredToday
                    ? const Color(0xFF10B981).withValues(alpha: 0.5)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.5),
                width: 0.9,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSecuredToday
                      ? Icons.check_circle_rounded
                      : Icons.hourglass_top_rounded,
                  size: 14,
                  color: isSecuredToday
                      ? const Color(0xFF10B981)
                      : const Color(0xFFD97706),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    isSecuredToday
                        ? (isAr
                              ? 'تم تأمين استقامة اليوم • بارك الله في عملك'
                              : 'Secured Today • Barakah Active')
                        : (isAr
                              ? 'أكمل عادات اليوم للحفاظ على استقامتك'
                              : 'Complete habits today to maintain streak'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSecuredToday
                          ? (isDark
                                ? const Color(0xFF6EE7B7)
                                : const Color(0xFF065F46))
                          : (isDark
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFF92400E)),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTrio({
    required int streak,
    required int longestStreak,
    required int completedTodayCount,
    required int totalHabits,
    required bool isDark,
    required bool isAr,
  }) {
    final streakStr = isAr ? '${_toArabicDigits('$streak')}ي' : '${streak}d';
    final bestStr = isAr
        ? '${_toArabicDigits('$longestStreak')}ي'
        : '${longestStreak}d';
    final ratioStr = isAr
        ? '${_toArabicDigits('$completedTodayCount')} / ${_toArabicDigits('$totalHabits')}'
        : '$completedTodayCount / $totalHabits';

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: isAr ? 'الاستمرارية' : 'Current',
            value: streakStr,
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFD97706),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            label: isAr ? 'أعلى رقم' : 'Best Streak',
            value: bestStr,
            icon: Icons.military_tech_rounded,
            iconColor: AppColors.secondary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            label: isAr ? 'عادات اليوم' : 'Today',
            value: ratioStr,
            icon: Icons.checklist_rounded,
            iconColor: const Color(0xFF10B981),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13221C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.borderLight,
          width: 0.9,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrackCard({
    required DateTime now,
    required Map<String, int> activityByDate,
    required bool isDark,
    required bool isAr,
  }) {
    final weekday = now.weekday;
    final startOfWeek = now.subtract(Duration(days: weekday - 1));
    final dayNamesEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayNamesAr = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13221C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.25)
              : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'مسار الأسبوع الحالي' : 'Current Week Track',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isAr ? 'الإثنين – الأحد' : 'Mon – Sun',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(7, (i) {
              final day = startOfWeek.add(Duration(days: i));
              final dateStr = DateFormat('yyyy-MM-dd').format(day);
              final isToday =
                  day.day == now.day &&
                  day.month == now.month &&
                  day.year == now.year;
              final isPast = day.isBefore(
                DateTime(now.year, now.month, now.day),
              );
              final count = activityByDate[dateStr] ?? 0;
              final isDone = count > 0;

              final label = isAr ? dayNamesAr[i] : dayNamesEn[i];
              final dayNum = isAr
                  ? _toArabicDigits('${day.day}')
                  : '${day.day}';

              Color circleBg;
              Color circleBorder;
              Widget iconWidget;

              if (isDone) {
                circleBg = const Color(0xFF10B981);
                circleBorder = const Color(0xFF059669);
                iconWidget = const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                );
              } else if (isToday) {
                circleBg = isDark
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
                    : const Color(0xFFFEF3C7);
                circleBorder = const Color(0xFFF59E0B);
                iconWidget = const Icon(
                  Icons.hourglass_bottom_rounded,
                  size: 13,
                  color: Color(0xFFD97706),
                );
              } else if (isPast) {
                circleBg = isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05);
                circleBorder = Colors.transparent;
                iconWidget = Text(
                  dayNum,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                );
              } else {
                circleBg = Colors.transparent;
                circleBorder = isDark ? Colors.white12 : Colors.black12;
                iconWidget = Text(
                  dayNum,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                );
              }

              return Expanded(
                child: Column(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                        color: isToday
                            ? const Color(0xFFD97706)
                            : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: circleBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: circleBorder, width: 1.2),
                      ),
                      alignment: Alignment.center,
                      child: iconWidget,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithBanner(bool isDark, bool isAr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.15)
            : const Color(0xFFF2F8F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 0.9,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            size: 20,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr
                      ? '«أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ»'
                      : '“The most beloved deeds to Allah are those done regularly, even if small.”',
                  style: TextStyle(
                    fontFamily: isAr ? 'amiri' : null,
                    fontSize: 12.5,
                    fontStyle: isAr ? FontStyle.normal : FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.black87,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isAr ? 'صحيح البخاري ومسلم' : 'Sahih al-Bukhari & Muslim',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneLadder({
    required int streak,
    required bool isDark,
    required bool isAr,
  }) {
    final stages = [
      (
        target: 3,
        nameAr: 'البداية (بذرة النية)',
        nameEn: 'Bidayah (Spark of Intention)',
        descAr: '٣ أيام استمرار',
        descEn: '3 days of continuous action',
      ),
      (
        target: 7,
        nameAr: 'الثبات (الأسبوع الأول)',
        nameEn: 'Thabat (First Solid Week)',
        descAr: '٧ أيام متتالية',
        descEn: '7 continuous days routine',
      ),
      (
        target: 21,
        nameAr: 'الاستقامة (بناء العادة)',
        nameEn: 'Istiqamah (Sunnah Habit Lock)',
        descAr: '٢١ يوماً لتأصيل العادة',
        descEn: '21 days neural entrenchment',
      ),
      (
        target: 40,
        nameAr: 'الإخلاص (نقاء القلب)',
        nameEn: 'Ikhlas (40-Day Heart Cleanse)',
        descAr: '٤٠ يوماً في سبيل الله',
        descEn: '40 days prophetic heart purification',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13221C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.borderLight,
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                isAr ? 'مراتب ومحطات الاستقامة' : 'Istiqamah Milestone Ladder',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < stages.length; i++) ...[
            _buildMilestoneRow(
              index: i + 1,
              target: stages[i].target,
              title: isAr ? stages[i].nameAr : stages[i].nameEn,
              desc: isAr ? stages[i].descAr : stages[i].descEn,
              streak: streak,
              isDark: isDark,
              isAr: isAr,
            ),
            if (i < stages.length - 1)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 16),
                child: Container(
                  width: 1.5,
                  height: 14,
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMilestoneRow({
    required int index,
    required int target,
    required String title,
    required String desc,
    required int streak,
    required bool isDark,
    required bool isAr,
  }) {
    final isReached = streak >= target;
    final inProgress = !isReached && (index == 1 || streak >= target ~/ 2);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isReached
                ? const Color(0xFF10B981)
                : inProgress
                ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                : (isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05)),
            shape: BoxShape.circle,
            border: Border.all(
              color: isReached
                  ? const Color(0xFF059669)
                  : inProgress
                  ? const Color(0xFFF59E0B)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: isReached
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : inProgress
              ? const Icon(
                  Icons.flag_rounded,
                  size: 14,
                  color: Color(0xFFD97706),
                )
              : Text(
                  isAr ? _toArabicDigits('$target') : '$target',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isReached
                      ? (isDark ? Colors.white : Colors.black87)
                      : inProgress
                      ? const Color(0xFFD97706)
                      : (isDark ? Colors.white54 : Colors.black45),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isReached)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isAr ? 'مكتمل' : 'Unlocked',
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          )
        else if (inProgress)
          Text(
            isAr
                ? '${_toArabicDigits('$streak')}/${_toArabicDigits('$target')}'
                : '$streak/$target',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD97706),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, bool isDark, bool isAr) {
    return AppPressable(
      onTap: () {
        AppHaptics.mediumImpact();
        Navigator.pop(context);
        context.go('/habits');
      },
      pressedScale: 0.98,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF0F4C3A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.checklist_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              isAr ? 'الذهاب إلى قائمة العادات اليومية' : 'View Daily Habits',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
