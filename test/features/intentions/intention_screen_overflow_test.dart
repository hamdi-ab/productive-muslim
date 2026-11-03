import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';
import 'package:productive_muslim/features/intentions/logic/intention_event.dart';
import 'package:productive_muslim/features/intentions/presentation/screens/intention_screen.dart';

import '../../helpers/overflow_test_helper.dart';

class _MockIntentionRepository extends Mock implements IntentionRepository {}

void main() {
  late _MockIntentionRepository mockRepository;

  setUp(() {
    mockRepository = _MockIntentionRepository();
    registerFallbackValue(
      IntentionEntry(id: 0, date: '', title: '', createdAt: 0),
    );
    registerFallbackValue(IntentionEntriesLoaded(''));

    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final testEntries = [
      IntentionEntry(
        id: 1,
        date: todayStr,
        title: 'Pray Fajr on time with devotion',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
      IntentionEntry(
        id: 2,
        date: todayStr,
        title: 'Read Surah Al-Kahf with contemplation',
        statement: 'Seeking tranquility and spiritual light for the week ahead',
        completed: true,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    ];

    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => testEntries);
  });

  Widget buildSubject() {
    return RepositoryProvider<IntentionRepository>.value(
      value: mockRepository,
      child: const IntentionScreen(),
    );
  }

  group('IntentionScreen - Overflow & Text-Scale Resilience', () {
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
