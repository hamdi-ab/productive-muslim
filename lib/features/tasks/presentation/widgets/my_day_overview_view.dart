import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/intentions/presentation/widgets/intention_create_dialog.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/plan_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Lightweight daily overview in My Day (Option C):
/// - Today's intention
/// - Priority tasks
/// - Habit check-ins
/// - Focus-session shortcut
class MyDayOverviewView extends StatelessWidget {
  final String formattedDate;
  final ValueChanged<PlanTab> onSwitchTab;
  final VoidCallback onShowCreateTask;
  final VoidCallback onShowCreateHabit;
  final bool isDark;

  const MyDayOverviewView({
    super.key,
    required this.formattedDate,
    required this.onSwitchTab,
    required this.onShowCreateTask,
    required this.onShowCreateHabit,
    required this.isDark,
  });

  T? _findRepo<T extends Object>(BuildContext context) {
    try {
      return context.read<T>();
    } catch (_) {
      if (getIt.isRegistered<T>()) {
        return getIt<T>();
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final taskRepo = _findRepo<TaskRepository>(context);
    final habitRepo = _findRepo<HabitRepository>(context);
    final intentionRepo = _findRepo<IntentionRepository>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Today's Intention Card
              _buildIntentionSection(context, intentionRepo, isAr),
              const SizedBox(height: AppSpacing.md),

              // 2. Priority Tasks Section
              _buildTasksSection(context, taskRepo, l10n, isAr),
              const SizedBox(height: AppSpacing.md),

              // 3. Habit Check-ins Section
              _buildHabitsSection(context, habitRepo, l10n, isAr),
              const SizedBox(height: AppSpacing.md),

              // 4. Focus Session Shortcut Card
              _buildFocusShortcutCard(context, l10n, isAr),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntentionSection(
    BuildContext context,
    IntentionRepository? repo,
    bool isAr,
  ) {
    if (repo == null) return const SizedBox.shrink();

    Stream<List<IntentionEntry>>? intentionStream;
    try {
      intentionStream = repo.watchEntriesForDate(formattedDate);
    } catch (_) {}
    if (intentionStream == null) return const SizedBox.shrink();

    return StreamBuilder<List<IntentionEntry>>(
      stream: intentionStream,
      builder: (context, snapshot) {
        final entries = snapshot.data ?? [];
        final hasIntention = entries.isNotEmpty;
        final intention = hasIntention ? entries.first : null;

        return GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F4C3A)
                                .withValues(alpha: isDark ? 0.35 : 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.spa_rounded,
                            size: 16,
                            color: Color(0xFF4EDEA3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isAr ? 'نية اليوم' : "Today's Intention",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: TextButton(
                        onPressed: () => showAddIntentionDialog(
                          context: context,
                          today: formattedDate,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          hasIntention
                              ? (isAr ? 'تعديل' : 'Edit')
                              : (isAr ? 'تحديد نية' : 'Set Intention'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFE9C349)
                                : const Color(0xFF0F4C3A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (hasIntention && intention != null) ...[
                Text(
                  intention.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                if (intention.statement != null &&
                    intention.statement!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    intention.statement!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ] else ...[
                Text(
                  isAr ? 'حدد نيتك لليوم واجعل أعمالك كلها لله' : 'Anchor your day in pure intention and meaningful purpose.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTasksSection(
    BuildContext context,
    TaskRepository? repo,
    AppLocalizations l10n,
    bool isAr,
  ) {
    if (repo == null) return const SizedBox.shrink();

    Stream<List<Task>>? taskStream;
    try {
      taskStream = repo.watchTasksForDate(formattedDate);
    } catch (_) {}
    if (taskStream == null) return const SizedBox.shrink();

    return StreamBuilder<List<Task>>(
      stream: taskStream,
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.tasks,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: TextButton(
                      onPressed: () => onSwitchTab(PlanTab.tasks),
                      child: Text(
                        isAr ? 'عرض الكل' : 'View all',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (tasks.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                isAr
                    ? 'تم إنجاز ${tasks.where((t) => t.completed).length} من أصل ${tasks.length} مهام'
                    : '${tasks.where((t) => t.completed).length} of ${tasks.length} tasks completed',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 6),
            if (tasks.isEmpty) ...[
              GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.md),
                borderRadius: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isAr
                            ? 'لا توجد مهام مجدولة لهذا اليوم'
                            : 'No tasks scheduled for today.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondary
                              : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            AppHaptics.lightImpact();
                            onShowCreateTask();
                          },
                          icon: const Icon(Icons.add, size: 14),
                          label: Text(l10n.newTask),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ...tasks
                  .take(3)
                  .map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        borderRadius: 14,
                        child: Row(
                          children: [
                            AppPressable(
                              onTap: () {
                                AppHaptics.lightImpact();
                                repo.toggleTask(task.id);
                              },
                              child: Icon(
                                task.completed
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: task.completed
                                    ? const Color(0xFF10B981)
                                    : (isDark
                                          ? Colors.white54
                                          : Colors.black38),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: task.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.completed
                                      ? (isDark
                                            ? Colors.white38
                                            : Colors.black38)
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHabitsSection(
    BuildContext context,
    HabitRepository? repo,
    AppLocalizations l10n,
    bool isAr,
  ) {
    if (repo == null) return const SizedBox.shrink();

    Stream<List<Habit>>? habitStream;
    try {
      habitStream = repo.watchActiveHabits();
    } catch (_) {}
    if (habitStream == null) return const SizedBox.shrink();

    Stream<Map<int, bool>>? completionStream;
    try {
      completionStream = repo.watchCompletionsForDate(formattedDate);
    } catch (_) {}
    completionStream ??= Stream.value(<int, bool>{});

    return StreamBuilder<List<Habit>>(
      stream: habitStream,
      builder: (context, habitSnapshot) {
        final habits = habitSnapshot.data ?? [];

        return StreamBuilder<Map<int, bool>>(
          stream: completionStream,
          builder: (context, completionSnapshot) {
            final completions = completionSnapshot.data ?? {};

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.habits,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: TextButton(
                          onPressed: () => onSwitchTab(PlanTab.habits),
                          child: Text(
                            isAr ? 'عرض الكل' : 'View all',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (habits.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    isAr
                        ? 'تم إنجاز ${completions.values.where((v) => v).length} من أصل ${habits.length} عادات'
                        : '${completions.values.where((v) => v).length} of ${habits.length} habits completed',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                if (habits.isEmpty) ...[
                  GlassContainer(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            isAr
                                ? 'لا توجد عادات مسجلة'
                                : 'No active habits yet.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSecondary
                                  : Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                AppHaptics.lightImpact();
                                onShowCreateHabit();
                              },
                              icon: const Icon(Icons.add, size: 14),
                              label: Text(l10n.newHabit),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ...habits.take(3).map((habit) {
                    final isDone = completions[habit.id] ?? false;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        borderRadius: 14,
                        child: Row(
                          children: [
                            AppPressable(
                              onTap: () {
                                AppHaptics.lightImpact();
                                repo.toggleCompletion(habit.id, formattedDate);
                              },
                              child: Icon(
                                isDone
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isDone
                                    ? const Color(0xFFF59E0B)
                                    : (isDark
                                          ? Colors.white54
                                          : Colors.black38),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                habit.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isDone
                                      ? (isDark
                                            ? Colors.white38
                                            : Colors.black38)
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFocusShortcutCard(
    BuildContext context,
    AppLocalizations l10n,
    bool isAr,
  ) {
    return AppPressable(
      onTap: () {
        AppHaptics.lightImpact();
        onSwitchTab(PlanTab.focus);
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: 20,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9C349)
                    .withValues(alpha: isDark ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.timer_rounded,
                color: Color(0xFFE9C349),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAr ? 'جلسة تركيز عميق' : 'Deep Focus Session',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAr
                        ? 'تخلص من المشتتات وأنجز أهم أعمالك باسم الله'
                        : 'Eliminate distractions and focus with Bismillah.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F4C3A)
                        .withValues(alpha: isDark ? 0.4 : 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isAr ? 'بدء' : 'Start',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF4EDEA3)
                              : const Color(0xFF0F4C3A),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 14,
                        color: isDark
                            ? const Color(0xFF4EDEA3)
                            : const Color(0xFF0F4C3A),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
