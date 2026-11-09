import 'package:flutter/material.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Card allowing selection and display of a linked task dedicated to this focus session.
class FocusTaskCard extends StatelessWidget {
  final Stream<List<Task>>? tasksStream;
  final Task? selectedTask;
  final int selectedDurationMinutes;
  final bool isRunning;
  final ValueChanged<Task?> onTaskSelected;
  final VoidCallback onClearTask;

  const FocusTaskCard({
    super.key,
    required this.tasksStream,
    required this.selectedTask,
    required this.selectedDurationMinutes,
    required this.isRunning,
    required this.onTaskSelected,
    required this.onClearTask,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<Task>>(
      key: const ValueKey('focus_task_stream_builder'),
      stream: tasksStream,
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        if (tasks.isEmpty && selectedTask == null) {
          return const SizedBox.shrink();
        }

        Task? matchedTask;
        if (selectedTask != null) {
          for (final task in tasks) {
            if (task.id == selectedTask?.id) {
              matchedTask = task;
              break;
            }
          }
          matchedTask ??= selectedTask;
        }

        if (matchedTask != null) {
          return GlassContainer(
            padding: const EdgeInsets.all(14),
            borderRadius: 18,
            borderColor: isDark
                ? AppColors.secondary.withValues(alpha: 0.25)
                : AppColors.primary.withValues(alpha: 0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.task_alt_rounded,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'LINKED SACRED TASK',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.6,
                                color: isDark
                                    ? AppColors.secondaryLight
                                    : AppColors.secondaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isRunning)
                      GestureDetector(
                        onTap: onClearTask,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceSubtle
                        : AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark.withValues(alpha: 0.6)
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        matchedTask.completed
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: matchedTask.completed
                            ? const Color(0xFF10B981)
                            : AppColors.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              matchedTask.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                                decoration: matchedTask.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(
                                      alpha: 0.14,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    matchedTask.lifeArea.isNotEmpty
                                        ? matchedTask.lifeArea
                                        : 'Focus Target',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withValues(
                                      alpha: 0.14,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${selectedDurationMinutes}m Target',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          borderColor: isDark
              ? AppColors.borderDark.withValues(alpha: 0.4)
              : AppColors.borderLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.task_alt_rounded,
                    size: 18,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.focusSelectTask,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Task?>(
                initialValue: null,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceSubtle
                      : AppColors.surfaceSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  const DropdownMenuItem<Task?>(
                    value: null,
                    child: Text(
                      'No task selected (General Focus)',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  ...tasks.map(
                    (t) => DropdownMenuItem<Task?>(
                      value: t,
                      child: Row(
                        children: [
                          Icon(
                            t.completed
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: t.completed
                                ? AppColors.primaryLight
                                : AppColors.textDisabled,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                decoration: t.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: isRunning ? null : onTaskSelected,
              ),
            ],
          ),
        );
      },
    );
  }
}
