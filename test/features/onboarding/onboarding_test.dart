import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsService settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settings = SettingsService(prefs: prefs);
  });

  Widget buildTestWidget({Locale? locale}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: OnboardingScreen(settings: settings),
    );
  }

  testWidgets('renders welcome step', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Build your day around what matters'), findsOneWidget);
    expect(
      find.text(
        'Strengthen your remembrance of Allah, organize around Salah, and live with intention',
      ),
      findsOneWidget,
    );
  });

  testWidgets('advances to name step', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('What is your name?'), findsOneWidget);
  });

  testWidgets('advances to intention step', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Ahmed');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();

    expect(find.text('What brings you today?'), findsOneWidget);
    expect(find.text('Seeking barakah in my time'), findsOneWidget);
  });

  testWidgets('advances to pillars step', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ahmed');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seeking barakah in my time'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();

    expect(find.text('Your Five Daily Pillars'), findsOneWidget);
    expect(find.text('Remember'), findsOneWidget);
    expect(find.text('Pray'), findsOneWidget);
    expect(find.text('Intend & Act'), findsOneWidget);
    expect(find.text('Reflect'), findsOneWidget);
    expect(find.text('Grow'), findsOneWidget);
  });

  testWidgets('advances to permission step', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ahmed');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seeking barakah in my time'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remember'));
    await tester.pumpAndSettle();

    final continueBtn3 = find.text('Continue').last;
    await tester.ensureVisible(continueBtn3);
    await tester.pumpAndSettle();
    await tester.tap(continueBtn3);
    await tester.pumpAndSettle();

    expect(find.text('Set up prayer times'), findsOneWidget);
  });

  testWidgets('last step shows Start Your Day', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ahmed');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seeking barakah in my time'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remember'));
    await tester.pumpAndSettle();

    final continueBtn4 = find.text('Continue').last;
    await tester.ensureVisible(continueBtn4);
    await tester.pumpAndSettle();
    await tester.tap(continueBtn4);
    await tester.pumpAndSettle();

    expect(find.text('Start Your Day'), findsOneWidget);
  });

  testWidgets('renders step indicator with 5 segments', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final indicatorRow = find.byKey(const Key('step_progress_indicator'));
    final containers = tester.widgetList<AnimatedContainer>(
      find.descendant(
        of: indicatorRow,
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect(containers.length, equals(5));
  });

  testWidgets('renders in Arabic locale', (tester) async {
    await tester.pumpWidget(buildTestWidget(locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('ابنِ يومك حول ما يهم'), findsOneWidget);
  });

  testWidgets('language toggle switches app language', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final arPill = find.text('العربية');
    expect(arPill, findsOneWidget);

    await tester.tap(arPill);
    await tester.pumpAndSettle();

    expect(settings.localeCode, 'ar');
    expect(settings.localeNotifier.value, const Locale('ar'));
  });
}
