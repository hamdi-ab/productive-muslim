import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_bloc.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_event.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// State view rendered when location access is denied or disabled.
/// Provides platform-aware instructions and actions to enable permissions or retry.
class PrayerLocationRequiredView extends StatelessWidget {
  final AppLocalizations l10n;

  const PrayerLocationRequiredView({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.08),
                border: Border.all(
                  color: isDark
                      ? const Color(0x3310B981)
                      : AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.location_off_outlined,
                size: 40,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.onboardingPermissionDeniedBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (kIsWeb)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? 'ملاحظة للمتصفح: اضغط على أيقونة القفل أو الإعدادات في شريط العنوان للسماح بالموقع.'
                      : 'Web Tip: Click the padlock or settings icon in your browser address bar to allow location.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    AppHaptics.selectionClick();
                    if (!kIsWeb) {
                      Geolocator.openAppSettings();
                    } else {
                      final isAr =
                          Localizations.localeOf(context).languageCode == 'ar';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAr
                                ? 'يرجى السماح بالوصول للموقع عبر أيقونة القفل أو الإعدادات في شريط عنوان المتصفح ثم الضغط على إعادة المحاولة.'
                                : 'Please allow location in your browser site settings (address bar icon) and click Retry.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  label: Text(l10n.onboardingPermissionOpenSettings),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    AppHaptics.mediumImpact();
                    context.read<PrayerTimesBloc>().add(
                      const PrayerTimesLoaded(),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.onboardingPermissionRetry),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
