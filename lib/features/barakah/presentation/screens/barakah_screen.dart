import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_bloc.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_event.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_state.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class BarakahScreen extends StatefulWidget {
  const BarakahScreen({super.key});

  @override
  State<BarakahScreen> createState() => _BarakahScreenState();
}

class _BarakahScreenState extends State<BarakahScreen> {
  final List<String> _selectedSources = [];
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return BlocProvider(
      create: (context) =>
          BarakahBloc(context.read<BarakahRepository>())
            ..add(BarakahLoaded(today)),
      child: BlocBuilder<BarakahBloc, BarakahState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n!.barakah)),
            body: state is Loaded
                ? ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      _buildPromptCard(context, today),
                      const SizedBox(height: 16),
                      _buildSourceChips(),
                      const SizedBox(height: 16),
                      _buildNoteInput(),
                      const SizedBox(height: 16),
                      _buildLogButton(context, today),
                      const SizedBox(height: 32),
                      _buildHistory(context, state.entries),
                    ],
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

  Widget _buildPromptCard(BuildContext context, String today) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const Icon(Icons.spa_outlined, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Verily, with hardship comes ease.',
              style: TextStyle(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              '— Surah Ash-Sharh 94:6',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Did you experience barakah in your time today?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _logEntry(context, today),
                    child: const Text('Yes'),
                  ),
                ),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<BarakahBloc>().add(BarakahSkipped(today));
                    },
                    child: const Text('Skip'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceChips() {
    final sources = [
      'Reading Quran',
      'Prayer on time',
      'Dhikr after salah',
      'Charity',
      'Family time',
      'Halal income',
      'Dua',
      'Knowledge',
      'Kindness',
      'Patience',
      'Gratitude',
      'Forgiveness',
      'Helping others',
      'Clean heart',
      'Early rising',
      'Healthy food',
      'Truthful speech',
      'Good example',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sources.map((source) {
        final selected = _selectedSources.contains(source);
        return FilterChip(
          label: Text(source),
          selected: selected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedSources.add(source);
              } else {
                _selectedSources.remove(source);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildNoteInput() {
    return TextField(
      controller: _noteController,
      decoration: const InputDecoration(
        labelText: 'Add a note (optional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildLogButton(BuildContext context, String today) {
    return FilledButton(
      onPressed: _selectedSources.isEmpty
          ? null
          : () => _logEntry(context, today),
      child: const Text('Log Barakah'),
    );
  }

  void _logEntry(BuildContext context, String today) {
    context.read<BarakahBloc>().add(
      BarakahLogged(
        BarakahEntry(
          id: 0,
          date: today,
          sourceIds: List<String>.unmodifiable(_selectedSources),
          note: _noteController.text.isEmpty ? null : _noteController.text,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
    setState(() {
      _selectedSources.clear();
      _noteController.clear();
    });
  }

  Widget _buildHistory(BuildContext context, List<BarakahEntry> entries) {
    if (entries.isEmpty) {
      return const Center(child: Text('No barakah entries yet'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Entries",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ...entries.map((entry) {
          return ListTile(
            leading: entry.skipped
                ? const Icon(Icons.remove_circle_outline)
                : const Icon(Icons.spa_outlined, color: AppColors.success),
            title: entry.skipped
                ? const Text('Skipped')
                : Text(entry.sourceIds.join(', ')),
            subtitle: entry.note != null ? Text(entry.note!) : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () {
                final bloc = context.read<BarakahBloc>();
                bloc.add(BarakahDeleted(entry.id));
              },
            ),
          );
        }),
      ],
    );
  }
}
