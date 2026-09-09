import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: child,
      bottomSheet: const _PrayerCountdownSheet(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getIndexForLocation(location),
        onTap: (index) => _navigateToIndex(context, index),
        items: [
          BottomNavigationItem(
            icon: const Icon(Icons.home_outlined),
            label: l10n.home,
          ),
          BottomNavigationItem(
            icon: const Icon(Icons.check_circle_outlined),
            label: l10n.tasks,
          ),
          BottomNavigationItem(
            icon: const Icon(Icons.repeat_outlined),
            label: l10n.habits,
          ),
          BottomNavigationItem(
            icon: const Icon(Icons.spa_outlined),
            label: l10n.barakah,
          ),
          BottomNavigationItem(
            icon: const Icon(Icons.book_outlined),
            label: l10n.journal,
          ),
        ],
      ),
    );
  }

  static int _getIndexForLocation(String location) {
    switch (location) {
      case '/':
        return 0;
      case '/tasks':
        return 1;
      case '/habits':
        return 2;
      case '/barakah':
        return 3;
      case '/journal':
        return 4;
      default:
        return 0;
    }
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

class _PrayerCountdownSheet extends StatelessWidget {
  const _PrayerCountdownSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        spacing: 12,
        children: [
          const Icon(Icons.access_time_outlined, size: 20),
          Text(l10n.nextPrayer),
          const Spacer(),
          const Text('00:00:00'),
        ],
      ),
    );
  }
}