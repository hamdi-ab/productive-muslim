import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:productive_muslim/features/home/presentation/screens/home_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) {
      // TODO: check onboarding_completed from SharedPreferences
      // If not completed and not on /onboarding, redirect to /onboarding
      // If completed and on /onboarding, redirect to /
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Center(child: Text('Home')),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const Center(child: Text('Tasks')),
          ),
          GoRoute(
            path: '/habits',
            builder: (context, state) => const Center(child: Text('Habits')),
          ),
          GoRoute(
            path: '/barakah',
            builder: (context, state) => const Center(child: Text('Barakah')),
          ),
          GoRoute(
            path: '/journal',
            builder: (context, state) => const Center(child: Text('Journal')),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              body: const Center(child: Text('Settings')),
            ),
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