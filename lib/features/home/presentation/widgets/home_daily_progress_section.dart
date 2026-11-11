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

String _toArabicDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], arabic[i]);
  }
  return input;
}

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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
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
              final pct = (progress * 100).toInt();

              final progressLabel = isAr
                  ? '${_toArabicDigits('$pct')}٪'
                  : '$pct%';
              final taskSubtitle = isAr
                  ? (tasks.isEmpty
                        ? 'لا توجد مهام اليوم'
                        : 'تم إنجاز ${_toArabicDigits('$completed')} من ${_toArabicDigits('${tasks.length}')}')
                  : '$completed / ${tasks.length} done';

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
                        progressLabel,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      taskSubtitle,
                      style: TextStyle(fontSize: 12, color: secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

                  final habitSubtitle = isAr
                      ? (total == 0
                            ? 'لا توجد عادات نشطة'
                            : 'تم إنجاز ${_toArabicDigits('$completedCount')} من ${_toArabicDigits('$total')}')
                      : (total == 0
                            ? '$total active habits'
                            : '$completedCount / $total done');

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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          habitSubtitle,
                          style: TextStyle(fontSize: 12, color: secondaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
