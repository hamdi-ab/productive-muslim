import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/widgets/floating_glass_nav_bar.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/features/home/presentation/screens/home_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockPrayerTimeService extends PrayerTimeService {
  @override
  Future<Position?> getCurrentPosition() async => null;
}

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
    expect(find.byIcon(Icons.task_alt_outlined), findsOneWidget);
    expect(find.byIcon(Icons.published_with_changes_outlined), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
  });

  testWidgets('renders prayer header chip in app bar', (tester) async {
    final router = _testRouter(child: const Center(child: Text('Home')));
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Next Prayer'), findsOneWidget);
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
