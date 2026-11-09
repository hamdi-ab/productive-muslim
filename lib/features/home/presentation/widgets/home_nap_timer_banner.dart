import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';

class HomeNapTimerBanner extends StatefulWidget {
  const HomeNapTimerBanner({super.key});

  @override
  State<HomeNapTimerBanner> createState() => _HomeNapTimerBannerState();
}

class _HomeNapTimerBannerState extends State<HomeNapTimerBanner> {
  bool _dismissed = false;
  bool _isRunning = false;
  bool _isPaused = false;
  int _totalSeconds = 15 * 60;
  int _remainingSeconds = 15 * 60;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startNap(int minutes) {
    _timer?.cancel();
    HapticFeedback.mediumImpact();
    setState(() {
      _totalSeconds = minutes * 60;
      _remainingSeconds = minutes * 60;
      _isRunning = true;
      _isPaused = false;
      _dismissed = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isPaused) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          t.cancel();
          HapticFeedback.heavyImpact();
          setState(() {
            _isRunning = false;
          });
        }
      }
    });
  }

  void _togglePause() {
    HapticFeedback.selectionClick();
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _stopNap() {
    _timer?.cancel();
    HapticFeedback.lightImpact();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed && !_isRunning) {
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => setState(() => _dismissed = false),
          icon: const Icon(Icons.refresh_rounded, size: 14),
          label: const Text(
            'Show Sunnah Nap Routine',
            style: TextStyle(fontSize: 11),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    final isMidday = hour >= 11 && hour < 16;
    final title = isMidday ? 'Midday Barakah Boost' : 'Sunnah Qaylulah Nap';

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      borderColor: const Color(0xFFD4AF37)
          .withValues(alpha: isDark ? 0.25 : 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFD4AF37),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD4AF37)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'Sunnah Routine',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isRunning
                          ? 'Taking Sunnah Qaylulah nap before Salah to revitalize Khushu\'.'
                          : 'Renew your Wudhu and take a 15-min Qaylulah (Sunnah nap) before Asr prayer to revitalize your Khushu\'.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
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
          if (_isRunning) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _totalSeconds > 0
                    ? (_totalSeconds - _remainingSeconds) / _totalSeconds
                    : 0,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFD4AF37),
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bedtime_rounded,
                      size: 16,
                      color: Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isPaused ? '(Paused)' : 'remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 20,
                      ),
                      onPressed: _togglePause,
                      tooltip: _isPaused ? 'Resume' : 'Pause',
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop_rounded, size: 20),
                      onPressed: _stopNap,
                      tooltip: 'End Nap',
                    ),
                    TextButton.icon(
                      onPressed: () => context.push('/energy'),
                      icon: const Icon(Icons.graphic_eq_rounded, size: 14),
                      label: const Text(
                        'Soundscape',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: FilledButton.icon(
                    onPressed: () => _startNap(15),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4C3A),
                      foregroundColor: const Color(0xFF99D3BA),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.bedtime_rounded, size: 16),
                    label: const Text(
                      'Start 15m Nap',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: OutlinedButton(
                    onPressed: () => _startNap(20),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    child: const Text(
                      '20m',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TextButton(
                    onPressed: () => setState(() => _dismissed = true),
                    child: Text(
                      'Dismiss',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
