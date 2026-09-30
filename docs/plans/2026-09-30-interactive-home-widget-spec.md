# Interactive Home Screen Widget Specification

## 1. Overview
Enhance the Productive Muslim Android Home Screen Widget into an interactive Islamic productivity companion featuring:
- Direct interactive **+1 Quick Tasbih** button executed via background broadcast without opening the app.
- Direct **Khushu' Focus** launcher (`productivemuslim://focus`).
- Real-time **Hijri Date & Sunnah Fasting** badge (`productivemuslim://fasting`).
- Real-time **Next Prayer & Countdown** display (`productivemuslim://prayer_times`).
- Real-time **Barakah Window** active indicator (`productivemuslim://home`).

## 2. Architecture & Data Flow

```
[Android Home Screen Widget]
   ├── [+1 Quick Tasbih Button] ──> Background Broadcast Intent (productivemuslim://increment_tasbih)
   │                                     │
   │                                     ▼
   │                           [interactiveBackgroundCallback (Dart)]
   │                                     │
   │                                     ▼
   │                           [SharedPreferences / HomeWidget Storage]
   │                                     │
   │                                     ▼
   │                           [Instant Widget Redraw with updated count]
   │
   ├── [Focus Button] ───────────> Deep Link (productivemuslim://focus) -> FocusScreen
   ├── [Hijri/Fasting Badge] ────> Deep Link (productivemuslim://fasting) -> FastingScreen
   ├── [Prayers Action] ─────────> Deep Link (productivemuslim://prayer_times) -> PrayerTimesScreen
   └── [Adhkar Action] ──────────> Deep Link (productivemuslim://adhkar) -> AdhkarScreen
```

## 3. Detailed Component Spec
- **`HomeWidgetSyncService`**: Expanded with keys for `widget_hijri_date`, `widget_fasting_badge`, `widget_dhikr_raw_count`, and background increment helper.
- **`interactiveBackgroundCallback`**: `@pragma('vm:entry-point')` top-level callback handling `productivemuslim://increment_tasbih`.
- **`PrayerBarakahWidgetProvider.kt`**: RemoteViews binding for `HomeWidgetBackgroundIntent` on the increment button and `HomeWidgetLaunchIntent` on deep link buttons.
- **`prayer_barakah_widget.xml`**: Layout supporting direct +1 pill button, Hijri fasting badge, and crisp responsive styling.
