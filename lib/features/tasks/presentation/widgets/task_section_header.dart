import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';

class TaskSectionHeader extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? badge;

  const TaskSectionHeader({
    super.key,
    required this.label,
    this.icon,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF141E1A)
                        : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE9C349).withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE9C349),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (icon != null) ...[
                  Icon(icon, size: 14, color: const Color(0xFFE9C349)),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? const Color(0xFFE9C349)
                          : AppColors.secondaryDark,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF18221E)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF404944).withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFBFC9C3)
                          : AppColors.textSecondary,
                    ),
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
