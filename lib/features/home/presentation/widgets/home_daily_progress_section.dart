import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/animated_progress_ring.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class HomeDailyProgressSection extends StatelessWidget {
  final String today;
  final AppLocalizations l10n;

  const HomeDailyProgressSection({
    super.key,
    required this.today,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Row(
      children: [
        Expanded(
          child: StreamBuilder<List<Task>>(
            stream: context.read<TaskRepository>().watchTasksForDate(today),
            builder: (context, snapshot) {
              final tasks = snapshot.data ?? [];
              final completed = tasks.where((t) => t.completed).length;
              final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;

              return GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 24,
                child: Column(
                  children: [
                    AnimatedProgressRing(
                      progress: progress,
                      size: 56,
                      strokeWidth: 6,
                      color: AppColors.primary,
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.tasks,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed / ${tasks.length} done',
                      style: TextStyle(fontSize: 12, color: secondaryText),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: StreamBuilder<List<Habit>>(
            stream: context.read<HabitRepository>().watchActiveHabits(),
            builder: (context, habitSnapshot) {
              final habits = habitSnapshot.data ?? [];
              final total = habits.length;

              Stream<Map<int, bool>>? completionsStream;
              try {
                completionsStream = context
                    .read<HabitRepository>()
                    .watchCompletionsForDate(today);
              } catch (_) {}

              return StreamBuilder<Map<int, bool>>(
                stream: completionsStream,
                builder: (context, completionSnapshot) {
                  final completions = completionSnapshot.data ?? const {};
                  final completedCount = habits
                      .where((h) => completions[h.id] == true)
                      .length;
                  final progress = total == 0
                      ? 0.0
                      : (completedCount / total).clamp(0.0, 1.0);

                  return GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 24,
                    child: Column(
                      children: [
                        AnimatedProgressRing(
                          progress: progress,
                          size: 56,
                          strokeWidth: 6,
                          color: AppColors.secondary,
                          child: const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.secondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.habits,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          total == 0
                              ? '$total active habits'
                              : '$completedCount / $total done',
                          style: TextStyle(fontSize: 12, color: secondaryText),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
