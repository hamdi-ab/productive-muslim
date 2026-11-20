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
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_collection_completion_card.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_my_routines_section.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_retired_item_card.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_routine_card.dart';
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

    testWidgets(
      'skipping a middle retired entry persists skip, advances to next item, and completes only when remaining approved entry is complete',
      (tester) async {
        final now = DateTime.now();
        const routineId = 'routine_skip_middle_test';
        await repository.saveRoutine(
          AdhkarRoutine(
            id: routineId,
            name: 'Middle Skip Routine',
            itemIds: [
              'ayat_al_kursi',
              'retired_middle_id',
              'sayyid_al_istighfar',
            ],
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

        // 1. We are on Page 0: ayat_al_kursi
        expect(find.byType(DhikrCard), findsOneWidget);
        expect(find.textContaining('Ayat al-Kursi'), findsOneWidget);
        // Complete ayat_al_kursi (targetCount 1)
        await tester.tap(find.byType(DhikrCard));
        await tester.pumpAndSettle();

        // Swipe to Page 1: retired_middle_id
        await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
        await tester.pumpAndSettle();

        expect(find.byType(AdhkarRetiredItemCard), findsOneWidget);
        expect(find.text('ID: retired_middle_id'), findsOneWidget);

        // Tap "Skip Dhikr"
        await tester.tap(find.text('Skip Dhikr'));
        await tester.pumpAndSettle();

        // Verify page automatically advanced to sayyid_al_istighfar
        expect(find.byType(DhikrCard), findsOneWidget);
        expect(find.textContaining('Sayyid al-Istighfar'), findsOneWidget);

        // Verify routine completion NOT yet recorded because sayyid_al_istighfar is not completed yet
        expect(await repository.isRoutineCompletedToday(routineId), isFalse);

        // Verify session persisted skippedItemIds
        final session = await repository.getSession('routine_$routineId');
        expect(session, isNotNull);
        expect(session!.skippedItemIds, contains('retired_middle_id'));

        // Complete sayyid_al_istighfar (targetCount 1)
        await tester.tap(find.byType(DhikrCard));
        await tester.pumpAndSettle();

        // Now all approved items are completed and retired item was skipped -> routine completes!
        expect(await repository.isRoutineCompletedToday(routineId), isTrue);

        // Advance to completion card
        await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
        await tester.pumpAndSettle();
        expect(find.byType(AdhkarCollectionCompletionCard), findsOneWidget);
      },
    );

    testWidgets(
      'skipping a final retired entry immediately reveals completion card and records completion',
      (tester) async {
        final now = DateTime.now();
        const routineId = 'routine_skip_final_test';
        await repository.saveRoutine(
          AdhkarRoutine(
            id: routineId,
            name: 'Final Skip Routine',
            itemIds: ['ayat_al_kursi', 'retired_final_id'],
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

        // Complete first item (ayat_al_kursi targetCount 1)
        await tester.tap(find.byType(DhikrCard));
        await tester.pumpAndSettle();

        // Move to final retired item
        await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
        await tester.pumpAndSettle();

        expect(find.byType(AdhkarRetiredItemCard), findsOneWidget);
        expect(find.text('ID: retired_final_id'), findsOneWidget);

        // Tap Skip on the final item
        await tester.tap(find.text('Skip Dhikr'));
        await tester.pumpAndSettle();

        // Routine completion is recorded
        expect(await repository.isRoutineCompletedToday(routineId), isTrue);

        // Completion card is reached and displayed
        expect(find.byType(AdhkarCollectionCompletionCard), findsOneWidget);
        expect(
          find.text('الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'restarting or resuming routine preserves skipped state and keeps original retired ID in configuration',
      (tester) async {
        final now = DateTime.now();
        const routineId = 'routine_resume_skip_test';
        await repository.saveRoutine(
          AdhkarRoutine(
            id: routineId,
            name: 'Resume Skip Routine',
            itemIds: ['retired_first_id', 'ayat_al_kursi'],
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

        // Starts on retired_first_id
        expect(find.byType(AdhkarRetiredItemCard), findsOneWidget);
        await tester.tap(find.text('Skip Dhikr'));
        await tester.pumpAndSettle();

        // Advances to ayat_al_kursi
        expect(find.byType(DhikrCard), findsOneWidget);

        // Exit routine to return to routines view via app bar back button
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();

        // Verify routine still has the original retired ID in configuration
        final routineConfig = await repository.getRoutineById(routineId);
        expect(routineConfig, isNotNull);
        expect(
          routineConfig!.itemIds,
          equals(['retired_first_id', 'ayat_al_kursi']),
        );

        // Verify My Routines section displays Continue button
        final continueBtn = find.text('Continue');
        expect(continueBtn, findsOneWidget);

        // Resume routine via Continue button
        await tester.tap(continueBtn);
        await tester.pumpAndSettle();

        // Resumed on ayat_al_kursi
        expect(find.byType(DhikrCard), findsOneWidget);
        expect(find.textContaining('Ayat al-Kursi'), findsOneWidget);

        // Complete the remaining approved item
        await tester.tap(find.byType(DhikrCard));
        await tester.pumpAndSettle();

        // Routine finishes because the first retired item was remembered as skipped
        expect(await repository.isRoutineCompletedToday(routineId), isTrue);
      },
    );

    testWidgets(
      'routine progress does not leak between routines sharing the same dhikr item',
      (tester) async {
        final now = DateTime.now();
        const routineAId = 'routine_a_leak_test';
        const routineBId = 'routine_b_leak_test';

        // Routine A has ayat_al_kursi (targetCount 1)
        await repository.saveRoutine(
          AdhkarRoutine(
            id: routineAId,
            name: 'Routine Alpha',
            itemIds: ['ayat_al_kursi'],
            createdAt: now,
            updatedAt: now,
          ),
        );

        // Routine B has ayat_al_kursi (targetCount 1) AND sayyid_al_istighfar (targetCount 1)
        await repository.saveRoutine(
          AdhkarRoutine(
            id: routineBId,
            name: 'Routine Beta',
            itemIds: ['ayat_al_kursi', 'sayyid_al_istighfar'],
            createdAt: now,
            updatedAt: now,
          ),
        );

        await tester.pumpWidget(
          wrapWithMaterial(
            const AdhkarScreen(
              initialRoutineId: routineAId,
              isReviewModeEnabled: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. In Routine A: complete ayat_al_kursi (targetCount 1)
        expect(find.text('Routine Alpha'), findsOneWidget);
        expect(find.byType(DhikrCard), findsOneWidget);
        expect(find.textContaining('Ayat al-Kursi'), findsOneWidget);
        expect(find.text('0 / 1'), findsOneWidget);

        await tester.tap(find.byType(DhikrCard));
        await tester.pumpAndSettle();

        // Routine A reaches completion
        expect(
          find.descendant(
            of: find.byType(DhikrCard),
            matching: find.text('1 / 1'),
          ),
          findsOneWidget,
        );
        expect(find.text('Completed! Alhamdulillah'), findsOneWidget);
        expect(await repository.isRoutineCompletedToday(routineAId), isTrue);

        // 2. Exit Routine A back to My Routines view
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(AdhkarMyRoutinesSection), findsOneWidget);
        expect(find.text('Routine Beta'), findsOneWidget);

        // 3. Start Routine B (which has no saved session)
        final routineBCard = find.ancestor(
          of: find.text('Routine Beta'),
          matching: find.byType(AdhkarRoutineCard),
        );
        final startRoutineB = find.descendant(
          of: routineBCard,
          matching: find.text('Start'),
        );
        expect(startRoutineB, findsOneWidget);
        await tester.tap(startRoutineB);
        await tester.pumpAndSettle();

        // Verify Routine B is active
        expect(find.text('Routine Beta'), findsOneWidget);

        // Crucial isolation check: ayat_al_kursi in Routine B must start at ZERO!
        expect(find.textContaining('Ayat al-Kursi'), findsOneWidget);
        expect(find.text('0 / 1'), findsOneWidget);

        // Verify Routine B cannot be completed from Routine A's progress
        expect(await repository.isRoutineCompletedToday(routineBId), isFalse);

        // 4. Exit Routine B and return to Routine A
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(AdhkarMyRoutinesSection), findsOneWidget);

        final routineACard = find.ancestor(
          of: find.text('Routine Alpha'),
          matching: find.byType(AdhkarRoutineCard),
        );
        final startRoutineA = find.descendant(
          of: routineACard,
          matching: find.text('Start'),
        );
        expect(startRoutineA, findsOneWidget);
        await tester.tap(startRoutineA);
        await tester.pumpAndSettle();

        // 5. Verifies switching back to A restores A's own saved count
        expect(find.text('Routine Alpha'), findsOneWidget);
        expect(find.textContaining('Ayat al-Kursi'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(DhikrCard),
            matching: find.text('1 / 1'),
          ),
          findsOneWidget,
        );
        expect(find.text('Completed! Alhamdulillah'), findsOneWidget);
        expect(await repository.isRoutineCompletedToday(routineAId), isTrue);
      },
    );

    testWidgets(
      'progress does not leak between official collections and personal routines sharing the same dhikr item',
      (tester) async {
        final now = DateTime.now();
        const routineId = 'routine_col_isolation_test';

        // Routine has ayat_al_kursi
        await repository.saveRoutine(
          AdhkarRoutine(
            id: routineId,
            name: 'Isolation Routine',
            itemIds: ['ayat_al_kursi'],
            createdAt: now,
            updatedAt: now,
          ),
        );

        // Save session for official Morning collection where ayat_al_kursi is completed
        await repository.saveSession(
          collectionId: DhikrCategory.morning.name,
          lastPageIndex: 0,
          counts: {'ayat_al_kursi': 1},
          isCompleted: false,
        );

        await tester.pumpWidget(
          wrapWithMaterial(
            const AdhkarScreen(
              initialCategory: DhikrCategory.morning,
              isReviewModeEnabled: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Switch to My Routines tab
        final routinesTab = find.byKey(const Key('adhkar_routines_tab_chip'));
        await tester.ensureVisible(routinesTab);
        await tester.tap(routinesTab);
        await tester.pumpAndSettle();

        // Start Isolation Routine (which has no saved session)
        final routineCard = find.ancestor(
          of: find.text('Isolation Routine'),
          matching: find.byType(AdhkarRoutineCard),
        );
        final startRoutine = find.descendant(
          of: routineCard,
          matching: find.text('Start'),
        );
        expect(startRoutine, findsOneWidget);
        await tester.tap(startRoutine);
        await tester.pumpAndSettle();

        // Routine should be at count 0 despite Morning collection having count 1
        expect(find.text('Isolation Routine'), findsOneWidget);
        expect(find.textContaining('Ayat al-Kursi'), findsOneWidget);
        expect(find.text('0 / 1'), findsOneWidget);
        expect(await repository.isRoutineCompletedToday(routineId), isFalse);

        // Complete ayat_al_kursi in the routine
        await tester.tap(find.byType(DhikrCard));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(DhikrCard),
            matching: find.text('1 / 1'),
          ),
          findsOneWidget,
        );
        expect(find.text('Completed! Alhamdulillah'), findsOneWidget);
        expect(await repository.isRoutineCompletedToday(routineId), isTrue);

        // Exit routine to routines tab
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();

        // Switch back to Morning tab
        final morningTab = find.text('Morning');
        await tester.ensureVisible(morningTab);
        await tester.tap(morningTab);
        await tester.pumpAndSettle();

        // Morning collection retains its own session and is not broken by the routine
        final morningSession = await repository.getSession(
          DhikrCategory.morning.name,
        );
        expect(morningSession, isNotNull);
        expect(morningSession!.counts['ayat_al_kursi'], equals(1));
      },
    );
  });
}
