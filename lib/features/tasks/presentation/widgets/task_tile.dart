import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/constants/app_life_areas.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/features/tasks/logic/task_bloc.dart';
import 'package:productive_muslim/features/tasks/logic/task_event.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool isCurrentFocus;

  const TaskTile({super.key, required this.task, this.isCurrentFocus = false});

  static const _lifeAreaColors = AppLifeArea.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _lifeAreaColors[task.lifeArea] ?? AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final timeLabel = task.startMinutes != null && task.endMinutes != null
        ? '${_formatMinutes(task.startMinutes!)} – ${_formatMinutes(task.endMinutes!)}'
        : null;

    final areaLabel = _areaLabel(l10n, task.lifeArea);
    final showFocusHighlight = isCurrentFocus && !task.completed && isDark;

    return Dismissible(
      key: ValueKey(task.id),
      direction: task.completed
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F4C3A), Color(0xFF10B981)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_rounded, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                l10n.taskSwipeComplete,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        context.read<TaskBloc>().add(TaskToggled(task.id));
        AppHaptics.lightImpact();
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: showFocusHighlight
                ? const LinearGradient(
                    colors: [
                      Color(0xFF0F4C3A),
                      Color(0xFF18221E),
                      Color(0xFF222C29),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: showFocusHighlight
                ? null
                : task.completed
                ? (isDark
                      ? const Color(0xFF0D251C).withValues(alpha: 0.6)
                      : const Color(0xFFF0FDF4).withValues(alpha: 0.8))
                : (isDark ? const Color(0xFF141E1A) : Colors.white),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: showFocusHighlight
                  ? const Color(0xFFE9C349).withValues(alpha: 0.7)
                  : task.completed
                  ? const Color(0xFF4EDEA3).withValues(alpha: 0.2)
                  : (isDark
                        ? const Color(0xFF404944).withValues(alpha: 0.5)
                        : AppColors.secondary.withValues(alpha: 0.15)),
              width: showFocusHighlight ? 1.5 : 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: showFocusHighlight
                    ? const Color(0xFFE9C349).withValues(alpha: 0.15)
                    : (isDark ? const Color(0xFF0F4C3A) : Colors.black)
                          .withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: showFocusHighlight ? 18 : 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showFocusHighlight) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9C349).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE9C349),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flare_rounded,
                            size: 11,
                            color: Color(0xFFE9C349),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Current Focus',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE9C349),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: Color(0xFF4EDEA3),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          style:
                              (Theme.of(context).textTheme.bodyLarge ??
                                      const TextStyle())
                                  .copyWith(
                                    decoration: task.completed
                                        ? TextDecoration.lineThrough
                                        : null,
                                    fontWeight: FontWeight.w600,
                                    color: task.completed
                                        ? (isDark
                                              ? const Color(0xFF8A938D)
                                              : AppColors.textDisabled)
                                        : (isDark
                                              ? const Color(0xFFDAE5E0)
                                              : AppColors.textPrimary),
                                  ),
                          child: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.25),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                areaLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                            if (timeLabel != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 12,
                                    color: Color(0xFF8A938D),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: isDark
                                              ? const Color(0xFFBFC9C3)
                                              : AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppPressable(
                    onTap: () => context.push('/focus', extra: task),
                    haptic: AppHapticFeedback.selection,
                    child: IconButton(
                      tooltip: 'Focus on task',
                      icon: const Icon(
                        Icons.timer_outlined,
                        size: 20,
                        color: Color(0xFF4EDEA3),
                      ),
                      onPressed: () => context.push('/focus', extra: task),
                    ),
                  ),
                  AppPressable(
                    onTap: () {
                      context.read<TaskBloc>().add(TaskToggled(task.id));
                    },
                    pressedScale: 0.85,
                    haptic: AppHapticFeedback.light,
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          task.completed
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          key: ValueKey(
                            'task_icon_${task.id}_${task.completed}',
                          ),
                          color: task.completed
                              ? const Color(0xFF4EDEA3)
                              : (isDark
                                    ? const Color(0xFF8A938D)
                                    : AppColors.textSecondary),
                          size: 24,
                        ),
                      ),
                      onPressed: () {
                        context.read<TaskBloc>().add(TaskToggled(task.id));
                      },
                    ),
                  ),
                ],
              ),
              if (showFocusHighlight) ...[
                const SizedBox(height: 10),
                AppPressable(
                  onTap: () => context.push('/focus', extra: task),
                  pressedScale: 0.97,
                  haptic: AppHapticFeedback.medium,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9C349),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE9C349).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          size: 16,
                          color: Color(0xFF241A00),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Start Focus Timer',
                          style: TextStyle(
                            color: Color(0xFF241A00),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _formatMinutes(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  static String _areaLabel(AppLocalizations l10n, String area) {
    return switch (area) {
      'spiritual' => l10n.sphereSpiritual,
      'physical' => l10n.spherePhysical,
      'social' => l10n.sphereSocial,
      'islam' => l10n.islam,
      'family' => l10n.family,
      'work' => l10n.work,
      'personal_dev' => l10n.personalDev,
      _ => area,
    };
  }
}
