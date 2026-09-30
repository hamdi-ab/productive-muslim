import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/core/widgets/gradient_card.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
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
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      for (int d = 1; d <= daysInMonth; d++) {
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hijriCalendarTitle)),
      body: SingleChildScrollView(
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              l10n.fastingStreak(_fastedDaysThisMonth),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
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
                ),

                const SizedBox(height: AppSpacing.lg),

                // 4. Sunnah Fasting Guidelines & Etiquette
                Text(
                  'Sunnah Fasting Guidelines',
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
                        title: 'Do Not Skip Suhoor',
                        body: 'The Prophet (ﷺ) said: "Take Suhoor, for in Suhoor there is Barakah (blessing)." (Bukhari)',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(
                        icon: Icons.water_drop_rounded,
                        title: 'Optimal Hydration',
                        body: 'Drink ample water between Iftar and Suhoor to maintain high energy and mental focus during fasting hours.',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(
                        icon: Icons.access_time_filled_rounded,
                        title: 'Hasten to Break the Fast',
                        body: 'Break your fast promptly at Maghrib with dates and water, following the Sunnah for maximum reward.',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
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
