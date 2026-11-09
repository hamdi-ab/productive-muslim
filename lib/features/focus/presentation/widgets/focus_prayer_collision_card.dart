import 'package:flutter/material.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Warning card and wind-down indicator that alerts users if an upcoming prayer
/// collides with or approaches their focus session.
class FocusPrayerCollisionCard extends StatelessWidget {
  final bool isPrayerCollision;
  final bool isRunning;
  final String nextPrayerName;
  final Duration? timeUntilNextPrayer;
  final ValueChanged<int> onSelectPreset;

  const FocusPrayerCollisionCard({
    super.key,
    required this.isPrayerCollision,
    required this.isRunning,
    required this.nextPrayerName,
    required this.timeUntilNextPrayer,
    required this.onSelectPreset,
  });

  String _getLocalizedPrayerName(String prayerName, AppLocalizations l10n) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return l10n.fajr;
      case 'sunrise':
        return l10n.sunrise;
      case 'dhuhr':
        return l10n.dhuhr;
      case 'asr':
        return l10n.asr;
      case 'maghrib':
        return l10n.maghrib;
      case 'isha':
        return l10n.isha;
      default:
        return prayerName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!isPrayerCollision &&
        (!isRunning ||
            timeUntilNextPrayer == null ||
            timeUntilNextPrayer!.inMinutes > 10)) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Prayer Collision Warning Card (when preparing session)
        if (isPrayerCollision) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFF59E0B),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.focusPrayerWarningTitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.focusPrayerOverlap(
                    _getLocalizedPrayerName(nextPrayerName, l10n),
                    timeUntilNextPrayer!.inMinutes,
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                if (timeUntilNextPrayer!.inMinutes >= 10) ...[
                  const SizedBox(height: 10),
                  ActionChip(
                    avatar: const Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    label: Text(
                      l10n.focusPrayerSuggestion(
                        (timeUntilNextPrayer!.inMinutes - 5).clamp(5, 60),
                        _getLocalizedPrayerName(nextPrayerName, l10n),
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      onSelectPreset(
                        (timeUntilNextPrayer!.inMinutes - 5).clamp(5, 60),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Wind-Down Indicator (when running and prayer is near)
        if (isRunning &&
            timeUntilNextPrayer != null &&
            timeUntilNextPrayer!.inMinutes <= 10) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_filled_rounded,
                  color: Color(0xFFF59E0B),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.focusWindDownWarning(timeUntilNextPrayer!.inMinutes),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
