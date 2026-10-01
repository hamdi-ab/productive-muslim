import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/widgets/bouncy_checkbox.dart';

void main() {
  group('BouncyCheckbox Widget Tests', () {
    testWidgets('renders unchecked state without check icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BouncyCheckbox(value: false))),
      );

      expect(find.byKey(const ValueKey('unchecked_empty')), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('renders checked state with check icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BouncyCheckbox(value: true))),
      );

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('toggles value and calls onChanged', (tester) async {
      bool currentVal = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: BouncyCheckbox(
                  value: currentVal,
                  onChanged: (val) {
                    setState(() => currentVal = val);
                  },
                ),
              ),
            );
          },
        ),
      );

      expect(find.byIcon(Icons.check_rounded), findsNothing);

      await tester.tap(find.byType(BouncyCheckbox));
      await tester.pumpAndSettle();

      expect(currentVal, isTrue);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}
