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
import 'package:productive_muslim/domain/models/tasbih_state.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/tasbih_screen.dart';
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

  Widget buildTestWidget({
    TasbihScreen screen = const TasbihScreen(),
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    );
  }

  group('TasbihScreen Counter Experience', () {
    testWidgets('renders initial 0 count and increments on tap', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
      expect(find.byKey(const Key('tasbih_counter_button')), findsOneWidget);

      // Tap counter button
      await tester.tap(find.byKey(const Key('tasbih_counter_button')));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);

      // Verify autosaved in repository
      final state = await repository.getTasbihState();
      expect(state.currentCount, 1);
    });

    testWidgets('undo action decrements count and is disabled when 0', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // At 0, tapping undo does nothing
      await tester.tap(find.byKey(const Key('tasbih_undo_button')));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);

      // Increment twice
      await tester.tap(find.byKey(const Key('tasbih_counter_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tasbih_counter_button')));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);

      // Tap undo -> count becomes 1
      await tester.tap(find.byKey(const Key('tasbih_undo_button')));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      final state = await repository.getTasbihState();
      expect(state.currentCount, 1);
    });

    testWidgets(
      'reset shows explicit confirmation dialog and preserves count on cancel',
      (tester) async {
        // Seed initial state with count = 5
        await repository.saveTasbihState(
          TasbihState(currentCount: 5, updatedAt: DateTime.now()),
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
        expect(find.text('5'), findsOneWidget);

        // Tap reset
        await tester.tap(find.byKey(const Key('tasbih_reset_button')));
        await tester.pumpAndSettle();

        // Dialog is visible
        expect(find.text('Reset Counter?'), findsOneWidget);
        expect(
          find.text(
            'Are you sure you want to reset the count to 0? Your chosen label and target will be preserved.',
          ),
          findsOneWidget,
        );

        // Tap Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Count remains 5
        expect(find.text('5'), findsOneWidget);
        final state = await repository.getTasbihState();
        expect(state.currentCount, 5);

        // Tap reset again and confirm
        await tester.tap(find.byKey(const Key('tasbih_reset_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tasbih_reset_confirm_button')));
        await tester.pumpAndSettle();

        // Count is now 0
        expect(find.text('0'), findsOneWidget);
        final resetState = await repository.getTasbihState();
        expect(resetState.currentCount, 0);
      },
    );

    testWidgets(
      'count survives recreating the screen (app restart simulation)',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Increment to 3
        await tester.tap(find.byKey(const Key('tasbih_counter_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tasbih_counter_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tasbih_counter_button')));
        await tester.pumpAndSettle();
        expect(find.text('3'), findsOneWidget);

        // Recreate screen
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('3'), findsOneWidget);
      },
    );
  });

  group('TasbihScreen Target Configuration & Acknowledgement', () {
    testWidgets(
      'distinguishes personal target from religious guidance and reaches target neutrally',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap target pill
        await tester.tap(find.byKey(const Key('tasbih_target_button')));
        await tester.pumpAndSettle();

        // Verifies disclaimer is shown
        expect(
          find.text(
            'Organizational only — not a prescribed repetition or spiritual score',
          ),
          findsOneWidget,
        );

        // Select preset 33
        await tester.tap(find.text('33'));
        await tester.pumpAndSettle();

        // Displays Target: 33
        expect(find.text('Target: 33'), findsOneWidget);

        // Set count to 32 via repository
        await repository.saveTasbihState(
          (await repository.getTasbihState()).copyWith(currentCount: 32),
        );
        await tester.pumpAndSettle();

        // Increment to 33 (target reached)
        await tester.tap(find.byKey(const Key('tasbih_counter_button')));
        await tester.pumpAndSettle();

        // Displays neutral acknowledgement
        expect(find.text('Personal target reached (33)'), findsOneWidget);

        // Can continue incrementing past target without stopping or scoring
        await tester.tap(find.byKey(const Key('tasbih_counter_button')));
        await tester.pumpAndSettle();
        expect(find.text('34'), findsOneWidget);
      },
    );

    testWidgets('sets custom numerical target', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tasbih_target_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('tasbih_custom_target_input')),
        '50',
      );
      await tester.tap(find.byKey(const Key('tasbih_save_target_button')));
      await tester.pumpAndSettle();

      expect(find.text('Target: 50'), findsOneWidget);
      final state = await repository.getTasbihState();
      expect(state.targetCount, 50);
    });
  });

  group('TasbihScreen Remembrance Selection & Disclaimers', () {
    testWidgets(
      'presents custom label with explicit non-religious badge and disclaimer',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('tasbih_set_remembrance_button')),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('tasbih_custom_label_option')));
        await tester.pumpAndSettle();

        // Verifies custom label notice inside dialog
        expect(
          find.text('Your personal label — not religiously sourced text'),
          findsWidgets,
        );

        await tester.enterText(
          find.byKey(const Key('tasbih_custom_label_input')),
          'Salawat & Istighfar',
        );
        await tester.tap(
          find.byKey(const Key('tasbih_custom_label_save_button')),
        );
        await tester.pumpAndSettle();

        // Card displays Personal Label badge and custom text
        expect(
          find.byKey(const Key('tasbih_personal_label_badge')),
          findsOneWidget,
        );
        expect(find.text('Salawat & Istighfar'), findsOneWidget);
        expect(
          find.text('Your personal label — not religiously sourced text'),
          findsOneWidget,
        );

        final state = await repository.getTasbihState();
        expect(state.customLabel, 'Salawat & Istighfar');
        expect(state.dhikrId, isNull);
      },
    );

    testWidgets(
      'library selection only allows approved items and hides pending-review items',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('tasbih_set_remembrance_button')),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('tasbih_choose_library_option')));
        await tester.pumpAndSettle();

        // In draft catalog without review mode, pending review items are strictly hidden
        for (final item in AdhkarCatalog.all) {
          expect(find.text(item.arabic), findsNothing);
        }

        // Close picker sheet
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();

        // Now enable review mode so items become eligible for selection
        await repository.setReviewModeEnabled(true);
        await tester.pumpWidget(
          buildTestWidget(
            screen: const TasbihScreen(isReviewModeEnabled: true),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('tasbih_set_remembrance_button')),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('tasbih_choose_library_option')));
        await tester.pumpAndSettle();

        final firstItem = AdhkarCatalog.all.first;
        expect(find.text(firstItem.arabic), findsOneWidget);

        await tester.tap(find.text(firstItem.arabic));
        await tester.pumpAndSettle();

        // Screen now displays Approved Library badge
        expect(find.text('Approved Library'), findsOneWidget);
        expect(find.text(firstItem.arabic), findsOneWidget);

        final state = await repository.getTasbihState();
        expect(state.dhikrId, firstItem.id);
      },
    );

    testWidgets(
      'handles retired or unapproved library entries safely with prominent warning',
      (tester) async {
        // Seed state with an unapproved/retired dhikrId
        final unapprovedItem = AdhkarCatalog.all.first;
        await repository.saveTasbihState(
          TasbihState(
            currentCount: 10,
            dhikrId: unapprovedItem.id,
            updatedAt: DateTime.now(),
          ),
        );

        // Load screen with review mode disabled (normal user)
        await tester.pumpWidget(
          buildTestWidget(
            screen: const TasbihScreen(isReviewModeEnabled: false),
          ),
        );
        await tester.pumpAndSettle();

        // Prominent retired warning is displayed and approved badge is NOT shown
        expect(find.byKey(const Key('tasbih_retired_warning')), findsOneWidget);
        expect(find.text('Remembrance retired or unapproved'), findsOneWidget);
        expect(find.text('Approved Library'), findsNothing);

        // Converting to custom label clears dhikrId and converts safely
        await tester.tap(
          find.byKey(const Key('tasbih_convert_to_custom_button')),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('tasbih_retired_warning')), findsNothing);
        expect(
          find.byKey(const Key('tasbih_personal_label_badge')),
          findsOneWidget,
        );

        final state = await repository.getTasbihState();
        expect(state.dhikrId, isNull);
        expect(state.customLabel, unapprovedItem.id);
      },
    );
  });

  group('TasbihScreen Session Isolation', () {
    testWidgets(
      'counting does not modify official collection or routine sessions',
      (tester) async {
        // 1. Seed official morning session
        await repository.saveSession(
          collectionId: 'morning',
          lastPageIndex: 1,
          counts: {'morning_1': 3},
        );

        // 2. Open Tasbih screen and increment 10 times
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        for (int i = 0; i < 10; i++) {
          await tester.tap(find.byKey(const Key('tasbih_counter_button')));
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pumpAndSettle();

        expect(find.text('10'), findsOneWidget);

        // 3. Verify official session is completely untouched
        final morning = await repository.getSession('morning');
        expect(morning, isNotNull);
        expect(morning!.counts['morning_1'], 3);
        expect(morning.lastPageIndex, 1);
      },
    );
  });
}
