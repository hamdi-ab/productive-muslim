import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/features/prayer_times/presentation/widgets/prayer_times_list_view.dart';
import 'package:productive_muslim/features/prayer_times/presentation/widgets/qibla_compass_view.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Capsule segmented switcher hosting "Prayer Times" and "Qibla Direction" tabs.
class PrayerTimesTabs extends StatelessWidget {
  final dynamic prayerTimes;
  final String nextPrayer;
  final String? locationName;

  const PrayerTimesTabs({
    super.key,
    required this.prayerTimes,
    required this.nextPrayer,
    this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Frosted Capsule Segmented Switcher (Stitch design specification)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F1A16)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isDark
                      ? AppColors.secondary.withValues(alpha: 0.25)
                      : AppColors.borderLight,
                  width: 0.8,
                ),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF0F4C3A), Color(0xFF13221C)]
                        : const [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? AppColors.secondary.withValues(alpha: 0.4)
                        : AppColors.primary.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.secondary : AppColors.primary)
                          .withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: isDark ? AppColors.secondary : Colors.white,
                unselectedLabelColor: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wb_twilight_rounded, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.qiblaTabTimes,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.explore_rounded, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.qiblaTabCompass,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                PrayerTimesListView(
                  prayerTimes: prayerTimes,
                  nextPrayer: nextPrayer,
                  locationName: locationName,
                ),
                QiblaCompassView(
                  latitude: prayerTimes.coordinates.latitude as double,
                  longitude: prayerTimes.coordinates.longitude as double,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
