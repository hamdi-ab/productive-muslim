import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/fasting/presentation/widgets/iftar_dua_dialog.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class FastingCountdownCard extends StatefulWidget {
  final VoidCallback? onStatusChanged;

  const FastingCountdownCard({super.key, this.onStatusChanged});

  @override
  State<FastingCountdownCard> createState() => _FastingCountdownCardState();
}

class _FastingCountdownCardState extends State<FastingCountdownCard> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  DateTime? _fajrTime;
  DateTime? _maghribTime;
  bool _isFasting = false;
  late String _today;

  @override
  void initState() {
    super.initState();
    _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadFastingStatus();
    _loadPrayerTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final now = DateTime.now();
        final currentToday = DateFormat('yyyy-MM-dd').format(now);
        if (currentToday != _today) {
          _today = currentToday;
          _loadFastingStatus();
          _loadPrayerTimes();
        }
        setState(() => _now = now);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadFastingStatus() {
    try {
      final settings = getIt<SettingsService>();
      setState(() {
        _isFasting = settings.isSunnahFastingTarget(_today);
      });
    } catch (_) {}
  }

  Future<void> _loadPrayerTimes() async {
    if (!getIt.isRegistered<PrayerTimeService>()) return;
    try {
      final service = getIt<PrayerTimeService>();
      final position = await service.getCurrentPosition();
      if (position != null) {
        final pt = service.getPrayerTimes(position);
        if (pt != null && mounted) {
          setState(() {
            _fajrTime = pt.fajr;
            _maghribTime = pt.maghrib;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _toggleFasting() async {
    HapticFeedback.lightImpact();
    try {
      final settings = getIt<SettingsService>();
      await settings.toggleSunnahFastingTarget(_today);
      setState(() => _isFasting = !_isFasting);
      widget.onStatusChanged?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fastingLoggedSuccess),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {}
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final hijriService = getIt.isRegistered<HijriService>()
        ? getIt<HijriService>()
        : HijriService();
    final fastingStatus = hijriService.getSunnahFastingStatus(_now);
    final reason = isArabic ? fastingStatus.reasonAr : fastingStatus.reasonEn;

    // Fasting timeline: Suhoor ends at Fajr, Iftar starts at Maghrib
    final isBeforeFajr = _fajrTime != null && _now.isBefore(_fajrTime!);
    final isDuringFast =
        _fajrTime != null &&
        _maghribTime != null &&
        _now.isAfter(_fajrTime!) &&
        _now.isBefore(_maghribTime!);
    final isAfterMaghrib = _maghribTime != null && _now.isAfter(_maghribTime!);

    String countdownLabel = '';
    String countdownTime = '--:--:--';
    String timelineStatus = l10n.suhoorWindow;

    if (isBeforeFajr) {
      final remaining = _fajrTime!.difference(_now);
      countdownLabel = l10n.fastingCountdownSuhoor(_formatDuration(remaining));
      countdownTime = _formatDuration(remaining);
      timelineStatus = l10n.suhoorWindow;
    } else if (isDuringFast) {
      final remaining = _maghribTime!.difference(_now);
      countdownLabel = l10n.fastingCountdownIftar(_formatDuration(remaining));
      countdownTime = _formatDuration(remaining);
      timelineStatus = l10n.fastInProgress;
    } else if (isAfterMaghrib) {
      countdownLabel = l10n.done;
      countdownTime = '00:00:00';
      timelineStatus = l10n.iftarCompleted;
    }

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (_isFasting ? AppColors.secondary : AppColors.primary)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isFasting
                      ? Icons.wb_twilight_rounded
                      : Icons.water_drop_outlined,
                  color: _isFasting ? AppColors.secondary : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _isFasting
                              ? l10n.fastingTodayActive
                              : l10n.fastingTodayInactive,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (fastingStatus.isSunnah) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            child: Text(
                              l10n.sunnahBadge,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.amber[200]
                                    : Colors.amber[900],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (reason != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        reason,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch.adaptive(
                value: _isFasting,
                activeThumbColor: AppColors.secondary,
                onChanged: (_) => _toggleFasting(),
              ),
            ],
          ),

          const Divider(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_fajrTime != null && _maghribTime != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timelineStatus,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      countdownTime,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      countdownLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                Expanded(
                  child: Text(
                    l10n.sunnahFastingDesc,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              FilledButton.tonalIcon(
                onPressed: () => IftarDuaDialog.show(context),
                icon: const Icon(Icons.menu_book_rounded, size: 16),
                label: Text(
                  l10n.iftarDuaTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
