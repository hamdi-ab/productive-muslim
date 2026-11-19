import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// 2x2 Lifetime Activity and Consistency Grid for the user's profile.
class ProfileLifetimeStatsGrid extends StatelessWidget {
  final int activeDays;
  final int lifetimeHabitCompletions;
  final int lifetimeTasksCompleted;
  final int totalFocusMinutes;
  final bool isDark;
  final bool isAr;

  const ProfileLifetimeStatsGrid({
    super.key,
    required this.activeDays,
    required this.lifetimeHabitCompletions,
    required this.lifetimeTasksCompleted,
    required this.totalFocusMinutes,
    required this.isDark,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final focusHours = (totalFocusMinutes / 60).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.lifetimeMomentum,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Row 1: Active Days & Habits
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: l10n.lifetimeActiveDays,
                value: '$activeDays ${isAr ? 'يوم' : 'days'}',
                subtitle: l10n.lifetimeActiveDaysDesc,
                icon: Icons.calendar_today_rounded,
                iconColor: const Color(0xFF059669),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: l10n.habitsCompleted,
                value: '$lifetimeHabitCompletions',
                subtitle: isAr ? 'سنة وعادة مباركة' : 'Sunnahs & habits built',
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF10B981),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2: Tasks & Focus Hours
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: l10n.tasksAccomplished,
                value: '$lifetimeTasksCompleted',
                subtitle: isAr ? 'أعمال صالحة منجزة' : 'Accomplished tasks',
                icon: Icons.task_alt_rounded,
                iconColor: const Color(0xFF0284C7),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: l10n.focusHours,
                value: '$focusHours ${isAr ? 'س' : 'hrs'}',
                subtitle: isAr
                    ? 'في طلب العلم والإتقان'
                    : 'Deep work & presence',
                icon: Icons.hourglass_top_rounded,
                iconColor: const Color(0xFF8B5CF6),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10221B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
