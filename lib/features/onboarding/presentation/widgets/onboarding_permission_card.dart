import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

enum OnboardingPermissionState {
  initial,
  requesting,
  granted,
  denied,
  deniedForever,
  serviceOff,
}

class OnboardingPermissionCard extends StatelessWidget {
  final OnboardingPermissionState state;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSettings;
  final AppLocalizations l10n;
  final bool isDark;

  const OnboardingPermissionCard({
    super.key,
    required this.state,
    required this.onRequestPermission,
    required this.onOpenSettings,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              state == OnboardingPermissionState.granted
                  ? Icons.check_circle_rounded
                  : Icons.location_on_rounded,
              size: 40,
              color: state == OnboardingPermissionState.granted
                  ? (isDark ? AppColors.secondary : AppColors.primary)
                  : AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state == OnboardingPermissionState.granted
                ? l10n.onboardingPermissionGranted
                : l10n.onboardingPermissionBody,
            style: const TextStyle(fontSize: 14, height: 1.45),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (state == OnboardingPermissionState.requesting)
            const CircularProgressIndicator()
          else if (state == OnboardingPermissionState.granted)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: isDark ? AppColors.secondary : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.onboardingPermissionGranted,
                    style: TextStyle(
                      color: isDark ? AppColors.secondary : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else if (state == OnboardingPermissionState.deniedForever ||
              state == OnboardingPermissionState.serviceOff)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: Text(l10n.onboardingPermissionOpenSettings),
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onRequestPermission,
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: Text(l10n.onboardingPermissionGrant),
            ),
        ],
      ),
    );
  }
}
