# Native Android Home Screen Widget Specification

**Issue**: [#42](https://github.com/hamdi-ab/productive-muslim/issues/42)  
**Date**: 2026-09-30  
**Status**: In Progress  

---

## 1. Overview
This feature introduces a native Android AppWidget (Home Screen Widget) for the Productive Muslim app, giving users instantaneous visibility into:
1. **Active Barakah Window**: Identifies the Islamic productivity time slot (e.g., *Post-Fajr Barakah Hour*, *Duha Focus*, *Post-Asr Wind-Down*).
2. **Upcoming Prayer Time**: Next prayer name and formatted time (e.g., *Dhuhr • 12:45 PM*).
3. **Daily Dhikr Tracker**: Number of completed dhikr counts today.
4. **Interactive Deep Links**: Direct navigation into Prayer Times, Adhkar, or Focus modes.

---

## 2. Technical Architecture

### A. Flutter Layer
- **`HomeWidgetSyncService`** (`lib/data/services/home_widget_sync_service.dart`):
  - Serializes current prayer times, active window, and today's dhikr count into Android `SharedPreferences` via `home_widget` plugin or custom platform channel bridge.
  - Updates widget views whenever prayer times change or dhikr is logged.
  - Deep link handler in router / app initialization to navigate to `/prayer-times`, `/adhkar`, or `/focus`.

### B. Android Native Layer
- **Layouts** (`android/app/src/main/res/layout/`):
  - `prayer_barakah_widget.xml`: Responsive RemoteViews layout featuring custom Islamic styling, glass card background, icon indicators, and action buttons.
- **Widget Metadata** (`android/app/src/main/res/xml/`):
  - `prayer_barakah_widget_info.xml`: Sizing (minWidth/minHeight, target cell count 4x2 or 3x2), resizeMode, and preview layout.
- **Provider** (`android/app/src/main/kotlin/`):
  - `PrayerBarakahWidgetProvider.kt`: Kotlin AppWidgetProvider updating remote views with keys synced from Flutter.
- **Manifest**:
  - Registered receiver for `android.appwidget.action.APPWIDGET_UPDATE`.

---

## 3. Localization
Support both English and Arabic strings for widget labels:
- `widgetBarakahWindow`: "Barakah Window" / "ساعة البركة"
- `widgetNextPrayer`: "Next Prayer" / "الصلاة القادمة"
- `widgetTodayDhikr`: "Today's Dhikr" / "أذكار اليوم"
- `widgetQuickLaunch`: "Open App" / "فتح التطبيق"

---

## 4. Test & Verification Plan
- Unit tests for `HomeWidgetSyncService` verifying payload formatting, key synchronization, and null safety.
- Integration verification ensuring clean static analysis and 100% test pass rate.
