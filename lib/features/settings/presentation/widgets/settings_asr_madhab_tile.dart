import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/prayer_times/models/prayer_calculation_options.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Settings tile that displays the active Asr madhab shadow convention
/// and opens a selection sheet to switch between Standard and Hanafi.
class SettingsAsrMadhabTile extends StatelessWidget {
  const SettingsAsrMadhabTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final settings = getIt.isRegistered<SettingsService>()
        ? getIt<SettingsService>()
        : null;

    return ValueListenableBuilder<Madhab>(
      valueListenable: settings?.madhabNotifier ?? ValueNotifier(Madhab.shafi),
      builder: (context, currentMadhab, _) {
        final displayTitle = PrayerCalculationOptions.getMadhabTitle(
          currentMadhab,
          isArabic: isArabic,
        );

        return ListTile(
          key: const Key('settings_asr_madhab_tile'),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.hourglass_bottom_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            l10n.prayerMadhab,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            displayTitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
          onTap: () => _showMadhabSelectionSheet(context, currentMadhab),
        );
      },
    );
  }

  void _showMadhabSelectionSheet(BuildContext context, Madhab activeMadhab) {
    AppHaptics.selectionClick();
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final settings = getIt.isRegistered<SettingsService>()
        ? getIt<SettingsService>()
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Material(
          color: isDark ? AppColors.darkBackground : AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.hourglass_bottom_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.prayerMadhab,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.prayerMadhabDesc,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...PrayerCalculationOptions.availableMadhabs.map((madhab) {
                    final isSelected = madhab == activeMadhab;
                    final title = PrayerCalculationOptions.getMadhabTitle(
                      madhab,
                      isArabic: isArabic,
                    );
                    final desc = PrayerCalculationOptions.getMadhabDescription(
                      madhab,
                      isArabic: isArabic,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.06)),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          key: Key('madhab_${madhab.name}'),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            desc,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                )
                              : null,
                          onTap: () async {
                            AppHaptics.selectionClick();
                            if (settings != null) {
                              await settings.setPrayerMadhab(madhab);
                            }
                            if (getIt.isRegistered<PrayerTimeService>()) {
                              await getIt<PrayerTimeService>()
                                  .onPrayerCalculationSettingsChanged();
                            }
                            if (modalContext.mounted) {
                              Navigator.pop(modalContext);
                            }
                          },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
