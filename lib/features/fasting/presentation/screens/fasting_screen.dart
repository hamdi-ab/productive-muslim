import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/core/widgets/gradient_card.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/features/fasting/presentation/widgets/fasting_countdown_card.dart';
import 'package:productive_muslim/features/fasting/presentation/widgets/hijri_calendar_view.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class FastingScreen extends StatefulWidget {
  const FastingScreen({super.key});

  @override
  State<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends State<FastingScreen> {
  int _fastedDaysThisMonth = 0;

  @override
  void initState() {
    super.initState();
    _calculateFastingStats();
  }

  void _calculateFastingStats() {
    try {
      final settings = getIt<SettingsService>();
      final now = DateTime.now();
      int count = 0;
      for (int d = 1; d <= now.day; d++) {
        final dateStr = DateFormat('yyyy-MM-dd')
            .format(DateTime(now.year, now.month, d));
        if (settings.isSunnahFastingTarget(dateStr)) {
          count++;
        }
      }
      setState(() => _fastedDaysThisMonth = count);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final hijriService = getIt.isRegistered<HijriService>()
        ? getIt<HijriService>()
        : HijriService();
    final todayHijri = hijriService.getHijriDate(DateTime.now());

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hijri Date & Virtue Header Card
              GradientCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic
                                    ? todayHijri.formatAr()
                                    : todayHijri.formatEn(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat.yMMMMEEEEd(isArabic ? 'ar' : 'en')
                                    .format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFD4AF37)
                                      .withValues(alpha: 0.6),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_fire_department_rounded,
                                    color: Color(0xFFD4AF37),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.fastingStreak(_fastedDaysThisMonth),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.format_quote_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.fastingVirtueDesc,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 2. Fasting Tracker & Countdown Card
              FastingCountdownCard(onStatusChanged: _calculateFastingStats),

              const SizedBox(height: AppSpacing.lg),

              // 3. Hijri Monthly Calendar Grid
              HijriCalendarView(
                onDateSelected: (_) => _calculateFastingStats(),
                onTargetToggled: _calculateFastingStats,
              ),

              const SizedBox(height: AppSpacing.lg),

              // 4. Sunnah Fasting Guidelines & Etiquette
              Text(
                l10n.fastingGuidelinesTitle,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 20,
                child: Column(
                  children: [
                    _buildTipItem(
                      icon: Icons.nightlight_round,
                      title: l10n.suhoorSunnahTitle,
                      body: l10n.suhoorSunnahDesc,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem(
                      icon: Icons.water_drop_rounded,
                      title: l10n.hydrationTitle,
                      body: l10n.hydrationDesc,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem(
                      icon: Icons.access_time_filled_rounded,
                      title: l10n.breakPromptTitle,
                      body: l10n.breakPromptDesc,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 5. Sunnah Energy & Physical Anchors Cross-link
              AppPressable(
                key: const Key('fasting_energy_shortcut_card'),
                onTap: () {
                  AppHaptics.lightImpact();
                  context.push(AppRoutes.energy);
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
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic
                                  ? 'إدارة الطاقة والسنن البدنية'
                                  : 'Energy & Physical Anchors',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isArabic
                                  ? 'سنة القيلولة والنشاط البدني لدعم صيامك'
                                  : 'Qaylulah nap and physical anchors to support your fast.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );

    final formattedHijri = isArabic
        ? todayHijri.formatAr()
        : todayHijri.formatEn();

    return Scaffold(
      appBar: ProductiveAppBar(
        title: l10n.hijriCalendarTitle,
        subtitle: formattedHijri,
        showBackButton: true,
      ),
      body: content,
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String body,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.secondary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
