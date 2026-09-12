import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/features/home/presentation/screens/home_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

GoRouter _testRouter({required Widget child}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(child: child),
      ),
    ],
  );
}

void main() {
  testWidgets('renders app bar with app title', (tester) async {
    final router = _testRouter(child: const Center(child: Text('Home')));
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Productive Muslim'), findsOneWidget);
  });

  testWidgets('renders 5 bottom navigation items', (tester) async {
    final router = _testRouter(child: const Center(child: Text('Home')));
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsNWidgets(2)); // label + child
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Habits'), findsOneWidget);
    expect(find.text('Barakah'), findsOneWidget);
    expect(find.text('Journal'), findsOneWidget);
  });

  testWidgets('renders prayer countdown sheet at bottom', (tester) async {
    final router = _testRouter(child: const Center(child: Text('Home')));
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Next Prayer'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
  });

  testWidgets('settings button is rendered', (tester) async {
    final router = _testRouter(child: const Center(child: Text('Home')));
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });
}
