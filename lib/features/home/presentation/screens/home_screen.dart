import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_router.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/floating_glass_nav_bar.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:intl/intl.dart';
import 'package:productive_muslim/data/services/home_widget_sync_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
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
        icon: Icons.flare_outlined,
        activeIcon: Icons.flare_rounded,
        label: l10n.adhkar,
      ),
      FloatingNavItem(
        icon: Icons.checklist_rtl_outlined,
        activeIcon: Icons.checklist_rtl_rounded,
        label: l10n.myDay,
      ),
      FloatingNavItem(
        icon: Icons.mosque_outlined,
        activeIcon: Icons.mosque_rounded,
        label: l10n.prayerTimes,
      ),
      FloatingNavItem(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book_rounded,
        label: l10n.reflect,
      ),
    ];

    final currentIndex = _getIndexForLocation(location);
    final headerInfo = _getHeaderInfo(location, l10n);
    final isHome = location == AppRoutes.home;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    String? subtitle;
    if (isHome) {
      final now = DateTime.now();
      final gregorianStr = DateFormat(
        'EEEE, d MMM',
        isAr ? 'ar' : 'en',
      ).format(now);
      if (getIt.isRegistered<HijriService>()) {
        final hijri = getIt<HijriService>().getHijriDate(now);
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
          subtitle = '$gregorianStr • $hijriStr • 🌙 $badge';
        } else {
          subtitle = '$gregorianStr • $hijriStr';
        }
      } else {
        subtitle = gregorianStr;
      }
    } else {
      subtitle = _getSubtitleForLocation(location, l10n, prayerService, isAr);
    }

    final Widget? homeLeading = isHome
        ? Padding(
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: Center(
              child: Tooltip(
                message: l10n.profile,
                child: AppPressable(
                  onTap: () => context.go(AppRoutes.profile),
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

    final isBarakah = location == AppRoutes.barakah;
    final hasNotificationFallback = AppRouter.hasNotificationFallback;
    final shouldShowBack = (!isHome && hasNotificationFallback) || isBarakah;

    return PopScope(
      canPop: isHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !isHome) {
          final fallback =
              AppRouter.consumeNotificationFallbackLocation() ?? AppRoutes.home;
          context.go(fallback);
        }
      },
      child: Scaffold(
        extendBody: true,
        appBar: ProductiveAppBar(
          title: headerInfo.title,
          subtitle: subtitle,
          leading: homeLeading,
          leadingIcon: isHome ? null : headerInfo.icon,
          showBackButton: shouldShowBack,
          onBackPressed: shouldShowBack
              ? () {
                  final fallback =
                      AppRouter.consumeNotificationFallbackLocation() ??
                      AppRoutes.home;
                  context.go(fallback);
                }
              : null,
          actions: [
            if (isHome) ...[
              ProductiveAppBarAction(
                icon: Icons.settings_outlined,
                tooltip: l10n.settings,
                onTap: () => context.push(AppRoutes.settings),
              ),
            ] else if (location.startsWith(AppRoutes.adhkar)) ...[
              ProductiveAppBarAction(
                key: const Key('open-adhkar-explore'),
                tooltip: l10n.adhkarExploreTitle,
                icon: Icons.explore_outlined,
                onTap: () => context.push(AppRoutes.adhkarExplore),
              ),
            ] else if (location.startsWith(AppRoutes.reflect) ||
                location == AppRoutes.barakah ||
                location == AppRoutes.journal) ...[
              ProductiveAppBarAction(
                key: const Key('open-review'),
                tooltip: l10n.barakahWeeklyTitle,
                icon: Icons.calendar_month_outlined,
                onTap: () => context.push(AppRoutes.barakahReview),
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
      ),
    );
  }

  static String? _getSubtitleForLocation(
    String location,
    AppLocalizations l10n,
    PrayerTimeService? prayerService,
    bool isAr,
  ) {
    if (location.startsWith(AppRoutes.adhkar)) {
      return l10n.adhkarSubtitle;
    }
    if (location.startsWith(AppRoutes.myDay) ||
        location == AppRoutes.plan ||
        location == AppRoutes.tasks ||
        location == AppRoutes.habits) {
      return isAr ? 'المهام والعادات والتركيز' : 'Tasks, Habits & Focus';
    }
    if (location.startsWith(AppRoutes.prayerTimes)) {
      return prayerService?.cachedLocationName != null &&
              prayerService!.cachedLocationName!.isNotEmpty
          ? '📍 ${prayerService.cachedLocationName}'
          : null;
    }
    if (location.startsWith(AppRoutes.reflect) ||
        location == AppRoutes.journal ||
        location == AppRoutes.intentions) {
      return isAr ? 'محاسبة النفس والتأمل' : 'Muhasabah & Reflection';
    }
    if (location.startsWith(AppRoutes.barakah)) {
      return isAr ? 'البركة والنمو' : 'Barakah & Growth';
    }
    if (location.startsWith(AppRoutes.profile)) {
      return l10n.profileSubtitle;
    }
    return null;
  }

  static String _getHomeGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = l10n.goodMorning;
    } else if (hour < 17) {
      greeting = l10n.goodAfternoon;
    } else {
      greeting = l10n.goodEvening;
    }

    try {
      if (getIt.isRegistered<SettingsService>()) {
        final name = getIt<SettingsService>().userName;
        if (name != null && name.trim().isNotEmpty) {
          greeting = l10n.homeGreeting(name.trim());
        }
      }
    } catch (_) {}

    return greeting;
  }

  static ({String title, IconData icon}) _getHeaderInfo(
    String location,
    AppLocalizations l10n,
  ) {
    if (location == AppRoutes.home) {
      return (title: _getHomeGreeting(l10n), icon: Icons.nights_stay_rounded);
    }
    if (location.startsWith(AppRoutes.adhkar)) {
      return (title: l10n.adhkarTitle, icon: Icons.flare_rounded);
    }
    if (location.startsWith(AppRoutes.myDay) ||
        location == AppRoutes.plan ||
        location == AppRoutes.tasks ||
        location == AppRoutes.habits) {
      return (title: l10n.myDay, icon: Icons.checklist_rtl_rounded);
    }
    if (location.startsWith(AppRoutes.prayerTimes)) {
      return (title: l10n.prayerTimes, icon: Icons.mosque_rounded);
    }
    if (location.startsWith(AppRoutes.reflect) ||
        location == AppRoutes.journal ||
        location == AppRoutes.intentions ||
        location.startsWith(AppRoutes.barakah)) {
      return (title: l10n.reflect, icon: Icons.menu_book_rounded);
    }
    if (location.startsWith(AppRoutes.profile)) {
      return (title: l10n.profile, icon: Icons.person_rounded);
    }
    return (title: l10n.appTitle, icon: Icons.nights_stay_rounded);
  }

  static int _getIndexForLocation(String location) {
    if (location == AppRoutes.home) return 0;
    if (location.startsWith(AppRoutes.adhkar)) return 1;
    if (location.startsWith(AppRoutes.myDay) ||
        location == AppRoutes.plan ||
        location == AppRoutes.tasks ||
        location == AppRoutes.habits) {
      return 2;
    }
    if (location.startsWith(AppRoutes.prayerTimes)) return 3;
    if (location.startsWith(AppRoutes.reflect) ||
        location == AppRoutes.journal ||
        location == AppRoutes.intentions ||
        location.startsWith(AppRoutes.barakah)) {
      return 4;
    }
    return 0;
  }

  static void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.adhkar);
        break;
      case 2:
        context.go(AppRoutes.myDay);
        break;
      case 3:
        context.go(AppRoutes.prayerTimes);
        break;
      case 4:
        context.go(AppRoutes.reflect);
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
