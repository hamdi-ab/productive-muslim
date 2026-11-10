import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/tasks/logic/task_bloc.dart';
import 'package:productive_muslim/features/tasks/logic/task_event.dart';
import 'package:productive_muslim/features/tasks/logic/task_state.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/create_task_sheet.dart';
import 'package:productive_muslim/features/tasks/presentation/widgets/task_empty_state.dart';
import 'package:productive_muslim/features/tasks/presentation/widgets/task_error_state.dart';
import 'package:productive_muslim/features/tasks/presentation/widgets/task_list_view.dart';
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
            backgroundColor: hasParentScaffold ? Colors.transparent : null,
            appBar: hasParentScaffold ? null : AppBar(title: Text(l10n.tasks)),
            floatingActionButton: hasParentScaffold
                ? null
                : FloatingActionButton(
                    onPressed: () {
                      AppHaptics.lightImpact();
                      _showCreateSheet(context, activeDate);
                    },
                    child: const Icon(Icons.add),
                  ),
            body: state is Loaded
                ? state.tasks.isEmpty
                      ? TaskEmptyState(l10n: l10n)
                      : TaskListView(tasks: state.tasks)
                : state is Loading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : state is Error
                ? TaskErrorState(message: state.message)
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context, String today) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
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
