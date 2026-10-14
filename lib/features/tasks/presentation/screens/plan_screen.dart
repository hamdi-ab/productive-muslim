import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/habits/logic/habit_bloc.dart';
import 'package:productive_muslim/features/habits/logic/habit_event.dart';
import 'package:productive_muslim/features/habits/presentation/screens/create_habit_sheet.dart';
import 'package:productive_muslim/features/habits/presentation/screens/habit_screen.dart';
import 'package:productive_muslim/features/tasks/logic/task_bloc.dart';
import 'package:productive_muslim/features/tasks/logic/task_event.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/create_task_sheet.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/task_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

enum PlanTab { tasks, habits }

class PlanScreen extends StatefulWidget {
  final PlanTab initialTab;

  const PlanScreen({super.key, this.initialTab = PlanTab.tasks});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late PlanTab _selectedTab;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  void _onTabChanged(PlanTab tab) {
    if (_selectedTab == tab) return;
    AppHaptics.selectionClick();
    setState(() => _selectedTab = tab);
  }

  void _changeDate(int days) {
    AppHaptics.selectionClick();
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  void _showRenewNiyyahSheet(BuildContext context) {
    AppHaptics.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.secondary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Renew Your Daily Intention',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ\n"Actions are judged solely by intentions."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Purify your heart for Allah alone. Dedicate your work, family duties, and worship today as acts of divine devotion for His pleasure.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              AppPressable(
                onTap: () {
                  AppHaptics.mediumImpact();
                  Navigator.pop(ctx);
                  context.push('/journal');
                },
                pressedScale: 0.96,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF135D47)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Record Niyyah in Journal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showCreateTaskSheet(BuildContext context) {
    AppHaptics.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (ctx) =>
            TaskBloc(ctx.read<TaskRepository>())
              ..add(TaskLoaded(_formattedDate)),
        child: CreateTaskSheet(
          date: _formattedDate,
          onSwitchToHabit: () {
            Navigator.pop(context);
            _showCreateHabitSheet(context);
          },
        ),
      ),
    );
  }

  void _showCreateHabitSheet(BuildContext context) {
    AppHaptics.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (ctx) =>
            HabitBloc(ctx.read<HabitRepository>())..add(const HabitLoaded()),
        child: CreateHabitSheet(
          onSwitchToTask: () {
            Navigator.pop(context);
            _showCreateTaskSheet(context);
          },
        ),
      ),
    );
  }

  void _showCreateAction(BuildContext context) {
    if (_selectedTab == PlanTab.tasks) {
      _showCreateTaskSheet(context);
    } else {
      _showCreateHabitSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: AppPressable(
        onTap: () => _showCreateAction(context),
        pressedScale: 0.90,
        haptic: AppHapticFeedback.light,
        child: FloatingActionButton.extended(
          onPressed: () => _showCreateAction(context),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            _selectedTab == PlanTab.tasks ? l10n.newTask : l10n.newHabit,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Date Switcher Navigator
          _buildDateNavigator(context, isDark),

          // 2. Spiritual Anchor Banner (Bismillah & Niyyah Renewal)
          _buildSpiritualAnchorBanner(context, isDark),

          // 3. Barakah Alignment Progress Meter
          _buildBarakahAlignmentMeter(context, isDark),

          // 4. Segmented Capsule Switcher [Tasks | Habits]
          _buildSegmentedTabSwitcher(context, l10n, isDark),

          // 5. Active Tab Content View
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _selectedTab == PlanTab.tasks
                  ? TaskScreen(
                      key: ValueKey('plan_task_view_$_formattedDate'),
                      date: _formattedDate,
                    )
                  : const HabitScreen(key: ValueKey('plan_habit_view')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigator(BuildContext context, bool isDark) {
    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    String hijriText = '';
    if (getIt.isRegistered<HijriService>()) {
      final hijri = getIt<HijriService>().getHijriDate(_selectedDate);
      final isAr = Localizations.localeOf(context).languageCode == 'ar';
      hijriText = isAr
          ? '${hijri.hDay} ${hijri.monthNameAr} ${hijri.hYear} هـ'
          : '${hijri.hDay} ${hijri.monthNameEn} ${hijri.hYear} AH';
    }

    String prayerTimesSub = DateFormat('EEEE, d MMMM yyyy')
        .format(_selectedDate);
    if (getIt.isRegistered<PrayerTimeService>()) {
      final prayerService = getIt<PrayerTimeService>();
      if (prayerService.cachedPrayerTimes != null) {
        final pt = prayerService.cachedPrayerTimes!;
        final fajrStr =
            '${pt.fajr.hour.toString().padLeft(2, '0')}:${pt.fajr.minute.toString().padLeft(2, '0')}';
        final sunsetStr =
            '${pt.maghrib.hour.toString().padLeft(2, '0')}:${pt.maghrib.minute.toString().padLeft(2, '0')}';
        prayerTimesSub += ' • Fajr $fajrStr • Sunset $sunsetStr';
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.primary.withValues(alpha: 0.12),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppPressable(
            onTap: () => _changeDate(-1),
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
                Icons.chevron_left_rounded,
                size: 20,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.event_note_rounded,
                      size: 15,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        hijriText.isNotEmpty
                            ? hijriText
                            : DateFormat('d MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  prayerTimesSub,
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
          AppPressable(
            onTap: () => _changeDate(1),
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
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpiritualAnchorBanner(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.md, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF072118),
                  AppColors.primaryDark,
                  const Color(0xFF0F4C3A),
                ]
              : [
                  const Color(0xFF0A3427),
                  AppColors.primary,
                  const Color(0xFF135D47),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C3A)
                .withValues(alpha: isDark ? 0.3 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: Color(0xFFFFD700),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Spiritual Anchor',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFE082),
                      ),
                    ),
                  ],
                ),
              ),
              AppPressable(
                onTap: () => _showRenewNiyyahSheet(context),
                pressedScale: 0.92,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Renew Niyyah',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.sync_rounded, size: 13, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: Color(0xFFFFF8E1),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"Actions are judged by intentions (Niyyah). Align today\'s focus with Barakah."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.white.withValues(alpha: 0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarakahAlignmentMeter(BuildContext context, bool isDark) {
    return StreamBuilder<List<Task>>(
      stream: context.read<TaskRepository>().watchTasksForDate(_formattedDate),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        final totalTasks = tasks.length;
        final completedTasks = tasks.where((t) => t.completed).length;

        final percent = totalTasks > 0
            ? (completedTasks / totalTasks * 100).round()
            : 0;

        return Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            10,
            AppSpacing.md,
            0,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        totalTasks == 0
                            ? 'Daily Intention Alignment'
                            : '$completedTasks of $totalTasks Intentions Completed',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      '$percent% Barakah Alignment',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Segmented 10-bar progress indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 6,
                  child: Row(
                    children: List.generate(10, (idx) {
                      final segmentPercent = (idx + 1) * 10;
                      final isFilled = percent >= segmentPercent;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: idx < 9 ? 2 : 0),
                          decoration: BoxDecoration(
                            color: isFilled
                                ? (idx < 7
                                      ? AppColors.primary
                                      : const Color(0xFFD4AF37))
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.06)),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegmentedTabSwitcher(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.md, 4),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabPill(
                context: context,
                tab: PlanTab.tasks,
                label: l10n.tasks,
                icon: Icons.task_alt_rounded,
                isSelected: _selectedTab == PlanTab.tasks,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildTabPill(
                context: context,
                tab: PlanTab.habits,
                label: l10n.habits,
                icon: Icons.published_with_changes_rounded,
                isSelected: _selectedTab == PlanTab.habits,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required BuildContext context,
    required PlanTab tab,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return AppPressable(
      onTap: () => _onTabChanged(tab),
      pressedScale: 0.96,
      haptic: AppHapticFeedback.selection,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final unselectedColor = isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isSelected ? Colors.white : unselectedColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : unselectedColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
