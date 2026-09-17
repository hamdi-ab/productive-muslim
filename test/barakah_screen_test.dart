import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockBarakahRepository extends Mock implements BarakahRepository {}

void main() {
  const entry = BarakahEntry(
    id: 1,
    date: '2026-09-17',
    sourceIds: ['Charity'],
    createdAt: 0,
  );

  setUpAll(() => registerFallbackValue(entry));

  Future<void> pumpScreen(
    WidgetTester tester,
    BarakahRepository repository,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RepositoryProvider<BarakahRepository>.value(
        value: repository,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BarakahScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final button in ['Yes', 'Log Barakah']) {
    testWidgets('$button preserves selected sources when clearing the form', (
      tester,
    ) async {
      final repository = MockBarakahRepository();
      when(() => repository.getEntriesForDate(any()))
          .thenAnswer((_) async => []);
      when(() => repository.insertEntry(any())).thenAnswer((_) async => 1);
      await pumpScreen(tester, repository);
      await tester.tap(find.widgetWithText(FilterChip, 'Charity'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Helped a neighbour');
      await tester.tap(find.widgetWithText(FilledButton, button));
      await tester.pumpAndSettle();

      final saved =
          verify(() => repository.insertEntry(captureAny())).captured.single
              as BarakahEntry;
      expect(saved.sourceIds, ['Charity']);
      expect(saved.note, 'Helped a neighbour');
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Charity'))
            .selected,
        isFalse,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('deletes an entry using the screen Bloc provider', (
    tester,
  ) async {
    final repository = MockBarakahRepository();
    when(() => repository.getEntriesForDate(any()))
        .thenAnswer((_) async => [entry]);
    when(() => repository.deleteEntry(1)).thenAnswer((_) async => 1);
    await pumpScreen(tester, repository);
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    verify(() => repository.deleteEntry(1)).called(1);
    expect(find.byType(ListTile), findsNothing);
  });
}
