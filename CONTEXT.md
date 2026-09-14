# Context

Productive Muslim — a Flutter mobile app for university students and young professionals that helps them become Productive Muslims through the 9 essential qualities framework.

## Core concepts

- **Barakah**: divine blessing and spiritual nourishment
- **Habits**: daily routines that build the 9 essential qualities
- **Tasks**: specific actions within a habit
- **Intentions**: journaling daily intentions and reflections
- **Onboarding**: guided setup of user profile, preferences, and goals

## Architecture notes

Feature-first with clean architecture layers (domain / data / presentation) within each feature. Drift for local SQLite, BLoC for state, GoRouter for navigation, GetIt for DI, Freezed for code generation.
