import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/focus/presentation/screens/focus_screen.dart';

import '../../helpers/overflow_test_helper.dart';

class MockPrayerTimeService extends PrayerTimeService {
  Position? position = Position(
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

  Duration? nextPrayerDuration = const Duration(minutes: 50);
  String nextPrayer = 'Asr';

  @override
  Future<Position?> getCurrentPosition() async => position;

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
  String? getNextPrayerName(PrayerTimes prayerTimes) => nextPrayer;

  @override
  Duration? getTimeUntilNextPrayer(PrayerTimes prayerTimes) =>
      nextPrayerDuration ?? const Duration(minutes: 50);

  @override
  DateTime? getNextPrayerTime(PrayerTimes prayerTimes) =>
      DateTime.now().add(nextPrayerDuration ?? const Duration(minutes: 50));
}

class MockTaskRepository implements TaskRepository {
  List<Task> tasks = [];

  @override
  Stream<List<Task>> watchTasksForDate(String date) => Stream.value(tasks);

  @override
  Future<List<Task>> getTasksForDate(String date) async => tasks;

  @override
  Future<List<Task>> getTasksForRange(String start, String end) async => tasks;

  @override
  Future<Task?> getTaskById(int id) async =>
      tasks.where((t) => t.id == id).firstOrNull;

  @override
  Future<int> insertTask(Task task) async {
    tasks.add(task);
    return 1;
  }

  @override
  Future<bool> updateTask(Task task) async => true;

  @override
  Future<int> toggleTask(int id) async => 1;

  @override
  Future<int> deactivateTask(int id) async => 1;

  @override
  Future<int> getLifetimeCompletedTasksCount() async =>
      tasks.where((t) => t.completed).length;
}

void main() {
  late MockPrayerTimeService prayerTimeService;
  late MockTaskRepository taskRepository;

  setUp(() {
    if (!getIt.isRegistered<SettingsService>()) {
      getIt.registerSingleton<SettingsService>(SettingsService.empty());
    }
    prayerTimeService = MockPrayerTimeService();
    if (getIt.isRegistered<PrayerTimeService>()) {
      getIt.unregister<PrayerTimeService>();
    }
    getIt.registerSingleton<PrayerTimeService>(prayerTimeService);

    taskRepository = MockTaskRepository();
  });

  tearDown(() {
    if (getIt.isRegistered<PrayerTimeService>()) {
      getIt.unregister<PrayerTimeService>();
    }
  });

  group('FocusScreen RTL and Text Scale Resilience', () {
    testWidgets('FocusScreen has zero overflow at 1.5x scale in Arabic RTL', (
      tester,
    ) async {
      await pumpAndCheckOverflow(
        tester,
        child: RepositoryProvider<TaskRepository>.value(
          value: taskRepository,
          child: const SizedBox(height: 1200, child: FocusScreen()),
        ),
        locale: const Locale('ar'),
        textScale: 1.5,
        isDark: true,
        screenSize: const Size(360, 780),
      );
    });

    testWidgets(
      'FocusScreen with prayer collision warning has zero overflow in Arabic RTL at 1.5x',
      (tester) async {
        prayerTimeService.nextPrayer = 'Dhuhr';
        prayerTimeService.nextPrayerDuration = const Duration(minutes: 20);

        await pumpAndCheckOverflow(
          tester,
          child: RepositoryProvider<TaskRepository>.value(
            value: taskRepository,
            child: const SizedBox(height: 1200, child: FocusScreen()),
          ),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'FocusScreen with linked task card has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        final task = Task(
          id: 1,
          title: 'مراجعة معمارية النظام والتدقيق الشامل لرمز المشروع',
          lifeArea: 'العمل والمسار المهني',
          date: DateTime.now().toIso8601String().substring(0, 10),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        taskRepository.tasks = [task];

        await pumpAndCheckOverflow(
          tester,
          child: RepositoryProvider<TaskRepository>.value(
            value: taskRepository,
            child: SizedBox(
              height: 1200,
              child: FocusScreen(initialTask: task),
            ),
          ),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'FocusScreen in light mode has zero overflow at 1.5x scale in English',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: RepositoryProvider<TaskRepository>.value(
            value: taskRepository,
            child: const SizedBox(height: 1200, child: FocusScreen()),
          ),
          locale: const Locale('en'),
          textScale: 1.5,
          isDark: false,
          screenSize: const Size(360, 780),
        );
      },
    );
  });
}
