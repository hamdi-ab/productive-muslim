import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/energy/presentation/screens/energy_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

void main() {
  setUp(() {
    if (!getIt.isRegistered<SettingsService>()) {
      getIt.registerSingleton<SettingsService>(SettingsService.empty());
    }
  });

  Widget buildSubject() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: EnergyScreen(),
    );
  }

  testWidgets(
    'renders energy screen with ratings, Qaylulah, and fasting tracker',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Triple-Energy Management'), findsOneWidget);
      expect(find.text('Today\'s Energy Levels'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget);
    },
  );

  testWidgets('tapping Qaylulah start toggles nap timer to pause button', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final startBtn = find.text('Start Qaylulah Nap');
    expect(startBtn, findsOneWidget);

    await tester.ensureVisible(startBtn);
    await tester.tap(startBtn);
    await tester.pump();

    expect(find.text('Pause'), findsOneWidget);
  });

  testWidgets('tapping Fasting button navigates to FastingScreen', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/energy',
      routes: [
        GoRoute(path: '/energy', builder: (_, _) => const EnergyScreen()),
        GoRoute(
          path: AppRoutes.fasting,
          builder: (_, _) => const Scaffold(body: Text('Fasting Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();

    final hijriBtn = find.text('Hijri Calendar & Fasting');
    expect(hijriBtn, findsOneWidget);

    await tester.ensureVisible(hijriBtn);
    await tester.tap(hijriBtn);
    await tester.pumpAndSettle();

    expect(find.text('Fasting Screen'), findsOneWidget);
  });
}
