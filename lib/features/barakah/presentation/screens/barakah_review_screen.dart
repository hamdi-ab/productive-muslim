import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_typography_extension.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/barakah_analytics_summary.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_weekly_review.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_review_bloc.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_review_event.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_review_state.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_analytics_cards.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_heatmap_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class BarakahReviewScreen extends StatelessWidget {
  const BarakahReviewScreen({super.key, this.now});

  final DateTime Function()? now;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        BarakahReviewBloc(context.read<BarakahRepository>(), now: now)
          ..add(const BarakahReviewWeekSelected(0)),
    child: const _ReviewView(),
  );
}

class _ReviewView extends StatelessWidget {
  const _ReviewView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dates = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    return Scaffold(
      appBar: AppBar(title: Text(l10n.barakahWeeklyTitle)),
      body: SafeArea(
        child: BlocBuilder<BarakahReviewBloc, BarakahReviewState>(
          builder: (context, state) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('review-previous'),
                      tooltip: l10n.barakahWeeklyPrevious,
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.read<BarakahReviewBloc>().add(
                        const BarakahReviewWeekSelected(-1),
                      ),
                    ),
                    Expanded(
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          l10n.barakahWeeklyRange(
                            _localizedDigits(
                              context,
                              dates.format(state.week.start),
                            ),
                            _localizedDigits(
                              context,
                              dates.format(state.week.end),
                            ),
                          ),
                          key: const Key('review-range'),
                          textAlign: TextAlign.center,
                          style: AppTypography.labelLarge,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('review-next'),
                      tooltip: l10n.barakahWeeklyNext,
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: state.week.canGoNext
                          ? () => context.read<BarakahReviewBloc>().add(
                              const BarakahReviewWeekSelected(1),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: switch (state) {
                  BarakahReviewLoading() => const Align(
                    alignment: Alignment.topCenter,
                    child: LinearProgressIndicator(),
                  ),
                  BarakahReviewFailure() => SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        Text(l10n.barakahWeeklyFailure),
                        TextButton(
                          onPressed: () => context
                              .read<BarakahReviewBloc>()
                              .add(const BarakahReviewWeekSelected(0)),
                          child: Text(l10n.barakahDailyRetry),
                        ),
                      ],
                    ),
                  ),
                  BarakahReviewLoaded(:final review) => _ReviewContent(
                    key: ValueKey(state.week.startDate),
                    review: review,
                    week: state.week,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _localizedDigits(BuildContext context, String value) {
  if (Localizations.localeOf(context).languageCode != 'ar') return value;
  return value.replaceAllMapped(
    RegExp('[0-9]'),
    (match) => String.fromCharCode(0x0660 + int.parse(match[0]!)),
  );
}

String _answerLabel(AppLocalizations l10n, BarakahAnswer answer) =>
    switch (answer) {
      BarakahAnswer.yes => l10n.barakahDailyYes,
      BarakahAnswer.somewhat => l10n.barakahDailySomewhat,
      BarakahAnswer.no => l10n.barakahDailyNo,
      BarakahAnswer.skip => l10n.barakahWeeklySkipped,
    };

class _ReviewContent extends StatelessWidget {
  const _ReviewContent({super.key, required this.review, required this.week});

  final BarakahWeeklyReview review;
  final BarakahReviewWeek week;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sources = review.sourceCounts;

    final settings = getIt.isRegistered<SettingsService>()
        ? getIt<SettingsService>()
        : null;

    final analytics = BarakahWeeklyAnalytics.calculate(
      review: review,
      week: week,
      getEnergy: (date) =>
          settings?.getDailyEnergy(date) ??
          (physical: 3, spiritual: 3, mental: 3),
      getDhikr: (date) => settings?.getCompletedDhikrIds(date) ?? [],
      isFasting: (date) => settings?.isSunnahFastingTarget(date) ?? false,
      languageCode: Localizations.localeOf(context).languageCode,
    );

    return ListView(
      key: const Key('review-list'),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(l10n.barakahWeeklyDescription),
        const SizedBox(height: AppSpacing.lg),
        if (review.savedCount == 0) ...[
          Text(l10n.barakahWeeklyEmpty),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(l10n.barakahWeeklyAnswers, style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        for (final entry in review.answerCounts.entries)
          Text(
            l10n.barakahWeeklyCount(
              _answerLabel(l10n, entry.key),
              _localizedDigits(context, entry.value.toString()),
            ),
            key: Key('review-count-${entry.key.name}'),
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.barakahWeeklySources, style: AppTypography.labelLarge),
        Text(l10n.barakahWeeklySourcesDescription),
        const SizedBox(height: AppSpacing.sm),
        if (sources.isEmpty) Text(l10n.barakahWeeklyNoSources),
        for (final entry in sources.entries)
          Text(
            l10n.barakahWeeklyCount(
              l10n.barakahDailySource(entry.key),
              _localizedDigits(context, entry.value.toString()),
            ),
            key: Key('review-source-${entry.key}'),
          ),
        const SizedBox(height: AppSpacing.lg),
        BarakahConsistencyMatrixCard(analytics: analytics),
        const SizedBox(height: AppSpacing.md),
        Builder(
          builder: (context) {
            final cutoff = analytics.week.today.isBefore(analytics.week.end)
                ? analytics.week.today
                : analytics.week.end;
            final settingsService = getIt.isRegistered<SettingsService>()
                ? getIt<SettingsService>()
                : null;
            final activityMap = <String, int>{};
            if (settingsService != null) {
              for (var i = 0; i < 84; i++) {
                final d = DateTime(cutoff.year, cutoff.month, cutoff.day - i);
                final key = BarakahReviewWeek.dateKey(d);
                final dhikrCount = settingsService
                    .getCompletedDhikrIds(key)
                    .length;
                final isFasting = settingsService.isSunnahFastingTarget(key);
                final energy = settingsService.getDailyEnergy(key);
                // Only add the energy point when a real saved record exists.
                final energyPoint = energy.physical > 0 ? 1 : 0;
                final score = dhikrCount + (isFasting ? 3 : 0) + energyPoint;
                if (score > 0) {
                  activityMap[key] = score;
                }
              }
            }
            for (final d in analytics.dailySnapshots) {
              final key = BarakahReviewWeek.dateKey(d.date);
              // Dhikr and fasting are already counted via SettingsService above;
              // add only the daily-review bonus so we don't double-count.
              final reviewBonus = d.barakahAnswer != null ? 2 : 0;
              if (reviewBonus > 0) {
                activityMap[key] = (activityMap[key] ?? 0) + reviewBonus;
              }
            }
            return BarakahHeatmapCard(
              activityByDate: activityMap,
              referenceDate: cutoff,
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        EnergyTriadBreakdownCard(analytics: analytics),
        const SizedBox(height: AppSpacing.md),
        BarakahCoachingInsightsCard(analytics: analytics),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.barakahWeeklyDays, style: AppTypography.labelLarge),
        for (final day in review.days) _ReviewDay(day: day),
      ],
    );
  }
}

class _ReviewDay extends StatelessWidget {
  const _ReviewDay({required this.day});

  final BarakahReviewDay day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dates = DateFormat.yMMMMEEEEd(
      Localizations.localeOf(context).toString(),
    );
    final response = day.response;
    return Padding(
      key: Key('review-day-${BarakahReviewWeek.dateKey(day.date)}'),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Semantics(
            header: true,
            child: Text(
              _localizedDigits(context, dates.format(day.date)),
              style: AppTypography.labelLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (response == null)
            Text(
              day.future ? l10n.barakahWeeklyFuture : l10n.barakahWeeklyMissing,
            )
          else ...[
            Text(l10n.barakahDailyQuestion(response.promptId)),
            Text(_answerLabel(l10n, response.answer)),
            for (final source in day.selectedSources)
              Text(l10n.barakahDailySource(source)),
            if (response.note case final note? when note.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.barakahWeeklyNote, style: AppTypography.labelMedium),
              SelectableText(note),
            ],
          ],
        ],
      ),
    );
  }
}
