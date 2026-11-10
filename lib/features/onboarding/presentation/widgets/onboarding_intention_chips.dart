import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class OnboardingIntentionChips extends StatelessWidget {
  final String selectedIntention;
  final ValueChanged<String> onSelected;
  final AppLocalizations l10n;
  final bool isDark;

  const OnboardingIntentionChips({
    super.key,
    required this.selectedIntention,
    required this.onSelected,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final intentions = [
      ('barakah', l10n.seekingBarakah, Icons.auto_awesome_rounded),
      ('worship', l10n.consistentWorship, Icons.mosque_rounded),
      ('productivity', l10n.mindfulProductivity, Icons.bolt_rounded),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: intentions.map((item) {
        final selected = selectedIntention == item.$1;
        return InkWell(
          onTap: () => onSelected(selected ? '' : item.$1),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : (isDark
                        ? AppColors.darkSurfaceSubtle
                        : AppColors.surfaceSubtle),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.$3,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  item.$2,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
