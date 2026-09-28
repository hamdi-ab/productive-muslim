# Technical Specification: Contextual Adhkar & Daily Du'as Engine (Right-Time Remembrances)

**Document Date:** 2026-09-28  
**Status:** DRAFT (Ready for Execution)  
**Author:** AI Pair Architect & Engineer  
**Feature:** Contextual Adhkar, Sunnah Daily Du'as, Smart Event-Driven Triggers, and Full-Screen Haptic Tasbih

---

## 1. Executive Summary & Problem Analysis

### The Problem with Existing Islamic Apps
Traditional Islamic apps offer an "Adhkar" tab, but retain very low long-term engagement. The root causes are:
1. **The "Wall of Text" Paradigm:** Long, unpaced lists of Arabic text cause cognitive fatigue.
2. **Clock-Based Notification Fatigue:** Blasting generic alarms at 7:00 AM or 5:00 PM ignores the user's real-time state, leading to disabled notifications.
3. **No Habit Stacking:** Sunnah remembrances are inherently **event-anchored** (waking up, post-prayer, leaving home, before sleeping), but apps treat them in isolation.
4. **Friction in Counting:** Small on-screen buttons force visual focus on the screen rather than allowing mindful remembrance (*Khushu'*).

### Our Solution: The Context-Aware Adhkar Engine
- **Solar & Event Triggers:** Dynamically activate relevant Adhkar based on prayer times (`PrayerTimeService`), app lifecycle (first morning unlock, night wind-down), and user actions (post-salah checkoff, Qaylulah timer completion).
- **Single-Card Story Experience:** Paced, one-dhikr-at-a-time carousel with typography optimized for legibility, translation, transliteration, and authentic Hadith virtues.
- **Full-Screen Haptic Tasbih:** The entire viewport acts as the tap area, delivering distinct tactile vibration ticks per count and milestone pulses upon reaching completion.
- **3 Spheres Integration:** Adhkar completion feeds directly into the daily **Spiritual Sphere** consistency tracker.

---

## 2. Architecture & Data Model

### A. Data Schema (`lib/domain/models/dhikr.dart`)

```dart
enum DhikrCategory {
  morning,      // Post-Fajr to Sunrise
  evening,      // Post-Asr to Maghrib
  wakingUp,     // Morning app resume / wake
  sleeping,     // Post-Isha / bedtime wind-down
  postPrayer,   // After completing Salah
  dailySunnah,  // Entering home, meals, stress, gratitude
}

class DhikrItem {
  final String id;
  final DhikrCategory category;
  final String titleEn;
  final String titleAr;
  final String arabic;
  final String transliteration;
  final String translationEn;
  final String translationAr;
  final String reference;     // e.g. "Sahih al-Bukhari 6306"
  final String virtue;        // Benefit/Virtue from Hadith
  final int targetCount;      // 1, 3, 33, 100
  final int order;
}

class DhikrSessionProgress {
  final String dhikrId;
  final int currentCount;
  final int targetCount;
  final bool isCompleted;
}
```

### B. Smart Trigger Engine (`AdhkarTriggerService`)
- Evaluates the current time relative to `PrayerTimeService` calculations:
  - `morning`: $t \in [\text{Fajr}, \text{Sunrise} + 120\text{min}]$
  - `evening`: $t \in [\text{Asr}, \text{Maghrib}]$
  - `sleeping`: $t \ge \text{Isha}$ or $t \ge 21:30$ local time
  - `wakingUp`: First app resume between 04:00 and 11:00
- Provides active context to the Home Screen dynamic pill and routes.

---

## 3. UI / UX Design & Interaction Patterns

```
┌─────────────────────────────────────────────────────────┐
│  ← Back             Morning Adhkar             (3 / 7)  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   [ 🌟 Protection from Sudden Affliction ]               │
│                                                         │
│   بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي... │
│                                                         │
│   "Bismillahil-ladhi la yadurru ma'as-mihi..."          │
│                                                         │
│   "In the Name of Allah, with Whose Name nothing        │
│    can cause harm in the earth nor in the heavens..."   │
│                                                         │
│   ┌─────────────────────────────────────────────────┐   │
│   │ 📖 Abu Dawud: Recite 3x in morning & evening    │   │
│   └─────────────────────────────────────────────────┘   │
│                                                         │
│                        ( 2 / 3 )                        │
│                 [ TAP ANYWHERE TO COUNT ]               │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  [  Reset  ]                     [  Next Dhikr →  ]     │
└─────────────────────────────────────────────────────────┘
```

1. **Full Viewport Tap Surface:** Tapping anywhere counts up with `HapticFeedback.lightImpact()`.
2. **Completion Milestone:** When `count == targetCount`, triggers `HapticFeedback.mediumImpact()` with audio chime (optional toggle) and automatically advances to the next card or reveals the completion summary.
3. **Ambient Home Pill:** Displays on the Home screen header: *"Morning Adhkar • 5 min remaining"* with quick one-tap entry.

---

## 4. Phased Implementation Plan

### Phase 1: Domain Models & Static Curated Catalog
- **Files:**
  - `lib/domain/models/dhikr.dart` (Model class & Category enum)
  - `lib/data/catalogs/adhkar_catalog.dart` (Curated authentic items with full Arabic, transliteration, English/Arabic translations, references, and virtues)
  - `test/domain/dhikr_model_test.dart` (Unit tests)

### Phase 2: Adhkar Trigger & Settings Persistence
- **Files:**
  - `lib/data/services/adhkar_service.dart` (Trigger evaluation & completion tracking)
  - `lib/data/services/settings_service.dart` (Add adhkar audio/haptic preferences)
  - `test/data/services/adhkar_service_test.dart`

### Phase 3: Full-Screen Haptic Tasbih & Story Carousel
- **Files:**
  - `lib/features/adhkar/presentation/screens/adhkar_screen.dart` (Full-screen carousel route `/adhkar`)
  - `lib/features/adhkar/presentation/widgets/dhikr_card.dart` (Typography & tap detector)
  - `lib/features/adhkar/presentation/widgets/tasbih_tap_area.dart`
  - `test/features/adhkar/adhkar_screen_test.dart`

### Phase 4: Home Ambient Pill & Event Integrations
- **Files:**
  - `lib/features/home/presentation/widgets/home_adhkar_pill.dart`
  - `lib/features/home/presentation/screens/home_content.dart` (Embed pill in header)
  - `lib/features/tasks/presentation/screens/task_screen.dart` (Post-prayer prompt)
  - `lib/core/router/app_router.dart` (Register `/adhkar` with `category` argument)
  - `lib/l10n/app_en.arb` & `lib/l10n/app_ar.arb` (Full localization)

---

## 5. Verification & Quality Gates

### Automated Verification
- **Unit & Bloc Tests:** `flutter test` must pass 100% with $\ge 90\%$ test coverage on new services.
- **Widget Tests:** Test gesture detection, haptic triggers, counter incrementation, completion state, and Arabic RTL layout.
- **Static Analysis:** `flutter analyze` must produce zero warnings/errors.
- **Formatting:** `dart format .` passing cleanly.

### Manual Verification
- Test full-screen tap responsiveness on both light and dark themes.
- Test in Arabic (`ar`) locale to ensure RTL text formatting, tashkeel fonts, and typography are crisp.
- Verify prayer-relative dynamic category selection at different times of the day.
