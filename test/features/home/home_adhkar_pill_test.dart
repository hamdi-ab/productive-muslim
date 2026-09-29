import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
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
}
