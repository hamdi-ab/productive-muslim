import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/features/tasks/logic/task_bloc.dart';
import 'package:productive_muslim/features/tasks/logic/task_event.dart';
import 'package:productive_muslim/features/tasks/logic/task_state.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String _lifeArea = 'islam';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return BlocProvider(
      create: (context) => TaskBloc(context.read<TaskRepository>())
        ..add(TaskLoaded(today)),
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.tasks),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddTaskDialog(context, today),
                ),
              ],
            ),
            body: state is Loaded
                ? state.tasks.isEmpty
                    ? Center(child: Text(l10n.emptyTasks))
                    : ListView.builder(
                        itemCount: state.tasks.length,
                        itemBuilder: (context, index) {
                          final task = state.tasks[index];
                          return _TaskTile(task: task);
                        },
                      )
                : state is Loading
                    ? const Center(child: CircularProgressIndicator())
                    : state is Error
                        ? Center(child: Text(state.message))
                        : const Center(child: SizedBox.shrink()),
          );
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, String today) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.newTask),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.lifeArea),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: Text(AppLocalizations.of(context)!.islam),
                  selected: _lifeArea == 'islam',
                  onSelected: (selected) => setState(() => _lifeArea = 'islam'),
                ),
                FilterChip(
                  label: Text(AppLocalizations.of(context)!.family),
                  selected: _lifeArea == 'family',
                  onSelected: (selected) => setState(() => _lifeArea = 'family'),
                ),
                FilterChip(
                  label: Text(AppLocalizations.of(context)!.work),
                  selected: _lifeArea == 'work',
                  onSelected: (selected) => setState(() => _lifeArea = 'work'),
                ),
                FilterChip(
                  label: Text(AppLocalizations.of(context)!.personalDev),
                  selected: _lifeArea == 'personal_dev',
                  onSelected: (selected) => setState(() => _lifeArea = 'personal_dev'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              final bloc = context.read<TaskBloc>();
              bloc.add(TaskCreated(Task(
                id: 0,
                title: titleController.text,
                lifeArea: _lifeArea,
                date: today,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              )));
              Navigator.pop(dialogContext);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;

  const _TaskTile({required this.task});

  static const _successColor = Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    final time = task.startMinutes != null && task.endMinutes != null
        ? '${_formatMinutes(task.startMinutes!)} – ${_formatMinutes(task.endMinutes!)}'
        : null;

    return ListTile(
      leading: IconButton(
        icon: Icon(
          task.completed ? Icons.check_circle : Icons.check_circle_outline,
          color: task.completed ? _successColor : null,
        ),
        onPressed: () => context.read<TaskBloc>().add(TaskToggled(task.id)),
      ),
      title: Text(task.title),
      subtitle: time != null ? Text(time) : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => context.read<TaskBloc>().add(TaskDeleted(task.id)),
      ),
    );
  }

  static String _formatMinutes(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}