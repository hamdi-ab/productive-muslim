import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/fasting/presentation/screens/fasting_screen.dart';
import 'package:productive_muslim/features/fasting/presentation/widgets/fasting_countdown_card.dart';
import 'package:productive_muslim/features/fasting/presentation/widgets/hijri_calendar_view.dart';
import 'package:productive_muslim/features/fasting/presentation/widgets/iftar_dua_dialog.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

void main() {
  setUp(() {
    if (!getIt.isRegistered<SettingsService>()) {
      getIt.registerSingleton<SettingsService>(SettingsService.empty());
    }
    if (!getIt.isRegistered<HijriService>()) {
      getIt.registerSingleton<HijriService>(HijriService());
    }
  });

  Widget buildSubject({String language = 'en'}) {
    return MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const FastingScreen(),
    );
  }

  testWidgets(
    'renders FastingScreen with Hijri header, countdown and calendar grid',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(FastingScreen), findsOneWidget);
      expect(find.byType(FastingCountdownCard), findsOneWidget);
      expect(find.byType(HijriCalendarView), findsOneWidget);
      expect(find.text('Sunnah Fasting Guidelines'), findsOneWidget);
    },
  );

  testWidgets('tapping Iftar Du\'a button opens IftarDuaDialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: IftarDuaDialog()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sunnah Iftar Du\'a'), findsOneWidget);
    expect(
      find.text(
        'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
  });

  testWidgets('renders FastingScreen in Arabic locale', (tester) async {
    await tester.pumpWidget(buildSubject(language: 'ar'));
    await tester.pumpAndSettle();

    expect(find.text('التقويم الهجري وصيام السنة'), findsOneWidget);
    expect(find.text('الأيام البيض'), findsOneWidget);
  });

  testWidgets('renders Energy shortcut card and navigates to EnergyScreen', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/fasting',
      routes: [
        GoRoute(path: '/fasting', builder: (_, _) => const FastingScreen()),
        GoRoute(
          path: AppRoutes.energy,
          builder: (_, _) => const Scaffold(body: Text('Energy Screen')),
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

    final energyCard = find.byKey(const Key('fasting_energy_shortcut_card'));
    expect(energyCard, findsOneWidget);

    await tester.ensureVisible(energyCard);
    await tester.tap(energyCard);
    await tester.pumpAndSettle();

    expect(find.text('Energy Screen'), findsOneWidget);
  });
}
