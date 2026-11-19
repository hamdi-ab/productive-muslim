import 'package:intl/intl.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/muhasabah_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';

/// Factual summary of user-reported app activity for the day.
///
/// NOTE: These counts represent observable app interactions (habits logged,
/// tasks completed, focus minutes recorded, reflections written) and are NOT
/// a measure of faith, sincerity, spiritual rank, or divine blessing.
class BarakahActivitySummary {
  final int completedHabitsToday;
  final int totalHabitsToday;
  final int completedTasksToday;
  final int totalTasksToday;
  final int barakahEntriesToday;
  final bool hasDailyResponse;
  final int focusMinutes;
  final int completedDhikrCount;
  final bool isSunnahFasting;

  const BarakahActivitySummary({
    this.completedHabitsToday = 0,
    this.totalHabitsToday = 0,
    this.completedTasksToday = 0,
    this.totalTasksToday = 0,
    this.barakahEntriesToday = 0,
    this.hasDailyResponse = false,
    this.focusMinutes = 0,
    this.completedDhikrCount = 0,
    this.isSunnahFasting = false,
  });

  bool get hasActivityToday =>
      completedHabitsToday > 0 ||
      completedTasksToday > 0 ||
      barakahEntriesToday > 0 ||
      hasDailyResponse ||
      focusMinutes > 0 ||
      completedDhikrCount > 0;
}

/// Service that aggregates observable activity metrics without assigning
/// numerical scores, percentages, ranks, tiers, streaks, or divine blessing.
class BarakahActivityService {
  final HabitRepository? _habitRepo;
  final TaskRepository? _taskRepo;
  final BarakahRepository? _barakahRepo;
  final MuhasabahRepository? _muhasabahRepo;
  final SettingsService? _settingsService;
  final AdhkarService? _adhkarService;
  final HijriService? _hijriService;

  BarakahActivityService({
    HabitRepository? habitRepo,
    TaskRepository? taskRepo,
    BarakahRepository? barakahRepo,
    MuhasabahRepository? muhasabahRepo,
    SettingsService? settingsService,
    AdhkarService? adhkarService,
    HijriService? hijriService,
  }) : _habitRepo = habitRepo,
       _taskRepo = taskRepo,
       _barakahRepo = barakahRepo,
       _muhasabahRepo = muhasabahRepo,
       _settingsService = settingsService,
       _adhkarService = adhkarService,
       _hijriService = hijriService;

  /// Pure assembly from metric primitives
  BarakahActivitySummary calculateActivitySummary({
    required int focusMinutes,
    required int completedDhikrCount,
    required bool isSunnahFasting,
    required int completedHabitsToday,
    required int totalHabitsToday,
    required int barakahEntriesToday,
    required bool hasDailyResponse,
    required int completedTasksToday,
    required int totalTasksToday,
  }) {
    return BarakahActivitySummary(
      focusMinutes: focusMinutes,
      completedDhikrCount: completedDhikrCount,
      isSunnahFasting: isSunnahFasting,
      completedHabitsToday: completedHabitsToday,
      totalHabitsToday: totalHabitsToday,
      barakahEntriesToday: barakahEntriesToday,
      hasDailyResponse: hasDailyResponse,
      completedTasksToday: completedTasksToday,
      totalTasksToday: totalTasksToday,
    );
  }

  /// Async helper to pull live observable records from repositories
  Future<BarakahActivitySummary> calculateLiveSummary({String? date}) async {
    final targetDate = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

    int completedHabitsToday = 0;
    int totalHabitsToday = 0;

    final habitRepo =
        _habitRepo ??
        (getIt.isRegistered<HabitRepository>()
            ? getIt<HabitRepository>()
            : null);
    if (habitRepo != null) {
      try {
        final habits = await habitRepo.getActiveHabits();
        totalHabitsToday = habits.length;
        final completions = await habitRepo.getCompletionsForDateMap(
          targetDate,
        );
        completedHabitsToday = habits
            .where((h) => completions[h.id] == true)
            .length;
      } catch (_) {}
    }

    int completedTasksToday = 0;
    int totalTasksToday = 0;
    final taskRepo =
        _taskRepo ??
        (getIt.isRegistered<TaskRepository>() ? getIt<TaskRepository>() : null);
    if (taskRepo != null) {
      try {
        final tasks = await taskRepo.getTasksForDate(targetDate);
        totalTasksToday = tasks.length;
        completedTasksToday = tasks.where((t) => t.completed).length;
      } catch (_) {}
    }

    int barakahEntriesToday = 0;
    bool hasDailyResponse = false;
    final barakahRepo =
        _barakahRepo ??
        (getIt.isRegistered<BarakahRepository>()
            ? getIt<BarakahRepository>()
            : null);
    if (barakahRepo != null) {
      try {
        final entries = await barakahRepo.getEntriesForDate(targetDate);
        barakahEntriesToday = entries.length;
        final daily = await barakahRepo.watchDailyResponse(targetDate).first;
        hasDailyResponse = daily?.answer != null;
      } catch (_) {}
    }

    final muhasabahRepo =
        _muhasabahRepo ??
        (getIt.isRegistered<MuhasabahRepository>()
            ? getIt<MuhasabahRepository>()
            : null);
    if (muhasabahRepo != null) {
      try {
        final mEntries = await muhasabahRepo.getEntriesForDate(targetDate);
        if (mEntries.isNotEmpty) {
          hasDailyResponse = true;
        }
      } catch (_) {}
    }

    int focusMinutes = 0;
    bool isFasting = false;
    int completedDhikrCount = 0;

    final settings =
        _settingsService ??
        (getIt.isRegistered<SettingsService>()
            ? getIt<SettingsService>()
            : null);
    if (settings != null) {
      try {
        focusMinutes = settings.totalFocusMinutes;
        isFasting = settings.isSunnahFastingTarget(targetDate);
        completedDhikrCount = settings.getCompletedDhikrIds(targetDate).length;
      } catch (_) {}
    }

    final adhkar =
        _adhkarService ??
        (getIt.isRegistered<AdhkarService>() ? getIt<AdhkarService>() : null);
    if (adhkar != null) {
      try {
        final count = adhkar.getCompletedDhikrIdsForDate(targetDate).length;
        if (count > completedDhikrCount) completedDhikrCount = count;
      } catch (_) {}
    }

    final hijri =
        _hijriService ??
        (getIt.isRegistered<HijriService>() ? getIt<HijriService>() : null);
    if (hijri != null) {
      try {
        final status = hijri.getSunnahFastingStatus(DateTime.now());
        if (status.isSunnah) isFasting = true;
      } catch (_) {}
    }

    return calculateActivitySummary(
      focusMinutes: focusMinutes,
      completedDhikrCount: completedDhikrCount,
      isSunnahFasting: isFasting,
      completedHabitsToday: completedHabitsToday,
      totalHabitsToday: totalHabitsToday,
      barakahEntriesToday: barakahEntriesToday,
      hasDailyResponse: hasDailyResponse,
      completedTasksToday: completedTasksToday,
      totalTasksToday: totalTasksToday,
    );
  }
}

/// Backwards compatibility alias
typedef BarakahScoreService = BarakahActivityService;
