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
import 'package:productive_muslim/features/tasks/presentation/screens/task_screen.dart';
import 'package:productive_muslim/features/habits/presentation/screens/habit_screen.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_screen.dart';
import 'package:productive_muslim/features/intentions/presentation/screens/intention_screen.dart';

class AppRouter {
  AppRouter._();

  static bool _pendingBarakahReminder = false;

  static void openBarakahReminder() {
    _pendingBarakahReminder = true;
    router.go('/barakah');
  }

  static bool _isOnboardingDone() {
    try {
      return getIt<SettingsService>().onboardingCompleted;
    } catch (_) {
      return false;
    }
  }

  static final GoRouter router = GoRouter(
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
      ShellRoute(
        builder: (context, state, child) =>
            getIt.isRegistered<BarakahReminderService>()
            ? BarakahReminderLifecycle(
                service: getIt<BarakahReminderService>(),
                child: child,
              )
            : child,
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (context, state) {
              try {
                return OnboardingScreen(settings: getIt<SettingsService>());
              } catch (_) {
                return const OnboardingScreen();
              }
            },
          ),
          ShellRoute(
            builder: (context, state, child) => HomeScreen(child: child),
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeContent(),
              ),
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TaskScreen(),
              ),
              GoRoute(
                path: '/habits',
                builder: (context, state) => const HabitScreen(),
              ),
              GoRoute(
                path: '/barakah',
                builder: (context, state) => const BarakahScreen(),
              ),
              GoRoute(
                path: '/journal',
                builder: (context, state) => const IntentionScreen(),
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(child: Text('Route not found: ${state.uri.path}')),
    ),
  );
}
