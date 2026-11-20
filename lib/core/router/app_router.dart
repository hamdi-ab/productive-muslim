import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_routes.dart';

export 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/features/settings/presentation/barakah_reminder_lifecycle.dart';
import 'package:productive_muslim/features/settings/presentation/screens/settings_screen.dart';
import 'package:productive_muslim/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:productive_muslim/features/home/presentation/screens/home_screen.dart';
import 'package:productive_muslim/features/home/presentation/screens/home_content.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/features/profile/presentation/screens/profile_screen.dart';
import 'package:productive_muslim/features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/plan_screen.dart';
import 'package:productive_muslim/features/focus/presentation/screens/focus_screen.dart';
import 'package:productive_muslim/features/energy/presentation/screens/energy_screen.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_screen.dart';
import 'package:productive_muslim/domain/models/adhkar_routine.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_explore_screen.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_routines_screen.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_routine_edit_screen.dart';
import 'package:productive_muslim/features/fasting/presentation/screens/fasting_screen.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_review_screen.dart';
import 'package:productive_muslim/features/reflect/presentation/screens/reflect_screen.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static bool _pendingBarakahReminder = false;

  static String? _previousLocationBeforeNotification;

  static bool get hasNotificationFallback =>
      _previousLocationBeforeNotification != null;

  static String? consumeNotificationFallbackLocation() {
    final loc = _previousLocationBeforeNotification;
    _previousLocationBeforeNotification = null;
    return loc;
  }

  @visibleForTesting
  static void resetForTesting() {
    _previousLocationBeforeNotification = null;
    _pendingBarakahReminder = false;
  }

  static void openBarakahReminder() {
    try {
      final currentUri = router.routeInformationProvider.value.uri.toString();
      if (currentUri.isNotEmpty &&
          currentUri != AppRoutes.barakah &&
          currentUri != AppRoutes.reflectBarakah &&
          !currentUri.contains(AppRoutes.onboarding)) {
        _previousLocationBeforeNotification = currentUri;
      }
    } catch (_) {}
    _pendingBarakahReminder = true;
    router.go(AppRoutes.barakah);
  }

  static void handleNotificationPayload(String payload) {
    if (payload.isEmpty) return;

    try {
      final currentUri = router.routeInformationProvider.value.uri.toString();
      if (currentUri.isNotEmpty &&
          currentUri != payload &&
          !currentUri.contains(AppRoutes.onboarding)) {
        _previousLocationBeforeNotification = currentUri;
      }
    } catch (_) {}

    if (payload == AppRoutes.barakah) {
      openBarakahReminder();
      return;
    }

    final uri = Uri.tryParse(payload);
    final path = uri?.path.toLowerCase() ?? payload;
    if (path == AppRoutes.intentions || path == AppRoutes.journal) {
      router.go(AppRoutes.reflect);
    } else if (path == AppRoutes.plan) {
      router.go(AppRoutes.myDay);
    } else {
      router.go(payload);
    }
  }

  static void handleDeepLinkUri(Uri uri) {
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();

    if (host == 'prayer_times' ||
        host == 'prayer-times' ||
        path == AppRoutes.prayerTimes ||
        path == AppRoutes.prayerTimesUnderscore) {
      router.go(AppRoutes.prayerTimes);
    } else if (host == 'adhkar' || path == AppRoutes.adhkar) {
      final query = uri.hasQuery ? '?${uri.query}' : '';
      handleNotificationPayload('${AppRoutes.adhkar}$query');
    } else if (host == 'focus' || path == AppRoutes.focus) {
      handleNotificationPayload(AppRoutes.focus);
    } else if (host == 'energy' || path == AppRoutes.energy) {
      handleNotificationPayload(AppRoutes.energy);
    } else if (host == 'fasting' || path == AppRoutes.fasting) {
      handleNotificationPayload(AppRoutes.fasting);
    } else if (host == 'profile' || path == AppRoutes.profile) {
      router.go(AppRoutes.profile);
    } else if (host == 'barakah' || path == AppRoutes.barakah) {
      handleNotificationPayload(AppRoutes.barakah);
    } else if (host == 'tasks' || path == AppRoutes.tasks) {
      router.go(AppRoutes.tasks);
    } else if (host == 'habits' ||
        path == AppRoutes.habits ||
        host == 'streak' ||
        path == AppRoutes.streak) {
      router.go(AppRoutes.habits);
    } else if (host == 'my-day' ||
        host == 'my_day' ||
        host == 'plan' ||
        path == AppRoutes.myDay ||
        path == AppRoutes.plan) {
      router.go(AppRoutes.myDay);
    } else if (host == 'reflect' ||
        host == 'journal' ||
        path == AppRoutes.reflect ||
        path == AppRoutes.journal ||
        host == 'intentions' ||
        path == AppRoutes.intentions) {
      router.go(AppRoutes.reflect);
    } else if (host == 'settings' || path == AppRoutes.settings) {
      handleNotificationPayload(AppRoutes.settings);
    } else if (host == 'home' ||
        host.isEmpty ||
        path == AppRoutes.home ||
        path == '/home') {
      router.go(AppRoutes.home);
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
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final onboardingDone = _isOnboardingDone();
      final goingToOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (!onboardingDone && !goingToOnboarding) return AppRoutes.onboarding;
      if (onboardingDone && _pendingBarakahReminder) {
        _pendingBarakahReminder = false;
        return state.matchedLocation == AppRoutes.barakah ||
                state.matchedLocation == AppRoutes.reflectBarakah
            ? null
            : AppRoutes.barakah;
      }
      if (onboardingDone && goingToOnboarding) return AppRoutes.home;
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
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeContent(),
          ),
          GoRoute(
            path: AppRoutes.adhkar,
            builder: (context, state) {
              DhikrCategory category = DhikrCategory.morning;
              if (state.extra is DhikrCategory) {
                category = state.extra as DhikrCategory;
              } else if (state.extra is Map &&
                  (state.extra as Map)['category'] is DhikrCategory) {
                category = (state.extra as Map)['category'] as DhikrCategory;
              } else {
                final queryCat = state.uri.queryParameters['category'];
                if (queryCat != null) {
                  category = DhikrCategory.values.firstWhere(
                    (c) => c.name.toLowerCase() == queryCat.toLowerCase(),
                    orElse: () => DhikrCategory.morning,
                  );
                }
              }

              String? itemId;
              if (state.extra is Map &&
                  (state.extra as Map)['itemId'] is String) {
                itemId = (state.extra as Map)['itemId'] as String;
              } else {
                itemId = state.uri.queryParameters['itemId'];
              }

              bool? isReviewMode;
              final settingsService = getIt.isRegistered<SettingsService>()
                  ? getIt<SettingsService>()
                  : null;
              final isAvailable =
                  settingsService?.isAdhkarReviewModeAvailable ?? !kReleaseMode;
              if (isAvailable) {
                if (state.extra is Map &&
                    (state.extra as Map)['reviewMode'] is bool) {
                  isReviewMode = (state.extra as Map)['reviewMode'] as bool;
                } else if (state.uri.queryParameters['reviewMode'] == 'true' ||
                    state.uri.queryParameters['internalReview'] == 'true') {
                  isReviewMode = true;
                }
              }
              String? routineId;
              if (state.extra is Map &&
                  (state.extra as Map)['routineId'] is String) {
                routineId = (state.extra as Map)['routineId'] as String;
              } else {
                routineId = state.uri.queryParameters['routineId'];
              }

              return AdhkarScreen(
                initialCategory: category,
                initialItemId: itemId,
                initialRoutineId: routineId,
                isReviewModeEnabled: isReviewMode,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.myDay,
            builder: (context, state) => const PlanScreen(),
          ),
          GoRoute(
            path: AppRoutes.myDayTasks,
            builder: (context, state) =>
                const PlanScreen(initialTab: PlanTab.tasks),
          ),
          GoRoute(
            path: AppRoutes.myDayHabits,
            builder: (context, state) =>
                const PlanScreen(initialTab: PlanTab.habits),
          ),
          GoRoute(
            path: AppRoutes.myDayFocus,
            builder: (context, state) =>
                const PlanScreen(initialTab: PlanTab.focus),
          ),
          GoRoute(
            path: AppRoutes.plan,
            builder: (context, state) => const PlanScreen(),
          ),
          GoRoute(
            path: AppRoutes.tasks,
            builder: (context, state) =>
                const PlanScreen(initialTab: PlanTab.tasks),
          ),
          GoRoute(
            path: AppRoutes.habits,
            builder: (context, state) =>
                const PlanScreen(initialTab: PlanTab.habits),
          ),
          GoRoute(
            path: AppRoutes.prayerTimes,
            builder: (context, state) => const PrayerTimesScreen(),
          ),
          GoRoute(
            path: AppRoutes.reflect,
            builder: (context, state) => const ReflectScreen(),
          ),
          GoRoute(
            path: AppRoutes.reflectMuhasabah,
            builder: (context, state) =>
                const ReflectScreen(initialTab: ReflectTab.muhasabah),
          ),
          GoRoute(
            path: AppRoutes.reflectBarakah,
            builder: (context, state) =>
                const ReflectScreen(initialTab: ReflectTab.barakah),
          ),
          GoRoute(
            path: AppRoutes.journal,
            builder: (context, state) =>
                const ReflectScreen(initialTab: ReflectTab.muhasabah),
          ),
          GoRoute(
            path: AppRoutes.barakah,
            builder: (context, state) =>
                const ReflectScreen(initialTab: ReflectTab.barakah),
          ),
        ],
      ),
      // Redirect aliases
      GoRoute(
        path: AppRoutes.intentions,
        redirect: (context, state) => AppRoutes.reflect,
      ),
      GoRoute(
        path: AppRoutes.prayerTimesUnderscore,
        redirect: (context, state) => AppRoutes.prayerTimes,
      ),
      GoRoute(
        path: AppRoutes.streak,
        redirect: (context, state) => AppRoutes.habits,
      ),

      // 2. Subpages / Detail Screens (Full-Screen, NO Bottom Navigation)
      GoRoute(
        path: AppRoutes.onboarding,
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
        path: AppRoutes.settings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.focus,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => FocusScreen(
          initialTask: state.extra is Task ? state.extra as Task : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.energy,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EnergyScreen(),
      ),
      GoRoute(
        path: AppRoutes.fasting,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FastingScreen(),
      ),
      GoRoute(
        path: AppRoutes.barakahReview,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const BarakahReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.adhkarExplore,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          bool? isReviewMode;
          if (state.extra is Map &&
              (state.extra as Map)['reviewMode'] is bool) {
            isReviewMode = (state.extra as Map)['reviewMode'] as bool;
          } else if (state.uri.queryParameters['reviewMode'] == 'true' ||
              state.uri.queryParameters['internalReview'] == 'true') {
            isReviewMode = true;
          }
          return AdhkarExploreScreen(isReviewModeEnabled: isReviewMode);
        },
      ),
      GoRoute(
        path: AppRoutes.adhkarRoutines,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AdhkarRoutinesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adhkarRoutineEdit,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final routine = state.extra is AdhkarRoutine
              ? state.extra as AdhkarRoutine
              : null;
          return AdhkarRoutineEditScreen(routine: routine);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(child: Text('Route not found: ${state.uri.path}')),
    ),
  );
}
