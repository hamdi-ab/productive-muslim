# Local Backup & Restore and Barakah Consistency Heatmap Specification

## 1. Objectives
1. **Local Data Sovereignty**: Empower users to export their entire spiritual and productivity history into a structured JSON file/clipboard string and restore it safely on any device without internet access or third-party servers.
2. **Barakah Consistency Heatmap**: Provide a multi-week (12-week / 84-day) visual activity heatmap in the Barakah Analytics screen, showing daily consistency across Salah, Adhkar, Fasting, Focus sessions, Habits, and Daily Reflections.

## 2. Architecture & Data Model

### A. Backup Service (`BackupService`)
- Extracts database rows from:
  - `Tasks`
  - `Habits` & `HabitCompletions`
  - `IntentionEntries`
  - `BarakahEntries` & `BarakahDailyResponses`
  - `BarakahPrompts`
  - User preferences from `SettingsService`
- Generates versioned JSON with schema verification:
```json
{
  "version": 1,
  "exportedAt": "2026-09-30T20:30:00Z",
  "appVersion": "1.0.0",
  "data": {
    "tasks": [...],
    "habits": [...],
    "habitCompletions": [...],
    "intentions": [...],
    "barakahEntries": [...],
    "barakahDailyResponses": [...],
    "settings": {...}
  }
}
```
- Restoration runs in a transactional batch to guarantee zero partial-state corruption.

### B. Barakah Consistency Heatmap (`BarakahHeatmapCard`)
- 12 weeks of columns (84 days) ending at the current week's Sunday.
- 5 intensity levels (0 = None, 1 = Low, 2 = Medium, 3 = High, 4 = Peak Barakah).
- Day tap shows detailed activity count for that date.
- Full RTL and Arabic localization support.
