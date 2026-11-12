import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/features/settings/presentation/barakah_reminder_lifecycle.dart';
import 'package:productive_muslim/features/settings/presentation/screens/settings_screen.dart';
import 'package:productive_muslim/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:productive_muslim/features/home/presentation/screens/home_screen.dart';
import 'package:productive_muslim/features/home/presentation/screens/home_content.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_screen.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/features/intentions/presentation/screens/intention_screen.dart';
import 'package:productive_muslim/features/profile/presentation/screens/profile_screen.dart';
import 'package:productive_muslim/features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/plan_screen.dart';
import 'package:productive_muslim/features/focus/presentation/screens/focus_screen.dart';
import 'package:productive_muslim/features/energy/presentation/screens/energy_screen.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_screen.dart';
import 'package:productive_muslim/features/fasting/presentation/screens/fasting_screen.dart';

import 'package:productive_muslim/features/barakah/presentation/screens/barakah_review_screen.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static bool _pendingBarakahReminder = false;

  static String? _previousLocationBeforeNotification;

  static String? consumeNotificationFallbackLocation() {
    final loc = _previousLocationBeforeNotification;
    _previousLocationBeforeNotification = null;
    return loc;
  }

  static void openBarakahReminder() {
    try {
      final currentUri = router.routeInformationProvider.value.uri.toString();
      if (currentUri.isNotEmpty &&
          currentUri != '/barakah' &&
          !currentUri.contains('onboarding')) {
        _previousLocationBeforeNotification = currentUri;
      }
    } catch (_) {}
    _pendingBarakahReminder = true;
    router.go('/barakah');
  }

  static void handleNotificationPayload(String payload) {
    if (payload.isEmpty) return;

    try {
      final currentUri = router.routeInformationProvider.value.uri.toString();
      if (currentUri.isNotEmpty &&
          currentUri != payload &&
          !currentUri.contains('onboarding')) {
        _previousLocationBeforeNotification = currentUri;
      }
    } catch (_) {}

    if (payload == '/barakah') {
      openBarakahReminder();
      return;
    }

    final uri = Uri.tryParse(payload);
    final path = uri?.path.toLowerCase() ?? payload;
    if (path == '/intentions') {
      router.go('/journal');
    } else {
      router.go(payload);
    }
  }

  static void handleDeepLinkUri(Uri uri) {
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();

    if (host == 'prayer_times' ||
        host == 'prayer-times' ||
        path == '/prayer-times' ||
        path == '/prayer_times') {
      router.go('/prayer-times');
    } else if (host == 'adhkar' || path == '/adhkar') {
      final query = uri.hasQuery ? '?${uri.query}' : '';
      handleNotificationPayload('/adhkar$query');
    } else if (host == 'focus' || path == '/focus') {
      handleNotificationPayload('/focus');
    } else if (host == 'energy' || path == '/energy') {
      handleNotificationPayload('/energy');
    } else if (host == 'fasting' || path == '/fasting') {
      handleNotificationPayload('/fasting');
    } else if (host == 'profile' || path == '/profile') {
      router.go('/profile');
    } else if (host == 'barakah' || path == '/barakah') {
      handleNotificationPayload('/barakah');
    } else if (host == 'tasks' || path == '/tasks') {
      router.go('/tasks');
    } else if (host == 'habits' ||
        path == '/habits' ||
        host == 'streak' ||
        path == '/streak') {
      router.go('/habits');
    } else if (host == 'journal' ||
        path == '/journal' ||
        host == 'intentions' ||
        path == '/intentions') {
      router.go('/journal');
    } else if (host == 'settings' || path == '/settings') {
      handleNotificationPayload('/settings');
    } else if (host == 'home' ||
        host.isEmpty ||
        path == '/' ||
        path == '/home') {
      router.go('/');
    } else if (path.isNotEmpty) {
      handleNotificationPayload(path);
    }
  }

  static bool _isOnboardingDone() {
    try {
      return getIt<SettingsService>().onboardingCompleted;
    } catch (_) {
      return false;
    }
  }

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final onboardingDone = _isOnboardingDone();
      final goingToOnboarding = state.matchedLocation == '/onboarding';

      if (!onboardingDone && !goingToOnboarding) return '/onboarding';
      if (onboardingDone && _pendingBarakahReminder) {
        _pendingBarakahReminder = false;
        return state.matchedLocation == '/barakah' ? null : '/barakah';
      }
      if (onboardingDone && goingToOnboarding) return '/';
      return null;
    },
    routes: [
      // 1. Primary Bottom Navigation Shell (Top-level Tabs)
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) =>
            getIt.isRegistered<BarakahReminderService>()
            ? BarakahReminderLifecycle(
                service: getIt<BarakahReminderService>(),
                child: HomeScreen(child: child),
              )
            : HomeScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeContent()),
          GoRoute(
            path: '/plan',
            builder: (context, state) => const PlanScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) =>
                const PlanScreen(initialTab: PlanTab.tasks),
          ),
          GoRoute(
            path: '/habits',
            builder: (context, state) =>
                const PlanScreen(initialTab: PlanTab.habits),
          ),
          GoRoute(
            path: '/prayer-times',
            builder: (context, state) => const PrayerTimesScreen(),
          ),
          GoRoute(
            path: '/journal',
            builder: (context, state) => const IntentionScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/barakah',
            builder: (context, state) => const BarakahScreen(),
          ),
        ],
      ),
      // Redirect aliases
      GoRoute(path: '/intentions', redirect: (context, state) => '/journal'),
      GoRoute(
        path: '/prayer_times',
        redirect: (context, state) => '/prayer-times',
      ),
      GoRoute(path: '/streak', redirect: (context, state) => '/habits'),

      // 2. Subpages / Detail Screens (Full-Screen, NO Bottom Navigation)
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          try {
            return OnboardingScreen(settings: getIt<SettingsService>());
          } catch (_) {
            return const OnboardingScreen();
          }
        },
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/focus',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => FocusScreen(
          initialTask: state.extra is Task ? state.extra as Task : null,
        ),
      ),
      GoRoute(
        path: '/energy',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EnergyScreen(),
      ),
      GoRoute(
        path: '/fasting',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FastingScreen(),
      ),
      GoRoute(
        path: '/adhkar',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          DhikrCategory category = DhikrCategory.morning;
          if (state.extra is DhikrCategory) {
            category = state.extra as DhikrCategory;
          } else {
            final queryCat = state.uri.queryParameters['category'];
            if (queryCat != null) {
              category = DhikrCategory.values.firstWhere(
                (c) => c.name.toLowerCase() == queryCat.toLowerCase(),
                orElse: () => DhikrCategory.morning,
              );
            }
          }
          return AdhkarScreen(initialCategory: category);
        },
      ),
      GoRoute(
        path: '/barakah/review',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const BarakahReviewScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(child: Text('Route not found: ${state.uri.path}')),
    ),
  );
}
