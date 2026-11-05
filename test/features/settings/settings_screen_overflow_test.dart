import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/settings/logic/settings_bloc.dart';
import 'package:productive_muslim/features/settings/presentation/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_reminder_scheduler.dart';
import '../../helpers/overflow_test_helper.dart';

void main() {
  late FakeReminderScheduler scheduler;
  late SettingsService settings;
  late BarakahReminderService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = SettingsService(prefs: await SharedPreferences.getInstance());
    scheduler = FakeReminderScheduler();
    service = BarakahReminderService(settings: settings, scheduler: scheduler);
    if (!getIt.isRegistered<SettingsService>()) {
      getIt.registerSingleton<SettingsService>(settings);
    }
  });

  tearDown(() {
    service.dispose();
    if (getIt.isRegistered<SettingsService>()) {
      getIt.unregister<SettingsService>();
    }
  });

  Widget buildSubject() {
    return BlocProvider(
      create: (_) => SettingsBloc(service),
      child: const SettingsView(),
    );
  }

  group('SettingsScreen - Overflow & Text-Scale Resilience', () {
    testWidgets('no overflow at 1.0x text scale (LTR)', (tester) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('en'),
        textScale: 1.0,
        wrapInScrollView: false,
      );
    });

    testWidgets('no overflow at 1.5x text scale (LTR)', (tester) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('en'),
        textScale: 1.5,
        wrapInScrollView: false,
      );
    });

    testWidgets('no overflow at 1.5x text scale (RTL Arabic)', (tester) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('ar'),
        textScale: 1.5,
        wrapInScrollView: false,
      );
    });
  });
}
