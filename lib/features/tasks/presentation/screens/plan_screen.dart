import 'dart:math' as math;

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
      backgroundColor: isDark ? const Color(0xFF0B1512) : null,
      floatingActionButton: AppPressable(
        onTap: () => _showCreateAction(context),
        pressedScale: 0.90,
        haptic: AppHapticFeedback.light,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE9C349), Color(0xFFFFD54F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE9C349).withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _showCreateAction(context),
            elevation: 0,
            highlightElevation: 0,
            backgroundColor: Colors.transparent,
            icon: const Icon(Icons.add_rounded, color: Color(0xFF241A00)),
            label: Text(
              _selectedTab == PlanTab.tasks ? l10n.newTask : l10n.newHabit,
              style: const TextStyle(
                color: Color(0xFF241A00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Sacred Geometry Watermark
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _IslamicLatticeBackgroundPainter(isDark: isDark),
              ),
            ),
          ),
          // Subtle Atmospheric Sacred Glow (Stitch style)
          Positioned(
            top: -50,
            left: 0,
            right: 0,
            height: 260,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.6),
                    radius: 0.85,
                    colors: [
                      const Color(0xFFE9C349)
                          .withValues(alpha: isDark ? 0.12 : 0.08),
                      const Color(0xFF0F4C3A)
                          .withValues(alpha: isDark ? 0.08 : 0.04),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Bottom subtle emerald glow
          Positioned(
            bottom: -40,
            left: -40,
            width: 220,
            height: 220,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0F4C3A)
                          .withValues(alpha: isDark ? 0.12 : 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    String hijriText = '';
    if (getIt.isRegistered<HijriService>()) {
      final hijri = getIt<HijriService>().getHijriDate(_selectedDate);
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

    final dayOfYear =
        _selectedDate.difference(DateTime(_selectedDate.year, 1, 1)).inDays + 1;
    final dayProgressStr = isAr
        ? 'اليوم $dayOfYear من ٣٥٤'
        : 'Day $dayOfYear of 354';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hijri Date Anchor & Day Pill Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE9C349),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        hijriText.isNotEmpty
                            ? hijriText
                            : DateFormat('EEEE, d MMMM yyyy')
                                  .format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE9C349),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141E1A)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF404944).withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  dayProgressStr,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark
                        ? const Color(0xFFBFC9C3)
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Daily Plan Screen Title & Barakah Focus Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isAr ? 'الخطة اليومية' : 'Daily Plan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: isDark
                        ? const Color(0xFFDAE5E0)
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF004D33).withValues(alpha: 0.5)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF4EDEA3).withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.energy_savings_leaf_rounded,
                      size: 13,
                      color: Color(0xFF4EDEA3),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAr ? 'تركيز البركة' : 'Barakah Focus',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF4EDEA3)
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date Switcher Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppPressable(
                  onTap: () => _changeDate(-1),
                  pressedScale: 0.88,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
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
                          ? const Color(0xFFDAE5E0)
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
                            Icons.calendar_month_rounded,
                            size: 15,
                            color: Color(0xFFE9C349),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              DateFormat('d MMMM yyyy').format(_selectedDate),
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
                                color: const Color(0xFF004D33)
                                    .withValues(alpha: isDark ? 0.6 : 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF4EDEA3)
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Today',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4EDEA3),
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
                              ? const Color(0xFFBFC9C3)
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
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
                    width: 32,
                    height: 32,
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
                          ? const Color(0xFFDAE5E0)
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
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
                  const Color(0xFF06100D),
                  const Color(0xFF0F4C3A),
                  const Color(0xFF141E1A),
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
          color: const Color(0xFFE9C349).withValues(alpha: 0.35),
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
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9C349).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE9C349).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Color(0xFFE9C349),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Spiritual Anchor',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFE088),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: AppPressable(
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
                          Icon(
                            Icons.sync_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141E1A) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? const Color(0xFFE9C349).withValues(alpha: 0.25)
                  : AppColors.secondary.withValues(alpha: 0.18),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF0F4C3A) : Colors.black)
                    .withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Intention Alignment',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFFBFC9C3)
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          totalTasks == 0
                              ? 'Daily Intention Alignment'
                              : '$completedTasks of $totalTasks Tasks Completed',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFDAE5E0)
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(44, 44),
                          painter: _GaugeRingPainter(
                            progress: percent / 100,
                            trackColor: isDark
                                ? const Color(0xFF2D3733)
                                : Colors.black.withValues(alpha: 0.06),
                            progressColor: const Color(0xFFE9C349),
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE9C349),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                                      ? const Color(0xFF4EDEA3)
                                      : const Color(0xFFE9C349))
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
              ? const Color(0xFF18221E)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? const Color(0xFF404944).withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.06),
          ),
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
                icon: Icons.local_fire_department_rounded,
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
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF0F4C3A), Color(0xFF004D33)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFFE9C349).withValues(alpha: 0.35),
                  width: 1,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4EDEA3).withValues(alpha: 0.22),
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
                ? const Color(0xFFBFC9C3)
                : AppColors.textSecondary;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isSelected ? const Color(0xFFE9C349) : unselectedColor,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : unselectedColor,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontSize: 13.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _GaugeRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _GaugeRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugeRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}

class _IslamicLatticeBackgroundPainter extends CustomPainter {
  final bool isDark;

  const _IslamicLatticeBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? const Color(0xFF4EDEA3) : AppColors.primary)
          .withValues(alpha: isDark ? 0.025 : 0.015)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const step = 56.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        canvas.drawCircle(Offset(x, y), step * 0.35, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicLatticeBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
