import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:productive_muslim/core/widgets/floating_glass_nav_bar.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/features/home/presentation/screens/home_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

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

    expect(find.byType(FloatingGlassNavBar), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
    expect(find.byIcon(Icons.flare_outlined), findsOneWidget);
    expect(find.byIcon(Icons.checklist_rtl_outlined), findsOneWidget);
    expect(find.byIcon(Icons.mosque_outlined), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
  });

  testWidgets('renders streak badge and avatar on home app bar', (
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

    expect(find.byKey(const Key('home_streak_badge')), findsOneWidget);
    expect(find.text('0d'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    expect(find.byIcon(Icons.spa_rounded), findsOneWidget);
  });

  testWidgets('renders dynamic streak from HabitRepository on home app bar', (
    tester,
  ) async {
    final mockHabitRepo = MockHabitRepository();
    when(() => mockHabitRepo.watchOverallStreak())
        .thenAnswer((_) => Stream.value(14));
    GetIt.instance.registerSingleton<HabitRepository>(mockHabitRepo);

    final router = _testRouter(child: const Center(child: Text('Home')));
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('14d'), findsOneWidget);
    GetIt.instance.unregister<HabitRepository>();
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
