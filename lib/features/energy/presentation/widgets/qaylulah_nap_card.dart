import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/arabic_typography.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/pulsing_glow.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Interactive Qaylulah (Sunnah midday nap) card with presets,
/// countdown timer, soundscape picker, and waking Sunnah remembrance.
class QaylulahNapCard extends StatefulWidget {
  const QaylulahNapCard({super.key});

  @override
  State<QaylulahNapCard> createState() => _QaylulahNapCardState();
}

class _QaylulahNapCardState extends State<QaylulahNapCard> {
  bool _isNapRunning = false;
  int _napTotalSeconds = 20 * 60;
  int _napSeconds = 20 * 60;
  Timer? _napTimer;
  String _selectedSoundscape = "Rain on Prophet's Rawdah";

  @override
  void dispose() {
    _napTimer?.cancel();
    super.dispose();
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
        title: const Row(
          children: [
            Icon(Icons.wb_sunny_rounded, color: Color(0xFFE9C349)),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Qaylulah Complete',
                style: TextStyle(
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
                color: const Color(0xFF141E1A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF4EDEA3).withValues(alpha: 0.3),
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
                  const Text(
                    '"All praise is for Allah who gave us life after having taken it from us and unto Him is the resurrection."',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Color(0xFF4EDEA3)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Alhamdulillah',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE9C349),
              ),
            ),
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
              Flexible(
                child: FittedBox(
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
                            Flexible(
                              child: FittedBox(
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
                            ),
                            Flexible(
                              child: FittedBox(
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
                const Row(
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 13,
                      color: Color(0xFFE9C349),
                    ),
                    SizedBox(width: 4),
                    Expanded(
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
}
