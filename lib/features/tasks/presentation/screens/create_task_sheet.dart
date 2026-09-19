import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/constants/app_radius.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/features/tasks/logic/task_bloc.dart';
import 'package:productive_muslim/features/tasks/logic/task_event.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class CreateTaskSheet extends StatefulWidget {
  final String date;
  const CreateTaskSheet({super.key, required this.date});

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _lifeArea = 'islam';
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _repeatDaily = false;
  bool _repeatWeekly = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSave => _titleController.text.trim().isNotEmpty;

  int? _timeToMinutes(TimeOfDay? time) {
    if (time == null) return null;
    return time.hour * 60 + time.minute;
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTime ??= const TimeOfDay(hour: 9, minute: 0))
        : (_endTime ??= const TimeOfDay(hour: 10, minute: 0));

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          // Auto-set end time to start + 1 hour if not set
          _endTime ??= TimeOfDay(
            hour: (picked.hour + 1) % 24,
            minute: picked.minute,
          );
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _save() {
    if (!_canSave) return;

    final task = Task(
      id: 0,
      title: _titleController.text.trim(),
      lifeArea: _lifeArea,
      startMinutes: _timeToMinutes(_startTime),
      endMinutes: _timeToMinutes(_endTime),
      date: widget.date,
      repeatDaily: _repeatDaily,
      repeatWeekly: _repeatWeekly,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    context.read<TaskBloc>().add(TaskCreated(task));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + bottomPadding,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.newTask,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            TextField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.taskTitle,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Life area
            Text(l10n.lifeArea, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            _LifeAreaSelector(
              selected: _lifeArea,
              onChanged: (area) => setState(() => _lifeArea = area),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Time block
            Text(
              AppLocalizations.of(context)!.taskScheduled,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _TimeButton(
                    label: l10n.taskStartTime,
                    time: _startTime,
                    onTap: () => _pickTime(isStart: true),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TimeButton(
                    label: l10n.taskEndTime,
                    time: _endTime,
                    onTap: () => _pickTime(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Repeat
            Text(
              l10n.taskRepeat,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                FilterChip(
                  label: Text(l10n.taskRepeatDaily),
                  selected: _repeatDaily,
                  onSelected: (selected) =>
                      setState(() => _repeatDaily = selected),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilterChip(
                  label: Text(l10n.taskRepeatWeekly),
                  selected: _repeatWeekly,
                  onSelected: (selected) =>
                      setState(() => _repeatWeekly = selected),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Notes
            TextField(
              controller: _notesController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.taskNotes,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Save
            FilledButton(
              onPressed: _canSave ? _save : null,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _LifeAreaSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _LifeAreaSelector({required this.selected, required this.onChanged});

  static const _areas = [
    ('islam', AppColors.primary),
    ('family', Color(0xFFE67E22)),
    ('work', Color(0xFF3498DB)),
    ('personal_dev', Color(0xFF9B59B6)),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = {
      'islam': l10n.islam,
      'family': l10n.family,
      'work': l10n.work,
      'personal_dev': l10n.personalDev,
    };

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _areas.map((area) {
        final isSelected = selected == area.$1;
        return FilterChip(
          avatar: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: area.$2, shape: BoxShape.circle),
          ),
          label: Text(labels[area.$1] ?? area.$1),
          selected: isSelected,
          onSelected: (_) => onChanged(area.$1),
        );
      }).toList(),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimeButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = time != null
        ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
        : label;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            size: 18,
            color: time != null ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            displayText,
            style: TextStyle(
              color: time != null ? null : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
