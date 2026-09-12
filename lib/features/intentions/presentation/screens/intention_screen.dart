import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/app_typography_extension.dart';
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return BlocProvider(
      create: (context) => IntentionBloc(context.read<IntentionRepository>())
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
                    ? const Center(child: CircularProgressIndicator())
                    : state is IntentionError
                        ? Center(child: Text(state.message))
                        : const Center(child: SizedBox.shrink()),
          );
        },
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context, String today, List<IntentionEntry> entries) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todayIntentions,
              style: context.appTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (entries.isEmpty)
              Text(
                l10n.noIntentionsToday,
                style: context.appTypography.bodyMedium,
              )
            else
              ...entries.map((entry) => _buildIntentionTile(context, entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildIntentionTile(BuildContext context, IntentionEntry entry) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          entry.completed ? Icons.check_circle : Icons.check_circle_outline,
          color: entry.completed ? AppColors.success : null,
        ),
        onPressed: () => context
            .read<IntentionBloc>()
            .add(IntentionToggled(entry)),
      ),
      title: Text(entry.title),
      subtitle: entry.statement != null ? Text(entry.statement!) : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: () => context
            .read<IntentionBloc>()
            .add(IntentionDeleted(entry.id)),
      ),
    );
  }

  Widget _buildReflectionCard(BuildContext context, List<IntentionEntry> entries) {
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
              style: context.appTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${completed.length} / $total ${l10n.completed}',
              style: context.appTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(value: ratio),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _reflectionController,
              decoration: const InputDecoration(),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: completed.isEmpty
                  ? null
                  : () {
                      final bloc = context.read<IntentionBloc>();
                      for (final entry in completed) {
                        bloc.add(IntentionReflectionSaved(
                          entry.id,
                          _reflectionController.text,
                        ));
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
              decoration: const InputDecoration(),
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
                context.read<IntentionBloc>().add(IntentionCreated(IntentionEntry(
                      id: 0,
                      date: today,
                      title: _titleController.text.trim(),
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                    )));
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
