# Wayfinder Map: Productive Muslim App

## Destination

A shipped Flutter mobile app (Android first, iOS later) for university students and young professionals that helps them become Productive Muslims through the 9 essential qualities framework — a coach-like guided experience combining Islamic intention-setting with modern productivity science.

## Notes

- Domain: Islamic productivity + mobile app development
- Skills to consult: flutter-* skills, research, prototyping
- Standing preferences: V1 is lean — prayer notifications + Taskinator + Habitator + Barakah tracker + Intentions journal. No full Quran/Qibla/mosque finder (those are table-stakes features already solved by Muslim Pro).
- Target segment: University students and young professionals (18-35)
- Monetization: Free V1

## Decisions so far

- [V1 scope and platform target](ticket-task-init-flutter.md) — Android-first Flutter app with prayer notifications, Taskinator, Habitator, Barakah tracker, and Intentions journal; no Quran/Qibla/mosque finder in V1
- [Prayer time and adhan package stack](tickets/research-prayer-packages-resolution.md) — adhan_dart + flutter_local_notifications + timezone
- [Local storage solution](tickets/research-storage-resolution.md) — Drift (SQLite) for core data + SharedPreferences for user preferences
- [Barakah tracker interaction pattern](tickets/research-barakah-tracker-resolution.md) — Pattern D: Hybrid Contextual Prompt Cards with 18 sources, daily prompts, and a read-only weekly review (descriptive counts only, no scoring or productivity correlations)
- [Navigation structure and onboarding](tickets/prototype-navigation-resolution.md) — 5-tab bottom nav (Home, Tasks, Habits, Barakah, Journal), 4-screen onboarding (<90s), Home as daily command center with prayer card + quick stats + Today's Focus feed
- [Core feature flows](tickets/prototype-features-resolution.md) — Taskinator (time-blocking with 4 life areas), Habitator (category-grouped checklists with streaks), Barakah (daily prompt cards with reflection logging), Intentions (single-active-intention journal with Active/Reflected/Archived status)
- [State management](ticket-task-init-flutter.md) — Bloc chosen over Riverpod for experimentation; clean architecture with domain/data/presentation layers
- [Dependency injection](ticket-task-init-flutter.md) — get_it service locator for repositories and Blocs
- [Development device preview](ticket-task-init-flutter.md) — device_preview 3.0.0 for multi-device simulation in debug/profile only; off in release

## Not yet specified

- Design system / visual identity (colors, typography, icons)
- Testing strategy (unit, integration, user testing)
- Launch readiness checklist (Play Store, permissions, privacy policy)
- Accessibility audit plan
- Performance benchmarks and optimization targets

## Out of scope

- Full Quran with translations and audio
- Qibla compass
- Mosque finder / Halal food finder
- Zakat calculator
- Hajj & Umrah guides
- Social features / community (post-V1)
- Freemium / paid tiers (post-V1)
- iOS launch (post-V1)
- Web dashboard
- Backend sync / cloud backup (post-V1)

## Tickets

### Open tickets

- [Initialize Flutter project with clean architecture](ticket-task-init-flutter.md) — Set up project foundation

### Blocking relationships

- `ticket-task-init-flutter.md` — ready to claim (all research and prototype dependencies closed)
