import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_bloc.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_event.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Error state view displaying an error banner and a retry button.
class PrayerErrorView extends StatelessWidget {
  final String message;

  const PrayerErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                AppHaptics.mediumImpact();
                context.read<PrayerTimesBloc>().add(const PrayerTimesLoaded());
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.retry),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
