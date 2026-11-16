import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
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
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_muhasabah_audit_card.dart';
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
                              // 1. Live Barakah Capacity & Score Badge
                              FutureBuilder<BarakahScores>(
                                future:
                                    getIt.isRegistered<BarakahScoreService>()
                                    ? getIt<BarakahScoreService>()
                                          .calculateLiveScores(date: today)
                                    : null,
                                builder: (context, scoreSnapshot) {
                                  final scores = scoreSnapshot.data;
                                  return BarakahScoreHeaderCard(
                                    isDark: isDark,
                                    isAr: isAr,
                                    scorePercent: scores?.scorePercent ?? 0.85,
                                    scorePoints: scores?.scorePoints ?? 85,
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

                              // 4. Dedicated 9-Qualities Radar & Profile Callout
                              _buildProfileRadarCallout(context, isDark, isAr),
                              const SizedBox(height: AppSpacing.md),

                              // 5. Spiritual Focus & Khushu' Audit Card
                              const BarakahMuhasabahAuditCard(),
                              const SizedBox(height: AppSpacing.md),

                              // 6. Weekly Muhasabah Review Launchpad Card
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

  Widget _buildProfileRadarCallout(
    BuildContext context,
    bool isDark,
    bool isAr,
  ) {
    return AppPressable(
      onTap: () {
        AppHaptics.lightImpact();
        final router = GoRouter.maybeOf(context);
        if (router != null) {
          context.go('/profile');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.primary.withValues(alpha: 0.15),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.darkSurface,
                  ]
                : [
                    AppColors.primary.withValues(alpha: 0.06),
                    AppColors.surface,
                  ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.radar_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr
                        ? 'مخطط الصفات التسع ومعدل الاستمرارية'
                        : '9-Qualities Radar & Momentum',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAr
                        ? 'انتقل إلى ملفك الشخصي لعرض توازن الصفات ومحاسبة الأداء'
                        : 'View qualities balance & consistency momentum in Profile',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isAr ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
