import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Card showing that the active timer configuration safely concludes before the
/// next prayer call without overlapping Salah.
class FocusSalahAlignmentCard extends StatelessWidget {
  final bool isRunning;
  final Duration? timeUntilNextPrayer;
  final bool isPrayerCollision;
  final String nextPrayerName;
  final int selectedDurationMinutes;

  const FocusSalahAlignmentCard({
    super.key,
    required this.isRunning,
    required this.timeUntilNextPrayer,
    required this.isPrayerCollision,
    required this.nextPrayerName,
    required this.selectedDurationMinutes,
  });

  String _getLocalizedPrayerName(String prayerName, AppLocalizations l10n) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return l10n.fajr;
      case 'sunrise':
        return l10n.sunrise;
      case 'dhuhr':
        return l10n.dhuhr;
      case 'asr':
        return l10n.asr;
      case 'maghrib':
        return l10n.maghrib;
      case 'isha':
        return l10n.isha;
      default:
        return prayerName;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isRunning || timeUntilNextPrayer == null || isPrayerCollision) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safetyMargin =
        timeUntilNextPrayer!.inMinutes - selectedDurationMinutes;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.md),
        GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          borderColor: AppColors.primaryLight.withValues(alpha: 0.25),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  size: 18,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Next: ${_getLocalizedPrayerName(nextPrayerName, l10n)} in ${timeUntilNextPrayer!.inMinutes}m',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Salah Safe Alignment',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Session finishes safely ${safetyMargin}m before prayer call.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.lock_clock_rounded,
                size: 18,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
