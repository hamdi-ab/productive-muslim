import 'package:flutter_test/flutter_test.dart';

import 'package:productive_muslim/main.dart';

void main() {
  testWidgets('app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // App should render the onboarding screen
    expect(find.text('Build your day around what matters'), findsOneWidget);
  });
}
