import 'dart:convert';

import 'package:drift/drift.dart' show Value;
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

  /// Generate full backup data map (Version 2)
  Future<Map<String, dynamic>> createBackupPayload() async {
    final tasksList = await _db.select(_db.tasks).get();
    final habitsList = await _db.select(_db.habits).get();
    final completionsList = await _db.select(_db.habitCompletions).get();
    final intentionsList = await _db.select(_db.intentionEntries).get();
    final muhasabahList = await _db.select(_db.muhasabahEntries).get();
    final barakahList = await _db.select(_db.barakahEntries).get();
    final dailyResponsesList = await _db
        .select(_db.barakahDailyResponses)
        .get();

    final settingsMap =
        _settingsService?.exportSettings() ?? <String, dynamic>{};

    return {
      'version': 2,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'app': 'Productive Muslim',
      'data': {
        'tasks': tasksList.map((t) => t.toJson()).toList(),
        'habits': habitsList.map((h) => h.toJson()).toList(),
        'habitCompletions': completionsList.map((c) => c.toJson()).toList(),
        'intentions': intentionsList.map((i) => i.toJson()).toList(),
        'muhasabahEntries': muhasabahList.map((m) => m.toJson()).toList(),
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

  /// Validate and import backup payload from JSON string (supports v1 and v2)
  Future<bool> importBackupFromJson(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return false;
      final version = decoded['version'];
      if ((version != 1 && version != 2) ||
          decoded['data'] is! Map<String, dynamic>) {
        return false;
      }

      final data = decoded['data'] as Map<String, dynamic>;

      const requiredTables = [
        'tasks',
        'habits',
        'habitCompletions',
        'intentions',
        'barakahEntries',
        'barakahDailyResponses',
      ];

      for (final table in requiredTables) {
        final list = data[table];
        if (list is! List) return false;
        for (final item in list) {
          if (item is! Map<String, dynamic>) return false;
        }
      }

      if (version == 2) {
        final list = data['muhasabahEntries'];
        if (list is! List) return false;
        for (final item in list) {
          if (item is! Map<String, dynamic>) return false;
        }
      }

      if (data.containsKey('settings') &&
          data['settings'] is! Map<String, dynamic>) {
        return false;
      }

      // Pre-parse all entities before mutating database or preferences
      final tasks = (data['tasks'] as List)
          .map((i) => Task.fromJson(i as Map<String, dynamic>))
          .toList();
      final habits = (data['habits'] as List)
          .map((i) => Habit.fromJson(i as Map<String, dynamic>))
          .toList();
      final completions = (data['habitCompletions'] as List)
          .map((i) => HabitCompletion.fromJson(i as Map<String, dynamic>))
          .toList();
      final intentions = (data['intentions'] as List)
          .map((i) => IntentionEntry.fromJson(i as Map<String, dynamic>))
          .toList();
      final barakah = (data['barakahEntries'] as List)
          .map((i) => BarakahEntry.fromJson(i as Map<String, dynamic>))
          .toList();
      final responses = (data['barakahDailyResponses'] as List)
          .map(
            (i) => BarakahDailyResponseRow.fromJson(i as Map<String, dynamic>),
          )
          .toList();

      final List<MuhasabahEntryRow> muhasabah;
      if (version == 2) {
        muhasabah = (data['muhasabahEntries'] as List)
            .map((i) => MuhasabahEntryRow.fromJson(i as Map<String, dynamic>))
            .toList();
      } else {
        // Version 1 backup: migrate non-empty legacy reflections into Muhasabah rows
        muhasabah = [];
        for (final rawIntention in (data['intentions'] as List)) {
          final reflection = rawIntention['reflection'] as String?;
          if (reflection != null && reflection.trim().isNotEmpty) {
            final date = rawIntention['date'] as String? ?? '';
            final createdAt = rawIntention['createdAt'] as int? ?? 0;
            muhasabah.add(
              MuhasabahEntryRow(
                id: 0,
                date: date,
                content: reflection,
                createdAt: createdAt,
                updatedAt: createdAt,
              ),
            );
          }
        }
      }

      final settingsMap = data['settings'] as Map<String, dynamic>?;

      // Validate bedtime hour/minute in settings if present
      if (settingsMap != null) {
        if (settingsMap.containsKey('bedtime_reminder_hour')) {
          final h = settingsMap['bedtime_reminder_hour'];
          if (h is! int || h < 0 || h > 23) return false;
        }
        if (settingsMap.containsKey('bedtime_reminder_minute')) {
          final m = settingsMap['bedtime_reminder_minute'];
          if (m is! int || m < 0 || m > 59) return false;
        }
      }

      // Snapshot prior settings in case restore fails
      final previousSettings = _settingsService?.exportSettings();

      try {
        await _db.transaction(() async {
          // Clear existing tables
          await _db.delete(_db.tasks).go();
          await _db.delete(_db.habits).go();
          await _db.delete(_db.habitCompletions).go();
          await _db.delete(_db.intentionEntries).go();
          await _db.delete(_db.muhasabahEntries).go();
          await _db.delete(_db.barakahEntries).go();
          await _db.delete(_db.barakahDailyResponses).go();

          for (final t in tasks) {
            await _db.into(_db.tasks).insert(t);
          }
          for (final h in habits) {
            await _db.into(_db.habits).insert(h);
          }
          for (final c in completions) {
            await _db.into(_db.habitCompletions).insert(c);
          }
          for (final i in intentions) {
            await _db.into(_db.intentionEntries).insert(i);
          }
          for (final m in muhasabah) {
            if (m.id == 0) {
              await _db
                  .into(_db.muhasabahEntries)
                  .insert(
                    MuhasabahEntriesCompanion.insert(
                      date: m.date,
                      promptId: Value(m.promptId),
                      promptText: Value(m.promptText),
                      content: m.content,
                      tags: Value(m.tags),
                      createdAt: Value(m.createdAt),
                      updatedAt: Value(m.updatedAt),
                    ),
                  );
            } else {
              await _db.into(_db.muhasabahEntries).insert(m);
            }
          }
          for (final b in barakah) {
            await _db.into(_db.barakahEntries).insert(b);
          }
          for (final r in responses) {
            await _db.into(_db.barakahDailyResponses).insert(r);
          }

          // Import settings inside the transaction so any failure rolls back
          // the database changes together with the settings write.
          if (_settingsService != null && settingsMap != null) {
            await _settingsService.importSettings(settingsMap);
          }
        });

        return true;
      } catch (e) {
        // Restore prior settings, but don't let a restore failure replace
        // the original transaction error.
        if (_settingsService != null && previousSettings != null) {
          try {
            await _settingsService.importSettings(previousSettings);
          } catch (restoreError) {
            debugPrint('Backup settings restore failed: $restoreError');
          }
        }
        rethrow;
      }
    } catch (e, stack) {
      debugPrint('Backup restore failed: $e\n$stack');
      return false;
    }
  }
}
