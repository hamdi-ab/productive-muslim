import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:productive_muslim/data/local/daos/adhkar_dao.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/repositories/adhkar_repository_impl.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_adhkar_pill.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsService settingsService;
  late AdhkarService adhkarService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);
    adhkarService = AdhkarService(settingsService: settingsService);

    if (!GetIt.instance.isRegistered<SettingsService>()) {
      GetIt.instance.registerSingleton<SettingsService>(settingsService);
    }
    if (!GetIt.instance.isRegistered<AdhkarService>()) {
      GetIt.instance.registerSingleton<AdhkarService>(adhkarService);
    }
  });

  tearDown(() {
    if (GetIt.instance.isRegistered<SettingsService>()) {
      GetIt.instance.unregister<SettingsService>();
    }
    if (GetIt.instance.isRegistered<AdhkarService>()) {
      GetIt.instance.unregister<AdhkarService>();
    }
    if (GetIt.instance.isRegistered<AdhkarRepository>()) {
      GetIt.instance.unregister<AdhkarRepository>();
    }
    if (GetIt.instance.isRegistered<AdhkarDao>()) {
      GetIt.instance.unregister<AdhkarDao>();
    }
    if (GetIt.instance.isRegistered<AppDatabase>()) {
      GetIt.instance.unregister<AppDatabase>();
    }
  });

  testWidgets(
    'renders HomeAdhkarPill with active context and interacts properly',
    (tester) async {
      bool navigated = false;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: HomeAdhkarPill()),
          ),
          GoRoute(
            path: '/adhkar',
            builder: (context, state) {
              navigated = true;
              return const Scaffold(body: Text('Adhkar Screen Target'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeAdhkarPill), findsOneWidget);

      // Tap on the pill to navigate
      await tester.tap(find.byType(HomeAdhkarPill));
      await tester.pumpAndSettle();

      expect(navigated, isTrue);
      expect(find.text('Adhkar Screen Target'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeAdhkarPill reacts in real-time to SQLite Drift session updates (Single Source of Truth)',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final dao = AdhkarDao(db);
      final repo = AdhkarRepositoryImpl(
        adhkarDao: dao,
        settingsService: settingsService,
      );
      await repo.setReviewModeEnabled(true);

      GetIt.instance.registerSingleton<AppDatabase>(db);
      GetIt.instance.registerSingleton<AdhkarDao>(dao);
      GetIt.instance.registerSingleton<AdhkarRepository>(repo);

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: HomeAdhkarPill()),
          ),
          GoRoute(
            path: '/adhkar',
            builder: (context, state) => const Scaffold(body: Text('Target')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      // Initially no progress
      expect(find.text('Tap to recite • 1-tap haptic counter'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

      // Simulate session progress saved to SQLite DB (e.g. 1 morning dhikr completed)
      final morningCategory = adhkarService.getCurrentContextCategory();
      final items = repo.getByCategory(morningCategory);

      await repo.saveSession(
        collectionId: morningCategory.name,
        lastPageIndex: 0,
        counts: {items.first.id: items.first.targetCount},
        isCompleted: false,
      );

      // StreamBuilder reacts immediately to Drift DB change
      await tester.pumpAndSettle();

      expect(
        find.textContaining('1 / ${items.length} completed'),
        findsOneWidget,
      );

      // Complete all items in the collection
      final allCompletedCounts = {
        for (final item in items) item.id: item.targetCount,
      };
      await repo.saveSession(
        collectionId: morningCategory.name,
        lastPageIndex: items.length - 1,
        counts: allCompletedCounts,
        isCompleted: true,
      );

      await tester.pumpAndSettle();

      expect(find.text('Completed! Alhamdulillah'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      await db.close();
    },
  );
}
