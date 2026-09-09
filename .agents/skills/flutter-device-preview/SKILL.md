---
name: flutter-device-preview
description: Use device_preview to simulate devices during development. Covers the one-line enable() call in main.dart, programmatic control via DevicePreview.controller, presets, and test bindings. Use when adding device_preview, switching simulated devices, or testing layout across device sizes.
package: device_preview
aliases: [device-preview, device-simulation, responsive-testing, multi-device]
sources: [chat, code]
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 09 Sep 2026 14:54:00 GMT
  versions:
    device_preview: ^3.0.0
---

# Device Preview for Development

This app uses `device_preview` to simulate devices during development. It is active in debug and profile builds only — completely off in release. The UI lives in Flutter DevTools, not in-app.

## Core Rules

1. `DevicePreview.enable()` in `main.dart` is the only required integration.
2. No `MaterialApp` wrapper needed — v3.0 simulates below the widget layer.
3. Never ship in release — `enable()` defaults to `!kReleaseMode`.
4. Use `DevicePreview.maybeController` in code that runs in release builds.
5. Use presets from `package:device_preview/presets.dart` — only referenced presets are compiled in.

## Setup

```dart
// pubspec.yaml
dependencies:
  device_preview: ^3.0.0

// main.dart
import 'package:device_preview/device_preview.dart';

void main() {
  DevicePreview.enable(); // on in debug/profile, off in release
  runApp(const MyApp());
}
```

## Programmatic Control

```dart
// Apply a preset
final c = DevicePreview.controller;
await c.applyPreset(DevicePresets.iPhone16);

// Update simulation
await c.update((s) => s.copyWith(
  textScaleFactor: 2.0,
  platformBrightness: Brightness.dark,
  orientation: Orientation.landscape,
));

// Reset to real device
await c.reset();

// Safe access in release builds
DevicePreview.maybeController?.applyPreset(DevicePresets.iPhone16);
```

## Arabic RTL Testing

This app supports Arabic. Test RTL layout explicitly:

```dart
await c.applyPreset(DevicePresets.iPhone16);
await c.update((s) => s.copyWith(
  locale: const Locale('ar'),
  platformBrightness: Brightness.dark,
));
```

## Widget Testing with Simulated Devices

```dart
// test/device_preview_binding.dart
import 'dart:ui' as ui;
import 'package:device_preview/device_preview.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class TestDevicePreviewBinding extends AutomatedTestWidgetsFlutterBinding
    with DevicePreviewBindingMixin {
  static TestDevicePreviewBinding? _instance;

  static TestDevicePreviewBinding ensureInitialized() {
    if (_instance == null) {
      DevicePreviewBindingMixin.latchConfiguration(
        enabled: true,
      );
      TestDevicePreviewBinding();
    }
    return _instance!;
  }

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  @override
  Widget wrapWithDefaultView(Widget rootWidget) {
    final ui.FlutterView? wrapperView = previewImplicitView;
    final controller = devicePreview;
    if (wrapperView != null) {
      return View(
        view: wrapperView,
        child: controller == null
            ? rootWidget
            : DevicePreviewFrame(
                simulation: controller.simulationListenable,
                child: rootWidget,
              ),
      );
    }
    return super.wrapWithDefaultView(rootWidget);
  }
}

// test/my_test.dart
import 'package:device_preview/presets.dart';

void main() {
  final binding = TestDevicePreviewBinding.ensureInitialized();

  testWidgets('renders on iPhone 16 in RTL', (tester) async {
    await binding.devicePreview!.applyPreset(DevicePresets.iPhone16);
    await tester.pumpWidget(const MyApp());
    expect(find.text('مواقيت الصلاة'), findsOneWidget);
  });

  testWidgets('no overflow at 200% text scale', (tester) async {
    await binding.devicePreview!.applyPreset(DevicePresets.iPhoneSe3);
    await binding.devicePreview!.update(
      (s) => s.copyWith(textScaleFactor: 2.0),
    );
    await tester.pumpWidget(const MyApp());
    expect(tester.takeException(), isNull);
  });
}
```

## What This Skill Does Not Cover

- DevTools panel UI — see Flutter DevTools documentation
- Custom device frames — use `registerPreset` or JSON specs
- Integration tests with simulated devices — compose with `integration_test` binding
- CI device matrix — use Firebase Test Lab or similar for CI