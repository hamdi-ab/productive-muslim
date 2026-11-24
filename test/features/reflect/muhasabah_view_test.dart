import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/muhasabah_entry.dart';
import 'package:productive_muslim/domain/repositories/muhasabah_repository.dart';
import 'package:productive_muslim/features/reflect/presentation/widgets/muhasabah_view.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockMuhasabahRepository mockRepo;
  late SettingsService settings;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    settings = SettingsService(prefs: await SharedPreferences.getInstance());

    mockRepo = MockMuhasabahRepository();
    stubDefaultRepositoryMocks(muhasabahRepo: mockRepo);

    getIt.registerSingleton<SettingsService>(settings);
    getIt.registerSingleton<MuhasabahRepository>(mockRepo);
    getIt.registerLazySingleton<PrayerTimeService>(
      () => MockPrayerTimeService(),
    );
    getIt.registerLazySingleton<AdhkarService>(
      () => AdhkarService(settingsService: settings),
    );

    registerFallbackValue(
      const MuhasabahEntry(
        id: 0,
        date: '',
        content: '',
        createdAt: 0,
        updatedAt: 0,
      ),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpSubject(
    WidgetTester tester, {
    List<MuhasabahEntry> initialEntries = const [],
  }) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    when(() => mockRepo.watchEntriesForDate(any()))
        .thenAnswer((_) => Stream.value(initialEntries));
    when(() => mockRepo.getEntriesForDate(any()))
        .thenAnswer((_) async => initialEntries);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RepositoryProvider<MuhasabahRepository>.value(
            value: mockRepo,
            child: const MuhasabahView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('MuhasabahView Tests', () {
    testWidgets(
      'renders verified Umar ibn al-Khattab quotation with authentic hadith citation',
      (tester) async {
        await pumpSubject(tester);

        // Banner title & Arabic heading
        expect(find.text('حَاسِبُوا أَنْفُسَكُمْ'), findsOneWidget);
        expect(find.text('Evening Muhasabah'), findsOneWidget);

        // Verified quotation wording
        expect(
          find.text(
            '“Take account of yourselves before you are taken to account, and weigh your deeds before they are weighed.”',
          ),
          findsOneWidget,
        );

        // Authoritative scholarly source citation (Item 4)
        expect(
          find.text(
            '— Umar ibn al-Khattab (RA) · Sunan al-Tirmidhi (2459), Kitab al-Zuhd by Ahmad (177)',
          ),
          findsOneWidget,
        );

        // Gentle empty state (no guilt, no streaks)
        expect(find.byIcon(Icons.spa_outlined), findsOneWidget);
        expect(
          find.text(
            'Take a quiet moment to reflect whenever you are ready. No scores, no streaks.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'supports selecting multiple prompts in one reflection session and saves both (Item 1)',
      (tester) async {
        when(() => mockRepo.insertEntry(any())).thenAnswer((_) async => 1);

        await pumpSubject(tester);

        // 1. Select Gratitude prompt
        await tester.tap(find.text('Gratitude'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'What blessing did you receive today that you are grateful for?',
          ),
          findsOneWidget,
        );

        // 2. Select Patience prompt as well (multiple prompts in one session!)
        await tester.tap(find.text('Patience'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Where did you face difficulty today, and how did you seek Allah\'s help?',
          ),
          findsOneWidget,
        );

        // Enter answers for both prompts
        final textFields = find.byType(TextField);
        await tester.enterText(
          textFields.at(0),
          'Grateful for health and time with family.',
        );
        await tester.enterText(
          textFields.at(1),
          'Exercised patience during a delay at work.',
        );
        await tester.pumpAndSettle();

        // Save reflection
        final saveBtn = find.widgetWithText(FilledButton, 'Save Reflection');
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        // Verify insertEntry captured both prompts and their answers
        final captured = verify(() => mockRepo.insertEntry(captureAny()))
            .captured;
        expect(captured.length, equals(1));
        final entry = captured.first as MuhasabahEntry;

        expect(entry.promptId, equals('gratitude,patience'));
        expect(entry.promptResponses.length, equals(2));
        expect(entry.promptResponses[0].promptId, equals('gratitude'));
        expect(
          entry.promptResponses[0].response,
          equals('Grateful for health and time with family.'),
        );
        expect(entry.promptResponses[1].promptId, equals('patience'));
        expect(
          entry.promptResponses[1].response,
          equals('Exercised patience during a delay at work.'),
        );
      },
    );

    testWidgets(
      'supports combining multiple prompts with free writing in one reflection (Item 1)',
      (tester) async {
        when(() => mockRepo.insertEntry(any())).thenAnswer((_) async => 1);

        await pumpSubject(tester);

        // Select Gratitude prompt
        await tester.tap(find.text('Gratitude'));
        await tester.pumpAndSettle();

        final textFields = find.byType(TextField);
        // Prompt input
        await tester.enterText(
          textFields.at(0),
          'Grateful for clarity after prayer.',
        );
        // Free writing input
        await tester.enterText(
          textFields.at(1),
          'Also feeling optimistic about tomorrow.',
        );
        await tester.pumpAndSettle();

        // Save
        final saveBtn = find.widgetWithText(FilledButton, 'Save Reflection');
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        final captured = verify(() => mockRepo.insertEntry(captureAny()))
            .captured;
        final entry = captured.first as MuhasabahEntry;

        expect(entry.promptResponses.length, equals(1));
        expect(
          entry.promptResponses[0].response,
          equals('Grateful for clarity after prayer.'),
        );
        expect(
          entry.freeWriting,
          equals('Also feeling optimistic about tomorrow.'),
        );
      },
    );

    testWidgets(
      'supports pure free writing without selecting any prompts (Item 1)',
      (tester) async {
        when(() => mockRepo.insertEntry(any())).thenAnswer((_) async => 1);

        await pumpSubject(tester);

        // Type directly into free reflection field without selecting prompts
        await tester.enterText(
          find.byType(TextField),
          'Open evening contemplation without any prompts.',
        );
        await tester.pumpAndSettle();

        final saveBtn = find.widgetWithText(FilledButton, 'Save Reflection');
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        final captured = verify(() => mockRepo.insertEntry(captureAny()))
            .captured;
        final entry = captured.first as MuhasabahEntry;

        expect(entry.promptId, isNull);
        expect(entry.promptResponses, isEmpty);
        expect(
          entry.content,
          equals('Open evening contemplation without any prompts.'),
        );
        expect(
          entry.freeWriting,
          equals('Open evening contemplation without any prompts.'),
        );
      },
    );

    testWidgets(
      'preserves original createdAt timestamp when editing a reflection (Item 2)',
      (tester) async {
        const originalCreatedAt = 1600000000000;
        final sample = MuhasabahEntry(
          id: 10,
          date: '2026-11-18',
          content: 'Original thoughts before evening prayer.',
          tags: '#Tawakkul',
          createdAt: originalCreatedAt,
          updatedAt: originalCreatedAt,
        );

        when(() => mockRepo.updateEntry(any())).thenAnswer((_) async => true);

        await pumpSubject(tester, initialEntries: [sample]);

        // Tap edit
        final editBtn = find.byIcon(Icons.edit_outlined);
        await tester.ensureVisible(editBtn);
        await tester.tap(editBtn);
        await tester.pumpAndSettle();

        // Verify editor is in editing mode
        expect(find.text('Update Reflection'), findsOneWidget);

        // Edit text
        await tester.enterText(
          find.byType(TextField),
          'Updated thoughts before evening prayer.',
        );
        await tester.pumpAndSettle();

        // Save updated reflection
        final updateBtn = find.widgetWithText(
          FilledButton,
          'Update Reflection',
        );
        await tester.ensureVisible(updateBtn);
        await tester.tap(updateBtn);
        await tester.pumpAndSettle();

        // Verify updateEntry was called with the exact original createdAt timestamp
        final captured = verify(() => mockRepo.updateEntry(captureAny()))
            .captured;
        expect(captured.length, equals(1));
        final updatedEntry = captured.first as MuhasabahEntry;

        expect(updatedEntry.id, equals(10));
        expect(
          updatedEntry.content,
          equals('Updated thoughts before evening prayer.'),
        );
        expect(
          updatedEntry.createdAt,
          equals(originalCreatedAt),
          reason: 'Original createdAt must be preserved when editing (Item 2)',
        );
        expect(
          updatedEntry.updatedAt,
          greaterThan(originalCreatedAt),
          reason: 'updatedAt must be refreshed on edit',
        );
      },
    );

    testWidgets('displays saved reflections for today with time and tags', (
      tester,
    ) async {
      final sample = MuhasabahEntry(
        id: 42,
        date: '2026-11-18',
        content: 'Reflected on how barakah came through focus after Fajr.',
        promptText: 'How did you strive for excellence (Ihsan)?',
        tags: '#Ihsan #Shukr',
        createdAt: DateTime(2026, 11, 18, 20, 30).millisecondsSinceEpoch,
        updatedAt: DateTime(2026, 11, 18, 20, 30).millisecondsSinceEpoch,
      );

      await pumpSubject(tester, initialEntries: [sample]);

      expect(
        find.text('Reflected on how barakah came through focus after Fajr.'),
        findsOneWidget,
      );
      expect(
        find.text('Q: How did you strive for excellence (Ihsan)?'),
        findsOneWidget,
      );
      expect(find.text('#Ihsan'), findsWidgets);
      expect(find.text('1'), findsOneWidget); // badge count
    });

    testWidgets('deleting a reflection prompts confirmation dialog', (
      tester,
    ) async {
      final sample = const MuhasabahEntry(
        id: 99,
        date: '2026-11-18',
        content: 'To be removed.',
        createdAt: 1700000000000,
        updatedAt: 1700000000000,
      );

      when(() => mockRepo.deleteEntry(99)).thenAnswer((_) async => 1);

      await pumpSubject(tester, initialEntries: [sample]);

      // Tap delete icon
      final deleteBtn = find.byIcon(Icons.delete_outline_rounded);
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.text('Delete Reflection?'), findsOneWidget);
      expect(
        find.text('Are you sure you want to remove this reflection entry?'),
        findsOneWidget,
      );

      // Confirm delete
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.deleteEntry(99)).called(1);
    });

    testWidgets(
      'renders daily vitality & wellbeing shortcut card and navigates to EnergyScreen',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/reflect',
          routes: [
            GoRoute(
              path: '/reflect',
              builder: (_, _) => Scaffold(
                body: RepositoryProvider<MuhasabahRepository>.value(
                  value: mockRepo,
                  child: const MuhasabahView(),
                ),
              ),
            ),
            GoRoute(
              path: AppRoutes.energy,
              builder: (_, _) => const Scaffold(body: Text('Energy Screen')),
            ),
          ],
        );

        when(() => mockRepo.watchEntriesForDate(any()))
            .thenAnswer((_) => Stream.value([]));
        when(() => mockRepo.getEntriesForDate(any()))
            .thenAnswer((_) async => []);

        await tester.binding.setSurfaceSize(const Size(800, 1600));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        );
        await tester.pumpAndSettle();

        final energyCard = find.byKey(
          const Key('muhasabah_energy_shortcut_card'),
        );
        expect(energyCard, findsOneWidget);

        await tester.ensureVisible(energyCard);
        await tester.tap(energyCard);
        await tester.pumpAndSettle();

        expect(find.text('Energy Screen'), findsOneWidget);
      },
    );
  });
}
