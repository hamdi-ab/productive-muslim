import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/services/settings_service.dart';

class BackupService {
  final AppDatabase _db;
  final SettingsService? _settingsService;

  const BackupService({
    required AppDatabase db,
    SettingsService? settingsService,
  }) : _db = db,
       _settingsService = settingsService;

  /// Generate full backup data map
  Future<Map<String, dynamic>> createBackupPayload() async {
    final tasksList = await _db.select(_db.tasks).get();
    final habitsList = await _db.select(_db.habits).get();
    final completionsList = await _db.select(_db.habitCompletions).get();
    final intentionsList = await _db.select(_db.intentionEntries).get();
    final barakahList = await _db.select(_db.barakahEntries).get();
    final dailyResponsesList = await _db
        .select(_db.barakahDailyResponses)
        .get();

    final settingsMap = _settingsService != null
        ? {
            'morningAdhkar': _settingsService.morningAdhkarNotificationEnabled,
            'eveningAdhkar': _settingsService.eveningAdhkarNotificationEnabled,
            'sleepingAdhkar':
                _settingsService.sleepingAdhkarNotificationEnabled,
            'sunnahFasting': _settingsService.sunnahFastingNotificationEnabled,
            'qaylulah': _settingsService.qaylulahNotificationEnabled,
            'bedtimeHour': _settingsService.bedtimeReminderHour,
            'bedtimeMinute': _settingsService.bedtimeReminderMinute,
            'userName': _settingsService.userName,
            'userIntention': _settingsService.userIntention,
            'onboardingCompleted': _settingsService.onboardingCompleted,
          }
        : <String, dynamic>{};

    return {
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'app': 'Productive Muslim',
      'data': {
        'tasks': tasksList.map((t) => t.toJson()).toList(),
        'habits': habitsList.map((h) => h.toJson()).toList(),
        'habitCompletions': completionsList.map((c) => c.toJson()).toList(),
        'intentions': intentionsList.map((i) => i.toJson()).toList(),
        'barakahEntries': barakahList.map((b) => b.toJson()).toList(),
        'barakahDailyResponses': dailyResponsesList
            .map((d) => d.toJson())
            .toList(),
        'settings': settingsMap,
      },
    };
  }

  /// Export backup as pretty-printed JSON string
  Future<String> exportBackupToJson() async {
    final payload = await createBackupPayload();
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Validate and import backup payload from JSON string
  Future<bool> importBackupFromJson(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return false;
      if (decoded['version'] != 1 || decoded['data'] is! Map<String, dynamic>) {
        return false;
      }

      final data = decoded['data'] as Map<String, dynamic>;

      await _db.transaction(() async {
        // Clear existing tables
        await _db.delete(_db.tasks).go();
        await _db.delete(_db.habits).go();
        await _db.delete(_db.habitCompletions).go();
        await _db.delete(_db.intentionEntries).go();
        await _db.delete(_db.barakahEntries).go();
        await _db.delete(_db.barakahDailyResponses).go();

        // Restore Tasks
        if (data['tasks'] is List) {
          for (final item in data['tasks']) {
            if (item is Map<String, dynamic>) {
              await _db.into(_db.tasks).insert(Task.fromJson(item));
            }
          }
        }

        // Restore Habits
        if (data['habits'] is List) {
          for (final item in data['habits']) {
            if (item is Map<String, dynamic>) {
              await _db.into(_db.habits).insert(Habit.fromJson(item));
            }
          }
        }

        // Restore Habit Completions
        if (data['habitCompletions'] is List) {
          for (final item in data['habitCompletions']) {
            if (item is Map<String, dynamic>) {
              await _db
                  .into(_db.habitCompletions)
                  .insert(HabitCompletion.fromJson(item));
            }
          }
        }

        // Restore Intentions
        if (data['intentions'] is List) {
          for (final item in data['intentions']) {
            if (item is Map<String, dynamic>) {
              await _db
                  .into(_db.intentionEntries)
                  .insert(IntentionEntry.fromJson(item));
            }
          }
        }

        // Restore Barakah Entries
        if (data['barakahEntries'] is List) {
          for (final item in data['barakahEntries']) {
            if (item is Map<String, dynamic>) {
              await _db
                  .into(_db.barakahEntries)
                  .insert(BarakahEntry.fromJson(item));
            }
          }
        }

        // Restore Daily Responses
        if (data['barakahDailyResponses'] is List) {
          for (final item in data['barakahDailyResponses']) {
            if (item is Map<String, dynamic>) {
              await _db
                  .into(_db.barakahDailyResponses)
                  .insert(BarakahDailyResponseRow.fromJson(item));
            }
          }
        }
      });

      // Restore Settings if provided
      if (_settingsService != null &&
          data['settings'] is Map<String, dynamic>) {
        final s = data['settings'] as Map<String, dynamic>;
        if (s['morningAdhkar'] is bool) {
          await _settingsService.setMorningAdhkarNotificationEnabled(
            s['morningAdhkar'] as bool,
          );
        }
        if (s['eveningAdhkar'] is bool) {
          await _settingsService.setEveningAdhkarNotificationEnabled(
            s['eveningAdhkar'] as bool,
          );
        }
        if (s['sleepingAdhkar'] is bool) {
          await _settingsService.setSleepingAdhkarNotificationEnabled(
            s['sleepingAdhkar'] as bool,
          );
        }
        if (s['sunnahFasting'] is bool) {
          await _settingsService.setSunnahFastingNotificationEnabled(
            s['sunnahFasting'] as bool,
          );
        }
        if (s['qaylulah'] is bool) {
          await _settingsService.setQaylulahNotificationEnabled(
            s['qaylulah'] as bool,
          );
        }
        if (s['bedtimeHour'] is int && s['bedtimeMinute'] is int) {
          await _settingsService.setBedtimeReminderTime(
            hour: s['bedtimeHour'] as int,
            minute: s['bedtimeMinute'] as int,
          );
        }
        if (s['userName'] is String) {
          await _settingsService.setUserName(s['userName'] as String);
        }
        if (s['userIntention'] is String) {
          await _settingsService.setUserIntention(s['userIntention'] as String);
        }
      }

      return true;
    } catch (e, stack) {
      debugPrint('Backup restore failed: $e\n$stack');
      return false;
    }
  }
}
