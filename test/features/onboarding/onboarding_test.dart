import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:productive_muslim/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

void main() {
  AppLocalizations l10n(WidgetTester tester) => AppLocalizations.of(
        tester.element(find.byType(OnboardingScreen)),
      )!;

  testWidgets('renders welcome step with title and subtitle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n(tester).onboardingWelcomeTitle), findsOneWidget);
    expect(find.text(l10n(tester).onboardingWelcomeSubtitle), findsOneWidget);
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

    expect(find.text(l10n(tester).onboardingNameTitle), findsOneWidget);
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

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Ahmed');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();

    expect(find.text(l10n(tester).onboardingIntentionTitle), findsOneWidget);
    expect(find.text(l10n(tester).seekingBarakah), findsOneWidget);
    expect(find.text(l10n(tester).consistentWorship), findsOneWidget);
    expect(find.text(l10n(tester).mindfulProductivity), findsOneWidget);
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

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Ahmed');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n(tester).seekingBarakah));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();

    expect(find.text(l10n(tester).onboardingPermissionTitle), findsOneWidget);
    expect(find.text(l10n(tester).onboardingPermissionSubtitle), findsOneWidget);
  });

  testWidgets('last step shows Start Your Day button', (tester) async {
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

    await tester.enterText(find.byType(TextField), 'Ahmed');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n(tester).seekingBarakah));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();

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

    final containers = tester.widgetList<Container>(
      find.descendant(of: find.byType(Row), matching: find.byType(Container)),
    );
    expect(containers.length, equals(4));
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

    expect(find.text(l10n(tester).onboardingWelcomeTitle), findsOneWidget);
  });
}
