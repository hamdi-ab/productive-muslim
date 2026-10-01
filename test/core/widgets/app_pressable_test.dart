import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';

void main() {
  group('AppPressable Widget Tests', () {
    testWidgets('renders child widget correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppPressable(child: Text('Press Me'))),
        ),
      );

      expect(find.text('Press Me'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when pressed', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPressable(
              onTap: () => tapped = true,
              child: const Text('Press Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Press Me'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('animates scale on tap down and tap up', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPressable(
              onTap: () {},
              pressedScale: 0.90,
              child: const Text('Scale Target'),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Scale Target')),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Animated scale in progress
      final scaleFinder = find.descendant(
        of: find.byType(AppPressable),
        matching: find.byType(ScaleTransition),
      );
      expect(scaleFinder, findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('triggers onLongPress callback', (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPressable(
              onLongPress: () => longPressed = true,
              child: const Text('Hold Me'),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Hold Me'));
      await tester.pumpAndSettle();

      expect(longPressed, isTrue);
    });
  });
}
