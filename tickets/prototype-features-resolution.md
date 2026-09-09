# The Productive Muslim - Core Feature Flows Design

## Overview
Target: University students & young professionals (18–35)
V1 stack: Flutter + adhan_dart + flutter_local_notifications + Drift (SQLite) + SharedPreferences

---

## 1. Taskinator — Daily Time-Blocking

### Screen: Create Task
```
+----------------------------------+
|  < Back              New Task    |
+----------------------------------+
|  Task Title                      |
|  [________________________]      |
|                                  |
|  Life Area                       |
|  [Islam ▼] [Family] [Work]       |
|       [Personal Dev]             |
|                                  |
|  Time Block                      |
|  Start: [09:00]  End: [10:00]    |
|                                  |
|  Repeat                          |
|  [ ] Daily  [ ] Weekly           |
|                                  |
|  Notes                           |
|  [________________________]      |
|                                  |
|  [        Save Task        ]     |
+----------------------------------+
```

### Screen: Task List
```
+----------------------------------+
|  Taskinator              + Add   |
+----------------------------------+
|  [==== 09:00 – 10:00 ====]      |
|  [Islam] Fajr reflection        |
|  [==== 10:00 – 11:00 ====]      |
|  [Work]  Complete assignment     |
|  [==== 11:00 – 12:00 ====]      |
|  [Personal Dev] Read 20 mins     |
|                                  |
|  [==== Overdue ====]             |
|  [Family]  Call mom              |
+----------------------------------+
```

### Key Interactions
- Swipe task to mark complete (triggers subtle haptic + notification)
- Tap task to edit time block or notes
- Long-press for delete/duplicate
- Auto-advance: completed task fades, next block highlights
- Prayer time integration: adhan_dart blocks 10-min buffer around salah

### Data Model (Drift)
```sql
CREATE TABLE tasks (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  title         TEXT NOT NULL,
  life_area     TEXT NOT NULL,  -- 'islam'|'family'|'work'|'personal_dev'
  start_time    INTEGER,        -- minutes from midnight (0–1439)
  end_time      INTEGER,
  date          TEXT NOT NULL,  -- ISO date 'YYYY-MM-DD'
  repeat_daily  INTEGER DEFAULT 0,
  repeat_weekly INTEGER DEFAULT 0,
  repeat_days   TEXT,           -- JSON array of weekday ints
  notes         TEXT,
  completed     INTEGER DEFAULT 0,
  completed_at  INTEGER,        -- epoch ms
  created_at    INTEGER NOT NULL DEFAULT (strftime('%s','now')*1000),
  synced        INTEGER DEFAULT 0
);
CREATE INDEX idx_tasks_date ON tasks(date, start_time);
```

---

## 2. Habitator — Habit Tracking

### Screen: Habit Checklist
```
+----------------------------------+
|  Habitator               + Add   |
+----------------------------------+
|  Today  —  Wed, Sep 3            |
|                                  |
|  [Islam]                         |
|  [✓] Fajr on time                |
|  [✓] Dhikr after salah           |
|  [ ] Quran reading (30 min)      |
|                                  |
|  [Family]                        |
|  [✓] Call parents                |
|  [ ] Help with chores            |
|                                  |
|  [Work]                          |
|  [✓] Deep work block             |
|  [ ] No social media at work     |
|                                  |
|  [Personal Dev]                  |
|  [ ] Exercise 30 min             |
|  [✓] Read 10 pages               |
+----------------------------------+
```

### Screen: Score Card & Streaks
```
+----------------------------------+
|  Score Card              < Back  |
+----------------------------------+
|  This Week                       |
|                                  |
|  [Islam]      ████████░░  80%    |
|  [Family]     ██████░░░░  60%    |
|  [Work]       █████████░  90%    |
|  [Personal]   ██████░░░░  60%    |
|                                  |
|  Overall:  ████████░░  72.5%    |
|                                  |
|  Streaks                         |
|  🔥 Fajr on time      14 days    |
|  🔥 Quran reading     7 days     |
|  ⬜ Exercise          0 days     |
+----------------------------------+
```

### Screen: Add Habit
```
+----------------------------------+
|  < Back            New Habit     |
+----------------------------------+
|  Habit Name                      |
|  [________________________]      |
|                                  |
|  Category                        |
|  [Islam ▼]                       |
|                                  |
|  Target Frequency                |
|  [Daily ▼]   [Weekly] [Custom]   |
|                                  |
|  Reminder                        |
|  [ ] Enable daily reminder       |
|  Time: [08:00]                   |
|                                  |
|  [        Save Habit        ]     |
+----------------------------------+
```

### Key Interactions
- Tap checkbox to toggle completion (today only)
- Tap category header to filter
- Pull-to-refresh syncs with server (future)
- Score card shows 7-day rolling average per category
- Streak counter: consecutive days with ALL habits in category done = category streak
- Habit creation: name + category + frequency + optional reminder time

### Data Model (Drift)
```sql
CREATE TABLE habits (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT NOT NULL,
  category    TEXT NOT NULL,  -- 'islam'|'family'|'work'|'personal_dev'
  frequency   TEXT NOT NULL DEFAULT 'daily',  -- 'daily'|'weekly'|'custom'
  target_days TEXT,           -- JSON array for custom
  reminder_enabled INTEGER DEFAULT 0,
  reminder_time INTEGER,      -- minutes from midnight
  active      INTEGER DEFAULT 1,
  created_at  INTEGER NOT NULL DEFAULT (strftime('%s','now')*1000)
);

CREATE TABLE habit_completions (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  habit_id    INTEGER NOT NULL REFERENCES habits(id),
  date        TEXT NOT NULL,  -- ISO date 'YYYY-MM-DD'
  completed   INTEGER DEFAULT 1,
  UNIQUE(habit_id, date)
);
CREATE INDEX idx_habit_completions_habit_date ON habit_completions(habit_id, date);
```

---

## 3. Barakah — Contextual Prompts

### Screen: Daily Prompt Card
```
+----------------------------------+
|  Barakah                         |
+----------------------------------+
|                                  |
|   "Verily, with hardship comes    |
|    ease."                         |
|   — Surah Ash-Sharh 94:6         |
|                                  |
|   Today's Prompt                  |
|   "What is one thing you can do   |
|    today with full presence?"     |
|                                  |
|   [ Log Reflection ]             |
|   [ Skip for Today ]             |
+----------------------------------+
```

### Screen: Log Entry
```
+----------------------------------+
|  < Back       Log Reflection     |
+----------------------------------+
|  Prompt                          |
|  "What is one thing you can do    |
|   today with full presence?"      |
|                                  |
|  Your Reflection                 |
|  [________________________]      |
|  [________________________]      |
|  [________________________]      |
|                                  |
|  Context Tags                    |
|  [Islam] [Work] [Gratitude]      |
|  [+] Add tag                     |
|                                  |
|  Mood                             |
|  [🙂] [😌] [🤲] [😔]            |
|                                  |
|  [        Save Entry        ]     |
+----------------------------------+
```

### Screen: History
```
+----------------------------------+
|  Barakah History          < Back |
+----------------------------------+
|                                  |
|  Today                           |
|  "What is one thing..."          |
|  "I will give full presence to   |
|   my morning dhikr..."           |
|                                  |
|  Yesterday                       |
|  "Verily, with hardship..."      |
|  (no reflection logged)          |
|                                  |
|  Sep 1                           |
|  "Patience is a light..."        |
|  "I felt grateful for..."        |
+----------------------------------+
```

### Key Interactions
- Daily prompt at 8:00 AM via flutter_local_notifications
- Verse/quote rotation from bundled local JSON asset
- Log entry: free text + optional tags + optional mood emoji
- Skip without penalty; skipped prompts show in history as "skipped"
- History sorted by date, most recent first

### Data Model (Drift)
```sql
CREATE TABLE barakah_prompts (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  prompt_type TEXT NOT NULL,       -- 'verse'|'hadith'|'reflection'
  content     TEXT NOT NULL,       -- the prompt text
  source      TEXT,                -- e.g., 'Surah Ash-Sharh 94:6'
  date        TEXT NOT NULL,       -- ISO date 'YYYY-MM-DD'
  created_at  INTEGER NOT NULL DEFAULT (strftime('%s','now')*1000)
);

CREATE TABLE barakah_entries (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  prompt_id   INTEGER NOT NULL REFERENCES barakah_prompts(id),
  reflection  TEXT,
  tags        TEXT,                -- JSON array of strings
  mood        TEXT,                -- 'grateful'|'peaceful'|'hopeful'|'struggling'|null
  skipped     INTEGER DEFAULT 0,
  created_at  INTEGER NOT NULL DEFAULT (strftime('%s','now')*1000)
);
```

---

## 4. Intentions — Journal

### Screen: Primary Intention
```
+----------------------------------+
|  Intentions                     |
+----------------------------------+
|  Your Primary Intention          |
|  "To grow in mindfulness and     |
|   strengthen my relationship     |
|   with Allah this semester."     |
|                                  |
|  Status: [Active ▼]              |
|  Added: Aug 28, 2025             |
|                                  |
|  [ Set New Intention ]           |
+----------------------------------+
```

### Screen: New Intention Form
```
+----------------------------------+
|  < Back      New Intention       |
+----------------------------------+
|  Your Intention                  |
|  [________________________]      |
|  [________________________]      |
|                                  |
|  Context (optional)              |
|  [________________________]      |
|                                  |
|  [        Save Intention  ]      |
+----------------------------------+
```

### Screen: Intentions List
```
+----------------------------------+
|  Intentions               + New  |
+----------------------------------+
|  ACTIVE                          |
|  "To grow in mindfulness..."     |
|    Added Aug 28 · Active         |
|                                  |
|  REFLECTED                       |
|  "To complete thesis on time"    |
|    Added Jan 10 · Reflected      |
|                                  |
|  ARCHIVED                        |
|  "To pray all 5 salah"           |
|    Added Mar 5 · Archived        |
+----------------------------------+
```

### Key Interactions
- Only ONE Active intention at a time (setting new auto-reflects old)
- Setting new intention prompts brief reflection on previous
- Reflected intentions can be re-activated (moves to Active, current becomes Reflected)
- Archived = permanently closed, read-only
- Delete available only for Archived

### Data Model (Drift)
```sql
CREATE TABLE intentions (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  text        TEXT NOT NULL,
  context     TEXT,
  status      TEXT NOT NULL DEFAULT 'active',
             -- 'active'|'reflected'|'archived'
  reflection  TEXT,                  -- notes when status changes
  created_at  INTEGER NOT NULL DEFAULT (strftime('%s','now')*1000),
  updated_at  INTEGER NOT NULL DEFAULT (strftime('%s','now')*1000),
  UNIQUE(status) WHERE status = 'active'
);
-- Only one row with status='active' at a time
-- reflected_at / archived_at can be added as INTEGER columns if needed
```

---

## Cross-Cutting Notes

### Local Storage
- **Drift**: All structured data (tasks, habits, barakah, intentions)
- **SharedPreferences**: App settings (prayer method, notification prefs, theme)
- **adhan_dart**: Prayer times computed offline, stored as cache
- **flutter_local_notifications**: Scheduled reminders (habits, barakah daily prompt)

### Sync Strategy (Future)
- All tables include `synced INTEGER DEFAULT 0`
- Background sync via Workmanager (Android) / background_fetch
- Conflict resolution: last-write-wins with server timestamp

### Navigation
- Bottom nav: Taskinator | Habitator | Barakah | Intentions
- Profile/Settings: secondary screen, prayer settings, notifications toggle

### Performance Targets
- App launch < 2s cold start
- Task list render < 100ms for 100 tasks
- Drift queries indexed on `date` + `start_time` for daily task loads
