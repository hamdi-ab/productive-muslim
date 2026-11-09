import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Lightweight Sunnah Fasting energy anchor card that replaces the
/// heavy duplicate countdown while providing instant toggle and deep link to `/fasting`.
class EnergyFastingCard extends StatefulWidget {
  const EnergyFastingCard({super.key});

  @override
  State<EnergyFastingCard> createState() => _EnergyFastingCardState();
}

class _EnergyFastingCardState extends State<EnergyFastingCard> {
  late final String _today;
  bool _isFasting = false;

  @override
  void initState() {
    super.initState();
    _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadStatus();
  }

  void _loadStatus() {
    try {
      if (getIt.isRegistered<SettingsService>()) {
        final settings = getIt<SettingsService>();
        setState(() {
          _isFasting = settings.isSunnahFastingTarget(_today);
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleFasting(bool value) async {
    AppHaptics.lightImpact();
    try {
      if (getIt.isRegistered<SettingsService>()) {
        final settings = getIt<SettingsService>();
        await settings.toggleSunnahFastingTarget(_today);
        setState(() => _isFasting = value);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFasting
                  ? AppLocalizations.of(context)!.fastingLoggedSuccess
                  : (Localizations.localeOf(context).languageCode == 'ar'
                        ? 'تم تحديث حالة الصيام'
                        : 'Fasting status updated'),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header Row
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.sunnahFasting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton.icon(
                  onPressed: () => context.push('/fasting'),
                  icon: const Icon(Icons.calendar_month_rounded, size: 16),
                  label: Text(
                    l10n.hijriCalendarTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Main Fasting Alignment Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141E1A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF404944).withValues(alpha: 0.5)
                  : AppColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fasting Status Row with Adaptive Switch
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9C349).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE9C349).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.nights_stay_rounded,
                      color: Color(0xFFE9C349),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'صيام سنة اليوم' : 'Fasting Sunnah Today',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAr
                              ? 'راحة للجهاز الهضمي وتجديد للطاقة الروحية'
                              : 'Digestive reset & cellular revitalization',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? const Color(0xFF8A938D)
                                : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch.adaptive(
                    value: _isFasting,
                    onChanged: _toggleFasting,
                    activeTrackColor: const Color(0xFF0F4C3A),
                    activeThumbColor: const Color(0xFF4EDEA3),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Sunnah Benefit Guidance Note
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF18221E)
                      : AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF404944).withValues(alpha: 0.3)
                        : AppColors.borderLight,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.spa_rounded,
                      color: Color(0xFF4EDEA3),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'الصيام يحرر طاقة الهضم لتعزيز التركيز الذهني والخشوع في العبادة.'
                            : 'Fasting frees digestive energy to sharpen mental clarity and prayer presence.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFFDAE5E0)
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 1-Tap Deep Link into Fasting Hub
              AppPressable(
                onTap: () {
                  AppHaptics.lightImpact();
                  context.push('/fasting');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0B1512)
                        : const Color(0xFFF7F9F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF404944).withValues(alpha: 0.4)
                          : AppColors.borderLight,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timelapse_rounded,
                        color: Color(0xFFE9C349),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isAr
                              ? 'عرض جدول الصيام الهجري وتفاصيل الإفطار'
                              : 'View Hijri Fasting Calendar & Iftar Details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isAr
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark
                            ? const Color(0xFF8A938D)
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
