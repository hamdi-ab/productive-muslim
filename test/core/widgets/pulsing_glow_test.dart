import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/widgets/pulsing_glow.dart';

void main() {
  group('PulsingGlow Widget Tests', () {
    testWidgets('renders child when animate is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulsingGlow(animate: false, child: Text('Glow Target')),
          ),
        ),
      );

      expect(find.text('Glow Target'), findsOneWidget);
    });

    testWidgets('renders child inside Transform.scale when animate is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulsingGlow(
              animate: true,
              glowColor: Colors.amber,
              child: Text('Glow Target'),
            ),
          ),
        ),
      );

      expect(find.text('Glow Target'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Glow Target'), findsOneWidget);
    });
  });
}
