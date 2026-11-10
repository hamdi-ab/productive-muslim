import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/features/tasks/presentation/widgets/task_section_header.dart';
import 'package:productive_muslim/features/tasks/presentation/widgets/task_sunnah_nudge_card.dart';
import 'package:productive_muslim/features/tasks/presentation/widgets/task_tile.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class TaskListView extends StatelessWidget {
  final List<Task> tasks;

  const TaskListView({super.key, required this.tasks});

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
          TaskSectionHeader(
            label: AppLocalizations.of(context)!.taskNoTime,
            icon: Icons.schedule_rounded,
            badge: 'No Time',
          ),
          ...overdue.map((task) => TaskTile(task: task)),
        ],
        if (scheduled.isNotEmpty) ...[
          TaskSectionHeader(
            label: AppLocalizations.of(context)!.taskScheduled,
            icon: Icons.wb_sunny_rounded,
            badge: 'Upcoming',
          ),
          const TaskSunnahNudgeCard(),
          ...scheduled.map(
            (task) =>
                TaskTile(task: task, isCurrentFocus: task == scheduled.first),
          ),
        ],
        if (completed.isNotEmpty) ...[
          TaskSectionHeader(
            label: AppLocalizations.of(context)!.done,
            icon: Icons.done_all_rounded,
            badge: 'Completed',
          ),
          ...completed.map((task) => TaskTile(task: task)),
        ],
      ],
    );
  }
}
