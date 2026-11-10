import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class OnboardingNameInput extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations l10n;
  final bool isDark;

  const OnboardingNameInput({
    super.key,
    required this.controller,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderRadius: 20,
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: l10n.enterYourName,
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
                : AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          icon: const Icon(
            Icons.edit_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
