import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';

import 'core/di/di.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/home_widget_sync_service.dart';
import 'domain/repositories/barakah_repository.dart';
import 'domain/repositories/habit_repository.dart';
import 'domain/repositories/intention_repository.dart';
import 'domain/repositories/task_repository.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDi();
  runApp(
    DevicePreview(enabled: !kReleaseMode, builder: (context) => const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri?>? _widgetClickSub;

  @override
  void initState() {
    super.initState();
    _initHomeWidgetDeepLinking();
  }

  void _initHomeWidgetDeepLinking() {
    if (getIt.isRegistered<HomeWidgetSyncService>()) {
      final service = getIt<HomeWidgetSyncService>();
      service.getInitiallyLaunchedUri().then((uri) {
        if (uri != null) {
          AppRouter.handleDeepLinkUri(uri);
        }
      });
      _widgetClickSub = service.widgetClickedStream.listen((uri) {
        if (uri != null) {
          AppRouter.handleDeepLinkUri(uri);
        }
      });
    }
  }

  @override
  void dispose() {
    _widgetClickSub?.cancel();
    super.dispose();
  }

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
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
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
