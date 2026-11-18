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
      expect(payload['version'], equals(2));
      expect(payload['app'], equals('Productive Muslim'));

      final data = payload['data'] as Map<String, dynamic>;
      expect((data['tasks'] as List).length, equals(1));
      expect((data['habits'] as List).length, equals(1));
      expect((data['muhasabahEntries'] as List).length, equals(0));
      expect(data['settings']['notif_morning_adhkar'], isTrue);
      expect(data['settings']['notif_evening_adhkar'], isFalse);

      final jsonStr = await backupService.exportBackupToJson();
      expect(jsonStr, isNotEmpty);
      expect(() => jsonDecode(jsonStr), returnsNormally);
    });

    test('importBackupFromJson restores tables and settings cleanly in a transaction', () async {
      await settingsService.addCompletedDhikr('2026-09-30', 'ayat_alkursi');
      await settingsService.setDailyEnergy(
        date: '2026-09-30',
        physical: 4,
        spiritual: 5,
        mental: 4,
      );

      final exported = await backupService.exportBackupToJson();
      expect(exported, contains('ayat_alkursi'));

      // Mutate local state
      await settingsService.setBedtimeReminderTime(hour: 21, minute: 0);

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
          'habitCompletions': [
            {'id': 1, 'habitId': 201, 'date': '2026-09-30', 'completed': 1},
          ],
          'intentions': [
            {
              'id': 301,
              'date': '2026-09-30',
              'title': 'Seek Barakah in Knowledge',
              'statement': 'Study with pure intention for Allah',
              'category': 'Spiritual',
              'completed': 1,
              'reflection': 'Felt deep peace during Fajr today',
              'createdAt': 0,
            },
          ],
          'barakahEntries': [
            {
              'id': 401,
              'date': '2026-09-30',
              'sourceIds': '["quran"]',
              'promptId': 'p1',
              'intensity': 5,
              'note': 'Blessed day',
              'skipped': 0,
              'createdAt': 0,
            },
          ],
          'barakahDailyResponses': [
            {
              'date': '2026-09-30',
              'promptId': 'q1',
              'answer': 'yes',
              'sourceIds': '["s1"]',
              'note': 'SubhanAllah',
              'createdAt': 0,
              'updatedAt': 0,
            },
          ],
          'settings': {
            'notif_morning_adhkar': true,
            'notif_evening_adhkar': true,
            'notif_sunnah_fasting': false,
            'bedtime_reminder_hour': 23,
            'bedtime_reminder_minute': 15,
            'adhkar_done_2026-09-30': ['morning_1', 'morning_2'],
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

      final completions = await db.select(db.habitCompletions).get();
      expect(completions.length, equals(1));

      final intentions = await db.select(db.intentionEntries).get();
      expect(intentions.length, equals(1));
      expect(intentions.first.title, contains('Barakah'));

      final muhasabah = await db.select(db.muhasabahEntries).get();
      expect(muhasabah.length, equals(1));
      expect(
        muhasabah.first.content,
        equals('Felt deep peace during Fajr today'),
      );
      expect(muhasabah.first.date, equals('2026-09-30'));

      final barakah = await db.select(db.barakahEntries).get();
      expect(barakah.length, equals(1));

      final responses = await db.select(db.barakahDailyResponses).get();
      expect(responses.length, equals(1));

      expect(settingsService.eveningAdhkarNotificationEnabled, isTrue);
      expect(settingsService.sunnahFastingNotificationEnabled, isFalse);
      expect(settingsService.bedtimeReminderHour, equals(23));
      expect(settingsService.bedtimeReminderMinute, equals(15));
      expect(
        settingsService.getCompletedDhikrIds('2026-09-30'),
        equals(['morning_1', 'morning_2']),
      );
    });

    test('importBackupFromJson safely returns false on invalid payload without corrupting seeded data', () async {
      // Seed existing data
      await db
          .into(db.tasks)
          .insert(
            Task(
              id: 1,
              title: 'Initial Seed Task',
              lifeArea: 'Work',
              date: '2026-09-30',
              repeatDaily: 0,
              repeatWeekly: 0,
              completed: 0,
              createdAt: 0,
              active: 1,
            ),
          );
      await settingsService.setBedtimeReminderTime(hour: 22, minute: 30);

      // Payload with missing tables
      final missingTableJson = '{"version": 1, "data": {"tasks": []}}';
      expect(
        await backupService.importBackupFromJson(missingTableJson),
        isFalse,
      );

      // Payload with non-map elements
      final nonMapJson = jsonEncode({
        'version': 1,
        'data': {
          'tasks': ['invalid_string'],
          'habits': [],
          'habitCompletions': [],
          'intentions': [],
          'barakahEntries': [],
          'barakahDailyResponses': [],
        },
      });
      expect(await backupService.importBackupFromJson(nonMapJson), isFalse);

      // Payload with invalid bedtime settings
      final invalidBedtimeJson = jsonEncode({
        'version': 1,
        'data': {
          'tasks': [],
          'habits': [],
          'habitCompletions': [],
          'intentions': [],
          'barakahEntries': [],
          'barakahDailyResponses': [],
          'settings': {
            'bedtime_reminder_hour': 99, // Invalid
          },
        },
      });
      expect(
        await backupService.importBackupFromJson(invalidBedtimeJson),
        isFalse,
      );

      // Verify original seeded data is completely intact
      final tasks = await db.select(db.tasks).get();
      expect(tasks.length, equals(1));
      expect(tasks.first.title, equals('Initial Seed Task'));
      expect(settingsService.bedtimeReminderHour, equals(22));
      expect(settingsService.bedtimeReminderMinute, equals(30));
    });
  });
}
