# Architecture: Productive Muslim App

A daily companion that helps Muslims strengthen their remembrance of Allah, organize their responsibilities around Salah, and develop a more intentional and balanced life — built on the Five Pillars framework (*Remember, Pray, Intend & Act, Reflect, Grow*).

## Stack

- **Framework:** Flutter 3.47+ / Dart 3.13+
- **State Management:** BLoC (`flutter_bloc` ^9.1.1)
- **Dependency Injection:** `get_it` ^9.2.1
- **Routing:** `go_router` ^18.0.1
- **Local Storage:** `drift` ^2.34.4 (SQLite) + `shared_preferences`
- **Serialization:** `freezed` ^4.0.1 + `json_serializable` ^6.14.0
- **Prayer Times:** `adhan_dart` ^2.0.1 + `flutter_local_notifications` ^22.3.0 + `timezone`
- **Location:** `geolocator` ^14.0.3 + `permission_handler` ^13.0.2
- **Localization:** `flutter_localizations` + `intl` ^0.20.3 (English + Arabic)
- **Theming:** Material 3 dynamic color + custom theme extensions (`AppColorsExtension`)

## Architecture Pattern

Feature-first with clean architecture layers (domain / data / presentation) within each feature:

- **Presentation:** Screens, widgets, and BLoC state consumers.
- **Logic / BLoC:** Event-driven state machines with past-tense events (`TaskCreated`, `PrayerTimesLoaded`) and Freezed sealed states.
- **Data:** Repository implementations, Drift database access, DAOs, and service wrappers.
- **Domain:** Pure entity models and repository interfaces.

## Folder Structure

```
lib/
├── core/
│   ├── constants/
│   ├── di/
│   ├── localization/
│   ├── router/
│   ├── theme/
│   └── utils/
├── data/
│   ├── local/database/
│   └── services/
└── features/
    ├── adhkar/
    ├── barakah/
    ├── energy/
    ├── fasting/
    ├── home/
    ├── onboarding/
    ├── prayer_times/
    ├── profile/
    ├── reflect/
    ├── settings/
    └── tasks/
```

## Conventions

- **Events:** Past-tense verbs (`TaskLoaded`, `HabitToggled`)
- **States:** Freezed sealed classes (`@freezed`)
- **Tests:** `bloc_test` for Blocs, `mocktail` for mocks, `flutter_test` for widgets
- **RTL & Text-Scale Resilience:** Every dynamic or localized `Text` in a `Row` must be wrapped in `Expanded` or `Flexible` with `overflow: TextOverflow.ellipsis` to prevent RenderFlex overflows under large font scaling and RTL Arabic.
- **Verification:** `flutter analyze` and `flutter test` must pass clean.
