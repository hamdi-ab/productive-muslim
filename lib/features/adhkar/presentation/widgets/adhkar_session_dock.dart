import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class AdhkarSessionDock extends StatelessWidget {
  final List<DhikrItem> items;
  final Map<String, int> counts;
  final int currentPageIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final AppLocalizations l10n;
  final bool isDark;

  const AdhkarSessionDock({
    super.key,
    required this.items,
    required this.counts,
    required this.currentPageIndex,
    required this.onPrevious,
    required this.onNext,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final completedCount = items
        .where((item) => (counts[item.id] ?? 0) >= item.targetCount)
        .length;
    final progressPercent = items.isNotEmpty
        ? (completedCount / items.length).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.md, 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0D1714).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fact_check_rounded,
                      size: 14,
                      color: isDark
                          ? AppColors.secondary
                          : AppColors.secondaryDark,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Session Progress',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$completedCount of ${items.length} completed (${(progressPercent * 100).round()}%)',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.secondary
                        : AppColors.secondaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 4,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(
                progressPercent == 1.0
                    ? const Color(0xFF10B981)
                    : AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(l10n.adhkarPrev),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(items.length, (index) {
                    final isCurrent = currentPageIndex == index;
                    final isItemDone =
                        (counts[items[index].id] ?? 0) >=
                        items[index].targetCount;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isCurrent ? 14 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: isCurrent
                            ? AppColors.secondary
                            : (isItemDone
                                  ? const Color(0xFF10B981)
                                        .withValues(alpha: 0.6)
                                  : (isDark ? Colors.white24 : Colors.black12)),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onNext,
                  label: Text(l10n.adhkarNext),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
