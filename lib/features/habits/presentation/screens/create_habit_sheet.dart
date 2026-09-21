import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/constants/app_life_areas.dart';
import 'package:productive_muslim/features/habits/logic/habit_bloc.dart';
import 'package:productive_muslim/features/habits/logic/habit_event.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class CreateHabitSheet extends StatefulWidget {
  const CreateHabitSheet({super.key});

  @override
  State<CreateHabitSheet> createState() => _CreateHabitSheetState();
}

class _CreateHabitSheetState extends State<CreateHabitSheet> {
  final _nameController = TextEditingController();
  String _category = 'islam';
  bool _canSave = false;

  static const _categories = [
    ('islam', AppLifeArea.islam),
    ('family', AppLifeArea.family),
    ('work', AppLifeArea.work),
    ('personal_dev', AppLifeArea.personalDev),
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() => _canSave = _nameController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    context.read<HabitBloc>().add(
      HabitCreated(
        Habit(
          id: 0,
          name: name,
          category: _category,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.newHabit, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.habitAddName,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (_canSave) _save();
            },
          ),
          const SizedBox(height: 16),
          Text(
            l10n.habitAddCategory,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((entry) {
              final (key, color) = entry;
              final categoryLabels = {
                'islam': l10n.islam,
                'family': l10n.family,
                'work': l10n.work,
                'personal_dev': l10n.personalDev,
              };
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(categoryLabels[key] ?? key),
                  ],
                ),
                selected: _category == key,
                onSelected: (_) => setState(() => _category = key),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _canSave ? _save : null,
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
