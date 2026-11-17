import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_router.dart';
import 'package:productive_muslim/core/widgets/floating_glass_nav_bar.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_screen.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_screen.dart';
import 'package:productive_muslim/features/focus/presentation/screens/focus_screen.dart';
import 'package:productive_muslim/features/habits/presentation/screens/habit_screen.dart';
import 'package:productive_muslim/features/home/presentation/screens/home_content.dart';
import 'package:productive_muslim/features/intentions/presentation/screens/intention_screen.dart';
import 'package:productive_muslim/features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:productive_muslim/features/profile/presentation/screens/profile_screen.dart';
import 'package:productive_muslim/features/reflect/presentation/screens/reflect_screen.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/plan_screen.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/task_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_reminder_scheduler.dart';
import '../helpers/mocks.dart';

void main() {
  late SettingsService settings;
  late MockBarakahRepository barakahRepo;
  late MockHabitRepository habitRepo;
  late MockTaskRepository taskRepo;
  late MockIntentionRepository intentionRepo;
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

    barakahRepo = MockBarakahRepository();
    habitRepo = MockHabitRepository();
    taskRepo = MockTaskRepository();
    intentionRepo = MockIntentionRepository();

    stubDefaultRepositoryMocks(
      barakahRepo: barakahRepo,
      habitRepo: habitRepo,
      taskRepo: taskRepo,
      intentionRepo: intentionRepo,
    );
    when(() => habitRepo.watchOverallStreak())
        .thenAnswer((_) => Stream.value(3));

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

    AppRouter.resetForTesting();
    AppRouter.router.go(AppRoutes.home);
  });

  tearDown(() async {
    AppRouter.resetForTesting();
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

  group('Five-Pillar App Shell Navigation Tests', () {
    testWidgets('all five primary destinations render through the shell', (
      tester,
    ) async {
      await pumpRouter(tester);

      // 1. Home
      expect(find.byType(HomeContent), findsOneWidget);
      expect(find.byType(FloatingGlassNavBar), findsOneWidget);

      // 2. Adhkar tab
      AppRouter.router.go(AppRoutes.adhkar);
      await pumpFrames(tester);
      expect(find.byType(AdhkarScreen), findsOneWidget);
      expect(find.byType(FloatingGlassNavBar), findsOneWidget);

      // 3. My Day tab
      AppRouter.router.go(AppRoutes.myDay);
      await pumpFrames(tester);
      expect(find.byType(PlanScreen), findsOneWidget);
      expect(find.byType(FloatingGlassNavBar), findsOneWidget);

      // 4. Prayer tab
      AppRouter.router.go(AppRoutes.prayerTimes);
      await pumpFrames(tester);
      expect(find.byType(PrayerTimesScreen), findsOneWidget);
      expect(find.byType(FloatingGlassNavBar), findsOneWidget);

      // 5. Reflect tab
      AppRouter.router.go(AppRoutes.reflect);
      await pumpFrames(tester);
      expect(find.byType(ReflectScreen), findsOneWidget);
      expect(find.byType(FloatingGlassNavBar), findsOneWidget);
    });

    testWidgets('My Day toggles between Tasks, Habits, and Focus tabs', (
      tester,
    ) async {
      AppRouter.router.go(AppRoutes.myDay);
      await pumpRouter(tester);

      // Initial tab is Tasks
      expect(find.byType(TaskScreen), findsOneWidget);

      // Switch to Habits
      await tester.tap(find.text('Habits'));
      await pumpFrames(tester);
      expect(find.byType(HabitScreen), findsOneWidget);

      // Switch to Focus
      await tester.tap(find.text('Focus'));
      await pumpFrames(tester);
      expect(find.byType(FocusScreen), findsOneWidget);
    });

    testWidgets('Reflect toggles between Muhasabah and Barakah tabs', (
      tester,
    ) async {
      AppRouter.router.go(AppRoutes.reflect);
      await pumpRouter(tester);

      // Initial tab is Muhasabah (IntentionScreen)
      expect(find.byType(IntentionScreen), findsOneWidget);

      // Switch to Barakah tab
      await tester.tap(find.text('Barakah'));
      await pumpFrames(tester);
      expect(find.byType(BarakahScreen), findsOneWidget);
    });

    testWidgets('Tapping profile avatar on Home opens Profile as root detail', (
      tester,
    ) async {
      await pumpRouter(tester);

      // Find the spa avatar in the leading app bar
      final avatar = find.byIcon(Icons.spa_rounded);
      expect(avatar, findsOneWidget);

      await tester.tap(avatar);
      await pumpFrames(tester);

      // Pushed to ProfileScreen
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(
        AppRouter.router.routeInformationProvider.value.uri.path,
        '/profile',
      );

      // Profile has back button on its ProductiveAppBar
      final backButton = find.descendant(
        of: find.byType(ProductiveAppBar),
        matching: find.byType(Tooltip),
      );
      expect(backButton, findsWidgets);

      await tester.tap(backButton.first);
      await pumpFrames(tester);

      // Returns to Home
      expect(find.byType(HomeContent), findsOneWidget);
      expect(AppRouter.router.routeInformationProvider.value.uri.path, '/');
    });

    testWidgets(
      'Legacy routes (/plan, /tasks, /habits, /focus, /journal, /barakah) resolve compatibly',
      (tester) async {
        // 1. /plan
        AppRouter.handleNotificationPayload('/plan');
        await pumpRouter(tester);
        expect(find.byType(PlanScreen), findsOneWidget);

        // 2. /tasks
        AppRouter.handleNotificationPayload('/tasks');
        await pumpFrames(tester);
        expect(find.byType(TaskScreen), findsOneWidget);

        // 3. /habits
        AppRouter.handleNotificationPayload('/habits');
        await pumpFrames(tester);
        expect(find.byType(HabitScreen), findsOneWidget);

        // 4. /focus
        AppRouter.handleNotificationPayload('/focus');
        await pumpFrames(tester);
        expect(find.byType(FocusScreen), findsOneWidget);

        // 5. /journal
        AppRouter.handleNotificationPayload('/journal');
        await pumpFrames(tester);
        expect(find.byType(ReflectScreen), findsOneWidget);

        // 6. /barakah
        AppRouter.handleNotificationPayload('/barakah');
        await pumpFrames(tester);
        expect(find.byType(BarakahScreen), findsOneWidget);
      },
    );
  });
}
