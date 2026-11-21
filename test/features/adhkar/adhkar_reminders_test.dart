import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/local/daos/adhkar_dao.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/repositories/adhkar_repository_impl.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/prayer_notification_scheduler.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_screen.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_reminders_sheet.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNotificationPlugin extends Mock
    implements NotificationPluginAdapter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AdhkarDao dao;
  late AdhkarRepository repo;
  late SettingsService settingsService;
  late MockNotificationPlugin mockPlugin;
  late PrayerNotificationScheduler scheduler;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);
    getIt.registerSingleton<SettingsService>(settingsService);

    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = AdhkarDao(db);
    repo = AdhkarRepositoryImpl(
      adhkarDao: dao,
      settingsService: settingsService,
    );
    getIt.registerSingleton<AppDatabase>(db);
    getIt.registerSingleton<AdhkarDao>(dao);
    getIt.registerSingleton<AdhkarRepository>(repo);
    getIt.registerSingleton<AdhkarService>(
      AdhkarService(settingsService: settingsService, adhkarRepository: repo),
    );

    mockPlugin = MockNotificationPlugin();
    when(() => mockPlugin.supported).thenReturn(true);
    when(
      () => mockPlugin.initialize(
        onNotificationTapped: any(named: 'onNotificationTapped'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockPlugin.requestPermission()).thenAnswer((_) async => true);
    when(() => mockPlugin.hasPermission()).thenAnswer((_) async => true);
    when(() => mockPlugin.cancel(any())).thenAnswer((_) async {});
    when(
      () => mockPlugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        payload: any(named: 'payload'),
        channelId: any(named: 'channelId'),
        channelName: any(named: 'channelName'),
        matchTimeOnly: any(named: 'matchTimeOnly'),
      ),
    ).thenAnswer((_) async {});

    scheduler = PrayerNotificationScheduler(
      settingsService: settingsService,
      plugin: mockPlugin,
    );
    getIt.registerSingleton<PrayerNotificationScheduler>(scheduler);
  });

  tearDown(() async {
    await db.close();
    await getIt.reset();
  });

  Widget buildSubject({Widget? child}) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child ?? const AdhkarRemindersSheet()),
    );
  }

  group('AdhkarRemindersSheet - Opt-in Defaults & Scheduling', () {
    testWidgets('renders opt-in disabled defaults with calm notice', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Check title and peaceful notice
      expect(find.text('Adhkar Reminders'), findsOneWidget);
      expect(
        find.text(
          'Reminders are local, peaceful, and completely optional. They never imply religious obligation, score progress, or send follow-up nudges.',
        ),
        findsOneWidget,
      );

      // Master switch is enabled by default
      final globalSwitch = tester.widget<Switch>(
        find.byKey(const Key('adhkar_reminders_global_toggle')),
      );
      expect(globalSwitch.value, isTrue);

      // Morning and Evening reminders are opt-in (disabled by default)
      final morningSwitch = tester.widget<Switch>(
        find.byKey(const Key('adhkar_morning_reminder_toggle')),
      );
      expect(morningSwitch.value, isFalse);

      final eveningSwitch = tester.widget<Switch>(
        find.byKey(const Key('adhkar_evening_reminder_toggle')),
      );
      expect(eveningSwitch.value, isFalse);

      // Zero notifications scheduled initially
      verifyNever(
        () => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
          channelId: any(named: 'channelId'),
          channelName: any(named: 'channelName'),
          matchTimeOnly: any(named: 'matchTimeOnly'),
        ),
      );
    });

    testWidgets(
      'toggling morning adhkar schedules gentle notification and toggling off cancels',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final morningSwitch = find.byKey(
          const Key('adhkar_morning_reminder_toggle'),
        );

        // 1. Toggle ON
        await tester.tap(morningSwitch);
        await tester.pumpAndSettle();

        expect(settingsService.morningAdhkarNotificationEnabled, isTrue);
        expect(settingsService.isMorningAdhkarReminderActive, isTrue);

        verify(
          () => mockPlugin.zonedSchedule(
            id: PrayerNotificationScheduler.idMorningAdhkar,
            title: 'Morning Adhkar',
            body: 'Start your day with peaceful remembrance.',
            scheduledDate: any(named: 'scheduledDate'),
            payload: '/adhkar?category=morning',
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            matchTimeOnly: true,
          ),
        ).called(1);

        // 2. Toggle OFF
        await tester.tap(morningSwitch);
        await tester.pumpAndSettle();

        expect(settingsService.morningAdhkarNotificationEnabled, isFalse);
        expect(settingsService.isMorningAdhkarReminderActive, isFalse);

        verify(
          () => mockPlugin.cancel(PrayerNotificationScheduler.idMorningAdhkar),
        ).called(1);
      },
    );

    testWidgets(
      'toggling evening adhkar schedules gentle notification and toggling off cancels',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final eveningSwitch = find.byKey(
          const Key('adhkar_evening_reminder_toggle'),
        );

        // 1. Toggle ON
        await tester.tap(eveningSwitch);
        await tester.pumpAndSettle();

        expect(settingsService.eveningAdhkarNotificationEnabled, isTrue);
        expect(settingsService.isEveningAdhkarReminderActive, isTrue);

        verify(
          () => mockPlugin.zonedSchedule(
            id: PrayerNotificationScheduler.idEveningAdhkar,
            title: 'Evening Adhkar',
            body: 'Wind down your day with peaceful remembrance.',
            scheduledDate: any(named: 'scheduledDate'),
            payload: '/adhkar?category=evening',
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            matchTimeOnly: true,
          ),
        ).called(1);

        // 2. Toggle OFF
        await tester.tap(eveningSwitch);
        await tester.pumpAndSettle();

        expect(settingsService.eveningAdhkarNotificationEnabled, isFalse);
        expect(settingsService.isEveningAdhkarReminderActive, isFalse);

        verify(
          () => mockPlugin.cancel(PrayerNotificationScheduler.idEveningAdhkar),
        ).called(1);
      },
    );

    testWidgets(
      'master global switch disables all reminders and cancels them',
      (tester) async {
        await settingsService.setMorningAdhkarNotificationEnabled(true);
        await settingsService.setEveningAdhkarNotificationEnabled(true);

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final globalSwitch = find.byKey(
          const Key('adhkar_reminders_global_toggle'),
        );
        expect(settingsService.hasAnyAdhkarReminderActive, isTrue);

        // Turn global switch OFF
        await tester.tap(globalSwitch);
        await tester.pumpAndSettle();

        expect(settingsService.adhkarRemindersGlobalEnabled, isFalse);
        expect(settingsService.hasAnyAdhkarReminderActive, isFalse);

        // Both morning and evening reminders should be cancelled
        verify(
          () => mockPlugin.cancel(PrayerNotificationScheduler.idMorningAdhkar),
        ).called(1);
        verify(
          () => mockPlugin.cancel(PrayerNotificationScheduler.idEveningAdhkar),
        ).called(1);

        // Sub-switches should be disabled (onChanged is null)
        final morningWidget = tester.widget<Switch>(
          find.byKey(const Key('adhkar_morning_reminder_toggle')),
        );
        expect(morningWidget.onChanged, isNull);

        final eveningWidget = tester.widget<Switch>(
          find.byKey(const Key('adhkar_evening_reminder_toggle')),
        );
        expect(eveningWidget.onChanged, isNull);

        // Turn global switch back ON
        await tester.tap(globalSwitch);
        await tester.pumpAndSettle();

        expect(settingsService.adhkarRemindersGlobalEnabled, isTrue);
        expect(settingsService.hasAnyAdhkarReminderActive, isTrue);

        // Both should be rescheduled
        verify(
          () => mockPlugin.zonedSchedule(
            id: PrayerNotificationScheduler.idMorningAdhkar,
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            payload: any(named: 'payload'),
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            matchTimeOnly: any(named: 'matchTimeOnly'),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'shows permission warning card when notification permission is denied',
      (tester) async {
        when(() => mockPlugin.hasPermission()).thenAnswer((_) async => false);

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('adhkar_reminders_permission_warning')),
          findsOneWidget,
        );
        expect(find.text('Notification Permission Required'), findsOneWidget);

        // Tap grant permission button
        final grantBtn = find.byKey(
          const Key('adhkar_reminders_grant_permission_button'),
        );
        expect(grantBtn, findsOneWidget);

        await tester.tap(grantBtn);
        await tester.pumpAndSettle();

        verify(() => mockPlugin.requestPermission()).called(1);
      },
    );

    testWidgets(
      'scheduling error reverts toggle state and displays error snackbar',
      (tester) async {
        when(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            payload: any(named: 'payload'),
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            matchTimeOnly: any(named: 'matchTimeOnly'),
          ),
        ).thenThrow(Exception('Platform scheduler error'));

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final morningSwitch = find.byKey(
          const Key('adhkar_morning_reminder_toggle'),
        );
        await tester.tap(morningSwitch);
        await tester.pumpAndSettle();

        // State was reverted to false
        expect(settingsService.morningAdhkarNotificationEnabled, isFalse);
        expect(
          find.byKey(const Key('adhkar_reminder_error_snackbar')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'isolation: reminder configuration never alters bookmarks, routines, or sessions',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // Toggle reminders
        await tester.tap(
          find.byKey(const Key('adhkar_morning_reminder_toggle')),
        );
        await tester.pumpAndSettle();

        // Verify db bookmarks & routines remain empty
        final bookmarks = await repo.getBookmarkedItems();
        expect(bookmarks, isEmpty);

        final routines = await repo.getRoutines();
        expect(routines, isEmpty);
      },
    );
  });

  group('AdhkarScreen Entry Point & Deep Linking', () {
    testWidgets(
      'renders notification bell icon with inactive state when reminders are disabled',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AdhkarScreen(),
          ),
        );
        await tester.pumpAndSettle();

        final actionFinder = find.byKey(
          const Key('adhkar_reminders_app_bar_action'),
        );
        expect(actionFinder, findsOneWidget);

        final iconWidget = tester.widget<Icon>(
          find.descendant(of: actionFinder, matching: find.byType(Icon)),
        );
        expect(iconWidget.icon, equals(Icons.notifications_none_rounded));
      },
    );

    testWidgets(
      'renders active bell icon when at least one reminder is active',
      (tester) async {
        await settingsService.setMorningAdhkarNotificationEnabled(true);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AdhkarScreen(),
          ),
        );
        await tester.pumpAndSettle();

        final actionFinder = find.byKey(
          const Key('adhkar_reminders_app_bar_action'),
        );
        expect(actionFinder, findsOneWidget);

        final iconWidget = tester.widget<Icon>(
          find.descendant(of: actionFinder, matching: find.byType(Icon)),
        );
        expect(iconWidget.icon, equals(Icons.notifications_active_rounded));
      },
    );

    testWidgets('tapping reminders button opens AdhkarRemindersSheet modal', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AdhkarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final actionFinder = find.byKey(
        const Key('adhkar_reminders_app_bar_action'),
      );
      await tester.tap(actionFinder);
      await tester.pumpAndSettle();

      expect(find.byType(AdhkarRemindersSheet), findsOneWidget);
    });

    testWidgets('deep link payload opens correct initial category', (
      tester,
    ) async {
      // 1. Morning category
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AdhkarScreen(initialCategory: DhikrCategory.morning),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Morning'), findsWidgets);

      // 2. Evening category
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AdhkarScreen(initialCategory: DhikrCategory.evening),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Evening'), findsWidgets);
    });
  });
}
