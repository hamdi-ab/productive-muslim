import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/features/habits/logic/habit_bloc.dart';
import 'package:productive_muslim/features/habits/logic/habit_event.dart';
import 'package:productive_muslim/features/habits/logic/habit_state.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  String _name = '';
  String _category = 'islam';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => HabitBloc(context.read<HabitRepository>())
        ..add(const HabitLoaded()),
      child: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.habits),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddHabitDialog(context),
                ),
              ],
            ),
            body: state is Loaded
                ? state.habits.isEmpty
                    ? Center(child: Text(l10n.emptyHabits))
                    : _buildHabitList(state.habits)
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

  Widget _buildHabitList(List<Habit> habits) {
    final grouped = <String, List<Habit>>{};
    for (final habit in habits) {
      grouped.putIfAbsent(habit.category, () => []).add(habit);
    }

    return ListView(
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                entry.key,
                style: Theme.of(context).typography.titleSmall,
              ),
            ),
            ...entry.value.map((habit) => _HabitTile(habit: habit)),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).newHabit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: BoxDecoration(
                labelText: AppLocalizations.of(context).name,
              ),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).lifeArea),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: Text(AppLocalizations.of(context).islam),
                  selected: _category == 'islam',
                  onSelected: (selected) => setState(() => _category = 'islam'),
                ),
                FilterChip(
                  label: Text(AppLocalizations.of(context).family),
                  selected: _category == 'family',
                  onSelected: (selected) => setState(() => _category = 'family'),
                ),
                FilterChip(
                  label: Text(AppLocalizations.of(context).work),
                  selected: _category == 'work',
                  onSelected: (selected) => setState(() => _category = 'work'),
                ),
                FilterChip(
                  label: Text(AppLocalizations.of(context).personalDev),
                  selected: _category == 'personal_dev',
                  onSelected: (selected) => setState(() => _category = 'personal_dev'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              final bloc = context.read<HabitBloc>();
              bloc.add(HabitCreated(Habit(
                id: 0,
                name: nameController.text,
                category: _category,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              )));
              Navigator.pop(dialogContext);
            },
            child: Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final Habit habit;

  const _HabitTile({required this.habit});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        icon: const Icon(Icons.check_circle_outline),
        onPressed: () => context.read<HabitBloc>().add(HabitToggled(habit.id)),
      ),
      title: Text(habit.name),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => context.read<HabitBloc>().add(HabitDeleted(habit.id)),
      ),
    );
  }
}