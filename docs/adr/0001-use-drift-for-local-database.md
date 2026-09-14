# ADR-0001: Use Drift for local database

## Status

Accepted

## Context

We need a local SQLite database for storing habits, tasks, barakah scores, and intentions. Drift provides type-safe queries, code generation, and reactive streams.

## Decision

Use Drift with a single `AppDatabase` class containing all tables. DAOs return Drift-generated types; repository implementations convert to domain models.

## Consequences

- Type-safe queries catch errors at compile time
- Code generation keeps boilerplate manageable
- Reactive streams enable BLoC to react to data changes
- Domain models remain plain Dart classes (no Drift dependency)
