import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';

import 'core/di/di.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/barakah_repository.dart';
import 'domain/repositories/habit_repository.dart';
import 'domain/repositories/intention_repository.dart';
import 'domain/repositories/task_repository.dart';
import 'l10n/app_localizations.dart';

void main() {
  DevicePreview.enable();
  setupDi();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BarakahRepository>.value(
          value: getIt<BarakahRepository>(),
        ),
        RepositoryProvider<HabitRepository>.value(
          value: getIt<HabitRepository>(),
        ),
        RepositoryProvider<TaskRepository>.value(
          value: getIt<TaskRepository>(),
        ),
        RepositoryProvider<IntentionRepository>.value(
          value: getIt<IntentionRepository>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Productive Muslim',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        routerConfig: AppRouter.router,
      ),
    );
  }
}
