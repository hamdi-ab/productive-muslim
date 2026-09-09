# Navigation Structure & Onboarding Flow — Design Resolution

## 1. Bottom Navigation Structure

### Tab Order & Icons
| Index | Label   | Icon            | Route              | Badge Logic                                  |
|-------|---------|-----------------|--------------------|----------------------------------------------|
| 0     | Home    | `home` / `compass` | `/`            | Next prayer countdown (HH:MM:SS); red when < 15 min |
| 1     | Tasks   | `check_circle`  | `/tasks`           | Pending task count; zero hides badge          |
| 2     | Habits  | `repeat`        | `/habits`          | Active streak flame when streak ≥ 7 days      |
| 3     | Barakah | `sparkles`      | `/barakah`         | Weekly points trend indicator                 |
| 4     | Journal | `book`          | `/journal`         | Draft count when > 0                          |

### Rules
- Fixed 5-tab bar; no context-sensitive tab swapping
- Center FAB (`add`) floats above bar, opens quick-add bottom sheet
- Swipe between tabs disabled; single-direction finger travel prevents accidental tab switches
- Selected state: `primary` color + 2 dp weight bottom indicator; unselected = `onSurfaceVariant` at 60% opacity

---

## 2. Onboarding Sequence

**Goal:** < 90 seconds | 4 screens max

### Screen 1 — Welcome
- Illustration: minimal geometric masjid silhouette at sunrise
- Headline: "Build your day around what matters"
- Subhead: "Prayer, tasks, habits, and intentions — together in one space"
- Primary CTA: "Get Started"
- Secondary link: "Already have an account? Log in" (skips to auth flow)

### Screen 2 — Name Input
- Field: `TextFormField` with `TextCapitalization.words`
- Validation: non-empty, max 40 chars, regex `^[\p{L}\p{M} \.\-']+$` (Unicode letters)
- CTA: "Continue"
- Persist to SharedPreferences key `user_display_name`

### Screen 3 — Intention Setting
- Intro: "What brings you here today?"
- Preset chips (single-select):
  1. "Seeking barakah in my time"
  2. "Consistent worship & routine"
  3. "Mindful productivity"
- Free-form: "Or write your own" → expands `TextFormField` (max 120 chars)
- Save to Drift `intentions` table, mark `is_primary = true`
- CTA: "Set My Intention"

### Screen 4 — Prayer Time Setup
- Permission request: "Allow location access for accurate prayer times?" with rationale text
- On deny: fallback to manual city search (type-ahead)
- Calculation method picker: `RadioListTile` grid (default: Muslim World League)
  - Muslim World League, Egyptian General Authority, Umm Al-Qura, University of Islamic Sciences, etc.
- Preview card: "Fajr 5:12 AM · Dhuhr 12:45 PM · Asr 4:20 PM · Maghrib 6:58 PM · Isha 8:30 PM"
- CTA: "Start Your Day"

### Completion
- `onboarding_completed = true` in SharedPreferences
- Navigate to Home with `replaceAll` to prevent back-navigation into onboarding

---

## 3. Home Screen Layout — Daily Command Center

```
┌─────────────────────────────────────┐
│ ☀️ Good morning, <Name>          ≡ │  ← Greeting + settings icon
│ Tuesday, September 9               │
├─────────────────────────────────────┤
│ 🕌 Next Prayer                        │
│ ▸ ASR in 1h 42m          📍 Nearby  │  ← Countdown + location chip
├─────────────────────────────────────┤
│ Quick Actions              [+ Add] │
│ [🎯 Next Task]  [🔥 12d Streak]     │  ← Two primary quick stats
│ [📅 3 upcoming]  [✨ 45 Barakah]   │
├─────────────────────────────────────┤
│ Today's Focus (3 items, mixed type) │  ← Scrollable card list
│ ┌─────────────────────────────────┐ │
│ │ ☑ Fajr (done)   [Task] 6:00 AM │ │
│ │ ⬜ Read 30 min  [Habit] Due 9PM │ │
│ │ ○ Write journal [Intention]     │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Behavior
- **Prayer card** is always top, full-width accent background; tapping opens prayer times sheet
- **Quick Actions** are 2×2 grid of stat chips; tapping navigates to respective tab
- **Today's Focus** pulls from unified `today_events` query (tasks + habit reminders + intentions due), sorted by priority + time
- FAB opens "Quick Add" bottom sheet with: New Task | New Habit | Journal Entry | Quick Intention

---

## 4. Navigation Flow Diagram

```mermaid
flowchart TD
    A[Launch] --> B{onboarding_completed?}
    B -->|false| S1[Screen 1: Welcome]
    S1 --> S2[Screen 2: Name Input]
    S2 --> S3[Screen 3: Intention Setting]
    S3 --> S4[Screen 4: Prayer Setup]
    S4 --> C[Home]
    B -->|true| C

    C --> C0[Home\n(Greeting + Next Prayer + Focus)]
    C --> C1[Tasks\n(Filtered list + FAB)]
    C --> C2[Habits\n(Streak grid + completion)]
    C --> C3[Barakah\n(Points + weekly chart)]
    C --> C4[Journal\n(Entries + draft indicator)]

    C0 -.-> D[Task Detail]
    C1 -.-> D
    C2 -.-> E[Habit Detail]
    C4 -.-> F[Entry Editor]

    S4 -.-> G[Permission Denied]
    G --> G1[Manual City Search]
    G1 --> S4
```

## 5. Edge Cases & Guardrails

- **Cold start latency:** Onboarding screens are pre-warmed into memory tree after splash; skip animation on return
- **Name change:** Settings screen only; does not re-trigger onboarding
- **Intention edit:** Available from Journal tab; no screen lockout
- **Location denied:** App remains functional with manual override; nudges once per week
- **Back button during onboarding:** app exit on Screen 1, back to previous onboarding screen on 2-3, confirmation dialog on 4 ("Leave setup? Your data won't be saved.")
- **Orientation:** Lock portrait during onboarding; Home supports landscape on tablet
- **Accessibility:** All icons have semantic labels; chips have minimum 48×48 touch target; countdown timer announces remaining minutes to TalkBack

## 6. Data Contracts

| Key / Table         | Type         | Purpose                        |
|---------------------|--------------|--------------------------------|
| `user_display_name` | SharedPrefs  | Personalization across app      |
| `onboarding_completed` | SharedPrefs | Gate for splash routing        |
| `user_intention`    | Drift table  | Primary intention (editable)    |
| `prayer_method`     | SharedPrefs  | Calculation method enum        |
| `location_granted`  | SharedPrefs  | Permission state               |
