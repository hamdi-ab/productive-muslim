import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/arabic_typography.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/core/widgets/pulsing_glow.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/fasting/presentation/widgets/fasting_countdown_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class EnergyScreen extends StatefulWidget {
  const EnergyScreen({super.key});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  late int _physical;
  late int _spiritual;
  late int _mental;
  final String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Qaylulah Nap Timer
  bool _isNapRunning = false;
  int _napTotalSeconds = 20 * 60;
  int _napSeconds = 20 * 60;
  Timer? _napTimer;
  String _selectedSoundscape = "Rain on Prophet's Rawdah";

  @override
  void initState() {
    super.initState();
    final settings = _getSettings();
    final energy = settings.getDailyEnergy(_today);
    _physical = energy.physical.clamp(1, 5);
    _spiritual = energy.spiritual.clamp(1, 5);
    _mental = energy.mental.clamp(1, 5);
  }

  @override
  void dispose() {
    _napTimer?.cancel();
    super.dispose();
  }

  SettingsService _getSettings() {
    try {
      return getIt<SettingsService>();
    } catch (_) {
      return SettingsService.empty();
    }
  }

  int get _compositeScore {
    // Weighted Islamic composite: Spiritual 40%, Physical 30%, Mental 30%
    final score = ((_spiritual * 40 + _physical * 30 + _mental * 30) / 5)
        .round()
        .clamp(0, 100);
    return score;
  }

  String get _compositeTier {
    if (_compositeScore >= 80) return 'Al-Qawiyy Tier';
    if (_compositeScore >= 60) return 'Barakah Flow Tier';
    return 'Recharge Needed';
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.energySaved),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _selectNapDuration(int minutes) {
    AppHaptics.selectionClick();
    if (_isNapRunning) {
      _napTimer?.cancel();
      _isNapRunning = false;
    }
    setState(() {
      _napTotalSeconds = minutes * 60;
      _napSeconds = minutes * 60;
    });
  }

  void _toggleNap() {
    AppHaptics.mediumImpact();
    if (_isNapRunning) {
      _napTimer?.cancel();
      setState(() => _isNapRunning = false);
    } else {
      setState(() => _isNapRunning = true);
      _napTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_napSeconds > 0) {
          setState(() => _napSeconds--);
        } else {
          _napTimer?.cancel();
          setState(() => _isNapRunning = false);
          _onNapComplete();
        }
      });
    }
  }

  void _resetNap() {
    AppHaptics.lightImpact();
    _napTimer?.cancel();
    setState(() {
      _isNapRunning = false;
      _napSeconds = _napTotalSeconds;
    });
  }

  void _onNapComplete() {
    AppHaptics.heavyImpact();
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B1512),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: const Color(0xFFE9C349).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.wb_sunny_rounded, color: Color(0xFFE9C349)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Qaylulah Complete',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFE9C349),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sunnah Power Nap completed. Wake up refreshed and remember Allah:',
              style: TextStyle(fontSize: 13, color: Color(0xFFDAE5E0)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F4C3A).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF4EDEA3).withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: ArabicFontFamily.amiri.getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE9C349),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.qaylulahWakingDua,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF4EDEA3),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0F4C3A),
              foregroundColor: const Color(0xFFE9C349),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetNap();
            },
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  String _formatNap(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1512) : AppColors.background,
      appBar: ProductiveAppBar(
        title: l10n.energyTitle,
        subtitle: l10n.energySubtitle,
        showBackButton: true,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Center(
              child: InkWell(
                onTap: _saveEnergy,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F4C3A).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF4EDEA3).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: Color(0xFF4EDEA3),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.save,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4EDEA3),
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
      body: Stack(
        children: [
          // Subtle Islamic Lattice Watermark
          Positioned.fill(
            child: CustomPaint(
              painter: _IslamicLatticeBackgroundPainter(isDark: isDark),
            ),
          ),

          // Atmospheric Radial Spiritual Glow Orbs
          Positioned(
            top: -60,
            left: 20,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0F4C3A)
                        .withValues(alpha: isDark ? 0.35 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 260,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE9C349)
                        .withValues(alpha: isDark ? 0.18 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Scrollable Body
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Hero Banner: Triple-Energy Management & Al-Qawiyy
                    _buildHeroHeaderCard(l10n, isDark),

                    const SizedBox(height: AppSpacing.md),

                    // SECTION 1: Holistic Energy Triad & Battery Gauge
                    _buildEnergyTriadSection(l10n, isDark),

                    const SizedBox(height: AppSpacing.lg),

                    // SECTION 2: Qaylulah (Midday Sunnah Nap) Recharge
                    _buildQaylulahSection(l10n, isDark),

                    const SizedBox(height: AppSpacing.lg),

                    // SECTION 3: Sunnah Fasting Tracker & Countdown
                    _buildFastingSection(l10n, isDark),

                    const SizedBox(height: AppSpacing.lg),

                    // SECTION 4: Sunnah Physical Anchors (Mohammed Faris)
                    _buildPhysicalAnchorsSection(l10n, isDark),

                    const SizedBox(height: AppSpacing.md),

                    // Inspirational Barakah Promise Banner
                    _buildBarakahPromiseCard(isDark),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Hero Banner
  // ---------------------------------------------------------------------------
  Widget _buildHeroHeaderCard(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C3A), Color(0xFF0B1512)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE9C349).withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C3A).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE9C349), Color(0xFFC79E23)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE9C349).withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Color(0xFF0B1512),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Triple-Energy Management',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.energySubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF4EDEA3).withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 1: Holistic Energy Triad & Battery Gauge
  // ---------------------------------------------------------------------------
  Widget _buildEnergyTriadSection(AppLocalizations l10n, bool isDark) {
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
                    const Text(
                      'SELF-AUDIT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4EDEA3),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Today\'s Energy Levels',
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
                      color: const Color(0xFFE9C349).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE9C349).withValues(alpha: 0.5),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.military_tech_rounded,
                          size: 13,
                          color: Color(0xFFE9C349),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _compositeTier,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE9C349),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Circular Battery Gauge
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(140, 140),
                    painter: _BarakahBatteryGaugePainter(
                      progress: _compositeScore / 100.0,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 18,
                        color: Color(0xFFE9C349),
                      ),
                      Text(
                        '$_compositeScore%',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const Text(
                        'Barakah Battery',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8A938D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
              FittedBox(
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

  // ---------------------------------------------------------------------------
  // SECTION 2: Qaylulah (Midday Sunnah Nap) Recharge
  // ---------------------------------------------------------------------------
  Widget _buildQaylulahSection(AppLocalizations l10n, bool isDark) {
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
          // Section Title Row
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bedtime_rounded,
                      size: 16,
                      color: Color(0xFFE9C349),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.qaylulah,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4EDEA3).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4EDEA3).withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: const Text(
                    'Sunnah Power Nap',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4EDEA3),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Prophet's Tradition Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0B1512).withValues(alpha: 0.7)
                  : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(10),
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
                Text(
                  '"Take a midday nap (Qaylulah), for indeed the Shaytan does not nap."',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? const Color(0xFFDAE5E0)
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '— Al-Mu\'jam al-Awsat li-l-Tabarani',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 9, color: Color(0xFF8A938D)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Nap Timer Preset Chips
          Row(
            children: [
              _buildNapDurationChip(15, '15 min', 'Micro-Recharge', isDark),
              const SizedBox(width: 8),
              _buildNapDurationChip(
                20,
                '20 min',
                'Sunnah Optimal',
                isDark,
                isIdeal: true,
              ),
              const SizedBox(width: 8),
              _buildNapDurationChip(30, '30 min', 'Deep Cycle', isDark),
            ],
          ),

          const SizedBox(height: 16),

          // Timer Dial & Controls
          Center(
            child: Column(
              children: [
                PulsingGlow(
                  animate: _isNapRunning,
                  minScale: 0.98,
                  maxScale: 1.02,
                  duration: const Duration(milliseconds: 2000),
                  child: Container(
                    width: 156,
                    height: 156,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF0F4C3A)
                              .withValues(alpha: _isNapRunning ? 0.4 : 0.15),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: _isNapRunning
                            ? const Color(0xFFE9C349)
                            : (isDark
                                  ? const Color(0xFF404944)
                                  : AppColors.borderLight),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Post-Dhuhr Window',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4EDEA3),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _formatNap(_napSeconds),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                  fontFeatures: const [
                                    ui.FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: _isNapRunning
                                          ? const Color(0xFF4EDEA3)
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isNapRunning
                                        ? 'Recharging'
                                        : 'Cerebral Reset',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Color(0xFF8A938D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Timer Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isNapRunning || _napSeconds < _napTotalSeconds) ...[
                      AppPressable(
                        onTap: _resetNap,
                        pressedScale: 0.88,
                        haptic: AppHapticFeedback.none,
                        child: IconButton.outlined(
                          onPressed: _resetNap,
                          icon: const Icon(Icons.refresh_rounded),
                          style: IconButton.styleFrom(
                            side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF404944)
                                  : AppColors.borderLight,
                            ),
                            foregroundColor: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AppPressable(
                          onTap: _toggleNap,
                          pressedScale: 0.93,
                          haptic: AppHapticFeedback.none,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE9C349), Color(0xFFD4AA26)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE9C349)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isNapRunning
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 20,
                                  color: const Color(0xFF0B1512),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isNapRunning
                                      ? 'Pause'
                                      : 'Start Qaylulah Nap',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B1512),
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
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Soundscape Picker & Adhan Wake
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF18221E) : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(12),
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
                  Icons.graphic_eq_rounded,
                  size: 16,
                  color: Color(0xFF4EDEA3),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Barakah Soundscape',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _selectedSoundscape,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF8A938D),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: _selectedSoundscape,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  onSelected: (val) =>
                      setState(() => _selectedSoundscape = val),
                  itemBuilder: (ctx) =>
                      [
                            "Rain on Prophet's Rawdah",
                            'Gentle Madinah Breeze',
                            'Desert Night Whisp',
                            'Pure Silence',
                          ]
                          .map((s) => PopupMenuItem(value: s, child: Text(s)))
                          .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Waking Sunnah Remembrance Dua
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1512) : const Color(0xFFF7F9F8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE9C349).withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_stories_rounded,
                      size: 13,
                      color: Color(0xFFE9C349),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'WAKING SUNNAH REMEMBRANCE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE9C349),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: ArabicFontFamily.amiri.getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE9C349),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '"Al-hamdu lillahi-lladhi ahyana ba\'da ma amatana wa ilayhin-nushur"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF4EDEA3),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '"All praise is for Allah who gave us life after having taken it from us and unto Him is the resurrection."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? const Color(0xFFBFC9C3)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNapDurationChip(
    int minutes,
    String label,
    String subtitle,
    bool isDark, {
    bool isIdeal = false,
  }) {
    final isSelected = _napTotalSeconds == minutes * 60;
    return Expanded(
      child: InkWell(
        onTap: () => _selectNapDuration(minutes),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0F4C3A).withValues(alpha: 0.4)
                : (isDark ? const Color(0xFF18221E) : AppColors.surfaceSubtle),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFE9C349)
                  : (isDark
                        ? const Color(0xFF404944).withValues(alpha: 0.4)
                        : AppColors.borderLight),
              width: isSelected ? 1.4 : 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isIdeal)
                Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9C349),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'OPTIMAL',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFFE9C349)
                        : (isDark ? Colors.white : AppColors.textPrimary),
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 8,
                    color: isDark
                        ? const Color(0xFF8A938D)
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 3: Sunnah Fasting Tracker & Countdown
  // ---------------------------------------------------------------------------
  Widget _buildFastingSection(AppLocalizations l10n, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        const FastingCountdownCard(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 4: Sunnah Physical Anchors (Mohammed Faris)
  // ---------------------------------------------------------------------------
  Widget _buildPhysicalAnchorsSection(AppLocalizations l10n, bool isDark) {
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'BARAKAH FRAMEWORK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4EDEA3),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Sunnah Physical Anchors',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '3 Daily Habits',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8A938D),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Card 1: Sleep on the Sunnah
          _buildAnchorHabitCard(
            icon: Icons.night_shelter_rounded,
            tag: 'Night Architecture',
            title: 'Sleep on the Sunnah',
            desc: 'Sleep immediately after Isha, perform Wudu before bed, dust the mattress, and sleep on the right side facing Qibla.',
            status: 'Tonight Checklist Ready',
            color: const Color(0xFF4EDEA3),
            isDark: isDark,
          ),

          const SizedBox(height: 10),

          // Card 2: 1/3 Rule for Nutrition
          _buildAnchorHabitCard(
            icon: Icons.restaurant_rounded,
            tag: 'Prophetic Diet',
            title: 'The 1/3 Rule for Nutrition',
            desc: '"One-third for food, one-third for drink, and one-third for breath." — Sunan al-Tirmidhi. Keeps digestion light and avoids sluggishness.',
            status: 'Clean & Light Midday',
            color: const Color(0xFFE9C349),
            isDark: isDark,
          ),

          const SizedBox(height: 10),

          // Card 3: Daily Movement to Mosque
          _buildAnchorHabitCard(
            icon: Icons.directions_walk_rounded,
            tag: 'Steps of Barakah',
            title: 'Daily Movement to the Mosque',
            desc: 'Intentional walking for congregational Salah — each step elevates a rank and erases an error.',
            status: '2,840 / 5,000 Steps Logged',
            color: const Color(0xFF99D3BA),
            isDark: isDark,
            progress: 0.56,
          ),
        ],
      ),
    );
  }

  Widget _buildAnchorHabitCard({
    required IconData icon,
    required String tag,
    required String title,
    required String desc,
    required String status,
    required Color color,
    required bool isDark,
    double? progress,
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              color: isDark ? const Color(0xFFBFC9C3) : AppColors.textSecondary,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: isDark
                    ? const Color(0xFF222C29)
                    : Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Inspirational Barakah Promise Banner
  // ---------------------------------------------------------------------------
  Widget _buildBarakahPromiseCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F4C3A).withValues(alpha: isDark ? 0.5 : 0.15),
            const Color(0xFF141E1A).withValues(alpha: isDark ? 0.9 : 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9C349).withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 20,
            color: Color(0xFFE9C349),
          ),
          const SizedBox(height: 4),
          Text(
            'Energize Body for the Creator',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Your energy is an investment in worship and service. Recharging with Sunnah intention transforms rest into continuous reward.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? const Color(0xFF8A938D) : AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Background Islamic Lattice Painter
// =============================================================================
class _IslamicLatticeBackgroundPainter extends CustomPainter {
  final bool isDark;
  const _IslamicLatticeBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? const Color(0xFFE9C349).withValues(alpha: 0.025)
          : const Color(0xFF0F4C3A).withValues(alpha: 0.02)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 50.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), spacing * 0.45, paint);
        final path = Path()
          ..moveTo(x, y - spacing * 0.45)
          ..lineTo(x + spacing * 0.45, y)
          ..lineTo(x, y + spacing * 0.45)
          ..lineTo(x - spacing * 0.45, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicLatticeBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

// =============================================================================
// Circular Barakah Battery Gauge Painter
// =============================================================================
class _BarakahBatteryGaugePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  const _BarakahBatteryGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;

    final backgroundPaint = Paint()
      ..color = const Color(0xFF2D3733).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    canvas.drawCircle(center, radius, backgroundPaint);

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    final gradient = const SweepGradient(
      colors: [Color(0xFF4EDEA3), Color(0xFF99D3BA), Color(0xFFE9C349)],
      stops: [0.0, 0.6, 1.0],
    );

    final activePaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BarakahBatteryGaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
