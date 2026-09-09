# Productive Muslim

A Flutter mobile app for university students and young professionals that helps them become Productive Muslims through the 9 essential qualities framework — a coach-like guided experience combining Islamic intention-setting with modern productivity science.

## Technical Stack

- **Framework**: Flutter 3.47+ with Dart 3.13+
- **State management**: `flutter_bloc` ^9.0.0
- **Routing**: `go_router` ^14.0.0
- **Dependency injection**: `get_it` ^7.6.0
- **Local storage**: `drift` ^2.34.0 (SQLite) + `shared_preferences` for settings
- **Serialization**: `freezed` ^2.5.0 + `json_serializable` ^6.8.0
- **Localization**: `flutter_localizations` + `intl` ^0.19.0 (English + Arabic)
- **Notifications**: `flutter_local_notifications` ^18.0.0
- **Prayer times**: `adhan_dart` ^2.0.0 + `timezone` ^0.11.0
- **Location**: `geolocator` ^11.0.0 + `permission_handler` ^12.0.0
- **Dev tooling**: `device_preview` ^3.0.0 (debug/profile only, off in release)

## Architecture

Feature-first with clean architecture layers (domain / data / presentation) within each feature. See `docs/agents/domain.md` for the full layout and consumer rules.

Each feature lives under `lib/features/<feature>/` with:
- `logic/` — Blocs, events, states (freezed)
- `presentation/` — screens and widgets
- `data/` — repository implementations

Core shared code lives under `lib/core/`:
- `di/` — get_it container setup
- `router/` — GoRouter configuration
- `theme/` — light/dark theme system
- `localization/` — localization delegates

## Conventions

- **Events**: past-tense verbs (`TaskLoaded`, `TaskCreated`)
- **States**: freezed sealed classes with `@freezed`
- **Tests**: `bloc_test` for Blocs, `mocktail` for mocking, `flutter_test` for widgets
- **Formatting**: `dart format .` before committing
- **Analysis**: `flutter analyze` must pass clean
- **Commits**: conventional commits — `feat:`, `fix:`, `refactor:`, `test:`, `chore:`

## Agent skills

### Issue tracker

Issues and PRDs for this repo live as GitHub issues. Use the `gh` CLI for all operations. See `docs/agents/issue-tracker.md`.

### Triage labels

_(triage skill not installed)_

### Domain docs

Single-context repo — one `CONTEXT.md` + `docs/adr/` at the root. See `docs/agents/domain.md`.

## Testing

```bash
# Unit + widget tests
flutter test

# Code generation (run after schema changes)
dart run build_runner build --delete-conflicting-outputs

# Static analysis
flutter analyze

# Format check
dart format --output=none --set-exit-if-changed .
```

## Running

```bash
# Debug build (device preview active)
flutter run

# Release build (device preview off)
flutter run --release