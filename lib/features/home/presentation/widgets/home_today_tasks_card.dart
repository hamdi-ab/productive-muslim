import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class HomeTodayTasksCard extends StatelessWidget {
  final String today;
  final AppLocalizations l10n;

  const HomeTodayTasksCard({
    super.key,
    required this.today,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return StreamBuilder<List<Task>>(
      stream: context.read<TaskRepository>().watchTasksForDate(today),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        if (tasks.isEmpty) return const SizedBox.shrink();

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
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: TextButton(
                      onPressed: () => context.push('/plan'),
                      child: Text(
                        isAr ? 'عرض الكل' : 'View All',
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
            const SizedBox(height: 8),
            ...tasks.take(3).map((task) => TaskItemTile(task: task)),
          ],
        );
      },
    );
  }
}

class TaskItemTile extends StatelessWidget {
  final Task task;

  const TaskItemTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.completed,
            onChanged: (val) {
              context.read<TaskRepository>().toggleTask(task.id);
            },
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: task.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: task.completed
                    ? (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary)
                    : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
