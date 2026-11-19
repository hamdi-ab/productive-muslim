import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/services/barakah_score_service.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_bloc.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_event.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_state.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_review_screen.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_atmosphere_background.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_daily_prompt_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_entry_form_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_score_header_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_weekly_review_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class BarakahScreen extends StatefulWidget {
  final String? date;

  const BarakahScreen({super.key, this.date});

  @override
  State<BarakahScreen> createState() => _BarakahScreenState();
}

class _BarakahScreenState extends State<BarakahScreen> {
  @override
  Widget build(BuildContext context) {
    final today =
        widget.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

    return BlocProvider(
      key: ValueKey(today),
      create: (context) => BarakahBloc(context.read<BarakahRepository>())
        ..add(BarakahLoaded(today))
        ..add(BarakahDailyResponseLoaded(today)),
      child: Builder(
        builder: (context) {
          final hasParentScaffold = Scaffold.maybeOf(context) != null;
          return BlocBuilder<BarakahBloc, BarakahState>(
            builder: (context, state) {
              final l10n = AppLocalizations.of(context)!;
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final isAr = Localizations.localeOf(context).languageCode == 'ar';

              return Scaffold(
                appBar: hasParentScaffold
                    ? null
                    : ProductiveAppBar(
                        title: l10n.barakah,
                        showBackButton: true,
                        actions: [
                          ProductiveAppBarAction(
                            key: const Key('open-review'),
                            tooltip: l10n.barakahWeeklyTitle,
                            icon: Icons.calendar_month_outlined,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const BarakahReviewScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                body: Stack(
                  children: [
                    BarakahAtmosphereBackground(isDark: isDark),
                    state is Loaded
                        ? ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            children: [
                              // 1. Live Barakah Activity Overview & Humility Disclaimer
                              FutureBuilder<BarakahActivitySummary>(
                                future:
                                    getIt.isRegistered<BarakahScoreService>()
                                    ? getIt<BarakahScoreService>()
                                          .calculateLiveSummary(date: today)
                                    : null,
                                builder: (context, scoreSnapshot) {
                                  final summary = scoreSnapshot.data;
                                  return BarakahScoreHeaderCard(
                                    isDark: isDark,
                                    isAr: isAr,
                                    summary: summary,
                                  );
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // 2. Daily Niyyah Prompt Card
                              if (state.daily case final daily?) ...[
                                BarakahDailyPromptCard(draft: daily),
                                const SizedBox(height: AppSpacing.md),
                              ],

                              // 3. Daily Shukr & Barakah Sources Log Card
                              BarakahEntryFormCard(
                                today: today,
                                entries: state.entries,
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // 4. Weekly Reflection Review Launchpad Card
                              const BarakahWeeklyReviewCard(),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                          )
                        : state is Loading
                        ? const Center(child: CircularProgressIndicator())
                        : state is Error
                        ? Center(child: Text(state.message))
                        : const Center(child: SizedBox.shrink()),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
