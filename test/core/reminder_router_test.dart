import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_router.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_screen.dart';
import 'package:productive_muslim/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:productive_muslim/features/settings/presentation/screens/settings_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_reminder_scheduler.dart';

class MockReminderBarakahRepository extends Mock implements BarakahRepository {}

void main() {
  late SettingsService settings;
  late MockReminderBarakahRepository repository;
  late BarakahReminderService service;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    settings = SettingsService(prefs: await SharedPreferences.getInstance());
    service = BarakahReminderService(
      settings: settings,
      scheduler: FakeReminderScheduler(),
    );
    getIt.registerSingleton<SettingsService>(settings);
    getIt.registerSingleton<BarakahReminderService>(service);
    repository = MockReminderBarakahRepository();
    when(() => repository.watchEntriesForDate(any()))
        .thenAnswer((_) => Stream.value([]));
    when(() => repository.getEntriesForDate(any())).thenAnswer((_) async => []);
    when(() => repository.watchDailyResponse(any()))
        .thenAnswer((_) => Stream.value(null));
  });

  tearDown(() async {
    await service.dispose();
    await getIt.reset();
  });

  Future<void> pumpRouter(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RepositoryProvider<BarakahRepository>.value(
        value: repository,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: AppRouter.router,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> pumpFrames(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
    'Settings route uses real screen and warm notification opens Barakah',
    (tester) async {
      await settings.setOnboardingCompleted();
      AppRouter.router.go('/settings');
      await pumpRouter(tester);
      expect(find.byType(SettingsScreen), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('barakah_reminder_toggle')),
        50,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('barakah_reminder_toggle')), findsOneWidget);
      AppRouter.openBarakahReminder();
      await pumpFrames(tester);
      expect(
        AppRouter.router.routeInformationProvider.value.uri.path,
        '/barakah',
      );
      expect(find.byType(BarakahScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cold reminder destination survives onboarding guard and completion',
    (tester) async {
      AppRouter.openBarakahReminder();
      await pumpRouter(tester);
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(BarakahScreen), findsNothing);
      await tester.tap(find.text('Skip'));
      await pumpFrames(tester);
      expect(settings.onboardingCompleted, isTrue);
      expect(
        AppRouter.router.routeInformationProvider.value.uri.path,
        '/barakah',
      );
      expect(find.byType(BarakahScreen), findsOneWidget);
      AppRouter.router.go('/settings');
      await pumpFrames(tester);
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'handleNotificationPayload navigates to smart reminder destinations',
    (tester) async {
      await settings.setOnboardingCompleted();
      await pumpRouter(tester);

      AppRouter.handleNotificationPayload('/adhkar?category=morning');
      await pumpFrames(tester);
      expect(
        AppRouter.router.routeInformationProvider.value.uri.toString(),
        '/adhkar?category=morning',
      );

      AppRouter.handleNotificationPayload('/energy');
      await pumpFrames(tester);
      expect(
        AppRouter.router.routeInformationProvider.value.uri.path,
        '/energy',
      );
    },
  );
}
