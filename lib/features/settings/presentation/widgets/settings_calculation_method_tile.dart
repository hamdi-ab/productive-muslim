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

/// Settings tile that displays the active prayer calculation convention
/// and opens a bottom sheet to select from available presets.
class SettingsCalculationMethodTile extends StatelessWidget {
  const SettingsCalculationMethodTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final settings = getIt.isRegistered<SettingsService>()
        ? getIt<SettingsService>()
        : null;

    return ValueListenableBuilder<CalculationMethod>(
      valueListenable:
          settings?.calculationMethodNotifier ??
          ValueNotifier(CalculationMethod.muslimWorldLeague),
      builder: (context, currentMethod, _) {
        final displayTitle = PrayerCalculationOptions.getMethodTitle(
          currentMethod,
          isArabic: isArabic,
        );

        return ListTile(
          key: const Key('settings_calculation_method_tile'),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            l10n.prayerCalculationMethod,
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
          onTap: () => _showMethodSelectionSheet(context, currentMethod),
        );
      },
    );
  }

  void _showMethodSelectionSheet(
    BuildContext context,
    CalculationMethod activeMethod,
  ) {
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(modalContext).height * 0.8,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
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
                                l10n.prayerCalculationMethod,
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
                                l10n.prayerCalculationMethodDesc,
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
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount:
                          PrayerCalculationOptions.availableMethods.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final method =
                            PrayerCalculationOptions.availableMethods[index];
                        final isSelected = method == activeMethod;
                        final title = PrayerCalculationOptions.getMethodTitle(
                          method,
                          isArabic: isArabic,
                        );

                        return ListTile(
                          key: Key('calc_method_${method.name}'),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                            overflow: TextOverflow.ellipsis,
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
                              await settings.setPrayerCalculationMethod(method);
                            }
                            if (getIt.isRegistered<PrayerTimeService>()) {
                              await getIt<PrayerTimeService>()
                                  .onPrayerCalculationSettingsChanged();
                            }
                            if (modalContext.mounted) {
                              Navigator.pop(modalContext);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
