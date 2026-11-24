import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/prayer_times/models/prayer_calculation_options.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Astrological & Location Header for Prayer Times screen.
/// Displays Bismillah pill, auto-synced live dot badge, location coordinates pill,
/// and calculation method badge with responsive overflow resilience.
class PrayerLocationHeader extends StatelessWidget {
  final dynamic prayerTimes;
  final String? locationName;

  const PrayerLocationHeader({
    super.key,
    required this.prayerTimes,
    this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final hasLocation = locationName != null && locationName!.isNotEmpty;
    final lat = (prayerTimes.coordinates.latitude as double).toStringAsFixed(2);
    final lng = (prayerTimes.coordinates.longitude as double).toStringAsFixed(
      2,
    );
    final maxPillWidth = MediaQuery.sizeOf(context).width - 64;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 13,
                        color: AppColors.secondary.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      l10n.prayerTimes,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F261E)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isAr ? 'متزامن تلقائياً' : 'Auto-Synced',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Location Pill & Calculation Method Row (Overflow-proof with Wrap)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (hasLocation)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxPillWidth),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141E1A)
                          : AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            locationName!,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($lat°, $lng°)',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxPillWidth),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const Key('prayer_calculation_method_badge'),
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      context.push(AppRoutes.settings);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF141E1A)
                            : AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                          width: 0.8,
                        ),
                      ),
                      child: Builder(
                        builder: (context) {
                          final settings = getIt.isRegistered<SettingsService>()
                              ? getIt<SettingsService>()
                              : null;
                          final CalculationMethod method;
                          final Madhab madhab;
                          if (prayerTimes is PrayerTimes) {
                            method = prayerTimes.calculationParameters.method;
                            madhab =
                                prayerTimes.calculationParameters.madhab ??
                                Madhab.shafi;
                          } else {
                            method =
                                settings?.prayerCalculationMethod ??
                                CalculationMethod.muslimWorldLeague;
                            madhab = settings?.prayerMadhab ?? Madhab.shafi;
                          }

                          final shortName =
                              PrayerCalculationOptions.getMethodShortName(
                                method,
                                isArabic: isAr,
                              );
                          final badgeLabel = madhab == Madhab.hanafi
                              ? (isAr
                                    ? '$shortName • حنفي'
                                    : '$shortName • Hanafi')
                              : shortName;

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  badgeLabel,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.tune_rounded,
                                size: 11,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
