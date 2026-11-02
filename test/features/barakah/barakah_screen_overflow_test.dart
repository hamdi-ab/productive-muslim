import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_screen.dart';

import '../../helpers/overflow_test_helper.dart';

class MockBarakahRepository extends Mock implements BarakahRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockBarakahRepository repository;

  const sampleEntry = BarakahEntry(
    id: 1,
    date: '2026-09-17',
    sourceIds: ['Charity', 'Reading Quran'],
    note: 'Deep morning focus after Fajr',
    createdAt: 0,
  );

  final sampleDaily = BarakahDailyResponse(
    date: '2026-09-17',
    promptId: 'quran_v1',
    answer: BarakahAnswer.yes,
    sourceIds: const ['Reading Quran'],
    note: 'Read Surah Al-Kahf with reflection',
    createdAt: 1,
    updatedAt: 2,
  );

  setUp(() {
    repository = MockBarakahRepository();
    when(() => repository.getEntriesForDate(any()))
        .thenAnswer((_) async => [sampleEntry]);
    when(() => repository.watchDailyResponse(any()))
        .thenAnswer((_) => Stream.value(sampleDaily));
  });

  group('BarakahScreen RTL and Text Scale Resilience', () {
    testWidgets('BarakahScreen has zero overflow at 1.5x scale in Arabic RTL', (
      tester,
    ) async {
      await pumpAndCheckOverflow(
        tester,
        child: RepositoryProvider<BarakahRepository>.value(
          value: repository,
          child: const SizedBox(
            height: 900,
            child: BarakahScreen(date: '2026-09-17'),
          ),
        ),
        locale: const Locale('ar'),
        textScale: 1.5,
        isDark: true,
        screenSize: const Size(360, 780),
      );
    });

    testWidgets(
      'BarakahScreen has zero overflow in light mode at 1.5x scale in English',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: RepositoryProvider<BarakahRepository>.value(
            value: repository,
            child: const SizedBox(
              height: 900,
              child: BarakahScreen(date: '2026-09-17'),
            ),
          ),
          locale: const Locale('en'),
          textScale: 1.5,
          isDark: false,
          screenSize: const Size(360, 780),
        );
      },
    );
  });
}
