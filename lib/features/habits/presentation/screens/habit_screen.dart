import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/features/habits/logic/habit_bloc.dart';
import 'package:productive_muslim/features/habits/logic/habit_event.dart';
import 'package:productive_muslim/features/habits/logic/habit_state.dart';
import 'package:productive_muslim/features/habits/presentation/screens/create_habit_sheet.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class HabitScreen extends StatelessWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) =>
          HabitBloc(context.read<HabitRepository>())..add(const HabitLoaded()),
      child: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.habits)),
            body: state is Loaded
                ? state.habits.isEmpty
                      ? _EmptyState(l10n: l10n)
                      : _HabitList(state: state, l10n: l10n)
                : state is Loading
                ? const Center(child: CircularProgressIndicator())
                : state is Error
                ? Center(child: Text(state.message))
                : const Center(child: SizedBox.shrink()),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCreateSheet(context),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<HabitBloc>(),
        child: const CreateHabitSheet(),
      ),
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
            Icons.self_improvement,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyHabits,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _HabitList extends StatelessWidget {
  final Loaded state;
  final AppLocalizations l10n;
  const _HabitList({required this.state, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Habit>>{};
    for (final habit in state.habits) {
      grouped.putIfAbsent(habit.category, () => []).add(habit);
    }

    final categoryLabels = {
      'islam': l10n.islam,
      'family': l10n.family,
      'work': l10n.work,
      'personal_dev': l10n.personalDev,
    };

    final categoryColors = {
      'islam': const Color(0xFF2E7D4F),
      'family': const Color(0xFFE67E22),
      'work': const Color(0xFF3498DB),
      'personal_dev': const Color(0xFF9B59B6),
    };

    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        _WeekHeader(l10n: l10n),
        const Divider(height: 1),
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: categoryColors[entry.key],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  categoryLabels[entry.key] ?? entry.key,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          for (final habit in entry.value)
            _HabitTile(
              habit: habit,
              completed: state.completions[habit.id] ?? false,
              streak: state.streaks[habit.id] ?? 0,
            ),
        ],
      ],
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final AppLocalizations l10n;
  const _WeekHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = now.weekday;
    final startOfWeek = now.subtract(Duration(days: weekday - 1));

    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.habitToday,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(7, (i) {
              final day = startOfWeek.add(Duration(days: i));
              final isToday =
                  day.day == now.day &&
                  day.month == now.month &&
                  day.year == now.year;

              return Expanded(
                child: Column(
                  children: [
                    Text(
                      dayLabels[i],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isToday
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final Habit habit;
  final bool completed;
  final int streak;

  const _HabitTile({
    required this.habit,
    required this.completed,
    required this.streak,
  });

  static const _categoryColors = {
    'islam': Color(0xFF2E7D4F),
    'family': Color(0xFFE67E22),
    'work': Color(0xFF3498DB),
    'personal_dev': Color(0xFF9B59B6),
  };

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[habit.category] ?? Colors.grey;

    return Dismissible(
      key: ValueKey('habit_${habit.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      confirmDismiss: (_) async {
        final l10n = AppLocalizations.of(context)!;
        return showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.delete),
            content: Text(l10n.habitSwipeDelete),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<HabitBloc>().add(HabitDeleted(habit.id));
      },
      child: ListTile(
        leading: GestureDetector(
          key: Key('habit_checkbox_${habit.id}'),
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<HabitBloc>().add(HabitCompletionToggled(habit.id));
          },
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: completed ? color : null,
              shape: BoxShape.circle,
              border: Border.all(
                color: completed
                    ? color
                    : Theme.of(context).colorScheme.outline,
                width: 2,
              ),
            ),
            child: completed
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            decoration: completed ? TextDecoration.lineThrough : null,
            color: completed
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : null,
          ),
        ),
        trailing: streak > 0
            ? Text(
                '\u{1F525} $streak',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              )
            : null,
      ),
    );
  }
}
