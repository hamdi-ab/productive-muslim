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
import 'package:productive_muslim/l10n/app_localizations.dart';

class FakePrayerTimeService extends PrayerTimeService {
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

  Duration? nextPrayerDuration;
  String nextPrayer = 'Dhuhr';

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
      nextPrayerDuration ?? const Duration(hours: 2);

  @override
  DateTime? getNextPrayerTime(PrayerTimes prayerTimes) =>
      DateTime.now().add(nextPrayerDuration ?? const Duration(hours: 2));
}

class FakeTaskRepository implements TaskRepository {
  List<Task> tasks = [];
  bool updateCalled = false;

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
  Future<bool> updateTask(Task task) async {
    updateCalled = true;
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
    }
    return true;
  }

  @override
  Future<int> toggleTask(int id) async => 1;

  @override
  Future<int> deactivateTask(int id) async => 1;

  @override
  Future<int> getLifetimeCompletedTasksCount() async =>
      tasks.where((t) => t.completed).length;
}

void main() {
  late FakePrayerTimeService prayerTimeService;

  setUp(() {
    if (!getIt.isRegistered<SettingsService>()) {
      getIt.registerSingleton<SettingsService>(SettingsService.empty());
    }
    prayerTimeService = FakePrayerTimeService();
    if (getIt.isRegistered<PrayerTimeService>()) {
      getIt.unregister<PrayerTimeService>();
    }
    getIt.registerSingleton<PrayerTimeService>(prayerTimeService);
  });

  tearDown(() {
    if (getIt.isRegistered<PrayerTimeService>()) {
      getIt.unregister<PrayerTimeService>();
    }
  });

  Widget buildSubject({TaskRepository? taskRepo, Task? initialTask}) {
    return RepositoryProvider<TaskRepository>.value(
      value: taskRepo ?? FakeTaskRepository(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FocusScreen(initialTask: initialTask),
      ),
    );
  }

  testWidgets(
    'renders focus screen with Niyyah banner and 25 min default timer',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('25:00'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(4));
    },
  );

  testWidgets('selecting 15m preset changes timer to 15:00', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('15 min'));
    await tester.pumpAndSettle();

    expect(find.text('15:00'), findsOneWidget);
  });

  testWidgets(
    'tapping start toggles timer to running state with pause button',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final playBtn = find.byIcon(Icons.play_arrow_rounded);
      await tester.ensureVisible(playBtn);
      await tester.tap(playBtn);
      await tester.pump();

      expect(find.text('In Flow...'), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    },
  );

  testWidgets('shows prayer collision warning banner when prayer is near', (
    tester,
  ) async {
    // 20 minutes until Dhuhr, default duration is 25m, buffer is 5m -> collision!
    prayerTimeService.nextPrayer = 'Dhuhr';
    prayerTimeService.nextPrayerDuration = const Duration(minutes: 20);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Prayer Approaching'), findsOneWidget);
    expect(
      find.text(
        'Next prayer (Dhuhr) is in 20m. Your session will overlap with Salah.',
      ),
      findsOneWidget,
    );

    // Should show 15 min suggestion chip (20 - 5 = 15m)
    final suggestionChip = find.text(
      'Set 15 min session to finish before Dhuhr',
    );
    expect(suggestionChip, findsOneWidget);

    await tester.tap(suggestionChip);
    await tester.pumpAndSettle();

    expect(find.text('15:00'), findsOneWidget);
  });

  testWidgets('renders focus screen in Arabic locale', (tester) async {
    await tester.pumpWidget(
      RepositoryProvider<TaskRepository>.value(
        value: FakeTaskRepository(),
        child: const MaterialApp(
          locale: Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FocusScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('جلسة تركيز وخشوع'), findsOneWidget);
    expect(find.text('ابدأ التركيز'), findsOneWidget);
  });
}
