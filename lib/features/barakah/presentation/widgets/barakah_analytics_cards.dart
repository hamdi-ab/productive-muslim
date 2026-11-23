import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/app_typography_extension.dart';
import 'package:productive_muslim/domain/models/barakah_analytics_summary.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

String _locDigits(BuildContext context, String value) {
  if (Localizations.localeOf(context).languageCode != 'ar') return value;
  return value.replaceAllMapped(
    RegExp('[0-9]'),
    (match) => String.fromCharCode(0x0660 + int.parse(match[0]!)),
  );
}

/// Visual 7-day matrix tracking daily prompt answers, dhikr and fasting
class BarakahConsistencyMatrixCard extends StatelessWidget {
  const BarakahConsistencyMatrixCard({super.key, required this.analytics});

  final BarakahWeeklyAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final weekdayLabelsEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final weekdayLabelsAr = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
    final labels = isAr ? weekdayLabelsAr : weekdayLabelsEn;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.grid_view_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        l10n.barakahAnalyticsConsistency,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.barakahAnalyticsActiveDays(analytics.activeDaysCount),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: List.generate(7, (index) {
              final snapshot = analytics.dailySnapshots[index];
              final label = labels[index];

              Color blockColor;
              IconData? blockIcon;

              if (snapshot.isFuture) {
                blockColor = isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.grey.shade100;
              } else if (snapshot.barakahAnswer == BarakahAnswer.yes) {
                blockColor = AppColors.primary.withValues(alpha: 0.85);
                blockIcon = Icons.check_rounded;
              } else if (snapshot.barakahAnswer == BarakahAnswer.somewhat) {
                blockColor = const Color(0xFFF59E0B).withValues(alpha: 0.85);
                blockIcon = Icons.remove_rounded;
              } else if (snapshot.hasActiveRecord) {
                blockColor = const Color(0xFF6366F1).withValues(alpha: 0.85);
                blockIcon = Icons.auto_awesome_rounded;
              } else {
                blockColor = isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300;
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: blockColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: blockIcon != null
                              ? Icon(blockIcon, size: 16, color: Colors.white)
                              : Text(
                                  _locDigits(context, '${snapshot.date.day}'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: snapshot.isFuture
                                        ? (isDark
                                              ? Colors.white24
                                              : Colors.black26)
                                        : (isDark
                                              ? Colors.white70
                                              : Colors.black87),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (snapshot.completedDhikrCount > 0)
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Personal wellbeing reflection on Inner Stillness, Mental Clarity, and Physical Rest
class EnergyTriadBreakdownCard extends StatelessWidget {
  const EnergyTriadBreakdownCard({super.key, required this.analytics});

  final BarakahWeeklyAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.spa_rounded, size: 18, color: Color(0xFF10B981)),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  l10n.barakahAnalyticsEnergyTriad,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isAr ? 'مراجعة ذاتية لحضورك الذهني والبدني، ليست مقياساً إيمانياً' : 'Self-reported reflection on daily presence and balance — not a spiritual measure.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _WellbeingTile(
            title: l10n.barakahAnalyticsSpiritual,
            desc: isAr
                ? 'حضور الذهن والخشوع في الروتين والذكر اليومي'
                : 'Mindful presence, sincere intention, and inner peace',
            color: const Color(0xFF10B981),
            icon: Icons.spa_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          _WellbeingTile(
            title: l10n.barakahAnalyticsMental,
            desc: isAr
                ? 'الوضوح المعرفي وإدارة الانتباه في الأعمال اليومية'
                : 'Cognitive focus, clarity, and intentional attention',
            color: const Color(0xFF6366F1),
            icon: Icons.psychology_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          _WellbeingTile(
            title: l10n.barakahAnalyticsPhysical,
            desc: isAr
                ? 'العناية بالبدن، النوم الكافي والتغذية السليمة'
                : 'Bodily energy, restorative rest, and healthy habits',
            color: const Color(0xFFF59E0B),
            icon: Icons.directions_run_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _WellbeingTile extends StatelessWidget {
  const _WellbeingTile({
    required this.title,
    required this.desc,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  final String title;
  final String desc;
  final Color color;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Coaching insights connecting spiritual habits to productive output
class BarakahCoachingInsightsCard extends StatelessWidget {
  const BarakahCoachingInsightsCard({super.key, required this.analytics});

  final BarakahWeeklyAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                size: 20,
                color: Color(0xFF10B981),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  l10n.barakahAnalyticsCoachingTitle,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF065F46),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final insight in analytics.insights)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF047857),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
