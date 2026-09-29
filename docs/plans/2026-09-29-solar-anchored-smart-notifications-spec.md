# Specification: Solar-Anchored Smart Notifications & Sunnah Reminders

**Date**: 2026-09-29  
**Status**: Draft / In-Progress  
**Author**: Antigravity Pair Programmer & Hamdi  
**Target Milestone**: v1.4.0 — Ambient Contextual Reminders  

---

## 1. Executive Summary & Problem Statement

### The Problem
Traditional Islamic apps either rely on:
1. **Dumb clock alarms** (e.g., fixed 6:00 AM or 5:00 PM alarms) that fail as solar prayer times shift dramatically throughout the year.
2. **Aggressive or spammy prayer alerts** that users quickly mute or disable entirely.
3. **No proactive guidance** for high-barakah Sunnah routines (e.g. remembering to intend a Sunnah fast on Sunday or Wednesday evening before sleeping, or taking a 20-minute Qaylulah before Dhuhr).

### The Solution
A **Solar-Anchored Smart Notification System** that calculates dynamic daily trigger times based on the user's local solar prayer calculations:
- 🌅 **Morning Adhkar Reminder**: 15–20 minutes after Fajr / Sunrise (optimal post-Salah golden hour).
- 🌆 **Evening Adhkar Reminder**: At Asr or 30 minutes before Maghrib (evening protection shield).
- 🌙 **Bedtime Adhkar & Witr Nudge**: User's configured target bedtime (or post-Isha wind-down).
- 🥣 **Sunnah Fasting Reminder**: Proactive gentle reminder on **Sunday & Wednesday evenings** (around 8:30 PM / after Isha) to set the intention (Niyyah) for Monday & Thursday fasting.
- 😴 **Sunnah Qaylulah Prompt**: Optional midday reminder (30 min before Dhuhr) to take a 20-minute power nap.

All notifications use soft, spiritually uplifting copy, 1-tap deep links directly to the relevant action screen (e.g. `/adhkar`, `/energy`), and respect user toggles stored locally in SQLite / SharedPreferences.

---

## 2. Technical Architecture & Component Design

### 2.1 Services & Managers
- **`PrayerNotificationScheduler`**:
  - Central service registered in `getIt` responsible for calculating exact scheduled trigger times and registering them with `flutter_local_notifications`.
  - Re-calculates and reschedules notifications whenever:
    1. The app launches or resumes (`AppLifecycleState.resumed`).
    2. The user's location changes or prayer times update.
    3. The user modifies notification preferences in `SettingsScreen`.
- **Notification Channels**:
  - `adhkar_reminders_channel` (High importance, gentle sound/vibration).
  - `sunnah_fasting_channel` (Default importance).
  - `routine_reminders_channel` (Default importance).

### 2.2 Deep Linking Routes
Each notification includes payload data routing the user via `GoRouter`:
- Morning Adhkar payload `route:/adhkar?category=morning` -> opens `AdhkarScreen(initialCategory: DhikrCategory.morning)`
- Evening Adhkar payload `route:/adhkar?category=evening` -> opens `AdhkarScreen(initialCategory: DhikrCategory.evening)`
- Bedtime Adhkar payload `route:/adhkar?category=sleeping` -> opens `AdhkarScreen(initialCategory: DhikrCategory.sleeping)`
- Sunnah Fasting payload `route:/energy` -> opens `EnergyScreen` with fasting tracker focused.

### 2.3 Settings & Granular Toggles (`SettingsService`)
Add persisted settings:
- `bool morningAdhkarNotificationEnabled` (default: `true`)
- `bool eveningAdhkarNotificationEnabled` (default: `true`)
- `bool sleepingAdhkarNotificationEnabled` (default: `true`)
- `bool sunnahFastingNotificationEnabled` (default: `true`)
- `bool qaylulahNotificationEnabled` (default: `false`)
- `TimeOfDay bedtimeReminderTime` (default: `22:30`)

---

## 3. Localization (English & Arabic)

### English Strings (`app_en.arb`)
- `notificationAdhkarMorningTitle`: `"🌅 Morning Adhkar • Golden Barakah Hour"`
- `notificationAdhkarMorningBody`: `"Start your day with divine protection and light. Tap for 1-tap haptic counting."`
- `notificationAdhkarEveningTitle`: `"🌆 Evening Adhkar • Shield Your Evening"`
- `notificationAdhkarEveningBody`: `"Fortify your soul before sunset with the authentic evening remembrances."`
- `notificationAdhkarSleepingTitle`: `"🌙 Bedtime Adhkar & Sunnah"`
- `notificationAdhkarSleepingBody`: `"Wind down with Surat Al-Ikhlas, Falaq, Nas, and the bedtime supplication."`
- `notificationFastingTitle`: `"🥣 Sunnah Fasting Reminder"`
- `notificationFastingBody`: `"Tomorrow is {dayName}. Intend to fast for Allah to gain immense Barakah."`
- `notificationQaylulahTitle`: `"😴 Sunnah Qaylulah Time"`
- `notificationQaylulahBody`: `"Recharge your physical energy with a 20-minute midday Sunnah power nap."`
- Settings UI labels and descriptions.

### Arabic Strings (`app_ar.arb`)
- Corresponding authentic Arabic titles, descriptions, and settings options.

---

## 4. Test Strategy (TDD Workflow)

1. **Service Unit Tests (`prayer_notification_scheduler_test.dart`)**:
   - Verify calculation of morning/evening solar offsets (e.g. Fajr + 15m, Asr + 0m).
   - Verify Sunday/Wednesday evening calculation for Sunnah Fasting.
   - Verify notification ID stability (no ID collisions).
   - Verify rescheduling on settings toggle updates.
2. **Settings BLoC & Screen Widget Tests (`settings_notifications_test.dart`)**:
   - Verify switches toggle preferences and trigger scheduler reconciliation.
   - Verify permission denial is handled gracefully with localized warning.
3. **Router Deep Link Integration Tests**:
   - Verify tapping notification payload routes to `/adhkar` with category extra.

---

## 5. Acceptance Criteria

- [ ] Notifications adjust dynamically to local prayer times (Fajr/Sunrise/Asr/Maghrib).
- [ ] Sunday and Wednesday evenings trigger Sunnah Fasting reminder (8:30 PM).
- [ ] Tapping a notification opens the exact target screen in the app.
- [ ] Settings screen allows turning individual reminders on/off.
- [ ] Fully localized in English and Arabic (RTL tested).
- [ ] 100% unit & widget test coverage for new scheduler and UI components.
- [ ] `flutter analyze` passes with 0 warnings/errors.
