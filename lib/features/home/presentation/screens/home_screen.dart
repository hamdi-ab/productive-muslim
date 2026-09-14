import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  final PrayerTimeService? prayerTimeService;

  const HomeScreen({super.key, required this.child, this.prayerTimeService});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: child,
      bottomSheet: _PrayerCountdownSheet(
        service: prayerTimeService ?? PrayerTimeService(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getIndexForLocation(location),
        onTap: (index) => _navigateToIndex(context, index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle_outlined),
            label: l10n.tasks,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.repeat_outlined),
            label: l10n.habits,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.spa_outlined),
            label: l10n.barakah,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book_outlined),
            label: l10n.journal,
          ),
        ],
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
  final PrayerTimeService service;

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
    final position = await widget.service.getCurrentPosition();
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

    final prayerTimes = widget.service.getPrayerTimes(position);
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

    final nextPrayer = widget.service.getNextPrayerName(prayerTimes);
    final timeUntil = widget.service.getTimeUntilNextPrayer(prayerTimes);

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        spacing: 12,
        children: [
          const Icon(Icons.access_time_outlined, size: 20),
          Text(l10n.nextPrayer),
          const Spacer(),
          if (_loading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text('$_nextPrayer in $_countdown'),
        ],
      ),
    );
  }
}
