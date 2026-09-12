import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:productive_muslim/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

void main() {
  testWidgets('renders welcome step with title and subtitle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Build your day around what matters'), findsOneWidget);
    expect(
      find.text('Prayer, tasks, habits, and intentions — together in one space'),
      findsOneWidget,
    );
  });

  testWidgets('advances to name step when Continue is tapped', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('What is your name?'), findsOneWidget);
  });

  testWidgets('advances to intention step', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Step 1 → 2
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    // Step 2 → 3
    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();

    expect(find.text('What brings you today?'), findsOneWidget);
    expect(find.text('Seeking barakah in my time'), findsOneWidget);
    expect(find.text('Consistent worship & routine'), findsOneWidget);
    expect(find.text('Mindful productivity'), findsOneWidget);
  });

  testWidgets('advances to prayer time step', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Step 1 → 2
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    // Step 2 → 3
    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();
    // Step 3 → 4
    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();

    expect(
      find.text('Set up prayer times'),
      findsOneWidget,
    );
    expect(
      find.text('Get accurate adhan notifications for your location'),
      findsOneWidget,
    );
  });

  testWidgets('Start Your Day completes onboarding', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Advance through all 3 remaining steps
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Continue').last);
      await tester.pumpAndSettle();
    }

    expect(find.text('Start Your Day'), findsOneWidget);
  });

  testWidgets('renders step indicator with 4 segments', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Each step indicator is a Container with height 4 inside a Row
    final row = find.byType(Row).evaluate().first;
    final children = row.children;
    expect(children.length, equals(4));
  });

  testWidgets('renders in Arabic locale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('المسلم المنتج'), findsOneWidget);
  });
}