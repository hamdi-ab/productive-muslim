import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';

class OnboardingBackgroundDecorations extends StatelessWidget {
  final bool isDark;

  const OnboardingBackgroundDecorations({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.15 : 0.08,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(
                  alpha: isDark ? 0.12 : 0.06,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
