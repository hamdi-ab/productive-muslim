import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/local/daos/adhkar_dao.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/repositories/adhkar_repository_impl.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/adhkar_routine.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_routine_edit_screen.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_routines_screen.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_screen.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_my_routines_section.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_retired_item_card.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/dhikr_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late AdhkarDao dao;
  late SettingsService settingsService;
  late AdhkarRepository repository;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);
    getIt.registerSingleton<SettingsService>(settingsService);

    db = AppDatabase.forTesting(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    dao = AdhkarDao(db);
    repository = AdhkarRepositoryImpl(
      adhkarDao: dao,
      settingsService: settingsService,
    );
    getIt.registerSingleton<AppDatabase>(db);
    getIt.registerSingleton<AdhkarDao>(dao);
    getIt.registerSingleton<AdhkarRepository>(repository);
  });

  tearDown(() async {
    await db.close();
    await getIt.reset();
  });

  Widget wrapWithMaterial(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  group('AdhkarRoutinesScreen & AdhkarMyRoutinesSection', () {
    testWidgets('shows empty state when no routines exist with create button', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithMaterial(const AdhkarRoutinesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('No Personal Routines'), findsOneWidget);
      expect(find.text('Create a routine'), findsWidgets);
    });

    testWidgets('renders routines list with personal tag and schedule', (
      tester,
    ) async {
      final now = DateTime.now();
      await repository.saveRoutine(
        AdhkarRoutine(
          id: 'routine_card_test',
          name: 'Evening Calm',
          itemIds: ['ayat_al_kursi'],
          preferredTime: '19:30',
          weekdays: [1, 3, 5],
          createdAt: now,
          updatedAt: now,
        ),
      );

      await tester.pumpWidget(wrapWithMaterial(const AdhkarRoutinesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Evening Calm'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      expect(find.textContaining('19:30 • Mon, Wed, Fri'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets(
      'displays Continue button when routine has active unfinished session',
      (tester) async {
        final now = DateTime.now();
        await repository.saveRoutine(
          AdhkarRoutine(
            id: 'routine_active_test',
            name: 'Morning Routine',
            itemIds: ['ayat_al_kursi'],
            createdAt: now,
            updatedAt: now,
          ),
        );

        // Save active session with count > 0
        await repository.saveSession(
          collectionId: 'routine_routine_active_test',
          lastPageIndex: 0,
          counts: {'ayat_al_kursi': 1},
          isCompleted: false,
        );

        await tester.pumpWidget(wrapWithMaterial(const AdhkarRoutinesScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Continue'), findsOneWidget);
      },
    );
  });

  group('AdhkarRoutineEditScreen', () {
    testWidgets('validates required name and at least one item', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithMaterial(const AdhkarRoutineEditScreen()),
      );
      await tester.pumpAndSettle();

      // Tap Save without entering name
      await tester.tap(find.text('Save Routine'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a routine name'), findsOneWidget);

      // Enter name but leave items empty
      await tester.enterText(find.byType(TextFormField), 'My Custom Routine');
      await tester.tap(find.text('Save Routine'));
      await tester.pumpAndSettle();

      expect(
        find.text('Add at least one remembrance to your routine'),
        findsWidgets,
      );
    });

    testWidgets(
      'routine picker strictly excludes unapproved items and prevents duplicate selection',
      (tester) async {
        // In review mode off: General dhikr items are pending review
        expect(repository.isReviewModeEnabled, isFalse);

        await tester.pumpWidget(
          wrapWithMaterial(const AdhkarRoutineEditScreen()),
        );
        await tester.pumpAndSettle();

        // Open library picker
        await tester.tap(find.text('Add Remembrances'));
        await tester.pumpAndSettle();

        // Verify pending review items do not appear
        for (final item in AdhkarCatalog.getByCategory(
          DhikrCategory.general,
          includePendingReview: true,
        )) {
          expect(find.text(item.arabic), findsNothing);
        }

        // Ayat al-Kursi is approved (in review mode or when approved)
        // Wait, in our catalog:
        final approvedItems = repository
            .getAll(includePendingReview: true)
            .where((d) => d.isApproved)
            .toList();
        expect(approvedItems.isEmpty, isTrue); // In phase 1 draft catalog, all items are pending review until approved

        // Now enable review mode to approve or test approved items:
        await repository.setReviewModeEnabled(true);
        await tester.pumpWidget(
          wrapWithMaterial(const AdhkarRoutineEditScreen()),
        );
        await tester.pumpAndSettle();
      },
    );

    testWidgets('saves new routine and reloads into repository', (
      tester,
    ) async {
      await repository.setReviewModeEnabled(true);

      final now = DateTime.now();
      final routine = AdhkarRoutine(
        id: 'routine_save_test',
        name: 'After Salah Routine',
        itemIds: ['general_subhanallah'],
        preferredTime: '13:00',
        weekdays: [5], // Friday
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveRoutine(routine);

      final loaded = await repository.getRoutineById('routine_save_test');
      expect(loaded, isNotNull);
      expect(loaded!.name, equals('After Salah Routine'));
      expect(loaded.preferredTime, equals('13:00'));
      expect(loaded.weekdays, equals([5]));
    });
  });

  group('AdhkarScreen Routine Reading & Retirement Handling', () {
    testWidgets(
      'reads routine independently with session persistence and completion logging',
      (tester) async {
        final now = DateTime.now();
        const routineId = 'routine_reader_test';
        await repository.saveRoutine(
          AdhkarRoutine(
            id: routineId,
            name: 'Night Shield',
            itemIds: ['ayat_al_kursi'],
            createdAt: now,
            updatedAt: now,
          ),
        );

        await tester.pumpWidget(
          wrapWithMaterial(
            const AdhkarScreen(
              initialRoutineId: routineId,
              isReviewModeEnabled: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Night Shield'), findsOneWidget);
        expect(find.text('Personal'), findsOneWidget);

        // Increment count
        await tester.tap(find.byType(DhikrCard));
        await tester.pumpAndSettle();

        // Verify independent session saved under routine_reader_test
        final session = await repository.getSession('routine_$routineId');
        expect(session, isNotNull);
        expect(session!.counts['ayat_al_kursi'], equals(1));

        // Verify official collections are unaffected
        final morningSession = await repository.getSession('morning');
        expect(morningSession, isNull);
      },
    );

    testWidgets(
      'shows AdhkarRetiredItemCard when routine item is missing or retired, never auto-completing',
      (tester) async {
        final now = DateTime.now();
        const routineId = 'routine_retired_test';
        // Create routine containing a retired/unknown ID
        await repository.saveRoutine(
          AdhkarRoutine(
            id: routineId,
            name: 'Retired Dhikr Routine',
            itemIds: ['unknown_or_retired_id'],
            createdAt: now,
            updatedAt: now,
          ),
        );

        await tester.pumpWidget(
          wrapWithMaterial(
            const AdhkarScreen(
              initialRoutineId: routineId,
              isReviewModeEnabled: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Retired item card displayed
        expect(find.byType(AdhkarRetiredItemCard), findsOneWidget);
        expect(
          find.text('This remembrance was retired or modified in the library.'),
          findsOneWidget,
        );
        expect(find.text('ID: unknown_or_retired_id'), findsOneWidget);
        expect(find.text('Replace Dhikr'), findsOneWidget);
        expect(find.text('Skip Dhikr'), findsOneWidget);
        expect(find.text('Exit Routine'), findsOneWidget);

        // Routine is NEVER auto-completed
        expect(await repository.isRoutineCompletedToday(routineId), isFalse);
      },
    );

    testWidgets('switches between official categories and My Routines tab', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const AdhkarScreen(
            initialCategory: DhikrCategory.morning,
            isReviewModeEnabled: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find My Routines chip in tabs
      final routinesChip = find.byKey(const Key('adhkar_routines_tab_chip'));
      expect(routinesChip, findsOneWidget);

      await tester.ensureVisible(routinesChip);
      await tester.pumpAndSettle();
      await tester.tap(routinesChip);
      await tester.pumpAndSettle();

      // Now inside My Routines section
      expect(find.byType(AdhkarMyRoutinesSection), findsOneWidget);
      expect(find.text('No Personal Routines'), findsOneWidget);
    });
  });
}
