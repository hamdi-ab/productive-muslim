import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/widgets/animated_progress_ring.dart';
import 'package:productive_muslim/core/widgets/floating_glass_nav_bar.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/core/widgets/gradient_card.dart';

void main() {
  group('GlassContainer', () {
    testWidgets('renders child and handles tap callback', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              onTap: () => tapped = true,
              child: const Text('Glass Content'),
            ),
          ),
        ),
      );

      expect(find.text('Glass Content'), findsOneWidget);

      await tester.tap(find.text('Glass Content'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets(
      'renders BackdropFilter when blur > 0 and omits when blur == 0',
      (tester) async {
        // blur > 0
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: GlassContainer(blur: 15.0, child: Text('Blurred')),
            ),
          ),
        );

        expect(find.byType(BackdropFilter), findsOneWidget);

        // blur <= 0
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: GlassContainer(blur: 0, child: Text('Unblurred')),
            ),
          ),
        );

        expect(find.byType(BackdropFilter), findsNothing);
        expect(find.text('Unblurred'), findsOneWidget);
      },
    );

    testWidgets('applies margin and custom dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              width: 200,
              height: 100,
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(8),
              child: Text('Sized Container'),
            ),
          ),
        ),
      );

      expect(find.text('Sized Container'), findsOneWidget);
    });
  });

  group('AnimatedProgressRing', () {
    testWidgets('renders child and paints progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedProgressRing(
              progress: 0.75,
              size: 80,
              child: Text('75%'),
            ),
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Settle animation
      await tester.pumpAndSettle();
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('clamps progress between 0.0 and 1.0 gracefully', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedProgressRing(progress: 1.5, size: 64)),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(AnimatedProgressRing), findsOneWidget);
    });
  });

  group('FloatingGlassNavBar', () {
    final testItems = [
      const FloatingNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
      ),
      const FloatingNavItem(
        icon: Icons.check_circle_outline,
        activeIcon: Icons.check_circle_rounded,
        label: 'Tasks',
      ),
      const FloatingNavItem(
        icon: Icons.track_changes_outlined,
        activeIcon: Icons.track_changes_rounded,
        label: 'Habits',
      ),
    ];

    testWidgets('renders all nav items and highlights selected index', (
      tester,
    ) async {
      int selectedIndex = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return FloatingGlassNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) => setState(() => selectedIndex = index),
                  items: testItems,
                );
              },
            ),
          ),
        ),
      );

      // Selected item label is rendered
      expect(find.text('Tasks'), findsOneWidget);

      // Tapping first item changes selected index to 0
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();

      expect(selectedIndex, 0);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('exposes proper accessibility semantics for navigation items', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: FloatingGlassNavBar(
              currentIndex: 0,
              onTap: (_) {},
              items: testItems,
            ),
          ),
        ),
      );

      final homeSemantics = tester.getSemantics(find.bySemanticsLabel('Home'));
      expect(homeSemantics.label, 'Home');
      expect(homeSemantics.flagsCollection.isButton, isTrue);
      expect(
        homeSemantics.flagsCollection.isSelected.toString(),
        'Tristate.isTrue',
      );

      final tasksSemantics = tester.getSemantics(
        find.bySemanticsLabel('Tasks'),
      );
      expect(tasksSemantics.label, 'Tasks');
      expect(tasksSemantics.flagsCollection.isButton, isTrue);
      expect(
        tasksSemantics.flagsCollection.isSelected.toString(),
        isNot('Tristate.isTrue'),
      );
    });
  });

  group('GradientCard', () {
    testWidgets('renders child and handles tap callback', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCard(
              onTap: () => tapped = true,
              margin: const EdgeInsets.all(8),
              child: const Text('Gradient Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Gradient Card Content'), findsOneWidget);

      await tester.tap(find.text('Gradient Card Content'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
