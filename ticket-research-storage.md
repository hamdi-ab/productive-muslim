# Ticket: Research Flutter local storage options

## Question

For V1 (offline-first, no backend), which Flutter local storage solution best fits our data model?

Data to store:
- User intentions (text entries, dates)
- Daily tasks (from Taskinator)
- Habit tracking entries (daily checks, scores)
- Barakah journal entries
- User preferences (prayer method, notification settings)

Evaluate: Hive, SQLite (sqflite), Moor/Drift, SharedPreferences. Consider:
- Performance for list queries (habits over time)
- Ease of schema evolution
- Offline-first reliability
- Package maintenance status

## Dependencies

None

## Assets

- [ ] Comparison matrix
- [ ] Recommended solution with migration path
