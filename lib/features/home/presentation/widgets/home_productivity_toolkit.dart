import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class HomeProductivityToolkit extends StatefulWidget {
  const HomeProductivityToolkit({super.key});

  @override
  State<HomeProductivityToolkit> createState() =>
      _HomeProductivityToolkitState();
}

class _HomeProductivityToolkitState extends State<HomeProductivityToolkit> {
  int _tasbihCount = 0;
  final int _tasbihTarget = 33;
  bool _isFasting = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (getIt.isRegistered<SettingsService>()) {
      _isFasting = getIt<SettingsService>().isSunnahFastingTarget(today);
    }
    if (getIt.isRegistered<AdhkarService>()) {
      final saved = getIt<AdhkarService>().getDhikrCount('subhanallah_33');
      _tasbihCount = saved > 0 ? saved : 0;
    }
  }

  void _incrementTasbih() {
    HapticFeedback.lightImpact();
    setState(() {
      _tasbihCount = (_tasbihCount % _tasbihTarget) + 1;
    });
    if (getIt.isRegistered<AdhkarService>()) {
      getIt<AdhkarService>().recordDhikrCount(
        dhikrId: 'subhanallah_33',
        count: _tasbihCount,
      );
    }
  }

  void _toggleFasting() {
    HapticFeedback.selectionClick();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      _isFasting = !_isFasting;
    });
    if (getIt.isRegistered<SettingsService>()) {
      getIt<SettingsService>().toggleSunnahFastingTarget(today);
    }
  }

  String _getFastingSubtitle(bool isAr) {
    if (getIt.isRegistered<HijriService>()) {
      final hijri = getIt<HijriService>();
      final now = DateTime.now();
      final todayStatus = hijri.getSunnahFastingStatus(now);
      if (todayStatus.isSunnah) {
        return isAr
            ? (todayStatus.reasonAr ?? 'صيام مسنون اليوم')
            : (todayStatus.reasonEn ?? 'Sunnah Fasting Today');
      }
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowStatus = hijri.getSunnahFastingStatus(tomorrow);
      if (tomorrowStatus.isSunnah) {
        return isAr
            ? 'غداً: ${tomorrowStatus.reasonAr ?? 'صيام مسنون'}'
            : 'Tomorrow: ${tomorrowStatus.reasonEn ?? 'Sunnah Fast'}';
      }
    }
    return isAr ? 'صيام الإثنين والخميس' : 'Mon & Thu Sunnah Fast';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.widgets_rounded,
                      size: 19,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.quickToolkit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.allTools,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Card 1: Khushu' Focus
            Expanded(
              child: _buildBentoCard(
                context: context,
                isDark: isDark,
                icon: Icons.timer_rounded,
                iconColor: AppColors.primary,
                bgColor: AppColors.primary.withValues(alpha: 0.15),
                pillLabel: '25m Block',
                pillColor: AppColors.primary,
                title: l10n.focus,
                subtitle: l10n.focusSubtitle,
                bottomAction: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/focus'),
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.primaryLight
                          : const Color(0xFF0F4C3A),
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 15),
                    label: const Text(
                      'Start Timer',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Card 2: Fasting & Sunnah Tracker
            Expanded(
              child: _buildBentoCard(
                context: context,
                isDark: isDark,
                icon: Icons.restaurant_rounded,
                iconColor: const Color(0xFFD4AF37),
                bgColor: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                pillLabel: 'Sunnah',
                pillColor: const Color(0xFFD4AF37),
                title: l10n.fastingTitle,
                subtitle: _getFastingSubtitle(isAr),
                bottomAction: InkWell(
                  onTap: _toggleFasting,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            isAr ? 'أنا صائم' : "I'm Fasting",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: _isFasting,
                            onChanged: (val) => _toggleFasting(),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            activeColor: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Card 3: Energy & Qaylulah Nap
            Expanded(
              child: _buildBentoCard(
                context: context,
                isDark: isDark,
                icon: Icons.nights_stay_rounded,
                iconColor: AppColors.secondary,
                bgColor: AppColors.secondary.withValues(alpha: 0.2),
                pillLabel: 'Qaylulah',
                pillColor: AppColors.secondary,
                title: l10n.energy,
                subtitle: 'Forest soundscape',
                bottomAction: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => context.push('/energy'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '15 min',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: InkWell(
                        onTap: () => context.push('/energy'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '20 min',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Card 4: Adhkar Studio (Digital Tasbih)
            Expanded(
              child: _buildBentoCard(
                context: context,
                isDark: isDark,
                icon: Icons.fingerprint_rounded,
                iconColor: const Color(0xFFD4AF37),
                bgColor: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                pillLabel: '$_tasbihCount/$_tasbihTarget',
                pillColor: const Color(0xFFD4AF37),
                title: 'SubhanAllah',
                subtitle: l10n.adhkarSubtitle,
                bottomAction: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _incrementTasbih,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF3C7),
                      foregroundColor: const Color(0xFF92400E),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.touch_app_rounded, size: 14),
                    label: Text(
                      'Tap: $_tasbihCount',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String pillLabel,
    required Color pillColor,
    required String title,
    required String subtitle,
    required Widget bottomAction,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      borderColor: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : AppColors.primary.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 17),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: pillColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pillLabel,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: pillColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          bottomAction,
        ],
      ),
    );
  }
}
