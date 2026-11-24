import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Contextual Sunnah Fasting & Hijri calendar entry card embedded inside the
/// Prayer Times view, providing natural discovery of the Fasting pillar tool.
class PrayerFastingEntryCard extends StatelessWidget {
  const PrayerFastingEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final hijriService = getIt.isRegistered<HijriService>()
        ? getIt<HijriService>()
        : null;
    final now = DateTime.now();
    final hijri = hijriService?.getHijriDate(now);

    final isFastingDay = hijri?.isSunnahFastingDay ?? false;
    final String statusText;
    if (isFastingDay && hijri != null) {
      final badge = hijri.isWhiteDay
          ? (isAr ? 'الأيام البيض' : 'White Day')
          : (hijri.isArafah
                ? (isAr ? 'يوم عرفة' : 'Arafah')
                : (hijri.isAshura
                      ? (isAr ? 'يوم عاشوراء' : 'Ashura')
                      : (isAr ? 'صيام سنة' : 'Sunnah Fast')));
      statusText = isAr
          ? '🌙 اليوم صيام سنة ($badge)'
          : '🌙 Today: Sunnah Fast ($badge)';
    } else {
      statusText = isAr
          ? 'الأيام البيض، الإثنين والخميس، وعدّاد الإفطار'
          : 'White Days, Mon/Thu & Iftar countdown';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: AppPressable(
        key: const Key('prayer_fasting_entry_card'),
        onTap: () {
          AppHaptics.lightImpact();
          context.push(AppRoutes.fasting);
        },
        pressedScale: 0.98,
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(
                    alpha: isDark ? 0.2 : 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  color: AppColors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAr
                          ? 'الصيام والتقويم الهجري'
                          : (l10n.fastingTitle.isNotEmpty
                                ? l10n.fastingTitle
                                : 'Sunnah Fasting & Hijri'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.35 : 0.12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isAr ? 'عرض' : 'View',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF4EDEA3)
                                : const Color(0xFF0F4C3A),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: isDark
                              ? const Color(0xFF4EDEA3)
                              : const Color(0xFF0F4C3A),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
