import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/settings/logic/settings_bloc.dart';
import 'package:productive_muslim/features/settings/presentation/barakah_reminder_lifecycle.dart';
import 'package:productive_muslim/features/settings/presentation/screens/settings_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fake_reminder_scheduler.dart';

void main() {
  late FakeReminderScheduler scheduler;
  late SettingsService settings;
  late BarakahReminderService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = SettingsService(prefs: await SharedPreferences.getInstance());
    scheduler = FakeReminderScheduler();
    service = BarakahReminderService(settings: settings, scheduler: scheduler);
  });
  tearDown(() => service.dispose());

  Future<void> pumpScreen(
    WidgetTester tester, {
    String language = 'en',
    bool lifecycle = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider(
          create: (_) => SettingsBloc(service),
          child: lifecycle
              ? BarakahReminderLifecycle(
                  service: service,
                  child: const SettingsView(),
                )
              : const SettingsView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('toggle enables and disables persisted reminder', (tester) async {
    await pumpScreen(tester);
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const Key('barakah_reminder_toggle')),
          )
          .value,
      isFalse,
    );
    expect(find.text('8:00 PM'), findsOneWidget);
    await tester.tap(find.byKey(const Key('barakah_reminder_toggle')));
    await tester.pumpAndSettle();
    expect(
      settings.barakahReminder.enabled,
      isTrue,
      reason:
          'calls=${scheduler.calls}, pending=${service.status.pending}, failure=${service.status.failure}',
    );
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const Key('barakah_reminder_toggle')),
          )
          .value,
      isTrue,
    );
    await tester.tap(find.byKey(const Key('barakah_reminder_toggle')));
    await tester.pumpAndSettle();
    expect(settings.barakahReminder.enabled, isFalse);
    expect(scheduler.calls.last, 'cancel');
  });

  testWidgets('time picker changes saved time and cancel leaves it unchanged', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Reminder time'));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '9');
    await tester.enterText(find.byType(TextField).at(1), '35');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(settings.barakahReminder, (enabled: false, hour: 21, minute: 35));
    expect(find.text('9:35 PM'), findsOneWidget);
    await tester.tap(find.text('Reminder time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(settings.barakahReminder.minute, 35);
    expect(scheduler.calls, ['initialize', 'cancel']);
  });

  testWidgets('permission pending disables switch and time picker', (
    tester,
  ) async {
    scheduler.permissionResult = Completer<bool>();
    await pumpScreen(tester);
    await tester.tap(find.byKey(const Key('barakah_reminder_toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Updating reminder…'), findsOneWidget);
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const Key('barakah_reminder_toggle')),
          )
          .onChanged,
      isNull,
    );
    expect(tester.widget<ListTile>(find.byType(ListTile).last).onTap, isNull);
    expect(settings.barakahReminder.enabled, isFalse);
    scheduler.permissionResult!.complete(true);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const Key('barakah_reminder_toggle')),
          )
          .onChanged,
      isNotNull,
    );
  });

  testWidgets('denial and error show English messages without enabled switch', (
    tester,
  ) async {
    scheduler.permitted = false;
    await pumpScreen(tester);
    await tester.tap(find.byKey(const Key('barakah_reminder_toggle')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Notifications are not allowed.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const Key('barakah_reminder_toggle')),
          )
          .value,
      isFalse,
    );
    scheduler.permitted = true;
    scheduler.scheduleFailed = true;
    await tester.tap(find.byKey(const Key('barakah_reminder_toggle')));
    await tester.pumpAndSettle();
    expect(
      find.text('The reminder could not be updated. Please try again.'),
      findsOneWidget,
    );
    expect(settings.barakahReminder.enabled, isFalse);
  });

  testWidgets(
    'unsupported UI explains availability and disables both controls',
    (tester) async {
      scheduler.supported = false;
      await service.dispose();
      service = BarakahReminderService(
        settings: settings,
        scheduler: scheduler,
      );
      await pumpScreen(tester);
      expect(
        find.textContaining('only in the Android and iOS apps'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<SwitchListTile>(
              find.byKey(const Key('barakah_reminder_toggle')),
            )
            .onChanged,
        isNull,
      );
      expect(tester.widget<ListTile>(find.byType(ListTile).last).onTap, isNull);
      expect(scheduler.calls, isEmpty);
    },
  );

  testWidgets(
    'Arabic screen is RTL with localized picker, denial and notification copy',
    (tester) async {
      scheduler.permitted = false;
      await pumpScreen(tester, language: 'ar');
      expect(find.text('الإعدادات'), findsOneWidget);
      expect(find.text('تذكير يومي بالبركة'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(SettingsView))),
        TextDirection.rtl,
      );
      await tester.tap(find.text('وقت التذكير'));
      await tester.pumpAndSettle();
      final pickerContext = tester.element(find.byType(TimePickerDialog));
      expect(Directionality.of(pickerContext), TextDirection.rtl);
      await tester.tap(
        find.text(MaterialLocalizations.of(pickerContext).cancelButtonLabel),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('barakah_reminder_toggle')));
      await tester.pumpAndSettle();
      expect(find.textContaining('الإشعارات غير مسموح بها.'), findsOneWidget);
      scheduler.permitted = true;
      await tester.tap(find.byKey(const Key('barakah_reminder_toggle')));
      await tester.pumpAndSettle();
      expect(scheduler.contents.single.title, 'تأمل يومي في البركة');
      expect(
        scheduler.contents.single.body,
        'خذ لحظة للتأمل في مصادر البركة في يومك.',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('lifecycle initializes and resumes without permission prompts', (
    tester,
  ) async {
    await service.setEnabled(true, reminderContent);
    scheduler.calls.clear();
    await pumpScreen(tester, lifecycle: true);
    expect(scheduler.calls, ['initialize', 'check', 'schedule']);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(scheduler.calls, [
      'initialize',
      'check',
      'schedule',
      'initialize',
      'check',
      'schedule',
    ]);
    expect(scheduler.calls, isNot(contains('request')));
  });

  testWidgets('initialization error leaves app visible and interactive', (
    tester,
  ) async {
    scheduler.initializationFailed = true;
    await pumpScreen(tester, lifecycle: true);
    expect(find.text('Settings'), findsOneWidget);
    expect(
      find.text('The reminder could not be updated. Please try again.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const Key('barakah_reminder_toggle')),
          )
          .onChanged,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });
}
