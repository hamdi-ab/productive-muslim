import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class TaskEmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const TaskEmptyState({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F4C3A).withValues(alpha: 0.25),
                border: Border.all(
                  color: const Color(0xFFE9C349).withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F4C3A)
                        .withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 42,
                color: Color(0xFFE9C349),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.emptyTasks,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFDAE5E0) : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Plan your daily intentions around prayer times for maximum Barakah.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFFBFC9C3)
                    : AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
