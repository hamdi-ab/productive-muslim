import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart';
import 'package:productive_muslim/domain/models/muhasabah_entry.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';
import 'package:productive_muslim/domain/repositories/muhasabah_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';

class MockAdhkarRepository extends Mock implements AdhkarRepository {}

class MockBarakahRepository extends Mock implements BarakahRepository {}

class MockHabitRepository extends Mock implements HabitRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

class MockIntentionRepository extends Mock implements IntentionRepository {}

class MockMuhasabahRepository extends Mock implements MuhasabahRepository {}

class MockSettingsService extends Mock implements SettingsService {}

class MockPrayerTimeService extends PrayerTimeService {
  final Position? mockPosition;

  MockPrayerTimeService({this.mockPosition});

  @override
  Future<Position?> getCurrentPosition() async => mockPosition;
}

/// Helper to seed standard empty/default responses on core repository mocks.
void stubDefaultRepositoryMocks({
  MockBarakahRepository? barakahRepo,
  MockHabitRepository? habitRepo,
  MockTaskRepository? taskRepo,
  MockIntentionRepository? intentionRepo,
  MockMuhasabahRepository? muhasabahRepo,
}) {
  if (barakahRepo != null) {
    when(() => barakahRepo.watchEntriesForDate(any()))
        .thenAnswer((_) => Stream.value(<BarakahEntry>[]));
    when(() => barakahRepo.getEntriesForDate(any()))
        .thenAnswer((_) async => []);
    when(() => barakahRepo.watchDailyResponse(any()))
        .thenAnswer((_) => Stream.value(null));
  }

  if (habitRepo != null) {
    when(() => habitRepo.watchOverallStreak())
        .thenAnswer((_) => Stream.value(0));
    when(() => habitRepo.watchActiveHabits())
        .thenAnswer((_) => Stream.value(<Habit>[]));
    when(() => habitRepo.watchCompletionsForDate(any()))
        .thenAnswer((_) => Stream.value(<int, bool>{}));
    when(() => habitRepo.getCompletionsCountByDate(days: any(named: 'days')))
        .thenAnswer((_) async => <String, int>{});
    when(() => habitRepo.getActiveHabits()).thenAnswer((_) async => []);
    when(() => habitRepo.getLongestStreak()).thenAnswer((_) async => 0);
    when(() => habitRepo.getLifetimeCompletionsCount())
        .thenAnswer((_) async => 0);
  }

  if (taskRepo != null) {
    when(() => taskRepo.watchTasksForDate(any()))
        .thenAnswer((_) => Stream.value(<Task>[]));
    when(() => taskRepo.getTasksForDate(any())).thenAnswer((_) async => []);
    when(() => taskRepo.getLifetimeCompletedTasksCount())
        .thenAnswer((_) async => 0);
  }

  if (intentionRepo != null) {
    when(() => intentionRepo.watchEntriesForDate(any()))
        .thenAnswer((_) => Stream.value(<IntentionEntry>[]));
    when(() => intentionRepo.getEntriesForDate(any()))
        .thenAnswer((_) async => []);
  }

  if (muhasabahRepo != null) {
    when(() => muhasabahRepo.watchEntriesForDate(any()))
        .thenAnswer((_) => Stream.value(<MuhasabahEntry>[]));
    when(() => muhasabahRepo.getEntriesForDate(any()))
        .thenAnswer((_) async => []);
  }
}
