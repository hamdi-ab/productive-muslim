import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/features/intentions/logic/intention_bloc.dart';
import 'package:productive_muslim/features/intentions/logic/intention_event.dart';
import 'package:productive_muslim/features/intentions/logic/intention_state.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class IntentionScreen extends StatefulWidget {
  const IntentionScreen({super.key});

  @override
  State<IntentionScreen> createState() => _IntentionScreenState();
}

class _IntentionScreenState extends State<IntentionScreen> {
  final _titleController = TextEditingController();
  final _reflectionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return BlocProvider(
      create: (context) =>
          IntentionBloc(context.read<IntentionRepository>())
            ..add(IntentionEntriesLoaded(today)),
      child: BlocBuilder<IntentionBloc, IntentionState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.journal)),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddDialog(context, today),
              child: const Icon(Icons.add),
            ),
            body: state is IntentionLoaded
                ? ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      _buildTodayCard(context, today, state.entries),
                      const SizedBox(height: AppSpacing.md),
                      _buildReflectionCard(context, state.entries),
                    ],
                  )
                : state is IntentionLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : state is IntentionError
                ? _ErrorState(message: state.message)
                : const Center(child: SizedBox.shrink()),
          );
        },
      ),
    );
  }

  Widget _buildTodayCard(
    BuildContext context,
    String today,
    List<IntentionEntry> entries,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todayIntentions,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (entries.isEmpty)
              Text(
                l10n.noIntentionsToday,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...entries.map((entry) => _buildIntentionTile(context, entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildIntentionTile(BuildContext context, IntentionEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: IconButton(
        icon: Icon(
          entry.completed ? Icons.check_circle : Icons.check_circle_outline,
          color: entry.completed ? AppColors.success : null,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          context.read<IntentionBloc>().add(IntentionToggled(entry));
        },
        tooltip: entry.completed ? l10n.habitUnmark : l10n.habitMarkComplete,
      ),
      title: Text(entry.title),
      subtitle: entry.statement != null ? Text(entry.statement!) : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.read<IntentionBloc>().add(IntentionDeleted(entry.id));
        },
        tooltip: l10n.delete,
      ),
    );
  }

  Widget _buildReflectionCard(
    BuildContext context,
    List<IntentionEntry> entries,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final completed = entries.where((e) => e.completed).toList();
    final total = entries.length;
    final ratio = total == 0 ? 0.0 : completed.length / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reflection,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${completed.length} / $total ${l10n.completed}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(value: ratio),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _reflectionController,
              decoration: const InputDecoration(hintText: 'Your reflection...'),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: completed.isEmpty
                  ? null
                  : () {
                      final bloc = context.read<IntentionBloc>();
                      for (final entry in completed) {
                        bloc.add(
                          IntentionReflectionSaved(
                            entry.id,
                            _reflectionController.text,
                          ),
                        );
                      }
                    },
              child: Text(l10n.saveReflection),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, String today) {
    _titleController.clear();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.newIntention),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Intention title'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              if (_titleController.text.trim().isNotEmpty) {
                context.read<IntentionBloc>().add(
                  IntentionCreated(
                    IntentionEntry(
                      id: 0,
                      date: today,
                      title: _titleController.text.trim(),
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                    ),
                  ),
                );
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
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
            onPressed: () => context.read<IntentionBloc>().add(
              IntentionEntriesLoaded(_todayStr()),
            ),
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
