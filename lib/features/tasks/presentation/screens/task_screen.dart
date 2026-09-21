import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/constants/app_radius.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/tasks/logic/task_bloc.dart';
import 'package:productive_muslim/features/tasks/logic/task_event.dart';
import 'package:productive_muslim/features/tasks/logic/task_state.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/create_task_sheet.dart';
import 'package:productive_muslim/core/constants/app_life_areas.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return BlocProvider(
      create: (context) =>
          TaskBloc(context.read<TaskRepository>())..add(TaskLoaded(today)),
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.tasks)),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCreateSheet(context, today),
              child: const Icon(Icons.add),
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
      builder: (_) => CreateTaskSheet(date: today),
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
            Icons.task_alt,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.emptyTasks,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: AppColors.textSecondary),
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
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (overdue.isNotEmpty) ...[
          _SectionHeader(label: AppLocalizations.of(context)!.taskNoTime),
          ...overdue.map((task) => _TaskTile(task: task)),
        ],
        if (scheduled.isNotEmpty) ...[
          _SectionHeader(label: AppLocalizations.of(context)!.taskScheduled),
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

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2),
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
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Text(l10n.taskSwipeComplete, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        context.read<TaskBloc>().add(TaskToggled(task.id));
        HapticFeedback.lightImpact();
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.completed ? AppColors.textDisabled : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Text(
                            areaLabel,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: color),
                          ),
                          if (timeLabel != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              timeLabel,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    task.completed
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: task.completed ? AppColors.success : null,
                  ),
                  onPressed: () {
                    context.read<TaskBloc>().add(TaskToggled(task.id));
                    HapticFeedback.lightImpact();
                  },
                ),
              ],
            ),
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
      'islam' => l10n.islam,
      'family' => l10n.family,
      'work' => l10n.work,
      'personal_dev' => l10n.personalDev,
      _ => area,
    };
  }
}
