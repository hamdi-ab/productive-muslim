import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_router.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_screen.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_screen.dart';
import 'package:productive_muslim/features/energy/presentation/screens/energy_screen.dart';
import 'package:productive_muslim/features/home/presentation/screens/home_content.dart';
import 'package:productive_muslim/features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_reminder_scheduler.dart';

class MockBarakahRepo extends Mock implements BarakahRepository {}

class MockHabitRepo extends Mock implements HabitRepository {}

class MockTaskRepo extends Mock implements TaskRepository {}

class MockIntentionRepo extends Mock implements IntentionRepository {}

class MockPrayerTimeService extends PrayerTimeService {
  @override
  Future<Position?> getCurrentPosition() async => null;
}

void main() {
  late SettingsService settings;
  late MockBarakahRepo barakahRepo;
  late MockHabitRepo habitRepo;
  late MockTaskRepo taskRepo;
  late MockIntentionRepo intentionRepo;
  late BarakahReminderService reminderService;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    settings = SettingsService(prefs: await SharedPreferences.getInstance());
    await settings.setOnboardingCompleted();

    reminderService = BarakahReminderService(
      settings: settings,
      scheduler: FakeReminderScheduler(),
    );

    barakahRepo = MockBarakahRepo();
    habitRepo = MockHabitRepo();
    taskRepo = MockTaskRepo();
    intentionRepo = MockIntentionRepo();

    when(() => barakahRepo.watchEntriesForDate(any()))
        .thenAnswer((_) => Stream.value(<BarakahEntry>[]));
    when(() => barakahRepo.getEntriesForDate(any()))
        .thenAnswer((_) async => []);
    when(() => barakahRepo.watchDailyResponse(any()))
        .thenAnswer((_) => Stream.value(null));
    when(() => habitRepo.watchOverallStreak())
        .thenAnswer((_) => Stream.value(5));
    when(() => habitRepo.watchActiveHabits())
        .thenAnswer((_) => Stream.value(<Habit>[]));
    when(() => habitRepo.watchCompletionsForDate(any()))
        .thenAnswer((_) => Stream.value(<int, bool>{}));
    when(() => habitRepo.getCompletionsCountByDate(days: any(named: 'days')))
        .thenAnswer((_) async => <String, int>{});
    when(() => taskRepo.watchTasksForDate(any()))
        .thenAnswer((_) => Stream.value(<Task>[]));
    when(() => intentionRepo.watchEntriesForDate(any()))
        .thenAnswer((_) => Stream.value([]));

    getIt.registerSingleton<SettingsService>(settings);
    getIt.registerSingleton<BarakahReminderService>(reminderService);
    getIt.registerSingleton<BarakahRepository>(barakahRepo);
    getIt.registerSingleton<HabitRepository>(habitRepo);
    getIt.registerSingleton<TaskRepository>(taskRepo);
    getIt.registerSingleton<IntentionRepository>(intentionRepo);
    getIt.registerLazySingleton<PrayerTimeService>(
      () => MockPrayerTimeService(),
    );
    getIt.registerLazySingleton<AdhkarService>(
      () => AdhkarService(settingsService: settings),
    );

    AppRouter.consumeNotificationFallbackLocation();
    AppRouter.router.go('/');
  });

  tearDown(() async {
    await reminderService.dispose();
    await getIt.reset();
  });

  Future<void> pumpRouter(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BarakahRepository>.value(value: barakahRepo),
          RepositoryProvider<HabitRepository>.value(value: habitRepo),
          RepositoryProvider<TaskRepository>.value(value: taskRepo),
          RepositoryProvider<IntentionRepository>.value(value: intentionRepo),
        ],
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

  group('Navigation & Notification Back-Stack Resilience Tests', () {
    testWidgets(
      'Navigating from notification to subpage allows returning to previous location',
      (tester) async {
        // 1. User starts on Plan tab
        AppRouter.router.go('/plan');
        await pumpRouter(tester);
        expect(
          AppRouter.router.routeInformationProvider.value.uri.path,
          '/plan',
        );

        // 2. Notification for Morning Adhkar arrives and is tapped
        AppRouter.handleNotificationPayload('/adhkar?category=morning');
        await pumpFrames(tester);

        expect(find.byType(AdhkarScreen), findsOneWidget);
        expect(
          AppRouter.router.routeInformationProvider.value.uri.toString(),
          '/adhkar?category=morning',
        );

        // 3. Tap back button on AdhkarScreen ProductiveAppBar
        final backButton = find.descendant(
          of: find.byType(ProductiveAppBar),
          matching: find.byType(Tooltip),
        );
        expect(backButton, findsWidgets);
        await tester.tap(backButton.first);
        await pumpFrames(tester);

        // 4. User is cleanly returned to /plan!
        expect(
          AppRouter.router.routeInformationProvider.value.uri.path,
          '/plan',
        );
      },
    );

    testWidgets(
      'Navigating from notification on cold launch falls back to Home when tapping back',
      (tester) async {
        // Notification launches app directly to Energy
        AppRouter.handleNotificationPayload('/energy');
        await pumpRouter(tester);

        expect(find.byType(EnergyScreen), findsOneWidget);

        // Tap back button
        final backButton = find.descendant(
          of: find.byType(ProductiveAppBar),
          matching: find.byType(Tooltip),
        );
        expect(backButton, findsWidgets);
        await tester.tap(backButton.first);
        await pumpFrames(tester);

        // User safely lands on Home
        expect(find.byType(HomeContent), findsOneWidget);
        expect(AppRouter.router.routeInformationProvider.value.uri.path, '/');
      },
    );

    testWidgets(
      'Barakah screen from notification shows functional back button returning to previous screen',
      (tester) async {
        AppRouter.router.go('/prayer-times');
        await pumpRouter(tester);
        expect(find.byType(PrayerTimesScreen), findsOneWidget);

        // 9pm Barakah Reminder notification tapped
        AppRouter.openBarakahReminder();
        await pumpFrames(tester);

        expect(find.byType(BarakahScreen), findsOneWidget);

        // Tap back button on Barakah screen
        final backButton = find.descendant(
          of: find.byType(ProductiveAppBar),
          matching: find.byType(Tooltip),
        );
        expect(backButton, findsWidgets);
        await tester.tap(backButton.first);
        await pumpFrames(tester);

        // Returns to /prayer-times
        expect(
          AppRouter.router.routeInformationProvider.value.uri.path,
          '/prayer-times',
        );
      },
    );

    testWidgets('Aliases /intentions and /prayer_times cleanly redirect', (
      tester,
    ) async {
      AppRouter.handleNotificationPayload('/intentions');
      await pumpRouter(tester);
      expect(
        AppRouter.router.routeInformationProvider.value.uri.path,
        '/journal',
      );

      AppRouter.handleNotificationPayload('/prayer_times');
      await pumpFrames(tester);
      expect(
        AppRouter.router.routeInformationProvider.value.uri.path,
        '/prayer-times',
      );
    });
  });
}
