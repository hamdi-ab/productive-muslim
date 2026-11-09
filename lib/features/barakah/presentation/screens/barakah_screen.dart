import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/arabic_typography.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_bloc.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_event.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_state.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_review_screen.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_atmosphere_background.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_daily_prompt_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_entry_form_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_heatmap_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_muhasabah_audit_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_radar_chart_card.dart';
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
                              // Bismillah & Muhasabah Header Pill
                              _buildBismillahPill(isDark, isAr),

                              // 1. Live Barakah Capacity & Score Badge
                              BarakahScoreHeaderCard(
                                isDark: isDark,
                                isAr: isAr,
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
                              const SizedBox(height: AppSpacing.lg),

                              // 4. 9-Qualities Radar / Spider Chart Card
                              const BarakahRadarChartCard(),
                              const SizedBox(height: AppSpacing.md),

                              // 5. 12-Week Activity & Barakah Heatmap
                              _buildHeatmapSection(state.entries, today),
                              const SizedBox(height: AppSpacing.md),

                              // 6. Spiritual Focus & Khushu' Audit Card
                              const BarakahMuhasabahAuditCard(),
                              const SizedBox(height: AppSpacing.md),

                              // 7. Weekly Muhasabah Review Launchpad Card
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

  Widget _buildBismillahPill(bool isDark, bool isAr) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceSubtle
                : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppColors.secondary.withValues(alpha: 0.35)
                  : AppColors.borderLight,
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textDirection: TextDirection.rtl,
                style: ArabicFontFamily.amiri.getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.secondary : AppColors.secondaryDark,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isAr ? 'محاسبة النفس' : 'MUHASABAH & BARAKAH',
                style: TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeatmapSection(List<BarakahEntry> entries, String today) {
    final Map<String, int> activity = {};
    for (final e in entries) {
      activity[e.date] = (activity[e.date] ?? 0) + 1;
    }
    activity[today] = (activity[today] ?? 0) + 1;

    DateTime? refDate;
    try {
      refDate = DateTime.parse(today);
    } catch (_) {}

    return BarakahHeatmapCard(activityByDate: activity, referenceDate: refDate);
  }
}
