import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Card orchestrating the 3 Energy Dimensions (Ruh, Jism, Aql)
/// for personal daily reflection and energy balance.
class EnergyTriadCard extends StatefulWidget {
  final VoidCallback? onSaved;

  const EnergyTriadCard({super.key, this.onSaved});

  @override
  State<EnergyTriadCard> createState() => _EnergyTriadCardState();
}

class _EnergyTriadCardState extends State<EnergyTriadCard> {
  late int _physical;
  late int _spiritual;
  late int _mental;
  late final String _today;

  @override
  void initState() {
    super.initState();
    _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final settings = _getSettings();
    final energy = settings.getDailyEnergy(_today);
    _physical = energy.physical.clamp(1, 5);
    _spiritual = energy.spiritual.clamp(1, 5);
    _mental = energy.mental.clamp(1, 5);
  }

  SettingsService _getSettings() {
    try {
      return getIt<SettingsService>();
    } catch (_) {
      return SettingsService.empty();
    }
  }

  Future<void> _saveEnergy() async {
    AppHaptics.selectionClick();
    final settings = _getSettings();
    await settings.setDailyEnergy(
      date: _today,
      physical: _physical,
      spiritual: _spiritual,
      mental: _mental,
    );
    widget.onSaved?.call();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.energySaved),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
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
          // Header Row: Today's Energy Levels + Al-Qawiyy Tier Badge
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAr ? 'التقييم الذاتي' : 'SELF-AUDIT',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4EDEA3),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      isAr ? 'مستويات طاقة اليوم' : 'Today\'s Energy Levels',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
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
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4EDEA3).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4EDEA3).withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.spa_rounded,
                          size: 13,
                          color: Color(0xFF4EDEA3),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAr ? 'توازن واعي' : 'Daily Check-in',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4EDEA3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Hadith Micro-Banner
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF18221E) : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF404944).withValues(alpha: 0.3)
                    : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            child: Text(
              '"The strong believer is better and more beloved to Allah than the weak believer, while there is good in both." — Sahih Muslim',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: isDark
                    ? const Color(0xFFBFC9C3)
                    : AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3 Energy Dimensions (Spiritual, Physical, Mental)
          _buildDimensionCard(
            title: l10n.energySpiritual,
            arabicSubtitle: 'رُوح (Ruh) • Divine Connection',
            desc: 'Presence in Salah, heartfelt Dhikr & purified intention',
            icon: Icons.spa_rounded,
            color: const Color(0xFFE9C349),
            value: _spiritual,
            onChanged: (v) => setState(() => _spiritual = v),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildDimensionCard(
            title: l10n.energyPhysical,
            arabicSubtitle: 'جِسْم (Jism) • Bodily Amanah',
            desc: 'Nutrition, hydration, sleep quality & restorative recovery',
            icon: Icons.fitness_center_rounded,
            color: const Color(0xFF4EDEA3),
            value: _physical,
            onChanged: (v) => setState(() => _physical = v),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildDimensionCard(
            title: l10n.energyMental,
            arabicSubtitle: 'عَقْل (Aql) • Cognitive Clarity',
            desc: 'Executive mental focus, attentiveness & deep work reserves',
            icon: Icons.psychology_rounded,
            color: const Color(0xFF99D3BA),
            value: _mental,
            onChanged: (v) => setState(() => _mental = v),
            isDark: isDark,
          ),

          const SizedBox(height: 14),

          // Save Button
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppPressable(
              onTap: _saveEnergy,
              pressedScale: 0.94,
              haptic: AppHapticFeedback.none,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F4C3A), Color(0xFF135A46)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF4EDEA3).withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Color(0xFF4EDEA3),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.save,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionCard({
    required String title,
    required String arabicSubtitle,
    required String desc,
    required IconData icon,
    required Color color,
    required int value,
    required ValueChanged<int> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18221E) : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? const Color(0xFF404944).withValues(alpha: 0.3)
              : AppColors.borderLight,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      arabicSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      final isFilled = starIndex <= value;
                      return InkWell(
                        onTap: () {
                          AppHaptics.selectionClick();
                          onChanged(starIndex);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(2.5),
                          child: Icon(
                            isFilled
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: isFilled
                                ? color
                                : (isDark
                                      ? const Color(0xFF404944)
                                      : AppColors.textSecondary.withValues(
                                          alpha: 0.3,
                                        )),
                            size: 20,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF8A938D) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
