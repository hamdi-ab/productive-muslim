# Research: Flutter Local Storage Options for The Productive Muslim App

## Executive Summary

For V1 (offline-first, no backend), **Drift (SQLite)** is the recommended solution. It handles all data types in this app's model, supports complex queries needed for habit tracking over time, has excellent schema evolution tooling, and is actively maintained with a large community. Hive is a viable lightweight alternative but its query limitations and uncertain maintenance trajectory make it less suitable for relational data like habit entries and task history.

---

## Data Model Requirements

The app must persist five distinct data domains offline:

| Data Domain | Structure | Access Patterns |
|-------------|-----------|-----------------|
| User intentions | Text entries with dates | List by date, chronological scroll |
| Daily tasks (Taskinator) | Tasks linked to time blocks, dates, categories (Islam/Family/Work/Personal) | Query by date, filter by category, update completion |
| Habit tracking entries | Daily checks, scores over time | **Heavy list queries**: habits over weeks/months, aggregations, streaks |
| Barakah journal entries | Text entries with dates, possibly linked to barakah sources | List by date, search, chronological |
| User preferences | Primitive settings (prayer method, notifications, etc.) | Key-value reads on app start |

The critical requirement is **habits over time**: the app needs to query, filter, aggregate, and trend habit data across days, weeks, and months. This rules out simple key-value stores.

---

## Option 1: Hive

### Overview
Hive is a lightweight, pure-Dart key-value database inspired by Bitcask. It stores Dart objects using generated TypeAdapters.

### Current Status
- **Latest stable**: 2.2.3 (published ~4 years ago, Jan 2021)
- **Prerelease**: 4.0.0-dev.2 available but not stable
- **Publisher**: isar.dev (same team behind Isar)
- **Downloads**: 1.06M weekly
- **License**: Apache-2.0 (per GitHub)

### Performance for List Queries
**Weakness.** Hive is a key-value store, not a query engine. Its native operations are `get`/`put`/`delete` by key. To query habits over time, you must:
- Maintain secondary indexes manually (e.g., store habits by date as composite keys)
- Load all objects into memory and filter in Dart
- Use `HiveList` for lazy linking, but this still requires loading source objects

The Hive documentation itself recommends **Isar** when queries, multi-isolate support, or links between objects are needed. For habit tracking — where the core feature is "show me all checks for habit X over the last 90 days" — Hive's lack of query primitives is a fundamental mismatch.

### Schema Evolution
Hive supports schema evolution through TypeAdapter versioning. You register a `typeId` and handle version differences in `read/write` methods. This works but is manual and error-prone for complex models with nested objects.

### Offline-First Reliability
Excellent. Pure Dart implementation means no native dependencies. Data is stored as files in the app's documents directory. AES-256 encryption is built in. No network calls, no external processes. Very reliable for offline use.

### Package Maintenance Status
**Concerning.** The last stable release was over 4 years ago. The development team has shifted focus to Isar (their newer product). While Hive still works and has a large user base, there is no active development on the stable branch. The 4.0.0-dev prerelease suggests a major rewrite is planned but not yet released.

### Learning Curve
Low. Simple API, minimal boilerplate. However, the simplicity becomes a liability when the data model grows beyond key-value patterns.

### Fit for This App
**Poor for core data, acceptable only for user preferences.** Hive cannot efficiently serve the habit tracking queries that are central to the app. Using it for intentions, tasks, habits, and journal entries would require significant manual indexing and in-memory filtering, which defeats the purpose of a local database.

---

## Option 2: SQLite (sqflite)

### Overview
SQLite is a self-contained, high-reliability, embedded SQL database engine. `sqflite` is the official Flutter plugin maintained by Alexandre Roux (tekartik).

### Current Status
- **Latest stable**: 2.4.3 (published 3 months ago, actively maintained)
- **Publisher**: tekartik.com (verified)
- **Downloads**: 2.82M weekly
- **License**: BSD-2-Clause
- **Platforms**: Android, iOS, macOS (with ffi for desktop/web)

### Performance for List Queries
**Excellent.** SQLite is purpose-built for exactly this workload. Complex queries across large datasets execute efficiently with proper indexing. For habit tracking over time, SQLite handles:
- Date-range filtering with indexes
- Aggregations (COUNT, AVG, SUM) for streaks and scores
- Joins across habits, entries, and dates
- Sorting and pagination

The Hive benchmark showing SQLite as slower is misleading for this use case — those benchmarks test simple key-value operations, not the complex relational queries this app requires. For relational workloads, SQLite is faster because it avoids loading entire datasets into memory.

### Schema Evolution
**Good, but manual.** `sqflite` supports version-based migrations via `onCreate`/`onUpgrade` callbacks. You write SQL `ALTER TABLE` statements or recreate tables. There is no built-in migration DSL — you manage version numbers and write migration SQL yourself. This is reliable but requires discipline. Third-party packages like `sqflite_migration` or `db_bloc` add migration helpers.

### Offline-First Reliability
**Excellent.** SQLite is the most battle-tested embedded database in existence. ACID-compliant, crash-resistant, and requires no network. The `sqflite` plugin wraps native SQLite on each platform. Very mature and reliable.

### Package Maintenance Status
**Strong.** tekartik maintains sqflite actively. Recent release (3 months ago), large download volume, Flutter Favorite status, and used in thousands of production apps. The federated plugin architecture (sqflite_android, sqflite_darwin, sqflite_common) means platform-specific fixes land independently.

### Learning Curve
**Moderate.** Requires SQL knowledge and understanding of the plugin's async API. You write raw SQL or build query maps, manage database connections, and handle migrations manually. More boilerplate than Hive or Drift for simple operations, but the SQL paradigm is well-documented and widely known.

### Fit for This App
**Strong.** SQLite can model all five data domains efficiently. Habit tracking queries — date ranges, aggregations, streaks — are exactly what SQL is designed for. The main drawback is the manual migration management and boilerplate compared to Drift.

---

## Option 3: Drift (formerly Moor)

### Overview
Drift is a reactive persistence library built on top of SQLite. It provides type-safe Dart APIs generated from table definitions, with support for SQL and Dart query builders.

### Current Status
- **Latest stable**: 2.34.4 (published **6 days ago**, very actively maintained)
- **Publisher**: simonbinder.eu (verified)
- **Downloads**: 1.18M weekly
- **License**: MIT
- **Flutter Favorite**: Yes
- **Sponsors**: Stream, PowerSync

### Performance for List Queries
**Excellent.** Drift compiles to SQLite, so query performance is identical to raw SQLite. The generated DAOs and reactive streams add negligible overhead. Drift uniquely supports:
- **Built-in threading**: Run queries on isolates with zero additional effort
- **Reactive queries**: Any query becomes an auto-updating `Stream`
- **Complex filters, joins, and window functions** via fluent Dart APIs

For habit tracking, this means you can write `isar.habitEntries.filter().dateBetween(start, end).sortByDate().watch()` and get a stream that automatically updates when entries change — perfect for a Flutter widget showing a habit streak.

### Schema Evolution
**Excellent.** Drift has the best schema migration story of any option. You define schema changes in a `Migration` object, and Drift handles:
- Version tracking automatically
- Generating migration steps
- Validating schema consistency
- Supporting complex migrations (data transformations, backfills)

The code generation catches schema mismatches at compile time rather than at runtime.

### Offline-First Reliability
**Excellent.** Built on SQLite with the same ACID guarantees. The reactive streams are local-only by default. Drift also supports ` moor_ffi` for native performance and has web support via `sql.js`.

### Package Maintenance Status
**Outstanding.** Published 6 days ago, very active development, large and growing community, Flutter Favorite, professional sponsorship. This is the most actively maintained option in this evaluation.

### Learning Curve
**Moderate.** Requires understanding:
- Code generation (`build_runner`)
- Table definition syntax (similar to SQL but in Dart)
- Migration objects
- DAO pattern (optional but recommended)

The generated code means you rarely write raw SQL, but you need to understand the Drift paradigm. The documentation is excellent and includes an IDE for SQL. The learning curve is higher than Hive but lower than raw sqflite for complex queries because Drift generates type-safe bindings.

### Fit for This App
**Excellent.** Drift handles all five data domains naturally. The reactive streams are ideal for Flutter's widget model — a habit streak widget can listen to filtered habit queries and rebuild automatically. The type-safe queries eliminate runtime errors from malformed SQL. Schema migrations are structured and safe. This is the most complete solution.

---

## Option 4: SharedPreferences

### Overview
SharedPreferences is a Flutter plugin wrapping platform-specific key-value stores (NSUserDefaults on iOS, SharedPreferences on Android). It is not a database — it stores simple typed values.

### Current Status
- **Latest stable**: 2.5.5 (published 5 months ago)
- **Publisher**: flutter.dev (official Flutter team)
- **Downloads**: 6.21M weekly (highest of all options)
- **License**: BSD-3-Clause

### Performance for List Queries
**N/A — Not suitable.** SharedPreferences stores primitive values (`int`, `double`, `bool`, `String`, `List<String>`) only. It cannot store objects, dates, or structured data natively. To store a list of habit entries, you would serialize the entire list to a JSON string and write it as one value — meaning every read loads the entire history into memory and every write rewrites the entire list. This does not scale.

### Schema Evolution
**N/A.** There is no schema — just keys. You manage all structure in code.

### Offline-First Reliability
**Adequate for settings, poor for data.** SharedPreferences is reliable for small configuration values. The plugin documentation explicitly warns: "this plugin must not be used for storing critical data" because writes are asynchronous with no guarantee of persistence after returning.

### Package Maintenance Status
**Excellent.** Maintained by the Flutter team, always up-to-date with Flutter SDK changes.

### Learning Curve
**Trivial.** Two lines of code to read or write a value.

### Fit for This App
**Suitable only for user preferences.** SharedPreferences is the right choice for prayer method, notification settings, theme preferences, and other simple flags. It is completely wrong for intentions, tasks, habits, and journal entries.

---

## Comparison Matrix

| Criterion | Hive | SQLite (sqflite) | Drift | SharedPreferences |
|-----------|------|------------------|-------|-------------------|
| Performance (list queries) | Poor | Excellent | Excellent | N/A |
| Schema evolution | Manual TypeAdapter versions | Manual SQL migrations | **Auto-generated, validated** | N/A |
| Offline reliability | Excellent | Excellent | Excellent | Adequate (not for data) |
| Maintenance status | Stagnant (4yr gap) | Active | **Very active** | Excellent |
| Learning curve | Low | Moderate | Moderate | Trivial |
| Relational queries | None (key-value only) | Full SQL | **Type-safe Dart/SQL** | None |
| Reactive streams | No | No | **Yes, built-in** | No |
| Multi-isolate support | No | No | **Yes, built-in** | No |
| Code generation | TypeAdapters only | No | **Full DAO/query gen** | No |

---

## Recommendation

### Primary choice: Drift

Drift is the correct foundation for this app's data layer because:

1. **Habit tracking is the core feature** — Drift's reactive queries and efficient date-range filtering are purpose-built for "habits over time" queries
2. **Type safety eliminates runtime errors** — generated code catches malformed queries at compile time
3. **Schema evolution is structured** — migration objects, version tracking, and compile-time validation reduce migration bugs
4. **Active maintenance** — published 6 days ago, Flutter Favorite, professional sponsorship
5. **Flutter-native** — reactive streams integrate directly with `StreamBuilder`, eliminating boilerplate state management
6. **Cross-platform** — works on mobile, desktop, and web from one codebase

### Supporting choice: SharedPreferences

Use SharedPreferences (specifically `SharedPreferencesAsync`) for user preferences only. This is the correct separation of concerns — settings do not need relational queries or schema migrations.

### Why not Hive?

Hive is excellent for apps whose data model is primarily key-value (caches, simple settings, offline snapshots). The Productive Muslim app's data model is fundamentally relational — habits have entries over time, tasks belong to dates and categories, journal entries are chronological lists. Forcing this into Hive would require:
- Manual secondary indexes for every query pattern
- In-memory filtering of large lists
- Custom serialization for nested objects
- Accepting an unmaintained package for the app's core data

Hive's performance advantage is in key-value operations, which is not where this app spends most of its database time.

### Why not raw SQLite?

Raw SQLite via `sqflite` is fully capable and would work. Drift is preferred because it adds type safety, reactive streams, and structured migrations without sacrificing SQLite's performance. For a solo or small-team project, Drift's generated code reduces bugs and boilerplate more than it adds complexity.

---

## Migration Path

If starting with Drift:

1. Add dependencies: `drift`, `drift_flutter`, `isar_flutter_libs` (for native sqlite3), `build_runner`, `drift_dev`
2. Define tables in Dart with `@Table` annotations:
   - `Intentions` (id, text, date, createdAt)
   - `Tasks` (id, title, date, category, completed, createdAt)
   - `Habits` (id, name, category, createdAt)
   - `HabitEntries` (id, habitId, date, completed, score, createdAt)
   - `JournalEntries` (id, text, date, barakahSource, createdAt)
   - `UserPreferences` (key, value)
3. Generate database code with `build_runner build`
4. Open database in `main.dart` using `FlutterQueryExecutor`
5. Create DAOs for each domain with reactive query methods
6. Use `StreamBuilder` in widgets to listen to query results

---

## Sources

- Hive: https://pub.dev/packages/hive (v2.2.3, 4yr old stable)
- Isar: https://pub.dev/packages/isar (v3.1.0+1, referenced by Hive docs as query successor)
- SQLite/sqflite: https://pub.dev/packages/sqflite (v2.4.3, tekartik)
- Drift: https://pub.dev/packages/drift (v2.34.4, simonbinder.eu)
- SharedPreferences: https://pub.dev/packages/shared_preferences (v2.5.5, flutter.dev)
- Hive benchmark: https://github.com/hivedb/hive_benchmark
- Drift docs: https://drift.simonbinder.eu/docs/getting-started/
