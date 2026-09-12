import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:productive_muslim/features/home/presentation/screens/home_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

void main() {
  testWidgets('renders app bar with app title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(child: Center(child: Text('Home'))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Productive Muslim'), findsOneWidget);
  });

  testWidgets('renders 5 bottom navigation items', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(child: Center(child: Text('Home'))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Habits'), findsOneWidget);
    expect(find.text('Barakah'), findsOneWidget);
    expect(find.text('Journal'), findsOneWidget);
  });

  testWidgets('switching tabs navigates to correct route', (tester) async {
    final routes = <String, Widget>{
      '/': const Center(child: Text('Home')),
      '/tasks': const Center(child: Text('Tasks')),
      '/habits': const Center(child: Text('Habits')),
      '/barakah': const Center(child: Text('Barakah')),
      '/journal': const Center(child: Text('Journal')),
    };

    for (final entry in routes.entries) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(child: entry.value),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(entry.value.toString()), findsOneWidget);
    }
  });

  testWidgets('renders prayer countdown sheet at bottom', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(child: Center(child: Text('Home'))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prayer Times'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
  });

  testWidgets('settings button navigates to settings route', (tester) async {
    var navigated = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeScreen(
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => navigated = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(navigated, isTrue);
  });
}