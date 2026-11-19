import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/focus/presentation/widgets/focus_soundscape_card.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_daily_ayah_card.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_daily_progress_section.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_qualities_carousel.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockBarakahRepository extends Mock implements BarakahRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

class MockHabitRepository extends Mock implements HabitRepository {}

class MockSettingsService extends Mock implements SettingsService {}

void main() {
  late MockBarakahRepository mockBarakahRepo;
  late MockTaskRepository mockTaskRepo;
  late MockHabitRepository mockHabitRepo;
  late MockSettingsService mockSettings;

  setUp(() {
    mockBarakahRepo = MockBarakahRepository();
    mockTaskRepo = MockTaskRepository();
    mockHabitRepo = MockHabitRepository();
    mockSettings = MockSettingsService();

    when(() => mockBarakahRepo.getEntriesForDate(any())).thenAnswer(
      (_) async => [
        const BarakahEntry(
          id: 1,
          date: '2026-11-11',
          note: 'Felt deep peace during Fajr',
          sourceIds: ['s1'],
          createdAt: 1000,
        ),
      ],
    );

    when(() => mockTaskRepo.watchTasksForDate(any())).thenAnswer(
      (_) => Stream.value([
        const Task(
          id: 1,
          title: 'Memorize Surah',
          lifeArea: 'spiritual',
          date: '2026-11-11',
          completed: true,
          createdAt: 1000,
        ),
        const Task(
          id: 2,
          title: 'Read Tafsir',
          lifeArea: 'knowledge',
          date: '2026-11-11',
          completed: false,
          createdAt: 1000,
        ),
      ]),
    );

    when(() => mockHabitRepo.watchActiveHabits()).thenAnswer(
      (_) => Stream.value([
        const Habit(
          id: 1,
          name: 'Morning Adhkar',
          category: 'spiritual',
          frequency: 'daily',
          targetDays: '7',
          createdAt: 1000,
        ),
      ]),
    );

    when(() => mockHabitRepo.watchCompletionsForDate(any()))
        .thenAnswer((_) => Stream.value({1: true}));

    when(() => mockSettings.getDailyEnergy(any()))
        .thenReturn((physical: 4, spiritual: 4, mental: 4));
    when(() => mockSettings.totalFocusMinutes).thenReturn(45);

    if (getIt.isRegistered<BarakahRepository>()) {
      getIt.unregister<BarakahRepository>();
    }
    getIt.registerSingleton<BarakahRepository>(mockBarakahRepo);

    if (getIt.isRegistered<SettingsService>()) {
      getIt.unregister<SettingsService>();
    }
    getIt.registerSingleton<SettingsService>(mockSettings);
  });

  tearDown(() {
    if (getIt.isRegistered<BarakahRepository>()) {
      getIt.unregister<BarakahRepository>();
    }
    if (getIt.isRegistered<SettingsService>()) {
      getIt.unregister<SettingsService>();
    }
  });

  Widget wrapWithProviders(Widget child, {Locale locale = const Locale('en')}) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TaskRepository>.value(value: mockTaskRepo),
        RepositoryProvider<HabitRepository>.value(value: mockHabitRepo),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  group('HomeDynamicWidgetsTests', () {
    testWidgets('HomeDailyAyahCard renders dynamic ayah and reflection note', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(const HomeDailyAyahCard(isDark: true)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeDailyAyahCard), findsOneWidget);
      expect(find.text('AYAH OF BARAKAH'), findsOneWidget);
      expect(find.text('Reflect & Journal'), findsOneWidget);
      expect(
        find.textContaining(
          'Today\'s reflection: "Felt deep peace during Fajr"',
        ),
        findsOneWidget,
      );

      // Bookmark button toggle
      final bookmarkBtn = find.byIcon(Icons.bookmark_outline_rounded);
      expect(bookmarkBtn, findsOneWidget);
      await tester.tap(bookmarkBtn);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    });

    testWidgets('HomeDailyAyahCard renders in Arabic correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const HomeDailyAyahCard(isDark: false),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('آية البركة اليومية'), findsOneWidget);
      expect(find.text('تدوين وتأمل'), findsOneWidget);
      expect(
        find.textContaining('تأمل اليوم: "Felt deep peace during Fajr"'),
        findsOneWidget,
      );
    });

    testWidgets('HomeQualitiesCarousel renders 9 essential qualities', (
      tester,
    ) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        wrapWithProviders(
          Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return HomeQualitiesCarousel(l10n: l10n);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Essential Qualities'), findsOneWidget);
      expect(find.text('Explore All'), findsOneWidget);
      expect(find.text('Ikhlas (Sincerity)'), findsOneWidget);
      expect(find.text('Muraqabah (Mindfulness)'), findsOneWidget);
    });

    testWidgets('HomeQualitiesCarousel renders localized in Arabic', (
      tester,
    ) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        wrapWithProviders(
          Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return HomeQualitiesCarousel(l10n: l10n);
            },
          ),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الصفات الأساسية التسع'), findsOneWidget);
      expect(find.text('عرض الكل'), findsOneWidget);
      expect(find.text('الإخلاص لله'), findsOneWidget);
    });

    testWidgets('HomeDailyProgressSection displays localized progress', (
      tester,
    ) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        wrapWithProviders(
          Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return HomeDailyProgressSection(today: '2026-11-11', l10n: l10n);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 / 2 done'), findsOneWidget);
      expect(find.text('1 / 1 done'), findsOneWidget);
    });

    testWidgets('HomeDailyProgressSection displays Arabic numerals in Arabic', (
      tester,
    ) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        wrapWithProviders(
          Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return HomeDailyProgressSection(today: '2026-11-11', l10n: l10n);
            },
          ),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تم إنجاز ١ من ٢'), findsOneWidget);
      expect(find.text('تم إنجاز ١ من ١'), findsOneWidget);
    });

    testWidgets('FocusSoundscapeCard renders localized in Arabic and English', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FocusSoundscapeCard(
              selectedSoundscapeIndex: 0,
              isRunning: true,
              onSoundscapeChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AMBIENT BARAKAH SOUNDSCAPE'), findsOneWidget);
      expect(find.text('Rain & Makkah'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FocusSoundscapeCard(
              selectedSoundscapeIndex: 0,
              isRunning: true,
              onSoundscapeChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('أصوات البركة والسكينة'), findsOneWidget);
      expect(find.text('مطر الحرم'), findsOneWidget);
      expect(find.text('مفعّل'), findsOneWidget);
    });
  });
}
