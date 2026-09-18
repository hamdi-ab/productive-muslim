# Architecture Setup Plan: Productive Muslim App

## Stack

- **Framework:** Flutter (Android-first, iOS later)
- **Language:** Dart 3.x
- **State Management:** ChangeNotifier + ListenableBuilder (MVVM)
- **Dependency Injection:** get_it + injectable
- **Routing:** GoRouter
- **Local Storage:** Drift (SQLite) + SharedPreferences
- **Prayer Times:** adhan_dart + flutter_local_notifications + timezone
- **Localization:** flutter_localizations + intl
- **Theming:** Material 3 dynamic color + custom theme extensions

## Architecture Pattern

Following Flutter best practices: **MVVM with Repository pattern**

- **Views:** Reusable, lean widgets. UI-specific operations only. Pass all data from ViewModel.
- **ViewModels:** Manage UI state, extend ChangeNotifier. Expose immutable state. Inject Repositories via constructor.
- **Repositories:** Single source of truth. Consume Services. Transform raw models into clean Domain Models. Handle caching, offline, retry.
- **Services:** Stateless wrappers around external APIs, local databases, platform plugins.
- **Use Cases:** Optional layer for complex business logic reused across multiple ViewModels.

## Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   ├── theme.dart
│   └── l10n/
│       ├── app_localizations.dart
│       ├── app_localizations_en.dart
│       └── app_localizations_ar.dart
├── core/
│   ├── constants/
│   │   ├── app_strings.dart
│   │   └── app_assets.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_theme.dart
│   │   └── app_theme.dart
│   └── utils/
│       ├── date_helpers.dart
│       ├── prayer_helpers.dart
│       └── barakah_helpers.dart
├── data/
│   ├── models/
│   │   ├── task_model.dart
│   │   ├── habit_model.dart
│   │   ├── barakah_model.dart
│   │   ├── intention_model.dart
│   │   └── prayer_settings_model.dart
│   ├── repositories/
│   │   ├── task_repository_impl.dart
│   │   ├── habit_repository_impl.dart
│   │   ├── barakah_repository_impl.dart
│   │   ├── intention_repository_impl.dart
│   │   └── prayer_repository_impl.dart
│   └── services/
│       ├── local/
│       │   ├── app_database.dart
│       │   ├── daos/
│       │   └── preferences_service.dart
│       └── remote/          # reserved for post-V1
├── domain/
│   ├── models/
│   │   ├── task.dart
│   │   ├── habit.dart
│   │   ├── barakah_entry.dart
│   │   ├── barakah_daily_response.dart
│   │   ├── barakah_weekly_review.dart
│   │   ├── intention.dart
│   │   └── prayer_settings.dart
│   └── use_cases/           # optional, only for complex shared logic
│       ├── tasks/
│       ├── habits/
│       ├── barakah/
│       └── intentions/
├── ui/
│   ├── core/
│   │   ├── widgets/
│   │   └── theme/
│   └── features/
│       ├── home/
│       │   ├── view_models/
│       │   │   └── home_view_model.dart
│       │   └── views/
│       │       └── home_view.dart
│       ├── tasks/
│       │   ├── view_models/
│       │   │   └── tasks_view_model.dart
│       │   └── views/
│       │       ├── tasks_view.dart
│       │       ├── task_form_view.dart
│       │       └── task_detail_view.dart
│       ├── habits/
│       │   ├── view_models/
│       │   │   └── habits_view_model.dart
│       │   └── views/
│       │       ├── habits_view.dart
│       │       ├── habit_form_view.dart
│       │       └── habit_detail_view.dart
│       ├── barakah/
│       │   ├── view_models/
│       │   │   └── barakah_view_model.dart
│       │   └── views/
│       │       ├── barakah_view.dart
│       │       └── barakah_entry_form_view.dart
│       ├── journal/
│       │   ├── view_models/
│       │   │   └── journal_view_model.dart
│       │   └── views/
│       │       ├── journal_view.dart
│       │       └── intention_form_view.dart
│       ├── onboarding/
│       │   ├── view_models/
│       │   │   ├── welcome_view_model.dart
│       │   │   ├── name_view_model.dart
│       │   │   ├── intention_view_model.dart
│       │   │   └── prayer_setup_view_model.dart
│       │   └── views/
│       │       ├── welcome_view.dart
│       │       ├── name_view.dart
│       │       ├── intention_view.dart
│       │       └── prayer_setup_view.dart
│       └── settings/
│           ├── view_models/
│           │   └── settings_view_model.dart
│           └── views/
│               └── settings_view.dart
├── injection/
│   └── injection_container.dart
├── generated/
│   └── (auto-generated Drift files)
└── l10n/
    ├── app_en.arb
    └── app_ar.arb
```

## Key Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

  # State management
  flutter_bloc: ^8.1.6        # optional, for future use; V1 uses ChangeNotifier
  bloc: ^8.1.4

  # Dependency injection
  get_it: ^7.7.0
  injectable: ^2.4.2

  # Routing
  go_router: ^14.2.7

  # Database
  drift: ^2.18.0
  drift_flutter: ^0.1.0
  sqlite3_flutter_libs: ^0.5.0

  # Preferences
  shared_preferences: ^2.3.2
  shared_preferences_async: ^2.3.0

  # Prayer times
  adhan_dart: ^2.0.1
  flutter_local_notifications: ^22.3.0
  timezone: ^0.9.4

  # Utils
  uuid: ^4.5.1
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.13
  drift_dev: ^2.18.0
  injectable_generator: ^2.4.1
  bloc_test: ^9.1.7
  mocktail: ^1.0.3
```

## Implementation Workflow (per feature)

1. **Define Domain Models** — immutable data classes in `domain/models/`
2. **Implement Services** — stateless wrappers in `data/services/`
3. **Implement Repositories** — single source of truth in `data/repositories/`
4. **Conditional: Use Cases** — only if complex shared logic
5. **Implement ViewModel** — ChangeNotifier in `ui/features/[feature]/view_models/`
6. **Implement View** — lean widget using ListenableBuilder in `ui/features/[feature]/views/`
7. **Inject Dependencies** — register in `injection_container.dart`
8. **Run Validator** — unit tests for ViewModel and Repository

## Next Steps After Setup

1. Create Flutter project: `flutter create productive_muslim --org com.productivemuslim --project-name productive_muslim`
2. Replace generated files with this architecture
3. Run `flutter pub get`
4. Run `flutter pub run build_runner build` to generate Drift files
5. Verify app launches on Android emulator
