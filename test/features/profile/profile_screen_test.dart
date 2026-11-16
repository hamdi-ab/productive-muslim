import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_heatmap_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_radar_chart_card.dart';
import 'package:productive_muslim/features/profile/presentation/screens/profile_screen.dart';
import 'package:productive_muslim/features/profile/presentation/widgets/profile_action_hub.dart';
import 'package:productive_muslim/features/profile/presentation/widgets/profile_badges_card.dart';
import 'package:productive_muslim/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:productive_muslim/features/profile/presentation/widgets/profile_lifetime_stats_grid.dart';
import 'package:productive_muslim/features/profile/presentation/widgets/profile_qualities_coaching_card.dart';
import 'package:productive_muslim/features/profile/presentation/widgets/profile_tier_progress_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockBarakahRepository extends Mock implements BarakahRepository {}

class MockHabitRepository extends Mock implements HabitRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockBarakahRepository mockRepository;
  late MockHabitRepository mockHabitRepository;
  late MockTaskRepository mockTaskRepository;

  const testEntry = BarakahEntry(
    id: 1,
    date: '2026-11-09',
    sourceIds: ['Charity', 'GoodIntentions'],
    createdAt: 0,
  );

  setUpAll(() {
    registerFallbackValue(testEntry);
  });

  setUp(() {
    mockRepository = MockBarakahRepository();
    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => [testEntry]);

    mockHabitRepository = MockHabitRepository();
    when(() => mockHabitRepository.watchOverallStreak())
        .thenAnswer((_) => Stream.value(21));
    when(() => mockHabitRepository.getOverallStreak())
        .thenAnswer((_) async => 21);
    when(() => mockHabitRepository.getLongestStreak())
        .thenAnswer((_) async => 28);
    when(() => mockHabitRepository.getLifetimeCompletionsCount())
        .thenAnswer((_) async => 142);
    when(
      () => mockHabitRepository.getCompletionsCountByDate(
        days: any(named: 'days'),
      ),
    ).thenAnswer((_) async => {});

    mockTaskRepository = MockTaskRepository();
    when(() => mockTaskRepository.getLifetimeCompletedTasksCount())
        .thenAnswer((_) async => 89);

    if (getIt.isRegistered<HabitRepository>()) {
      getIt.unregister<HabitRepository>();
    }
    getIt.registerSingleton<HabitRepository>(mockHabitRepository);

    if (getIt.isRegistered<TaskRepository>()) {
      getIt.unregister<TaskRepository>();
    }
    getIt.registerSingleton<TaskRepository>(mockTaskRepository);

    if (!getIt.isRegistered<SettingsService>()) {
      getIt.registerSingleton<SettingsService>(SettingsService.empty());
    }
  });

  tearDown(() {
    if (getIt.isRegistered<HabitRepository>()) {
      getIt.unregister<HabitRepository>();
    }
    if (getIt.isRegistered<TaskRepository>()) {
      getIt.unregister<TaskRepository>();
    }
  });

  Widget buildScreen({Locale locale = const Locale('en')}) {
    return RepositoryProvider<BarakahRepository>.value(
      value: mockRepository,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProfileScreen(),
      ),
    );
  }

  testWidgets(
    'renders Profile screen with hero identity card and spiritual rank',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ProfileHeaderCard), findsOneWidget);
      expect(find.text('Productive Seeker'), findsOneWidget);
      expect(find.textContaining('Al-Mubarak'), findsWidgets);
    },
  );

  testWidgets('renders all industry-standard profile components', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 3200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.byType(ProfileHeaderCard), findsOneWidget);
    expect(find.byType(ProfileTierProgressCard), findsOneWidget);
    expect(find.byType(ProfileLifetimeStatsGrid), findsOneWidget);
    expect(find.byType(ProfileBadgesCard), findsOneWidget);
    expect(find.byType(ProfileQualitiesCoachingCard), findsOneWidget);
    expect(find.byType(BarakahRadarChartCard), findsOneWidget);
    expect(find.byType(BarakahHeatmapCard), findsOneWidget);
    expect(find.byType(ProfileActionHub), findsOneWidget);
  });

  testWidgets('tapping edit profile opens modal dialog with form inputs', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    // Tap edit icon on header
    final editFinder = find.byIcon(Icons.edit_outlined);
    expect(editFinder, findsOneWidget);
    await tester.tap(editFinder);
    await tester.pumpAndSettle();

    // Verify dialog opened
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Display Name'), findsOneWidget);
    expect(find.text('Choose Avatar Symbol'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Profile'), findsNothing);
  });

  testWidgets('tapping a milestone badge opens bottom sheet detail', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 3200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    // Tap the Fajr Vanguard badge
    final fajrFinder = find.text('Fajr Vanguard');
    expect(fajrFinder, findsOneWidget);
    await tester.tap(fajrFinder);
    await tester.pumpAndSettle();

    // Verify modal bottom sheet opened with Hadith
    expect(find.text('Unlocked'), findsOneWidget);
    expect(find.textContaining('rak\'ahs of Fajr'), findsOneWidget);
  });

  testWidgets('renders Arabic RTL locale correctly with all widgets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 3200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildScreen(locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileHeaderCard), findsOneWidget);
    expect(find.text('طالب البركة'), findsOneWidget);
    expect(find.textContaining('الـمُبـارك'), findsWidgets);
    expect(find.byType(ProfileTierProgressCard), findsOneWidget);
    expect(find.byType(ProfileLifetimeStatsGrid), findsOneWidget);
    expect(find.byType(ProfileBadgesCard), findsOneWidget);
    expect(find.byType(ProfileActionHub), findsOneWidget);
  });
}
