import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'package:productive_muslim/core/router/app_router.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/daos/adhkar_dao.dart';
import 'package:productive_muslim/data/local/daos/barakah_dao.dart';
import 'package:productive_muslim/data/local/daos/habit_completions_dao.dart';
import 'package:productive_muslim/data/local/daos/habit_dao.dart';
import 'package:productive_muslim/data/local/daos/intention_dao.dart';
import 'package:productive_muslim/data/local/daos/muhasabah_dao.dart';
import 'package:productive_muslim/data/local/daos/task_dao.dart';
import 'package:productive_muslim/data/repositories/adhkar_repository_impl.dart';
import 'package:productive_muslim/data/repositories/barakah_repository_impl.dart';
import 'package:productive_muslim/data/repositories/habit_repository_impl.dart';
import 'package:productive_muslim/data/repositories/intention_repository_impl.dart';
import 'package:productive_muslim/data/repositories/muhasabah_repository_impl.dart';
import 'package:productive_muslim/data/repositories/task_repository_impl.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/data/services/local_barakah_reminder_scheduler.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/prayer_notification_scheduler.dart';
import 'package:productive_muslim/data/services/adhan_notification_service.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/home_widget_sync_service.dart';
import 'package:productive_muslim/data/services/qibla_service.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/backup_service.dart';
import 'package:productive_muslim/data/services/barakah_score_service.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/domain/repositories/barakah_reminder_scheduler.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';
import 'package:productive_muslim/domain/repositories/muhasabah_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';

final getIt = GetIt.instance;

Future<void> setupDi() async {
  // Initialize timezone database for adhan and schedule conversions
  try {
    tz_data.initializeTimeZones();
  } catch (_) {}

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Settings
  getIt.registerSingleton<SettingsService>(SettingsService(prefs: prefs));
  getIt.registerLazySingleton<BarakahReminderScheduler>(
    () =>
        LocalBarakahReminderScheduler(onTapped: AppRouter.openBarakahReminder),
  );
  getIt.registerLazySingleton<BarakahReminderService>(
    () => BarakahReminderService(
      settings: getIt<SettingsService>(),
      scheduler: getIt<BarakahReminderScheduler>(),
    ),
    dispose: (service) => service.dispose(),
  );

  // Database
  final database = AppDatabase();
  getIt.registerSingleton<AppDatabase>(database);

  // DAOs
  getIt.registerLazySingleton<BarakahDao>(() => BarakahDao(database));
  getIt.registerLazySingleton<HabitDao>(() => HabitDao(database));
  getIt.registerLazySingleton<HabitCompletionsDao>(
    () => HabitCompletionsDao(database),
  );
  getIt.registerLazySingleton<TaskDao>(() => TaskDao(database));
  getIt.registerLazySingleton<IntentionDao>(() => IntentionDao(database));
  getIt.registerLazySingleton<MuhasabahDao>(() => MuhasabahDao(database));
  getIt.registerLazySingleton<AdhkarDao>(() => AdhkarDao(database));

  // Repositories
  getIt.registerLazySingleton<BarakahRepository>(
    () => BarakahRepositoryImpl(barakahDao: getIt<BarakahDao>()),
  );
  getIt.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(
      habitDao: getIt<HabitDao>(),
      habitCompletionsDao: getIt<HabitCompletionsDao>(),
    ),
  );
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(taskDao: getIt<TaskDao>()),
  );
  getIt.registerLazySingleton<IntentionRepository>(
    () => IntentionRepositoryImpl(intentionDao: getIt<IntentionDao>()),
  );
  getIt.registerLazySingleton<MuhasabahRepository>(
    () => MuhasabahRepositoryImpl(muhasabahDao: getIt<MuhasabahDao>()),
  );
  getIt.registerLazySingleton<AdhkarRepository>(
    () => AdhkarRepositoryImpl(
      adhkarDao: getIt<AdhkarDao>(),
      settingsService: getIt<SettingsService>(),
    ),
  );

  // Services
  getIt.registerLazySingleton<HomeWidgetSyncService>(
    () => HomeWidgetSyncService(),
  );
  getIt.registerLazySingleton<PrayerTimeService>(() => PrayerTimeService());
  getIt.registerLazySingleton<AdhanNotificationService>(
    () => AdhanNotificationService(
      onNotificationTapped: AppRouter.handleNotificationPayload,
    ),
  );
  getIt.registerLazySingleton<AdhkarService>(
    () => AdhkarService(
      prayerTimeService: getIt<PrayerTimeService>(),
      settingsService: getIt<SettingsService>(),
      homeWidgetSyncService: getIt<HomeWidgetSyncService>(),
      adhkarRepository: getIt<AdhkarRepository>(),
    ),
  );
  getIt.registerLazySingleton<PrayerNotificationScheduler>(
    () => PrayerNotificationScheduler(
      settingsService: getIt<SettingsService>(),
      plugin: LocalNotificationPluginAdapter(
        onNotificationTapped: AppRouter.handleNotificationPayload,
      ),
    ),
  );
  getIt.registerLazySingleton<QiblaService>(() => QiblaService());
  getIt.registerLazySingleton<HijriService>(() => HijriService());
  getIt.registerLazySingleton<BackupService>(
    () => BackupService(
      db: getIt<AppDatabase>(),
      settingsService: getIt<SettingsService>(),
    ),
  );
  getIt.registerLazySingleton<BarakahScoreService>(
    () => BarakahScoreService(
      habitRepo: getIt<HabitRepository>(),
      taskRepo: getIt<TaskRepository>(),
      barakahRepo: getIt<BarakahRepository>(),
      muhasabahRepo: getIt<MuhasabahRepository>(),
      settingsService: getIt<SettingsService>(),
      adhkarService: getIt<AdhkarService>(),
      hijriService: getIt<HijriService>(),
    ),
  );

  // Router
  getIt.registerSingleton<GoRouter>(AppRouter.router);
}
