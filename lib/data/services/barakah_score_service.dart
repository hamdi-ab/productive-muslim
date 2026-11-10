import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';

class BarakahQualityDimension {
  final String key;
  final String nameEn;
  final String nameAr;
  final double score; // 0.0 to 100.0
  final Color color;

  const BarakahQualityDimension({
    required this.key,
    required this.nameEn,
    required this.nameAr,
    required this.score,
    required this.color,
  });
}

class BarakahScores {
  final List<BarakahQualityDimension> dimensions;
  final double scorePercent;
  final int scorePoints;
  final BarakahQualityDimension topStrength;
  final BarakahQualityDimension growthFocus;

  const BarakahScores({
    required this.dimensions,
    required this.scorePercent,
    required this.scorePoints,
    required this.topStrength,
    required this.growthFocus,
  });
}

class BarakahScoreService {
  final HabitRepository? _habitRepo;
  final TaskRepository? _taskRepo;
  final BarakahRepository? _barakahRepo;
  final SettingsService? _settingsService;
  final AdhkarService? _adhkarService;
  final HijriService? _hijriService;

  BarakahScoreService({
    HabitRepository? habitRepo,
    TaskRepository? taskRepo,
    BarakahRepository? barakahRepo,
    SettingsService? settingsService,
    AdhkarService? adhkarService,
    HijriService? hijriService,
  }) : _habitRepo = habitRepo,
       _taskRepo = taskRepo,
       _barakahRepo = barakahRepo,
       _settingsService = settingsService,
       _adhkarService = adhkarService,
       _hijriService = hijriService;

  /// Pure calculation from extracted metric primitives
  BarakahScores calculateScores({
    required int overallStreak,
    required ({int physical, int spiritual, int mental}) energy,
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
    // 1. Ruh (Spiritual)
    final double ruhScore = (energy.spiritual > 0)
        ? ((energy.spiritual / 5.0) * 60 +
                  math.min(completedDhikrCount, 4) * 10)
              .clamp(35.0, 100.0)
        : 75.0;

    // 2. Jism (Physical)
    final double jismScore = (energy.physical > 0)
        ? ((energy.physical / 5.0) * 70 +
                  (isSunnahFasting ? 15.0 : 0.0) +
                  (completedHabitsToday > 0 ? 15.0 : 0.0))
              .clamp(35.0, 100.0)
        : 70.0;

    // 3. Ummah (Social)
    final int totalSocialLife = totalTasksToday + totalHabitsToday;
    final int completedSocialLife = completedTasksToday + completedHabitsToday;
    final double ummahScore = totalSocialLife > 0
        ? ((completedSocialLife / totalSocialLife) * 35 + 65.0).clamp(
            40.0,
            100.0,
          )
        : 78.0;

    // 4. Aql (Mindset)
    final double aqlScore = (energy.mental > 0)
        ? ((energy.mental / 5.0) * 70 +
                  (completedTasksToday > 0 ? 15.0 : 0.0) +
                  15.0)
              .clamp(40.0, 100.0)
        : 80.0;

    // 5. Istiqamah (Consistency)
    final double istiqamahScore = totalHabitsToday > 0
        ? ((completedHabitsToday / totalHabitsToday) * 60 +
                  math.min(overallStreak, 10) * 4.0)
              .clamp(30.0, 100.0)
        : (50.0 + math.min(overallStreak, 10) * 5.0).clamp(30.0, 100.0);

    // 6. Khushu' (Focus)
    final double khushuScore =
        (50.0 +
                (math.min(focusMinutes, 60) / 60.0 * 35.0) +
                (hasDailyResponse ? 15.0 : 0.0))
            .clamp(35.0, 100.0);

    // 7. Niyyah (Intention)
    final double niyyahScore = hasDailyResponse ? 92.0 : 70.0;

    // 8. Shukr (Gratitude)
    final double shukrScore = (65.0 + math.min(barakahEntriesToday, 3) * 11.0)
        .clamp(40.0, 100.0);

    // 9. Ihsan (Excellence) - Master Harmony Average
    final double ihsanScore =
        (ruhScore +
            jismScore +
            ummahScore +
            aqlScore +
            istiqamahScore +
            khushuScore +
            niyyahScore +
            shukrScore) /
        8.0;

    final dimensions = [
      BarakahQualityDimension(
        key: 'ruh',
        nameEn: 'Ruh (Spiritual)',
        nameAr: 'الروح',
        score: (ruhScore * 10).round() / 10.0,
        color: const Color(0xFFE9C349),
      ),
      BarakahQualityDimension(
        key: 'jism',
        nameEn: 'Jism (Physical)',
        nameAr: 'الجسد',
        score: (jismScore * 10).round() / 10.0,
        color: const Color(0xFF6FFBBE),
      ),
      BarakahQualityDimension(
        key: 'ummah',
        nameEn: 'Ummah (Social)',
        nameAr: 'الأمة',
        score: (ummahScore * 10).round() / 10.0,
        color: const Color(0xFF4EDEA3),
      ),
      BarakahQualityDimension(
        key: 'aql',
        nameEn: 'Aql (Mindset)',
        nameAr: 'العقل',
        score: (aqlScore * 10).round() / 10.0,
        color: const Color(0xFFE9C349),
      ),
      BarakahQualityDimension(
        key: 'istiqamah',
        nameEn: 'Istiqaamah',
        nameAr: 'الاستقامة',
        score: (istiqamahScore * 10).round() / 10.0,
        color: const Color(0xFFFFE088),
      ),
      BarakahQualityDimension(
        key: 'khushu',
        nameEn: "Khushu' (Focus)",
        nameAr: 'الخشوع',
        score: (khushuScore * 10).round() / 10.0,
        color: const Color(0xFFFFB4AB),
      ),
      BarakahQualityDimension(
        key: 'niyyah',
        nameEn: 'Niyyah (Intention)',
        nameAr: 'النية',
        score: (niyyahScore * 10).round() / 10.0,
        color: const Color(0xFF4EDEA3),
      ),
      BarakahQualityDimension(
        key: 'shukr',
        nameEn: 'Shukr (Gratitude)',
        nameAr: 'الشكر',
        score: (shukrScore * 10).round() / 10.0,
        color: const Color(0xFFE9C349),
      ),
      BarakahQualityDimension(
        key: 'ihsan',
        nameEn: 'Ihsan (Excellence)',
        nameAr: 'الإحسان',
        score: (ihsanScore * 10).round() / 10.0,
        color: const Color(0xFF6FFBBE),
      ),
    ];

    final sorted = List<BarakahQualityDimension>.from(dimensions)
      ..sort((a, b) => b.score.compareTo(a.score));

    final overallPercent = (ihsanScore / 100.0).clamp(0.0, 1.0);
    final overallPoints = ihsanScore.round().clamp(0, 100);

    return BarakahScores(
      dimensions: dimensions,
      scorePercent: overallPercent,
      scorePoints: overallPoints,
      topStrength: sorted.first,
      growthFocus: sorted.last,
    );
  }

  /// Async helper to pull live records from the environment
  Future<BarakahScores> calculateLiveScores({String? date}) async {
    final targetDate = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

    int overallStreak = 0;
    int completedHabitsToday = 0;
    int totalHabitsToday = 0;

    final habitRepo =
        _habitRepo ??
        (getIt.isRegistered<HabitRepository>()
            ? getIt<HabitRepository>()
            : null);
    if (habitRepo != null) {
      try {
        overallStreak = await habitRepo.getOverallStreak();
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

    ({int physical, int spiritual, int mental}) energy = (
      physical: 3,
      spiritual: 3,
      mental: 3,
    );
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
        energy = settings.getDailyEnergy(targetDate);
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

    return calculateScores(
      overallStreak: overallStreak,
      energy: energy,
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
