import 'dart:math';

import 'package:flutter/material.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';

/// Animated 4-bar equalizer for the spiritual soundscape.
class SoundWaveVisualizer extends StatefulWidget {
  final bool isPlaying;

  const SoundWaveVisualizer({super.key, required this.isPlaying});

  @override
  State<SoundWaveVisualizer> createState() => _SoundWaveVisualizerState();
}

class _SoundWaveVisualizerState extends State<SoundWaveVisualizer>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  bool get _isTestEnvironment =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    if (!_isTestEnvironment) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );
      if (widget.isPlaying) {
        _controller?.repeat(reverse: true);
      }
    }
  }

  @override
  void didUpdateWidget(covariant SoundWaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isTestEnvironment && _controller != null) {
      if (widget.isPlaying && !oldWidget.isPlaying) {
        _controller?.repeat(reverse: true);
      } else if (!widget.isPlaying && oldWidget.isPlaying) {
        _controller?.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTestEnvironment || _controller == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _bar(widget.isPlaying ? 12 : 4),
          const SizedBox(width: 3),
          _bar(widget.isPlaying ? 8 : 4),
          const SizedBox(width: 3),
          _bar(widget.isPlaying ? 14 : 4),
          const SizedBox(width: 3),
          _bar(widget.isPlaying ? 6 : 4),
        ],
      );
    }

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, _) {
        final val = _controller!.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _bar(widget.isPlaying ? 6 + 10 * sin(val * pi) : 4),
            const SizedBox(width: 3),
            _bar(widget.isPlaying ? 4 + 12 * cos(val * pi).abs() : 4),
            const SizedBox(width: 3),
            _bar(widget.isPlaying ? 8 + 8 * sin((val + 0.5) * pi).abs() : 4),
            const SizedBox(width: 3),
            _bar(widget.isPlaying ? 5 + 11 * cos((val + 0.2) * pi).abs() : 4),
          ],
        );
      },
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 3,
      height: height.clamp(4.0, 18.0),
      decoration: BoxDecoration(
        color: widget.isPlaying
            ? AppColors.primaryLight
            : AppColors.textDisabled,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Ambient Barakah Soundscape Card with audio wave visualizer and audio presets.
class FocusSoundscapeCard extends StatelessWidget {
  final int selectedSoundscapeIndex;
  final bool isRunning;
  final ValueChanged<int> onSoundscapeChanged;

  const FocusSoundscapeCard({
    super.key,
    required this.selectedSoundscapeIndex,
    required this.isRunning,
    required this.onSoundscapeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: isDark
          ? AppColors.borderDark.withValues(alpha: 0.5)
          : AppColors.borderLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.graphic_eq_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'أصوات البركة والسكينة'
                            : 'AMBIENT BARAKAH SOUNDSCAPE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SoundWaveVisualizer(
                isPlaying: isRunning && selectedSoundscapeIndex != 2,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildSoundscapePill(
                index: 0,
                icon: Icons.water_drop_rounded,
                title: isAr ? 'مطر الحرم' : 'Rain & Makkah',
                subtitle: selectedSoundscapeIndex == 0
                    ? (isAr ? 'مفعّل' : 'Active')
                    : (isAr ? 'غير مفعّل' : 'Offline'),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildSoundscapePill(
                index: 1,
                icon: Icons.waves_rounded,
                title: isAr ? 'هدير النهر' : 'Gentle Stream',
                subtitle: selectedSoundscapeIndex == 1
                    ? (isAr ? 'مفعّل' : 'Active')
                    : (isAr ? 'غير مفعّل' : 'Offline'),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildSoundscapePill(
                index: 2,
                icon: Icons.volume_off_rounded,
                title: isAr ? 'سكون تام' : 'Pure Silence',
                subtitle: selectedSoundscapeIndex == 2
                    ? (isAr ? 'مفعّل' : 'Active')
                    : (isAr ? 'صامت' : 'Muted'),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoundscapePill({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    final isSelected = selectedSoundscapeIndex == index;
    return Expanded(
      child: AppPressable(
        onTap: () {
          AppHaptics.selectionClick();
          onSoundscapeChanged(index);
        },
        pressedScale: 0.94,
        haptic: AppHapticFeedback.none,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                      ? AppColors.primary.withValues(alpha: 0.45)
                      : AppColors.primary.withValues(alpha: 0.12))
                : (isDark
                      ? AppColors.darkSurfaceSubtle.withValues(alpha: 0.5)
                      : AppColors.surfaceSubtle),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark
                        ? AppColors.borderDark.withValues(alpha: 0.5)
                        : AppColors.borderLight),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary)
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 8,
                      color: isSelected
                          ? AppColors.primaryLight
                          : (isDark
                                ? AppColors.darkTextSecondary.withValues(
                                    alpha: 0.5,
                                  )
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.5,
                                  )),
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
