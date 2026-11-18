import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

import 'package:productive_muslim/core/widgets/floating_glass_nav_bar.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/home/presentation/screens/home_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockSettingsService extends Mock implements SettingsService {}

class MockPrayerTimeService extends PrayerTimeService {
  @override
  Future<Position?> getCurrentPosition() async => null;
}

GoRouter _testRouter({required Widget child, String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(child: child),
      ),
      GoRoute(
        path: '/prayer-times',
        builder: (context, state) => HomeScreen(child: child),
      ),
    ],
  );
}

void main() {
  setUp(() {
    GetIt.instance.registerLazySingleton<PrayerTimeService>(
      () => MockPrayerTimeService(),
    );
  });

  tearDown(() {
    GetIt.instance.unregister<PrayerTimeService>();
  });

  testWidgets('renders app bar with greeting and dual calendar date', (
    tester,
  ) async {
    final router = _testRouter(child: const Center(child: Text('Home')));
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(tester.element(find.byType(HomeScreen)))!;
    final expectedGreeting = hour < 12
        ? l10n.goodMorning
        : (hour < 17 ? l10n.goodAfternoon : l10n.goodEvening);

    expect(find.text(expectedGreeting), findsOneWidget);

    final gregorianPrefix = DateFormat('EEEE, d MMM').format(DateTime.now());
    expect(find.textContaining(gregorianPrefix), findsOneWidget);
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

    expect(find.byType(FloatingGlassNavBar), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
    expect(find.byIcon(Icons.flare_outlined), findsOneWidget);
    expect(find.byIcon(Icons.checklist_rtl_outlined), findsOneWidget);
    expect(find.byIcon(Icons.mosque_outlined), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
  });

  testWidgets(
    'does not render streak badge on home app bar but renders profile avatar',
    (tester) async {
      final router = _testRouter(child: const Center(child: Text('Home')));
      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_streak_badge')), findsNothing);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsNothing);
      expect(find.byIcon(Icons.spa_rounded), findsOneWidget);
    },
  );

  testWidgets('renders personalized greeting when user name is available', (
    tester,
  ) async {
    final mockSettings = MockSettingsService();
    when(() => mockSettings.userName).thenReturn('Hamdi');
    GetIt.instance.registerSingleton<SettingsService>(mockSettings);

    final router = _testRouter(child: const Center(child: Text('Home')));
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Hamdi'), findsOneWidget);
    GetIt.instance.unregister<SettingsService>();
  });

  testWidgets('settings button is rendered on home app bar', (tester) async {
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

  testWidgets('secondary tab (prayer-times) does not render settings button', (
    tester,
  ) async {
    final router = _testRouter(
      child: const Center(child: Text('Prayer Times')),
      initialLocation: '/prayer-times',
    );
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.settings_outlined), findsNothing);
  });
}
