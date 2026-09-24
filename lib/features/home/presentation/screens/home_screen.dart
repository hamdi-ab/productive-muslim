import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/floating_glass_nav_bar.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
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

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.nights_stay_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.appTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 110),
              child: child,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: GestureDetector(
              onTap: () => context.push('/prayer-times'),
              child: _PrayerCountdownSheet(service: prayerService),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FloatingGlassNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _navigateToIndex(context, index),
        items: navItems,
      ),
    );
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

class _PrayerCountdownSheet extends StatefulWidget {
  final PrayerTimeService? service;

  const _PrayerCountdownSheet({required this.service});

  @override
  State<_PrayerCountdownSheet> createState() => _PrayerCountdownSheetState();
}

class _PrayerCountdownSheetState extends State<_PrayerCountdownSheet> {
  String _nextPrayer = '';
  String _countdown = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
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
    if (position == null) {
      if (mounted) {
        setState(() {
          _nextPrayer = '--';
          _countdown = '--:--';
          _loading = false;
        });
      }
      return;
    }

    final prayerTimes = widget.service!.getPrayerTimes(position);
    if (prayerTimes == null) {
      if (mounted) {
        setState(() {
          _nextPrayer = '--';
          _countdown = '--:--';
          _loading = false;
        });
      }
      return;
    }

    final nextPrayer = widget.service!.getNextPrayerName(prayerTimes);
    final timeUntil = widget.service!.getTimeUntilNextPrayer(prayerTimes);

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
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 20,
        blur: 15,
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time_rounded,
                size: 18,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.nextPrayer,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (_loading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_nextPrayer in $_countdown',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
