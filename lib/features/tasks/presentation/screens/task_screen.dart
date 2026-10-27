import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/tasks/logic/task_bloc.dart';
import 'package:productive_muslim/features/tasks/logic/task_event.dart';
import 'package:productive_muslim/features/tasks/logic/task_state.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/create_task_sheet.dart';
import 'package:productive_muslim/core/constants/app_life_areas.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class TaskScreen extends StatefulWidget {
  final String? date;

  const TaskScreen({super.key, this.date});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeDate =
        widget.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    final hasParentScaffold = Scaffold.maybeOf(context) != null;

    return BlocProvider(
      create: (context) =>
          TaskBloc(context.read<TaskRepository>())..add(TaskLoaded(activeDate)),
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          return Scaffold(
            appBar: hasParentScaffold ? null : AppBar(title: Text(l10n.tasks)),
            floatingActionButton: AppPressable(
              onTap: () => _showCreateSheet(context, activeDate),
              pressedScale: 0.90,
              haptic: AppHapticFeedback.light,
              child: FloatingActionButton(
                onPressed: () => _showCreateSheet(context, activeDate),
                child: const Icon(Icons.add),
              ),
            ),
            body: state is Loaded
                ? state.tasks.isEmpty
                      ? _EmptyState(l10n: l10n)
                      : _TaskList(tasks: state.tasks)
                : state is Loading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : state is Error
                ? _ErrorState(message: state.message)
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context, String today) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: CreateTaskSheet(date: today),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.25 : 0.08,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 42,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.emptyTasks,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Plan your daily intentions around prayer times for maximum Barakah.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
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
            onPressed: () =>
                context.read<TaskBloc>().add(TaskLoaded(_todayStr())),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final overdue = <Task>[];
    final scheduled = <Task>[];

    for (final task in tasks) {
      if (task.completed) continue;
      if (task.startMinutes == null) {
        overdue.add(task);
      } else {
        scheduled.add(task);
      }
    }

    // Sort scheduled by start time
    scheduled.sort((a, b) => a.startMinutes! - b.startMinutes!);

    final completed = tasks.where((t) => t.completed).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        if (overdue.isNotEmpty) ...[
          _SectionHeader(label: AppLocalizations.of(context)!.taskNoTime),
          ...overdue.map((task) => _TaskTile(task: task)),
        ],
        if (scheduled.isNotEmpty) ...[
          _SectionHeader(label: AppLocalizations.of(context)!.taskScheduled),
          const _SunnahNudgeCard(),
          ...scheduled.map((task) => _TaskTile(task: task)),
        ],
        if (completed.isNotEmpty) ...[
          _SectionHeader(label: AppLocalizations.of(context)!.done),
          ...completed.map((task) => _TaskTile(task: task)),
        ],
      ],
    );
  }
}

class _SunnahNudgeCard extends StatelessWidget {
  const _SunnahNudgeCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.75)
            : const Color(0xFFFEF9C3).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F4C3A) : Colors.black).withValues(
              alpha: isDark ? 0.25 : 0.04,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Renew Wudhu before Adhan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Spiritual Nudge • Sunnah of Readiness',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 16,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isDark ? AppColors.secondary : AppColors.secondaryDark,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  const _TaskTile({required this.task});

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
            Text(
              l10n.taskSwipeComplete,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
            color: task.completed
                ? (isDark
                      ? const Color(0xFF0D251C).withValues(alpha: 0.6)
                      : const Color(0xFFF0FDF4).withValues(alpha: 0.8))
                : (isDark ? AppColors.darkSurface : Colors.white),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: task.completed
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : (isDark
                        ? AppColors.secondary.withValues(alpha: 0.22)
                        : AppColors.secondary.withValues(alpha: 0.15)),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF0F4C3A) : Colors.black)
                    .withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
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
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textDisabled)
                                    : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary),
                              ),
                      child: Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
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
                        if (timeLabel != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeLabel,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
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
                    color: AppColors.primary,
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
                      key: ValueKey('task_icon_${task.id}_${task.completed}'),
                      color: task.completed
                          ? AppColors.success
                          : (isDark
                                ? AppColors.darkTextSecondary
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
