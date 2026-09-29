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

/// Visual progress breakdown of Spiritual, Mental, and Physical energy
class EnergyTriadBreakdownCard extends StatelessWidget {
  const EnergyTriadBreakdownCard({super.key, required this.analytics});

  final BarakahWeeklyAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              const Icon(
                Icons.bolt_rounded,
                size: 18,
                color: Color(0xFFF59E0B),
              ),
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
          const SizedBox(height: AppSpacing.md),
          _EnergyBar(
            title: l10n.barakahAnalyticsSpiritual,
            value: analytics.avgSpiritual,
            color: const Color(0xFF10B981),
            icon: Icons.mosque_rounded,
          ),
          const SizedBox(height: AppSpacing.sm),
          _EnergyBar(
            title: l10n.barakahAnalyticsMental,
            value: analytics.avgMental,
            color: const Color(0xFF6366F1),
            icon: Icons.psychology_rounded,
          ),
          const SizedBox(height: AppSpacing.sm),
          _EnergyBar(
            title: l10n.barakahAnalyticsPhysical,
            value: analytics.avgPhysical,
            color: const Color(0xFFF59E0B),
            icon: Icons.directions_run_rounded,
          ),
        ],
      ),
    );
  }
}

class _EnergyBar extends StatelessWidget {
  const _EnergyBar({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalized = (value / 5.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _locDigits(context, '${value.toStringAsFixed(1)} / 5.0'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: normalized,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
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
