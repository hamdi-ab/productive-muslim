import 'dart:convert';

import 'package:adhan_dart/adhan_dart.dart';
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
      expect(payload['version'], equals(5));
      expect(payload['app'], equals('Productive Muslim'));

      final data = payload['data'] as Map<String, dynamic>;
      expect((data['tasks'] as List).length, equals(1));
      expect((data['habits'] as List).length, equals(1));
      expect((data['muhasabahEntries'] as List).length, equals(0));
      expect((data['adhkarBookmarks'] as List).length, equals(0));
      expect((data['adhkarSessions'] as List).length, equals(0));
      expect((data['adhkarCompletions'] as List).length, equals(0));
      expect((data['adhkarRoutines'] as List).length, equals(0));
      expect((data['adhkarRoutineCompletions'] as List).length, equals(0));
      expect((data['adhkarTasbih'] as List).length, equals(0));
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

    test(
      'backup and restore preserves prayer calculation method and Asr madhab',
      () async {
        await settingsService.setPrayerCalculationMethod(
          CalculationMethod.egyptian,
        );
        await settingsService.setPrayerMadhab(Madhab.hanafi);

        final payload = await backupService.createBackupPayload();
        final data = payload['data'] as Map<String, dynamic>;
        final exportedSettings = data['settings'] as Map<String, dynamic>;
        expect(
          exportedSettings['prayer_calculation_method'],
          equals('egyptian'),
        );
        expect(exportedSettings['prayer_madhab'], equals('hanafi'));

        // Mutate local state back to MWL / Shafi
        await settingsService.setPrayerCalculationMethod(
          CalculationMethod.muslimWorldLeague,
        );
        await settingsService.setPrayerMadhab(Madhab.shafi);

        // Restore payload with Karachi and Hanafi
        exportedSettings['prayer_calculation_method'] = 'karachi';
        exportedSettings['prayer_madhab'] = 'hanafi';
        final jsonStr = jsonEncode(payload);

        final success = await backupService.importBackupFromJson(jsonStr);
        expect(success, isTrue);
        expect(
          settingsService.prayerCalculationMethod,
          equals(CalculationMethod.karachi),
        );
        expect(settingsService.prayerMadhab, equals(Madhab.hanafi));
      },
    );

    test('importBackupFromJson correctly exports and restores version 3 adhkar records', () async {
      await db
          .into(db.adhkarBookmarks)
          .insert(
            const AdhkarBookmark(dhikrId: 'ayat_al_kursi', createdAt: 1000),
          );
      await db
          .into(db.adhkarSessions)
          .insert(
            const AdhkarSession(
              collectionId: 'morning',
              lastPageIndex: 2,
              countsJson: '{"ayat_al_kursi": 1}',
              lastAccessedAt: 2000,
              isCompleted: false,
            ),
          );
      await db
          .into(db.adhkarCompletions)
          .insert(
            const AdhkarCompletion(
              id: 1,
              collectionId: 'morning',
              date: '2026-09-30',
              completedAt: 3000,
            ),
          );

      final exported = await backupService.exportBackupToJson();
      expect(exported, contains('ayat_al_kursi'));
      expect(exported, contains('"version": 5'));

      // Clear the tables
      await db.delete(db.adhkarBookmarks).go();
      await db.delete(db.adhkarSessions).go();
      await db.delete(db.adhkarCompletions).go();

      expect((await db.select(db.adhkarBookmarks).get()).length, equals(0));
      expect((await db.select(db.adhkarSessions).get()).length, equals(0));
      expect((await db.select(db.adhkarCompletions).get()).length, equals(0));

      final success = await backupService.importBackupFromJson(exported);
      expect(success, isTrue);

      final bookmarks = await db.select(db.adhkarBookmarks).get();
      expect(bookmarks.length, equals(1));
      expect(bookmarks.first.dhikrId, equals('ayat_al_kursi'));

      final sessions = await db.select(db.adhkarSessions).get();
      expect(sessions.length, equals(1));
      expect(sessions.first.collectionId, equals('morning'));
      expect(sessions.first.lastPageIndex, equals(2));

      final completions = await db.select(db.adhkarCompletions).get();
      expect(completions.length, equals(1));
      expect(completions.first.collectionId, equals('morning'));
      expect(completions.first.date, equals('2026-09-30'));
    });

    test('importBackupFromJson correctly exports and restores version 5 tasbih records', () async {
      await db.adhkarDao.saveTasbihState(
        currentCount: 33,
        targetCount: 100,
        dhikrId: 'subhanallah',
        customLabel: 'My Dhikr',
        lastCount: 32,
        updatedAt: 5000,
      );

      final exported = await backupService.exportBackupToJson();
      expect(exported, contains('subhanallah'));
      expect(exported, contains('My Dhikr'));
      expect(exported, contains('"currentCount": 33'));

      // Clear tasbih table
      await db.delete(db.adhkarTasbih).go();
      expect((await db.select(db.adhkarTasbih).get()).length, equals(0));

      final success = await backupService.importBackupFromJson(exported);
      expect(success, isTrue);

      final tasbihList = await db.select(db.adhkarTasbih).get();
      expect(tasbihList.length, equals(1));
      expect(tasbihList.first.currentCount, equals(33));
      expect(tasbihList.first.targetCount, equals(100));
      expect(tasbihList.first.dhikrId, equals('subhanallah'));
      expect(tasbihList.first.customLabel, equals('My Dhikr'));
    });

    test(
      'importBackupFromJson is backwards compatible with version 4 payload',
      () async {
        final v4Json = jsonEncode({
          'version': 4,
          'app': 'Productive Muslim',
          'data': {
            'tasks': [],
            'habits': [],
            'habitCompletions': [],
            'intentions': [],
            'muhasabahEntries': [],
            'barakahEntries': [],
            'barakahDailyResponses': [],
            'adhkarBookmarks': [],
            'adhkarSessions': [],
            'adhkarCompletions': [],
            'adhkarRoutines': [
              {
                'id': 'routine_v4',
                'name': 'Routine V4',
                'itemIdsJson': '["item1"]',
                'createdAt': 1000,
                'updatedAt': 1000,
              },
            ],
            'adhkarRoutineCompletions': [],
            'settings': {'notif_morning_adhkar': true},
          },
        });

        final success = await backupService.importBackupFromJson(v4Json);
        expect(success, isTrue);

        final routines = await db.select(db.adhkarRoutines).get();
        expect(routines.any((r) => r.id == 'routine_v4'), isTrue);
      },
    );

    test(
      'importBackupFromJson is backwards compatible with version 3 payload',
      () async {
        final v3Json = jsonEncode({
          'version': 3,
          'app': 'Productive Muslim',
          'data': {
            'tasks': [],
            'habits': [],
            'habitCompletions': [],
            'intentions': [],
            'muhasabahEntries': [],
            'barakahEntries': [],
            'barakahDailyResponses': [],
            'adhkarBookmarks': [
              {'dhikrId': 'v3_dhikr', 'createdAt': 12345},
            ],
            'adhkarSessions': [],
            'adhkarCompletions': [],
            'settings': {'notif_morning_adhkar': true},
          },
        });

        final success = await backupService.importBackupFromJson(v3Json);
        expect(success, isTrue);

        final bookmarks = await db.select(db.adhkarBookmarks).get();
        expect(bookmarks.any((b) => b.dhikrId == 'v3_dhikr'), isTrue);
      },
    );

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
