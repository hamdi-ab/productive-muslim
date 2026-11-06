import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/floating_glass_nav_bar.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/home_widget_sync_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).matchedLocation;

    final prayerService = getIt.isRegistered<PrayerTimeService>()
        ? getIt<PrayerTimeService>()
        : null;

    final navItems = [
      FloatingNavItem(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        label: l10n.home,
      ),
      FloatingNavItem(
        icon: Icons.checklist_rtl_outlined,
        activeIcon: Icons.checklist_rtl_rounded,
        label: l10n.plan,
      ),
      FloatingNavItem(
        icon: Icons.mosque_outlined,
        activeIcon: Icons.mosque_rounded,
        label: l10n.prayerTimes,
      ),
      FloatingNavItem(
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome_rounded,
        label: l10n.barakah,
      ),
      FloatingNavItem(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book_rounded,
        label: l10n.journal,
      ),
    ];

    final currentIndex = _getIndexForLocation(location);
    final headerInfo = _getHeaderInfo(location, l10n);
    final isHome = location == '/';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    String? subtitle;
    if (isHome) {
      if (getIt.isRegistered<HijriService>()) {
        final hijri = getIt<HijriService>().getHijriDate(DateTime.now());
        final hijriStr = isAr
            ? '${hijri.hDay} ${hijri.monthNameAr}'
            : '${hijri.hDay} ${hijri.monthNameEn}';
        if (hijri.isSunnahFastingDay) {
          final badge = hijri.isWhiteDay
              ? l10n.whiteDayBadge
              : (hijri.isArafah
                    ? (isAr ? 'عرفة' : 'Arafah')
                    : (hijri.isAshura
                          ? (isAr ? 'عاشوراء' : 'Ashura')
                          : l10n.sunnahBadge));
          subtitle = '$hijriStr • 🌙 $badge';
        } else {
          subtitle = hijriStr;
        }
      }
    } else {
      subtitle = _getSubtitleForLocation(location, l10n, prayerService, isAr);
    }

    final Widget? homeLeading = isHome
        ? Padding(
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: Center(
              child: Tooltip(
                message: l10n.barakah,
                child: AppPressable(
                  onTap: () => context.push('/barakah'),
                  pressedScale: 0.92,
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.primary, Color(0xFFD4AF37)],
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: isDark
                              ? AppColors.darkSurface
                              : Colors.white,
                          child: const Icon(
                            Icons.spa_rounded,
                            size: 18,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF0B1512)
                                  : Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : null;

    return Scaffold(
      extendBody: true,
      appBar: ProductiveAppBar(
        title: headerInfo.title,
        subtitle: subtitle,
        leading: homeLeading,
        leadingIcon: isHome ? null : headerInfo.icon,
        showBackButton: false,
        actions: [
          if (isHome) ...[
            AppPressable(
              onTap: () => context.push('/barakah'),
              pressedScale: 0.92,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsetsDirectional.only(end: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFD97706),
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '12d',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFF92400E),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ProductiveAppBarAction(
              icon: Icons.settings_outlined,
              tooltip: l10n.settings,
              onTap: () => context.push('/settings'),
            ),
          ] else if (location == '/barakah') ...[
            ProductiveAppBarAction(
              key: const Key('open-review'),
              tooltip: l10n.barakahWeeklyTitle,
              icon: Icons.calendar_month_outlined,
              onTap: () => context.push('/barakah/review'),
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          _HomeWidgetSyncWatcher(service: prayerService),
          Padding(padding: const EdgeInsets.only(bottom: 80), child: child),
        ],
      ),
      bottomNavigationBar: FloatingGlassNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _navigateToIndex(context, index),
        items: navItems,
      ),
    );
  }

  static String? _getSubtitleForLocation(
    String location,
    AppLocalizations l10n,
    PrayerTimeService? prayerService,
    bool isAr,
  ) {
    return switch (location) {
      '/plan' || '/tasks' || '/habits' =>
        isAr ? '${l10n.tasks} والعادات' : '${l10n.tasks} & ${l10n.habits}',
      '/prayer-times' =>
        prayerService?.cachedLocationName != null &&
                prayerService!.cachedLocationName!.isNotEmpty
            ? '📍 ${prayerService.cachedLocationName}'
            : null,
      '/barakah' => isAr ? 'محاسبة النفس والبركة' : 'Mindset & Reflections',
      '/journal' => isAr ? 'النيات والخواطر' : 'Intentions & Reflections',
      _ => null,
    };
  }

  static ({String title, IconData icon}) _getHeaderInfo(
    String location,
    AppLocalizations l10n,
  ) {
    return switch (location) {
      '/' => (title: l10n.appTitle, icon: Icons.nights_stay_rounded),
      '/plan' ||
      '/tasks' ||
      '/habits' => (title: l10n.plan, icon: Icons.checklist_rtl_rounded),
      '/prayer-times' => (title: l10n.prayerTimes, icon: Icons.mosque_rounded),
      '/barakah' => (title: l10n.barakah, icon: Icons.auto_awesome_rounded),
      '/journal' => (title: l10n.journal, icon: Icons.menu_book_rounded),
      _ => (title: l10n.appTitle, icon: Icons.nights_stay_rounded),
    };
  }

  static int _getIndexForLocation(String location) {
    return switch (location) {
      '/' => 0,
      '/plan' || '/tasks' || '/habits' => 1,
      '/prayer-times' => 2,
      '/barakah' => 3,
      '/journal' => 4,
      _ => 0,
    };
  }

  static void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/plan');
        break;
      case 2:
        context.go('/prayer-times');
        break;
      case 3:
        context.go('/barakah');
        break;
      case 4:
        context.go('/journal');
        break;
    }
  }
}

class _HomeWidgetSyncWatcher extends StatefulWidget {
  final PrayerTimeService? service;

  const _HomeWidgetSyncWatcher({required this.service});

  @override
  State<_HomeWidgetSyncWatcher> createState() => _HomeWidgetSyncWatcherState();
}

class _HomeWidgetSyncWatcherState extends State<_HomeWidgetSyncWatcher> {
  Timer? _timer;
  PrayerTimes? _cachedPrayerTimes;

  @override
  void initState() {
    super.initState();
    if (widget.service != null && widget.service!.cachedPrayerTimes != null) {
      _cachedPrayerTimes = widget.service!.cachedPrayerTimes;
      _startTimer();
    }
    _loadPrayerTimes();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    if (widget.service == null) return;

    final position = await widget.service!.getCurrentPosition();
    if (!mounted || position == null) return;

    _cachedPrayerTimes = widget.service!.getPrayerTimes(position);
    _startTimer();
    _syncHomeWidget();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updatePrayerCountdown();
    });
  }

  void _updatePrayerCountdown() {
    if (widget.service == null) return;

    final now = DateTime.now();

    // Refresh prayer times if the calendar date has rolled over
    if (_cachedPrayerTimes != null && _cachedPrayerTimes!.fajr.day != now.day) {
      if (widget.service!.cachedPosition != null) {
        _cachedPrayerTimes = widget.service!.getPrayerTimes(
          widget.service!.cachedPosition!,
          date: now,
        );
        _syncHomeWidget();
      } else if (widget.service!.cachedPrayerTimes != null) {
        _cachedPrayerTimes = widget.service!.cachedPrayerTimes;
        _syncHomeWidget();
      }
    }
  }

  void _syncHomeWidget() {
    if (_cachedPrayerTimes == null ||
        widget.service == null ||
        !getIt.isRegistered<HomeWidgetSyncService>()) {
      return;
    }

    final nextPrayer =
        widget.service!.getNextPrayerName(_cachedPrayerTimes!) ?? '--';
    final timeUntil = widget.service!.getTimeUntilNextPrayer(
      _cachedPrayerTimes!,
    );
    final nextPrayerTime = widget.service!.getNextPrayerTime(
      _cachedPrayerTimes!,
    );
    final formattedTime = nextPrayerTime != null
        ? '${nextPrayerTime.hour.toString().padLeft(2, '0')}:${nextPrayerTime.minute.toString().padLeft(2, '0')}'
        : '--:--';
    final countdownStr = timeUntil != null ? _formatDuration(timeUntil) : '';

    int completedDhikr = 0;
    if (getIt.isRegistered<AdhkarService>()) {
      completedDhikr = getIt<AdhkarService>()
          .getCompletedDhikrIdsForDate(null)
          .length;
    }

    final l10n = AppLocalizations.of(context);
    final localizedPrayerName = l10n != null
        ? _getLocalizedPrayerName(nextPrayer, l10n)
        : nextPrayer;

    String hijriDateStr = '';
    String fastingBadgeStr = '';
    if (getIt.isRegistered<HijriService>()) {
      final hijriService = getIt<HijriService>();
      final now = DateTime.now();
      final hijriInfo = hijriService.getHijriDate(now);
      final isAr =
          l10n != null && Localizations.localeOf(context).languageCode == 'ar';
      hijriDateStr = isAr ? hijriInfo.formatAr() : hijriInfo.formatEn();
      if (hijriInfo.isSunnahFastingDay && l10n != null) {
        if (hijriInfo.isWhiteDay) {
          fastingBadgeStr = l10n.whiteDayBadge;
        } else if (hijriInfo.isArafah) {
          fastingBadgeStr = isAr ? 'عرفة' : 'Arafah';
        } else if (hijriInfo.isAshura) {
          fastingBadgeStr = isAr ? 'عاشوراء' : 'Ashura';
        } else {
          fastingBadgeStr = l10n.sunnahBadge;
        }
      }
    }

    getIt<HomeWidgetSyncService>().syncWidgetData(
      nextPrayerName: localizedPrayerName,
      nextPrayerTime: formattedTime,
      nextPrayerCountdown: countdownStr,
      activeSlot: 'Barakah Window',
      dhikrCount: completedDhikr,
      hijriDate: hijriDateStr,
      fastingBadge: fastingBadgeStr,
      appTitle: l10n?.widgetAppTitle ?? 'Productive Muslim',
      nextPrayerLabel: l10n?.widgetNextPrayerLabel ?? 'Next Prayer',
      btnPrayers: l10n?.widgetBtnPrayers ?? 'Prayers',
      btnAdhkar: l10n?.widgetBtnAdhkar ?? 'Adhkar',
      btnFocus: l10n?.widgetBtnFocus ?? 'Focus',
      btnPlusOne: l10n?.widgetBtnPlusOne ?? '+1',
    );
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

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

String _getLocalizedPrayerName(String key, AppLocalizations l10n) {
  return switch (key.toLowerCase()) {
    'fajr' => l10n.fajr,
    'sunrise' => l10n.sunrise,
    'dhuhr' => l10n.dhuhr,
    'asr' => l10n.asr,
    'maghrib' => l10n.maghrib,
    'isha' => l10n.isha,
    _ => key,
  };
}
