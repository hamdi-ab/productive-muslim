import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/features/onboarding/presentation/widgets/onboarding_step_model.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class OnboardingStepHeader extends StatelessWidget {
  final OnboardingStep step;
  final bool isDark;
  final AppLocalizations l10n;

  const OnboardingStepHeader({
    super.key,
    required this.step,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = step.getSubtitle(l10n);
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(step.icon, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 32),
        Text(
          step.getTitle(l10n),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 36),
      ],
    );
  }
}
