import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';

import 'package:productive_muslim/core/constants/app_life_areas.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/bouncy_checkbox.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/core/widgets/pulsing_glow.dart';
import 'package:productive_muslim/features/habits/logic/habit_bloc.dart';
import 'package:productive_muslim/features/habits/logic/habit_event.dart';
import 'package:productive_muslim/features/habits/logic/habit_state.dart';
import 'package:productive_muslim/features/habits/presentation/screens/create_habit_sheet.dart';
import 'package:productive_muslim/features/habits/presentation/screens/istiqamah_streak_sheet.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class HabitScreen extends StatelessWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasParentScaffold = Scaffold.maybeOf(context) != null;

    return BlocProvider(
      create: (context) =>
          HabitBloc(context.read<HabitRepository>())..add(const HabitLoaded()),
      child: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: hasParentScaffold ? Colors.transparent : null,
            appBar: hasParentScaffold ? null : AppBar(title: Text(l10n.habits)),
            body: state is Loaded
                ? state.habits.isEmpty
                      ? _EmptyState(l10n: l10n)
                      : _HabitList(state: state, l10n: l10n)
                : state is Loading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : state is Error
                ? _ErrorState(message: state.message)
                : const Center(child: SizedBox.shrink()),
            floatingActionButton: hasParentScaffold
                ? null
                : FloatingActionButton(
                    onPressed: () {
                      AppHaptics.lightImpact();
                      _showCreateSheet(context);
                    },
                    child: const Icon(Icons.add),
                  ),
          );
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<HabitBloc>(),
        child: const CreateHabitSheet(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.self_improvement,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.emptyHabits,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.read<HabitBloc>().add(const HabitLoaded()),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _HabitList extends StatelessWidget {
  final Loaded state;
  final AppLocalizations l10n;
  const _HabitList({required this.state, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Habit>>{};
    for (final habit in state.habits) {
      grouped.putIfAbsent(habit.category, () => []).add(habit);
    }

    final categoryColors = AppLifeArea.all;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        _WeekHeader(l10n: l10n),
        const Divider(height: 1),
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: categoryColors[entry.key],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _getLocalizedCategoryName(entry.key, l10n),
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          for (final habit in entry.value)
            _HabitTile(
              habit: habit,
              completed: state.completions[habit.id] ?? false,
              streak: state.streaks[habit.id] ?? 0,
            ),
        ],
      ],
    );
  }

  String _getLocalizedCategoryName(String key, AppLocalizations l10n) {
    return switch (key) {
      'spiritual' => l10n.sphereSpiritual,
      'physical' => l10n.spherePhysical,
      'social' => l10n.sphereSocial,
      'islam' => l10n.islam,
      'family' => l10n.family,
      'work' => l10n.work,
      'personal_dev' => l10n.personalDev,
      _ => AppLifeArea.labels[key] ?? key,
    };
  }
}

class _WeekHeader extends StatelessWidget {
  final AppLocalizations l10n;
  const _WeekHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = now.weekday;
    final startOfWeek = now.subtract(Duration(days: weekday - 1));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final dayLabels = isAr
        ? ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final habitRepo = getIt.isRegistered<HabitRepository>()
        ? getIt<HabitRepository>()
        : null;

    return StreamBuilder<int>(
      stream: habitRepo?.watchOverallStreak() ?? Stream.value(0),
      initialData: 0,
      builder: (context, streakSnapshot) {
        final streak = streakSnapshot.data ?? 0;

        return StreamBuilder<Map<String, int>>(
          stream:
              habitRepo?.watchCompletionsCountByDate(days: 14) ??
              Stream.value(const {}),
          initialData: const {},
          builder: (context, activitySnapshot) {
            final activityByDate = activitySnapshot.data ?? const {};

            return Padding(
              padding: const EdgeInsets.all(16),
              child: AppPressable(
                onTap: () {
                  AppHaptics.lightImpact();
                  IstiqamahStreakSheet.show(context);
                },
                pressedScale: 0.98,
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  l10n.habitToday,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 14,
                                  color: AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                key: const Key('habit_screen_streak_pill'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (isDark
                                              ? AppColors.secondary
                                              : AppColors.secondaryDark)
                                          .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        (isDark
                                                ? AppColors.secondary
                                                : AppColors.secondaryDark)
                                            .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 14,
                                      color: Color(0xFFD97706),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      streak > 0
                                          ? l10n.streak(streak)
                                          : l10n.weeklyTrack,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? const Color(0xFFFBBF24)
                                            : const Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: List.generate(7, (i) {
                          final day = startOfWeek.add(Duration(days: i));
                          final dateStr = DateFormat('yyyy-MM-dd').format(day);
                          final isToday =
                              day.day == now.day &&
                              day.month == now.month &&
                              day.year == now.year;
                          final isCompleted =
                              (activityByDate[dateStr] ?? 0) > 0;

                          return Expanded(
                            child: Column(
                              children: [
                                Text(
                                  dayLabels[i],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: isToday
                                        ? AppColors.primary
                                        : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.textSecondary),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? const Color(0xFF10B981)
                                        : isToday
                                        ? AppColors.primary
                                        : (isDark
                                              ? AppColors.darkSurfaceSubtle
                                              : AppColors.surfaceSubtle),
                                    shape: BoxShape.circle,
                                    border: isCompleted
                                        ? Border.all(
                                            color: const Color(0xFF059669),
                                            width: 1.2,
                                          )
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: isCompleted
                                      ? const Icon(
                                          Icons.check_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: (isCompleted || isToday)
                                                ? Colors.white
                                                : (isDark
                                                      ? AppColors
                                                            .darkTextPrimary
                                                      : AppColors.textPrimary),
                                            fontWeight: isToday
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HabitTile extends StatelessWidget {
  final Habit habit;
  final bool completed;
  final int streak;

  const _HabitTile({
    required this.habit,
    required this.completed,
    required this.streak,
  });

  static const _categoryColors = AppLifeArea.all;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[habit.category] ?? AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey('habit_${habit.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      confirmDismiss: (_) async {
        final l10n = AppLocalizations.of(context)!;
        return showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.delete),
            content: Text(l10n.habitSwipeDelete),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  AppHaptics.mediumImpact();
                  Navigator.pop(ctx, true);
                },
                child: Text(l10n.delete),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<HabitBloc>().add(HabitDeleted(habit.id));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: GlassContainer(
          padding: const EdgeInsets.all(14),
          borderRadius: 20,
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.8),
          child: Row(
            children: [
              BouncyCheckbox(
                key: Key('habit_checkbox_${habit.id}'),
                value: completed,
                activeColor: color,
                semanticLabel: habit.name,
                onChanged: (_) {
                  context.read<HabitBloc>().add(
                    HabitCompletionToggled(habit.id),
                  );
                },
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: completed ? TextDecoration.lineThrough : null,
                    color: completed
                        ? (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textDisabled)
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                  ),
                  child: Text(habit.name),
                ),
              ),
              if (streak > 0)
                PulsingGlow(
                  animate: streak >= 7,
                  minScale: 0.96,
                  maxScale: 1.04,
                  duration: const Duration(milliseconds: 1600),
                  child: Container(
                    key: Key('habit_streak_${habit.id}'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isDark
                                  ? AppColors.secondary
                                  : AppColors.secondaryDark)
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            (isDark
                                    ? AppColors.secondary
                                    : AppColors.secondaryDark)
                                .withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: streak >= 7
                          ? [
                              BoxShadow(
                                color:
                                    (isDark
                                            ? AppColors.secondary
                                            : AppColors.secondaryDark)
                                        .withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '$streak',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.secondary
                                : AppColors.secondaryDark,
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
    );
  }
}
