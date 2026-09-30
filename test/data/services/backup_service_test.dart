import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/services/backup_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late SettingsService settingsService;
  late BackupService backupService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'notif_morning_adhkar': true,
      'notif_evening_adhkar': false,
      'notif_sunnah_fasting': true,
    });
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);

    db = AppDatabase.forTesting(NativeDatabase.memory());
    backupService = BackupService(db: db, settingsService: settingsService);
  });

  tearDown(() async {
    await db.close();
  });

  group('BackupService', () {
    test('createBackupPayload produces valid JSON serializable structure with settings', () async {
      // Insert test task and habit
      await db
          .into(db.tasks)
          .insert(
            Task(
              id: 1,
              title: 'Morning Quran recitation',
              lifeArea: 'Spiritual',
              date: '2026-09-30',
              repeatDaily: 1,
              repeatWeekly: 0,
              completed: 1,
              createdAt: 0,
              active: 1,
            ),
          );

      await db
          .into(db.habits)
          .insert(
            const Habit(
              id: 1,
              name: 'Duha Prayer',
              category: 'Spiritual',
              frequency: 'daily',
              reminderEnabled: 0,
              active: 1,
              createdAt: 0,
            ),
          );

      final payload = await backupService.createBackupPayload();
      expect(payload['version'], equals(1));
      expect(payload['app'], equals('Productive Muslim'));

      final data = payload['data'] as Map<String, dynamic>;
      expect((data['tasks'] as List).length, equals(1));
      expect((data['habits'] as List).length, equals(1));
      expect(data['settings']['morningAdhkar'], isTrue);
      expect(data['settings']['eveningAdhkar'], isFalse);

      final jsonStr = await backupService.exportBackupToJson();
      expect(jsonStr, isNotEmpty);
      expect(() => jsonDecode(jsonStr), returnsNormally);
    });

    test('importBackupFromJson restores tables and settings cleanly in a transaction', () async {
      final sampleBackup = jsonEncode({
        'version': 1,
        'app': 'Productive Muslim',
        'exportedAt': '2026-09-30T10:00:00Z',
        'data': {
          'tasks': [
            {
              'id': 101,
              'title': 'Read Surah Al-Kahf',
              'lifeArea': 'Spiritual',
              'date': '2026-10-02',
              'repeatDaily': 0,
              'repeatWeekly': 1,
              'completed': 0,
              'createdAt': 0,
              'active': 1,
            },
          ],
          'habits': [
            {
              'id': 201,
              'name': 'Tahajjud Prayer',
              'category': 'Spiritual',
              'frequency': 'daily',
              'reminderEnabled': 1,
              'active': 1,
              'createdAt': 0,
            },
          ],
          'habitCompletions': [],
          'intentions': [
            {
              'id': 301,
              'date': '2026-09-30',
              'title': 'Seek Barakah in Knowledge',
              'statement': 'Study with pure intention for Allah',
              'category': 'Spiritual',
              'completed': 1,
              'createdAt': 0,
            },
          ],
          'barakahEntries': [],
          'barakahDailyResponses': [],
          'settings': {
            'morningAdhkar': true,
            'eveningAdhkar': true,
            'sunnahFasting': false,
            'bedtimeHour': 23,
            'bedtimeMinute': 15,
          },
        },
      });

      final success = await backupService.importBackupFromJson(sampleBackup);
      expect(success, isTrue);

      final tasks = await db.select(db.tasks).get();
      expect(tasks.length, equals(1));
      expect(tasks.first.title, equals('Read Surah Al-Kahf'));

      final habits = await db.select(db.habits).get();
      expect(habits.length, equals(1));
      expect(habits.first.name, equals('Tahajjud Prayer'));

      final intentions = await db.select(db.intentionEntries).get();
      expect(intentions.length, equals(1));
      expect(intentions.first.title, contains('Barakah'));

      expect(settingsService.eveningAdhkarNotificationEnabled, isTrue);
      expect(settingsService.sunnahFastingNotificationEnabled, isFalse);
      expect(settingsService.bedtimeReminderHour, equals(23));
      expect(settingsService.bedtimeReminderMinute, equals(15));
    });

    test('importBackupFromJson safely returns false on invalid payload without corrupting data', () async {
      final invalidJson = '{"version": 2, "corrupted": true}';
      final success = await backupService.importBackupFromJson(invalidJson);
      expect(success, isFalse);

      final badSyntax = '{invalid json syntax';
      final badSuccess = await backupService.importBackupFromJson(badSyntax);
      expect(badSuccess, isFalse);
    });
  });
}
