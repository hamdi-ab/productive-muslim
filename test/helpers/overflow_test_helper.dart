import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Helper to test that a widget does not cause RenderFlex overflows under
/// constrained conditions: narrow viewport, large font scaling, and Arabic RTL.
Future<void> pumpAndCheckOverflow(
  WidgetTester tester, {
  required Widget child,
  Locale locale = const Locale('ar'),
  double textScale = 1.5,
  bool isDark = true,
  Size screenSize = const Size(360, 780),
  bool wrapInScrollView = true,
}) async {
  tester.view.physicalSize = screenSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final Widget content = wrapInScrollView
      ? SingleChildScrollView(child: child)
      : SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: child,
        );

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: MediaQuery(
        data: MediaQueryData(
          size: screenSize,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(body: content),
      ),
    ),
  );

  await tester.pumpAndSettle();

  // Assert no layout overflow exceptions were thrown during render
  final exception = tester.takeException();
  expect(
    exception,
    isNull,
    reason:
        'Widget overflowed during render with textScale=$textScale, locale=$locale: $exception',
  );
}
