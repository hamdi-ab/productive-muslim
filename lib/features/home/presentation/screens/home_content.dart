import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_typography_extension.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(l10n),
          const SizedBox(height: AppSpacing.lg),
          _buildTodaySummary(context, today, l10n),
        ],
      ),
    );
  }

  Widget _buildGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.goodMorning
        : hour < 17
        ? l10n.goodAfternoon
        : l10n.goodEvening;
    return Text(greeting, style: AppTypography.headlineMedium);
  }

  Widget _buildTodaySummary(
    BuildContext context,
    String today,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.today, style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            StreamBuilder<List<Task>>(
              stream: context.read<TaskRepository>().watchTasksForDate(today),
              builder: (context, snapshot) {
                final tasks = snapshot.data ?? [];
                final completed = tasks.where((t) => t.completed).length;
                return Text(
                  '$completed / ${tasks.length} ${l10n.tasks.toLowerCase()}',
                  style: AppTypography.bodyLarge,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
