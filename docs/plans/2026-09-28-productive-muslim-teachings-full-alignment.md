# Productive Muslim Framework Full Alignment Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Bridge all remaining gaps between the codebase and *The Productive Muslim* book framework by Mohammed Faris, delivering the 3 Spheres architecture, dynamic Salah-anchored scheduling, Khushu' Focus Mode, Daily Energy & Sunnah Routine, and the 9 Essential Qualities Interactive Hub.

**Architecture:** Clean architecture feature-first structure (`lib/features/focus/`, `lib/features/energy/`, `lib/core/constants/`, `lib/features/tasks/`, `lib/features/habits/`, `lib/features/home/`). Backwards-compatible taxonomy mapping, dynamic prayer slot calculation via `adhan_dart`, and BLoC/Service reactive state management.

**Tech Stack:** Flutter 3.47+, Dart 3.13+, `flutter_bloc`, `adhan_dart`, `shared_preferences`, `intl`, `geolocator`, `drift`.

---

## Specification Summary (From Grilling Session Alignment)

### 1. 3 Spheres of Islamic Productivity
- **Spheres**:
  - `spiritual`: Salah, Quran, Dhikr, Fasting, Ilm (Knowledge), Dua.
  - `physical`: Sleep, Qaylulah, Nutrition, Physical Vitality, Movement.
  - `social`: Family, Marriage, Kinship, Work Excellence (Itqan), Ummah.
- **Mapping & Backward Compatibility**:
  - Legacy categories (`islam`, `family`, `work`, `personal_dev`) map into their respective parent spheres while preserving existing database rows.
  - Category selectors in Habit and Task sheets expose the 3 Core Spheres with sub-area tags.

### 2. Salah-Relative Scheduling (Dynamic Barakah Windows)
- **Barakah Slots**:
  - `early_morning`: Post-Fajr Barakah Hour (Fajr -> Sunrise)
  - `duha`: Forenoon Prime Study & Work Block (Sunrise + 20m -> Dhuhr)
  - `dhuhr`: Post-Dhuhr Block (Dhuhr -> Asr)
  - `asr`: Post-Asr Winding Down / Vitality Block (Asr -> Maghrib)
  - `maghrib`: Between Maghrib & Isha (Family / Quran block)
  - `isha`: Post-Isha Routine & Night Reflection (Isha -> +90m)
- **Calculation**: Dynamically computed for the selected date from `PrayerTimes` (via `PrayerTimeService`), falling back to solar defaults.

### 3. Khushu' Focus Mode / Deep Work Timer
- **Route**: `/focus`
- **Features**:
  - Pre-Focus Niyyah & Islamic Dua prompt (*"Rabbi zidni 'ilman"*).
  - Interval presets: 15m (Sprint), 25m (Barakah Pomodoro), 45m (Deep Work), 60m (Mastery).
  - Animated progress ring timer with Pause/Resume/Reset.
  - Task selector to link the focus session to an existing active task.
  - Post-session reflection dialog with *Alhamdulillah* blessing and focus time persistence.

### 4. Daily Energy & Sunnah Routine Management
- **Route**: `/energy`
- **Features**:
  - **Triple-Energy Check-in**: Physical Vitality, Spiritual State, Mental Focus (1-5 ratings).
  - **Sunnah Qaylulah**: 20-min midday nap timer with waking Dua.
  - **Sunnah Fasting Tracker**: Automatic indicators for Mondays, Thursdays, and White Days (13th, 14th, 15th) + intention switch.
  - **Sunnah Sleep Hygiene & Nutrition Guidelines**: Rules from the book (1/3 food rule, sleeping on right side, Wudu before sleep).

### 5. 9 Essential Qualities Interactive Hub
- Full 9 qualities: *Taqwa, Ikhlas, Sabr, Shukr, Tawakkul, Ihsan, Ilm, Dawah, Ummah*.
- Interactive bottom sheet on tap with:
  - Definition
  - Islamic Foundation (Quran/Hadith citation)
  - Practical Action Step from the book.

---

## Phased Implementation Tasks

### Phase 1: Constants & Localization (Completed)
- [x] Task 1.1: Add 3 Spheres mapping to `lib/core/constants/app_life_areas.dart`.
- [x] Task 1.2: Add `BarakahSlot` definitions in `lib/core/constants/app_prayer_slots.dart`.
- [x] Task 1.3: Add English & Arabic translations for all new features in `app_en.arb` and `app_ar.arb`.
- [x] Task 1.4: Run `flutter gen-l10n`.

### Phase 2: Service & Data Layer
- [x] Task 2.1: Add focus minutes, energy check-in, and fasting preferences to `lib/data/services/settings_service.dart`.
- [x] Task 2.2: Add dynamic prayer slot calculation method `getSlotMinutes()` in `lib/data/services/prayer_time_service.dart`.

### Phase 3: Task & Habit Feature Integration
- [x] Task 3.1: Update `lib/features/tasks/presentation/screens/create_task_sheet.dart` with dynamic prayer slot chips and 3 Spheres selection.
- [x] Task 3.2: Update `lib/features/tasks/presentation/screens/task_screen.dart` with 3 Spheres area labeling and quick focus launcher.
- [x] Task 3.3: Update `lib/features/habits/presentation/screens/create_habit_sheet.dart` and `habit_screen.dart` with 3 Spheres categorization.

### Phase 4: Focus Mode & Energy Management Screens
- [x] Task 4.1: Create `lib/features/focus/presentation/screens/focus_screen.dart` with Niyyah prompt, circular timer, presets, and task linking.
- [x] Task 4.2: Create `lib/features/energy/presentation/screens/energy_screen.dart` with triple-energy ratings, Qaylulah timer, fasting tracker, and Sunnah guidelines.
- [ ] Task 4.3: Register `/focus` and `/energy` routes in `lib/core/router/app_router.dart`.

### Phase 5: Home Dashboard & 9 Essential Qualities Interactive Hub
- [ ] Task 5.1: Add Focus Mode and Daily Energy quick access action cards in `lib/features/home/presentation/screens/home_content.dart`.
- [ ] Task 5.2: Implement the full 9 Essential Qualities Interactive Hub in `lib/features/home/presentation/screens/home_content.dart` with modal sheets explaining each quality's Islamic foundation and practical action.

### Phase 6: Automated Verification & Testing
- [ ] Task 6.1: Write unit & widget tests covering Focus Mode, Energy screen, Prayer slot calculations, and 3 Spheres.
- [ ] Task 6.2: Run `flutter test`, `flutter analyze`, and `dart format .`.
- [ ] Task 6.3: Run `graphify update .` to keep knowledge graph in sync.
