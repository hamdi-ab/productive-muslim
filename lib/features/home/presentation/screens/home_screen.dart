import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/floating_glass_nav_bar.dart';
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
        icon: Icons.task_alt_outlined,
        activeIcon: Icons.task_alt_rounded,
        label: l10n.tasks,
      ),
      FloatingNavItem(
        icon: Icons.published_with_changes_outlined,
        activeIcon: Icons.published_with_changes_rounded,
        label: l10n.habits,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isSubPage = location == '/settings' || location == '/prayer-times';

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        scrolledUnderElevation: 2,
        titleSpacing: isSubPage ? 0 : 16,
        leading: isSubPage
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              )
            : null,
        backgroundColor: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.85),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(headerInfo.icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                headerInfo.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          _PrayerHeaderChip(service: prayerService),
          if (location == '/barakah')
            IconButton(
              key: const Key('open-review'),
              tooltip: l10n.barakahWeeklyTitle,
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () => context.push('/barakah/review'),
            ),
          if (location != '/settings')
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: l10n.settings,
              onPressed: () => context.go('/settings'),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Padding(padding: const EdgeInsets.only(bottom: 80), child: child),
      bottomNavigationBar: FloatingGlassNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _navigateToIndex(context, index),
        items: navItems,
      ),
    );
  }

  static ({String title, IconData icon}) _getHeaderInfo(
    String location,
    AppLocalizations l10n,
  ) {
    return switch (location) {
      '/' => (title: l10n.appTitle, icon: Icons.nights_stay_rounded),
      '/tasks' => (title: l10n.tasks, icon: Icons.task_alt_rounded),
      '/habits' => (
        title: l10n.habits,
        icon: Icons.published_with_changes_rounded,
      ),
      '/barakah' => (title: l10n.barakah, icon: Icons.auto_awesome_rounded),
      '/journal' => (title: l10n.journal, icon: Icons.menu_book_rounded),
      '/settings' => (title: l10n.settings, icon: Icons.settings_rounded),
      '/prayer-times' => (title: l10n.prayerTimes, icon: Icons.mosque_rounded),
      _ => (title: l10n.appTitle, icon: Icons.nights_stay_rounded),
    };
  }

  static int _getIndexForLocation(String location) {
    return switch (location) {
      '/' => 0,
      '/tasks' => 1,
      '/habits' => 2,
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
        context.go('/tasks');
        break;
      case 2:
        context.go('/habits');
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

class _PrayerHeaderChip extends StatefulWidget {
  final PrayerTimeService? service;

  const _PrayerHeaderChip({required this.service});

  @override
  State<_PrayerHeaderChip> createState() => _PrayerHeaderChipState();
}

class _PrayerHeaderChipState extends State<_PrayerHeaderChip> {
  String _nextPrayer = '';
  String _countdown = '';
  bool _loading = true;
  Timer? _timer;
  PrayerTimes? _cachedPrayerTimes;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    if (widget.service == null) {
      if (mounted) {
        setState(() {
          _nextPrayer = '--';
          _countdown = '--:--';
          _loading = false;
        });
      }
      return;
    }

    final position = await widget.service!.getCurrentPosition();
    if (!mounted) return;
    if (position == null) {
      setState(() {
        _nextPrayer = '--';
        _countdown = '--:--';
        _loading = false;
      });
      return;
    }

    _cachedPrayerTimes = widget.service!.getPrayerTimes(position);
    _updatePrayerCountdown();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updatePrayerCountdown();
    });
  }

  void _updatePrayerCountdown() {
    if (_cachedPrayerTimes == null || widget.service == null) {
      return;
    }

    final nextPrayer = widget.service!.getNextPrayerName(_cachedPrayerTimes!);
    final timeUntil = widget.service!.getTimeUntilNextPrayer(
      _cachedPrayerTimes!,
    );

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
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes >= 10) {
      return '${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: l10n.nextPrayer,
      child: InkWell(
        onTap: () => context.push('/prayer-times'),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: isDark ? 0.2 : 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time_filled_rounded,
                size: 15,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              if (_loading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Flexible(
                  child: Text(
                    '${_getLocalizedPrayerName(_nextPrayer, l10n)} $_countdown',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
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
