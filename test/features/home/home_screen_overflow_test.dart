import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/home/presentation/screens/home_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/overflow_test_helper.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockHabitRepository extends Mock implements HabitRepository {}

class MockPrayerTimeService extends PrayerTimeService {
  final Position _mockPos = Position(
    longitude: 39.8262,
    latitude: 21.4225,
    timestamp: DateTime.now(),
    accuracy: 1.0,
    altitude: 0.0,
    altitudeAccuracy: 1.0,
    heading: 0.0,
    headingAccuracy: 1.0,
    speed: 0.0,
    speedAccuracy: 1.0,
  );

  @override
  Future<Position?> getCurrentPosition() async => _mockPos;

  @override
  Position? get cachedPosition => _mockPos;

  @override
  String? get cachedLocationName => 'London, UK';

  @override
  PrayerTimes? get cachedPrayerTimes => getPrayerTimes(_mockPos);

  @override
  PrayerTimes? getPrayerTimes(Position position, {DateTime? date}) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = CalculationMethodParameters.muslimWorldLeague();
    return PrayerTimes(
      date: date ?? DateTime.now(),
      coordinates: coordinates,
      calculationParameters: params,
    );
  }

  @override
  String? getNextPrayerName(PrayerTimes prayerTimes) => 'Asr';

  @override
  Duration? getTimeUntilNextPrayer(PrayerTimes prayerTimes) =>
      const Duration(minutes: 42);

  @override
  DateTime? getNextPrayerTime(PrayerTimes prayerTimes) =>
      DateTime.now().add(const Duration(minutes: 42));

  @override
  String getLocationName(Position? position) => 'London, UK';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTaskRepository mockTaskRepo;
  late MockHabitRepository mockHabitRepo;
  late SettingsService settingsService;
  late AdhkarService adhkarService;
  late HijriService hijriService;
  late MockPrayerTimeService mockPrayerService;

  final sampleTasks = [
    Task(
      id: 1,
      title: 'Review Product Architecture Document',
      lifeArea: 'work',
      startMinutes: 330,
      endMinutes: 510,
      date: '2026-09-17',
      completed: true,
      createdAt: 0,
    ),
    Task(
      id: 2,
      title: 'Dhuhr Prayer in Congregation',
      lifeArea: 'spiritual',
      date: '2026-09-17',
      completed: false,
      createdAt: 1,
    ),
  ];

  final sampleHabits = [
    const Habit(
      id: 1,
      name: 'Morning Adhkar Routine',
      category: 'spiritual',
      frequency: 'daily',
      createdAt: 0,
    ),
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);
    adhkarService = AdhkarService(settingsService: settingsService);
    hijriService = HijriService();
    mockPrayerService = MockPrayerTimeService();

    mockTaskRepo = MockTaskRepository();
    mockHabitRepo = MockHabitRepository();

    when(() => mockTaskRepo.watchTasksForDate(any()))
        .thenAnswer((_) => Stream.value(sampleTasks));
    when(() => mockTaskRepo.getTasksForDate(any()))
        .thenAnswer((_) async => sampleTasks);

    when(() => mockHabitRepo.watchActiveHabits())
        .thenAnswer((_) => Stream.value(sampleHabits));
    when(() => mockHabitRepo.watchCompletionsForDate(any()))
        .thenAnswer((_) => Stream.value(<int, bool>{1: true}));
    when(() => mockHabitRepo.watchOverallStreak())
        .thenAnswer((_) => Stream.value(5));
    when(() => mockHabitRepo.getOverallStreak()).thenAnswer((_) async => 5);
    when(() => mockHabitRepo.getCompletionsForDateMap(any()))
        .thenAnswer((_) async => <int, bool>{1: true});
    when(() => mockHabitRepo.getStreak(any())).thenAnswer((_) async => 5);

    if (!getIt.isRegistered<SettingsService>()) {
      getIt.registerSingleton<SettingsService>(settingsService);
    }
    if (!getIt.isRegistered<AdhkarService>()) {
      getIt.registerSingleton<AdhkarService>(adhkarService);
    }
    if (!getIt.isRegistered<HijriService>()) {
      getIt.registerSingleton<HijriService>(hijriService);
    }
    if (!getIt.isRegistered<PrayerTimeService>()) {
      getIt.registerSingleton<PrayerTimeService>(mockPrayerService);
    }
  });

  tearDown(() {
    if (getIt.isRegistered<PrayerTimeService>()) {
      getIt.unregister<PrayerTimeService>();
    }
    if (getIt.isRegistered<HijriService>()) {
      getIt.unregister<HijriService>();
    }
    if (getIt.isRegistered<AdhkarService>()) {
      getIt.unregister<AdhkarService>();
    }
    if (getIt.isRegistered<SettingsService>()) {
      getIt.unregister<SettingsService>();
    }
  });

  Widget buildSubject() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TaskRepository>.value(value: mockTaskRepo),
        RepositoryProvider<HabitRepository>.value(value: mockHabitRepo),
      ],
      child: const SizedBox(height: 850, child: Scaffold(body: HomeContent())),
    );
  }

  group('HomeScreen and HomeContent RTL and Text Scale Resilience', () {
    testWidgets('HomeContent has zero overflow at 1.5x scale in Arabic RTL', (
      tester,
    ) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('ar'),
        textScale: 1.5,
        isDark: true,
        screenSize: const Size(360, 780),
      );
    });

    testWidgets(
      'HomeContent has zero overflow in light mode at 1.5x scale in English',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: buildSubject(),
          locale: const Locale('en'),
          textScale: 1.5,
          isDark: false,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'HomeContent has zero overflow in dark mode at 1.5x scale in English',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: buildSubject(),
          locale: const Locale('en'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'HomeContent renders solar arc and prayer card cleanly without overflow',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: buildSubject(),
          locale: const Locale('en'),
          textScale: 1.2,
          isDark: true,
          screenSize: const Size(360, 780),
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
