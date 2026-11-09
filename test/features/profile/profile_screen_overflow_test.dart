import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/profile/presentation/screens/profile_screen.dart';

import '../../helpers/overflow_test_helper.dart';

class _MockBarakahRepository extends Mock implements BarakahRepository {}

void main() {
  late _MockBarakahRepository mockRepository;

  setUp(() {
    mockRepository = _MockBarakahRepository();
    registerFallbackValue(
      const BarakahEntry(id: 0, date: '', sourceIds: [], createdAt: 0),
    );

    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => []);
  });

  Widget buildSubject() {
    return RepositoryProvider<BarakahRepository>.value(
      value: mockRepository,
      child: const ProfileScreen(),
    );
  }

  group('ProfileScreen - Overflow & Text-Scale Resilience', () {
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
