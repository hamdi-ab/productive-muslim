import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
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
      MuhasabahEntry(id: 0, date: '', content: '', createdAt: 0, updatedAt: 0),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildSubject({List<MuhasabahEntry> initialEntries = const []}) {
    when(() => mockRepo.watchEntriesForDate(any()))
        .thenAnswer((_) => Stream.value(initialEntries));
    when(() => mockRepo.getEntriesForDate(any()))
        .thenAnswer((_) async => initialEntries);

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RepositoryProvider<MuhasabahRepository>.value(
          value: mockRepo,
          child: const MuhasabahView(),
        ),
      ),
    );
  }

  group('MuhasabahView Tests', () {
    testWidgets(
      'renders contemplative banner, prompts, and gentle empty state',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // Banner text
        expect(find.text('حَاسِبُوا أَنْفُسَكُمْ'), findsOneWidget);
        expect(find.text('Evening Muhasabah'), findsOneWidget);

        // Prompts
        expect(find.text('Thoughtful Prompts'), findsOneWidget);
        expect(find.text('Free Reflection'), findsOneWidget);
        expect(find.text('Gratitude'), findsOneWidget);
        expect(find.text('Patience'), findsOneWidget);

        // Input card
        expect(find.text('Reflection'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Save Reflection'), findsOneWidget);

        // Save button disabled when input is empty
        final saveButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Save Reflection'),
        );
        expect(saveButton.onPressed, isNull);

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

    testWidgets('selecting a prompt shows guiding question and suggests tag', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Tap Gratitude prompt
      await tester.tap(find.text('Gratitude'));
      await tester.pumpAndSettle();

      // Displays guided question
      expect(
        find.text(
          'What blessing did you receive today that you are grateful for?',
        ),
        findsOneWidget,
      );

      // Auto-selected tag
      expect(find.text('#Shukr'), findsWidgets);
    });

    testWidgets('typing reflection enables Save button and saves entry', (
      tester,
    ) async {
      when(() => mockRepo.insertEntry(any())).thenAnswer((_) async => 1);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter reflection
      await tester.enterText(
        find.byType(TextField),
        'Grateful for patience during a challenging exam today.',
      );
      await tester.pumpAndSettle();

      // Tap tag #Sabr
      await tester.tap(find.text('#Sabr'));
      await tester.pumpAndSettle();

      // Save button enabled
      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save Reflection'),
      );
      expect(saveButton.onPressed, isNotNull);

      // Tap save
      await tester.tap(find.widgetWithText(FilledButton, 'Save Reflection'));
      await tester.pumpAndSettle();

      // Verify insertEntry called
      verify(
        () => mockRepo.insertEntry(
          any(
            that: isA<MuhasabahEntry>().having(
              (e) => e.content,
              'content',
              'Grateful for patience during a challenging exam today.',
            ),
          ),
        ),
      ).called(1);

      // Input is cleared
      expect(
        find.text('Grateful for patience during a challenging exam today.'),
        findsNothing,
      );
    });

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

      await tester.pumpWidget(buildSubject(initialEntries: [sample]));
      await tester.pumpAndSettle();

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

    testWidgets('editing a reflection populates editor and calls updateEntry', (
      tester,
    ) async {
      final sample = MuhasabahEntry(
        id: 10,
        date: '2026-11-18',
        content: 'Original thoughts before evening prayer.',
        tags: '#Tawakkul',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      when(() => mockRepo.updateEntry(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(buildSubject(initialEntries: [sample]));
      await tester.pumpAndSettle();

      // Tap edit
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      // Editor now has content
      expect(
        find.text('Original thoughts before evening prayer.'),
        findsNWidgets(2),
      ); // in editor and list
      expect(find.text('Update Reflection'), findsOneWidget);

      // Save updated reflection
      await tester.tap(find.widgetWithText(FilledButton, 'Update Reflection'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.updateEntry(any())).called(1);
    });

    testWidgets('deleting a reflection prompts confirmation dialog', (
      tester,
    ) async {
      final sample = MuhasabahEntry(
        id: 99,
        date: '2026-11-18',
        content: 'To be removed.',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      when(() => mockRepo.deleteEntry(99)).thenAnswer((_) async => 1);

      await tester.pumpWidget(buildSubject(initialEntries: [sample]));
      await tester.pumpAndSettle();

      // Tap delete icon
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
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
  });
}
