import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';

class OnboardingStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final bool isDark;

  const OnboardingStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        key: const Key('step_progress_indicator'),
        children: List.generate(totalSteps, (i) {
          final isActive = i <= currentStep;
          final isCurrent = i == currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isCurrent ? 6 : 4,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.darkSurfaceSubtle
                          : AppColors.surfaceSubtle),
                borderRadius: BorderRadius.circular(3),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}
