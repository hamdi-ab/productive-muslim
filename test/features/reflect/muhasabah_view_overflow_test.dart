import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/muhasabah_entry.dart';
import 'package:productive_muslim/domain/repositories/muhasabah_repository.dart';
import 'package:productive_muslim/features/reflect/presentation/widgets/muhasabah_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/mocks.dart';
import '../../helpers/overflow_test_helper.dart';

void main() {
  late MockMuhasabahRepository mockRepo;
  late SettingsService settings;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    settings = SettingsService(prefs: await SharedPreferences.getInstance());

    mockRepo = MockMuhasabahRepository();
    stubDefaultRepositoryMocks(muhasabahRepo: mockRepo);

    final testEntries = [
      MuhasabahEntry(
        id: 1,
        date: '2026-11-18',
        content: 'A very long contemplative reflection documenting gratitude for family, sustained health, barakah in time, and patience through work and university exams.',
        promptText:
            'What blessing did you receive today that you are grateful for?',
        tags: '#Shukr #Sabr #Tawakkul #Ihsan #Gratitude',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    ];

    when(() => mockRepo.watchEntriesForDate(any()))
        .thenAnswer((_) => Stream.value(testEntries));
    when(() => mockRepo.getEntriesForDate(any()))
        .thenAnswer((_) async => testEntries);

    getIt.registerSingleton<SettingsService>(settings);
    getIt.registerSingleton<MuhasabahRepository>(mockRepo);
    getIt.registerLazySingleton<PrayerTimeService>(
      () => MockPrayerTimeService(),
    );
    getIt.registerLazySingleton<AdhkarService>(
      () => AdhkarService(settingsService: settings),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildSubject() {
    return RepositoryProvider<MuhasabahRepository>.value(
      value: mockRepo,
      child: const Scaffold(body: MuhasabahView()),
    );
  }

  group('MuhasabahView - Overflow & Text-Scale Resilience', () {
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

    testWidgets('no overflow at 2.0x text scale (LTR)', (tester) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('en'),
        textScale: 2.0,
        wrapInScrollView: false,
      );
    });

    testWidgets('no overflow at 1.0x text scale (RTL Arabic)', (tester) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('ar'),
        textScale: 1.0,
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

    testWidgets('no overflow at 2.0x text scale (RTL Arabic)', (tester) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('ar'),
        textScale: 2.0,
        wrapInScrollView: false,
      );
    });
  });
}
