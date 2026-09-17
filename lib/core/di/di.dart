import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:productive_muslim/core/router/app_router.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/daos/barakah_dao.dart';
import 'package:productive_muslim/data/local/daos/habit_dao.dart';
import 'package:productive_muslim/data/local/daos/intention_dao.dart';
import 'package:productive_muslim/data/local/daos/task_dao.dart';
import 'package:productive_muslim/data/repositories/barakah_repository_impl.dart';
import 'package:productive_muslim/data/repositories/habit_repository_impl.dart';
import 'package:productive_muslim/data/repositories/intention_repository_impl.dart';
import 'package:productive_muslim/data/repositories/task_repository_impl.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/data/services/local_barakah_reminder_scheduler.dart';
import 'package:productive_muslim/domain/repositories/barakah_reminder_scheduler.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';

final getIt = GetIt.instance;

Future<void> setupDi() async {
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
  getIt.registerLazySingleton<TaskDao>(() => TaskDao(database));
  getIt.registerLazySingleton<IntentionDao>(() => IntentionDao(database));

  // Repositories
  getIt.registerLazySingleton<BarakahRepository>(
    () => BarakahRepositoryImpl(barakahDao: getIt<BarakahDao>()),
  );
  getIt.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(habitDao: getIt<HabitDao>()),
  );
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(taskDao: getIt<TaskDao>()),
  );
  getIt.registerLazySingleton<IntentionRepository>(
    () => IntentionRepositoryImpl(intentionDao: getIt<IntentionDao>()),
  );

  // Router
  getIt.registerSingleton<GoRouter>(AppRouter.router);
}
