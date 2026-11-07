import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_bloc.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_event.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_state.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class BarakahDailyPromptCard extends StatefulWidget {
  final BarakahDailyDraft draft;

  const BarakahDailyPromptCard({super.key, required this.draft});

  @override
  State<BarakahDailyPromptCard> createState() => _BarakahDailyPromptCardState();
}

class _BarakahDailyPromptCardState extends State<BarakahDailyPromptCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.draft.note);
  }

  @override
  void didUpdateWidget(covariant BarakahDailyPromptCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.draft.note) {
      _controller.value = TextEditingValue(
        text: widget.draft.note,
        selection: TextSelection.collapsed(offset: widget.draft.note.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = widget.draft;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: Key('daily-prompt-${draft.prompt.id}'),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.35)
              : AppColors.secondary.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F4C3A) : Colors.black).withValues(
              alpha: isDark ? 0.3 : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        size: 17,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.barakahDailyTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: const Text(
                  'Niyyah',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.barakahDailyQuestion(draft.prompt.id),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          if (draft.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            )
          else if (draft.failure && draft.answer == null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.barakahDailyFailure),
            ),
            TextButton(
              onPressed: () => context.read<BarakahBloc>().add(
                BarakahDailyResponseLoaded(draft.date),
              ),
              child: Text(l10n.barakahDailyRetry),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: BarakahAnswer.values.map((answer) {
                final label = switch (answer) {
                  BarakahAnswer.yes => l10n.barakahDailyYes,
                  BarakahAnswer.somewhat => l10n.barakahDailySomewhat,
                  BarakahAnswer.no => l10n.barakahDailyNo,
                  BarakahAnswer.skip => l10n.barakahDailySkip,
                };
                return ChoiceChip(
                  key: Key('daily-answer-${answer.name}'),
                  label: Text(label),
                  selected: draft.answer == answer,
                  selectedColor: AppColors.primary.withValues(alpha: 0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: draft.saving
                      ? null
                      : (_) {
                          AppHaptics.selectionClick();
                          context.read<BarakahBloc>().add(
                            BarakahAnswerSelected(answer),
                          );
                        },
                );
              }).toList(),
            ),
            if (draft.allowsSources) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.barakahDailySources,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: draft.prompt.sourceIds
                    .map(
                      (sourceId) => FilterChip(
                        key: Key('daily-source-$sourceId'),
                        label: Text(l10n.barakahDailySource(sourceId)),
                        selected: draft.sourceIds.contains(sourceId),
                        selectedColor: AppColors.primary.withValues(
                          alpha: 0.22,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: draft.saving
                            ? null
                            : (_) {
                                AppHaptics.selectionClick();
                                context.read<BarakahBloc>().add(
                                  BarakahSourceToggled(sourceId),
                                );
                              },
                      ),
                    )
                    .toList(),
              ),
            ],
            if (draft.answer != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                key: const Key('daily-note'),
                controller: _controller,
                enabled: !draft.saving,
                decoration: InputDecoration(
                  labelText: l10n.barakahDailyNote,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                maxLength: 280,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                maxLines: 2,
                onChanged: (note) =>
                    context.read<BarakahBloc>().add(BarakahNoteChanged(note)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_rounded,
                            size: 13,
                            color: Color(0xFF4EDEA3),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              Localizations.localeOf(context).languageCode ==
                                      'ar'
                                  ? 'نية خالصة لوجه الله (الإخلاص)'
                                  : 'Intention Sanctified (Ikhlas)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4EDEA3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_controller.text.length}/280',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            AppPressable(
              onTap: draft.saving || draft.answer == null
                  ? null
                  : () {
                      context.read<BarakahBloc>().add(
                        const BarakahDailyResponseSaved(),
                      );
                    },
              pressedScale: 0.94,
              haptic: AppHapticFeedback.medium,
              child: FilledButton.icon(
                key: const Key('daily-save'),
                onPressed: draft.saving || draft.answer == null
                    ? null
                    : () {
                        context.read<BarakahBloc>().add(
                          const BarakahDailyResponseSaved(),
                        );
                      },
                icon: const Icon(Icons.verified_rounded, size: 16),
                label: Text(
                  draft.saving
                      ? l10n.barakahDailySaving
                      : draft.response == null
                      ? l10n.barakahDailySave
                      : l10n.barakahDailyUpdate,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (draft.saved)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.barakahDailySaved,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ),
            if (draft.failure)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.barakahDailyFailure,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
