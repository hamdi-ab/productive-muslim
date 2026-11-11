import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/data/services/adhan_notification_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_celestial_arc.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

String _toArabicDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], arabic[i]);
  }
  return input;
}

class HomePrayerCard extends StatefulWidget {
  const HomePrayerCard({super.key});

  @override
  State<HomePrayerCard> createState() => _HomePrayerCardState();
}

class _HomePrayerCardState extends State<HomePrayerCard> {
  String _nextPrayer = '--';
  String _countdown = '--:--';
  String? _locationName;
  bool _loading = true;
  bool _adhanEnabled = false;
  Timer? _timer;
  PrayerTimes? _cachedPrayerTimes;

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<SettingsService>()) {
      _adhanEnabled = getIt<SettingsService>().adhanNotificationsEnabled;
    }
    if (getIt.isRegistered<PrayerTimeService>()) {
      final service = getIt<PrayerTimeService>();
      if (service.cachedPrayerTimes != null) {
        _cachedPrayerTimes = service.cachedPrayerTimes;
        _locationName = service.cachedLocationName;
        _loading = false;
        _updatePrayerCountdown();
        _startTimer();
      }
    }
    _loadPrayerTimes();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      if (!getIt.isRegistered<PrayerTimeService>()) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final service = getIt<PrayerTimeService>();
      final position = await service.getCurrentPosition();
      if (!mounted) return;
      if (position == null) {
        if (_cachedPrayerTimes == null) {
          setState(() => _loading = false);
        }
        return;
      }

      _cachedPrayerTimes = service.getPrayerTimes(position);
      _locationName = service.getLocationName(position);
      _updatePrayerCountdown();
      _startTimer();
    } catch (_) {
      if (mounted && _cachedPrayerTimes == null) {
        setState(() => _loading = false);
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updatePrayerCountdown();
    });
  }

  void _updatePrayerCountdown() {
    if (!getIt.isRegistered<PrayerTimeService>()) {
      return;
    }

    final service = getIt<PrayerTimeService>();
    final now = DateTime.now();

    if (_cachedPrayerTimes != null && _cachedPrayerTimes!.fajr.day != now.day) {
      if (service.cachedPosition != null) {
        _cachedPrayerTimes = service.getPrayerTimes(
          service.cachedPosition!,
          date: now,
        );
      } else if (service.cachedPrayerTimes != null) {
        _cachedPrayerTimes = service.cachedPrayerTimes;
      }
    }

    if (_cachedPrayerTimes == null) {
      return;
    }

    final nextPrayer = service.getNextPrayerName(_cachedPrayerTimes!);
    final timeUntil = service.getTimeUntilNextPrayer(_cachedPrayerTimes!);

    if (mounted) {
      setState(() {
        _nextPrayer = nextPrayer ?? '--';
        _countdown = timeUntil != null ? _formatDuration(timeUntil) : '--:--';
        _loading = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final sStr = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours}h ${minutes}m ${sStr}s';
    }
    return '${minutes}m ${sStr}s';
  }

  String _formatPrayerTime(
    PrayerTimes times,
    String prayerName,
    BuildContext context,
  ) {
    final format = DateFormat.jm(Localizations.localeOf(context).languageCode);
    final dt = switch (prayerName.toLowerCase()) {
      'fajr' => times.fajr,
      'sunrise' => times.sunrise,
      'dhuhr' => times.dhuhr,
      'asr' => times.asr,
      'maghrib' => times.maghrib,
      'isha' => times.isha,
      _ => null,
    };
    return dt != null ? format.format(dt) : '';
  }

  Future<void> _toggleAdhan() async {
    AppHaptics.selectionClick();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final newValue = !_adhanEnabled;

    if (!getIt.isRegistered<SettingsService>()) {
      setState(() => _adhanEnabled = newValue);
      return;
    }

    final settings = getIt<SettingsService>();
    AdhanNotificationService? adhanService;
    if (getIt.isRegistered<AdhanNotificationService>()) {
      adhanService = getIt<AdhanNotificationService>();
    }

    if (newValue && adhanService != null) {
      final granted = await adhanService.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isAr
                    ? 'يرجى تفعيل إذن الإشعارات لتلقي تنبيهات الأذان'
                    : 'Please enable notifications permission for Adhan alerts',
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    }

    await settings.setAdhanNotificationsEnabled(newValue);

    if (adhanService != null) {
      if (newValue) {
        if (_cachedPrayerTimes != null) {
          await adhanService.initialize();
          await adhanService.schedulePrayerNotifications(
            fajr: _cachedPrayerTimes!.fajr,
            dhuhr: _cachedPrayerTimes!.dhuhr,
            asr: _cachedPrayerTimes!.asr,
            maghrib: _cachedPrayerTimes!.maghrib,
            isha: _cachedPrayerTimes!.isha,
          );
        }
      } else {
        await adhanService.cancelAll();
      }
    }

    if (mounted) {
      setState(() => _adhanEnabled = newValue);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? (isAr
                      ? 'تم تفعيل تنبيهات الأذان'
                      : 'Adhan notifications enabled')
                : (isAr
                      ? 'تم كتم تنبيهات الأذان'
                      : 'Adhan notifications muted'),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isAfterIsha =
        _cachedPrayerTimes != null &&
        DateTime.now().isAfter(_cachedPrayerTimes!.isha);
    final isTomorrowFajr = isAfterIsha && _nextPrayer.toLowerCase() == 'fajr';
    final prayerName = getLocalizedPrayerName(_nextPrayer, l10n);

    return AppPressable(
      onTap: () => context.push('/prayer-times'),
      pressedScale: 0.98,
      haptic: AppHapticFeedback.light,
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        borderColor: const Color(0xFFD4AF37)
            .withValues(alpha: isDark ? 0.3 : 0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Micro Badge & Audio Adhan Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isAr ? 'هدي السنة النبوية' : 'SUNNAH ALIGNMENT',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AppPressable(
                      onTap: _toggleAdhan,
                      pressedScale: 0.92,
                      haptic: AppHapticFeedback.none,
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        key: const Key('home_hero_adhan_toggle_badge'),
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _adhanEnabled
                              ? (isDark
                                    ? const Color(0xFF10281E)
                                    : const Color(0xFFE8F5E9))
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.04)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _adhanEnabled
                                ? const Color(0xFF10B981)
                                      .withValues(alpha: isDark ? 0.45 : 0.6)
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.08)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _adhanEnabled
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_off_rounded,
                              size: 13,
                              color: _adhanEnabled
                                  ? const Color(0xFF10B981)
                                  : (isDark ? Colors.white60 : Colors.black45),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _adhanEnabled
                                  ? (isAr ? 'الأذان: مفعّل' : 'Adhan: On')
                                  : (isAr ? 'الأذان: صامت' : 'Adhan: Muted'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _adhanEnabled
                                    ? (isDark
                                          ? const Color(0xFF4EDEA3)
                                          : const Color(0xFF1B5E20))
                                    : (isDark
                                          ? Colors.white60
                                          : Colors.black54),
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
            // Header: Upcoming Prayer Title & Countdown Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          prayerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isTomorrowFajr) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: isDark ? 0.22 : 0.14),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              isAr ? 'غداً' : 'Tomorrow',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFFBBF24)
                                    : const Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_loading)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFD97706),
                                ),
                              ),
                            )
                          else ...[
                            const Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAr
                                  ? 'خلال ${_toArabicDigits(_countdown)}'
                                  : 'in $_countdown',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Subtitle Row: Scheduled Time (Left) & Location Status (Right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_cachedPrayerTimes != null)
                  Flexible(
                    child: Text(
                      '${isAr ? 'في ' : 'at '}${_formatPrayerTime(_cachedPrayerTimes!, _nextPrayer, context)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationName != null && _locationName!.isNotEmpty
                        ? (isAr
                              ? '📍 $_locationName • مجدول مع الإقامة'
                              : '📍 $_locationName • Iqamah scheduled')
                        : (isAr
                              ? 'مجدول مع الإقامة • طهارة للصلاة'
                              : 'Iqamah scheduled • Clean for Salah'),
                    maxLines: 1,
                    textAlign: _cachedPrayerTimes != null
                        ? TextAlign.end
                        : TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Celestial Sun Arc Canvas Diagram
            SolarArcDiagram(
              key: const ValueKey('hero_solar_arc_diagram'),
              prayerTimes: _cachedPrayerTimes,
              nextPrayer: _nextPrayer,
              isDark: isDark,
            ),
            const SizedBox(height: 6),
            // 5 Daily Prayers Status Horizontal Cards Row
            if (_cachedPrayerTimes != null)
              _buildDailyPrayersRow(
                context,
                _cachedPrayerTimes!,
                _nextPrayer,
                l10n,
                isDark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyPrayersRow(
    BuildContext context,
    PrayerTimes prayerTimes,
    String nextPrayer,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final now = DateTime.now();
    final timeFormat = DateFormat.jm(
      Localizations.localeOf(context).languageCode,
    );

    final prayers = [
      (key: 'fajr', name: l10n.fajr, time: prayerTimes.fajr),
      (key: 'dhuhr', name: l10n.dhuhr, time: prayerTimes.dhuhr),
      (key: 'asr', name: l10n.asr, time: prayerTimes.asr),
      (key: 'maghrib', name: l10n.maghrib, time: prayerTimes.maghrib),
      (key: 'isha', name: l10n.isha, time: prayerTimes.isha),
    ];

    final isAfterIsha = now.isAfter(prayerTimes.isha);
    final nextKey = nextPrayer.toLowerCase();

    return Row(
      children: prayers.map((p) {
        final isNext = !isAfterIsha && p.key == nextKey;
        final isPast = p.time.isBefore(now) && !isNext;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            decoration: BoxDecoration(
              color: isNext
                  ? AppColors.primary
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isNext
                    ? AppColors.secondary.withValues(alpha: 0.8)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06)),
                width: isNext ? 1.5 : 1,
              ),
              boxShadow: isNext
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                    color: isNext
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  timeFormat.format(p.time),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                    color: isNext
                        ? AppColors.secondary
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 3),
                Icon(
                  isNext
                      ? Icons.radio_button_checked_rounded
                      : (isPast
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded),
                  size: 12,
                  color: isNext
                      ? AppColors.secondary
                      : (isPast
                            ? (isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary)
                            : (isDark ? Colors.white30 : Colors.black26)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
