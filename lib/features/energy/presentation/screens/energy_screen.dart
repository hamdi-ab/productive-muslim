import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/core/widgets/gradient_card.dart';
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
  int _napSeconds = 20 * 60;
  Timer? _napTimer;

  @override
  void initState() {
    super.initState();
    final settings = _getSettings();
    final energy = settings.getDailyEnergy(_today);
    _physical = energy.physical;
    _spiritual = energy.spiritual;
    _mental = energy.mental;
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
      _napSeconds = 20 * 60;
    });
  }

  void _onNapComplete() {
    AppHaptics.heavyImpact();
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.wb_sunny_rounded, color: AppColors.secondary),
            SizedBox(width: 8),
            Text(
              'Qaylulah Complete',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sunnah Power Nap completed. Wake up refreshed and remember Allah:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                l10n.qaylulahWakingDua,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
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

    final hasParentScaffold = Scaffold.maybeOf(context) != null;

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Card
              GradientCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Triple-Energy Management',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.energySubtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 1. Daily Energy Sliders
              Text(
                'Today\'s Energy Levels',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassContainer(
                padding: const EdgeInsets.all(18),
                borderRadius: 20,
                child: Column(
                  children: [
                    _buildEnergyRatingRow(
                      title: l10n.energySpiritual,
                      icon: Icons.auto_awesome_rounded,
                      color: AppColors.primary,
                      value: _spiritual,
                      onChanged: (v) => setState(() => _spiritual = v),
                    ),
                    const Divider(height: 24),
                    _buildEnergyRatingRow(
                      title: l10n.energyPhysical,
                      icon: Icons.fitness_center_rounded,
                      color: AppColors.secondary,
                      value: _physical,
                      onChanged: (v) => setState(() => _physical = v),
                    ),
                    const Divider(height: 24),
                    _buildEnergyRatingRow(
                      title: l10n.energyMental,
                      icon: Icons.psychology_rounded,
                      color: Colors.blue,
                      value: _mental,
                      onChanged: (v) => setState(() => _mental = v),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppPressable(
                        onTap: _saveEnergy,
                        pressedScale: 0.94,
                        haptic: AppHapticFeedback.none,
                        borderRadius: BorderRadius.circular(16),
                        child: FilledButton.icon(
                          onPressed: _saveEnergy,
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: Text(l10n.save),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 2. Sunnah Qaylulah (Power Nap) Card
              Text(
                l10n.qaylulah,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassContainer(
                padding: const EdgeInsets.all(18),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.hotel_rounded,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.qaylulah,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.qaylulahDesc,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PulsingGlow(
                          animate: _isNapRunning,
                          minScale: 0.98,
                          maxScale: 1.02,
                          duration: const Duration(milliseconds: 2000),
                          child: Text(
                            _formatNap(_napSeconds),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (_isNapRunning || _napSeconds < 20 * 60)
                              AppPressable(
                                onTap: _resetNap,
                                pressedScale: 0.88,
                                haptic: AppHapticFeedback.none,
                                child: IconButton.outlined(
                                  onPressed: _resetNap,
                                  icon: const Icon(Icons.refresh_rounded),
                                ),
                              ),
                            const SizedBox(width: 8),
                            AppPressable(
                              onTap: _toggleNap,
                              pressedScale: 0.93,
                              haptic: AppHapticFeedback.none,
                              borderRadius: BorderRadius.circular(16),
                              child: FilledButton.icon(
                                onPressed: _toggleNap,
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(
                                        scale: anim,
                                        child: child,
                                      ),
                                  child: Icon(
                                    _isNapRunning
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    key: ValueKey('nap_icon_$_isNapRunning'),
                                  ),
                                ),
                                label: Text(
                                  _isNapRunning
                                      ? l10n.focusPause
                                      : l10n.qaylulahStart,
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 3. Sunnah Fasting Tracker & Countdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.sunnahFasting,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
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
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const FastingCountdownCard(),

              const SizedBox(height: AppSpacing.xl),

              // 4. Physical Productivity Guidelines (Mohammed Faris)
              Text(
                'Physical Productivity Rules',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 20,
                child: Column(
                  children: [
                    _buildRuleItem(
                      icon: Icons.nights_stay_rounded,
                      title: 'Sleep on the Sunnah',
                      body: 'Sleep after Isha, make Wudu, recite Surah Al-Mulk, and sleep on your right side for restorative rest.',
                    ),
                    const SizedBox(height: 14),
                    _buildRuleItem(
                      icon: Icons.restaurant_rounded,
                      title: 'The 1/3 Rule for Nutrition',
                      body: 'Eat to live, not live to eat. 1/3 for food, 1/3 for liquid, and 1/3 for breath to avoid post-meal fatigue.',
                    ),
                    const SizedBox(height: 14),
                    _buildRuleItem(
                      icon: Icons.directions_walk_rounded,
                      title: 'Daily Movement & Walking',
                      body: 'Walking to the mosque for congregational prayer builds baseline physical vitality and clears mental clutter.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );

    if (hasParentScaffold) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.energyTitle)),
      body: content,
    );
  }

  Widget _buildEnergyRatingRow({
    required String title,
    required IconData icon,
    required Color color,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isFilled = starIndex <= value;
            return AppPressable(
              onTap: () {
                onChanged(starIndex);
              },
              pressedScale: 0.85,
              haptic: AppHapticFeedback.selection,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  scale: isFilled ? 1.08 : 1.0,
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isFilled
                        ? color
                        : AppColors.textSecondary.withValues(alpha: 0.4),
                    size: 24,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRuleItem({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
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
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
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
