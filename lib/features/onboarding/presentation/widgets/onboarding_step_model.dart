import 'package:flutter/material.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class OnboardingStep {
  final String titleKey;
  final String? subtitleKey;
  final IconData icon;
  final bool hasInput;
  final bool hasChips;
  final bool hasQualities;
  final bool hasPermission;

  const OnboardingStep({
    required this.titleKey,
    this.subtitleKey,
    required this.icon,
    this.hasInput = false,
    this.hasChips = false,
    this.hasQualities = false,
    this.hasPermission = false,
  });

  String getTitle(AppLocalizations l10n) {
    switch (titleKey) {
      case 'onboardingWelcomeTitle':
        return l10n.onboardingWelcomeTitle;
      case 'onboardingNameTitle':
        return l10n.onboardingNameTitle;
      case 'onboardingIntentionTitle':
        return l10n.onboardingIntentionTitle;
      case 'onboardingQualitiesTitle':
        return l10n.onboardingQualitiesTitle;
      case 'onboardingPermissionTitle':
        return l10n.onboardingPermissionTitle;
      default:
        return titleKey;
    }
  }

  String? getSubtitle(AppLocalizations l10n) {
    if (subtitleKey == null) return null;
    switch (subtitleKey) {
      case 'onboardingWelcomeSubtitle':
        return l10n.onboardingWelcomeSubtitle;
      case 'onboardingNameSubtitle':
        return l10n.onboardingNameSubtitle;
      case 'onboardingIntentionSubtitle':
        return l10n.onboardingIntentionSubtitle;
      case 'onboardingQualitiesSubtitle':
        return l10n.onboardingQualitiesSubtitle;
      case 'onboardingPermissionSubtitle':
        return l10n.onboardingPermissionSubtitle;
      default:
        return subtitleKey;
    }
  }
}
