# Barakah Tracker Interaction Pattern — Research Resolution

## 1. Problem Statement

The Productive Muslim app needs a barakah tracker that lets users log the 18 sources of barakah, visualize trends, connect barakah to productivity metrics, and receive daily/weekly prompts. The target audience is university students and young professionals (18–35) who are familiar with Islamic concepts but need low-friction, spiritually meaningful tracking.

---

## 2. Evaluated Interaction Patterns

### 2.1 Pattern A — Quick-Tap Checklist with Context Chips

**Description**
A daily screen shows the 18 sources as a scrollable checklist. The user taps any source they experienced that day. After selecting one or more, optional context chips appear (e.g., "At Fajr," "During study," "With family," "At work") and a single-line note field. Submit is one tap.

**User friction:** Low. Logging a day takes 15–30 seconds for the common case.
**Data richness:** Moderate. Captures which sources were present and rough context, but lacks depth for personal reflection.
**Visualization potential:** Strong. Bar chart of source frequency, streak heatmap, correlation with task/habit completion.
**Target-audience fit:** High. Students and young professionals prefer quick logging after Salah or at bedtime. Context chips reduce typing while keeping data structured enough for analytics.

### 2.2 Pattern B — Barakah Journal with Smart Tags

**Description**
A free-form journal entry with auto-suggested tags drawn from the 18 sources. The user writes a brief note (e.g., "Had a great study session after making dua") and tags one or more sources. Entries appear in a feed with search and filter.

**User friction:** Medium-high. Requires writing, which many users skip on busy days.
**Data richness:** High. Captures narrative context, emotional tone, and multiple sources per event.
**Visualization potential:** Moderate. Tag clouds and word clouds are possible, but structured analytics (streaks, correlations) require extra NLP effort.
**Target-audience fit:** Moderate. Fits users who already journal, but risks abandonment by users who want a 10-second log. The 18–35 demographic often starts strong and drops off if friction increases.

### 2.3 Pattern C — Slider + Source Multi-Select (Mood/Energy Tracker Style)

**Description**
The primary input is a 1–5 slider labeled "How much barakah did you feel today?" Below it, a multi-select grid of the 18 sources. The user adjusts the slider and taps sources. Optional "What contributed?" free-text appears only when the slider is low (≤2) or high (≥4).

**User friction:** Medium. Slider feels subjective; users may overthink "how much barakah" and abandon the entry.
**Data richness:** Moderate-high. Captures self-reported barakah intensity plus sources, plus conditional context.
**Visualization potential:** Moderate. Time-series of intensity is possible, but intensity is subjective and hard to correlate with objective metrics like task completion.
**Target-audience fit:** Moderate-to-low. University students and young professionals may find the slider gimmicky or spiritually uncomfortable — barakah is not a mood, and quantifying divine blessing can feel reductive. Risk of low engagement or perceived trivialization.

### 2.4 Pattern D — Hybrid: Contextual Prompt Cards (Recommended)

**Description**
The app surfaces a single daily prompt card at a meaningful time (e.g., after Maghrib or before bed). The card asks a brief, contextual question such as:
- "Did you experience barakah in your time today?"
- "Was your income or food from halal sources?"
- "Did you connect with family today?"

The user taps "Yes," "Somewhat," or "No," and the card reveals the relevant 1–3 sources as quick-tap chips. A single optional note field sits at the bottom. Over a week, the prompts rotate through the 18 sources so each is surfaced roughly 2–3 times per month without overwhelming the user.

**User friction:** Very low. One question, one or two taps, optional note. Feels like a quick reflection, not data entry.
**Data richness:** High enough. Each answer maps to structured source data, and notes are captured when the user has something to say.
**Visualization potential:** Strong. Because every entry is tied to a source (or small set of sources), analytics are clean. Trends, streaks, and correlations with productivity metrics are easy to compute.
**Target-audience fit:** High. Fits the target audience's schedule and mindset: quick, spiritually framed, and integrated into existing routines (post-prayer or evening reflection).

---

## 3. Comparative Matrix

| Criterion | A — Checklist | B — Journal + Tags | C — Slider + Multi-Select | D — Hybrid Prompt Cards |
|---|---|---|---|---|
| Logging time | 15–30s | 1–3 min | 20–40s | 10–20s |
| Completion rate | High | Low–Medium | Medium | High |
| Structured analytics | Yes | Partial | Partial | Yes |
| Narrative depth | Low | High | Medium | Medium |
| Spiritual fit | Moderate | Moderate | Low | High |
| Implementation effort | Low | Medium | Low–Medium | Medium |

---

## 4. Recommendation

**Adopt Pattern D — Hybrid Contextual Prompt Cards.**

Rationale:
- **Lowest friction for the target audience.** Students and young professionals abandon apps that feel like homework. A single contextual question per prompt keeps engagement high.
- **Spiritually appropriate framing.** Prompts tie barakah to lived experience ("Did you feel your time was productive?") rather than demanding quantification of a divine concept.
- **Clean data for analytics.** Because each prompt maps to a known source (or small source set), the app can still produce streak charts, source frequency graphs, and productivity correlations without NLP.
- **Scalable.** The prompt bank can grow over time, and users can skip prompts if they are already logging that source elsewhere.

Pattern A is the strongest runner-up. If the team prefers a pure checklist for V1, Pattern A with optional "Add note" is a viable fallback.

---

## 5. Recommended Data Model Schema

### 5.1 Core Entities

```yaml
# barakah_source
id: string (uuid)
name: string            # e.g., "Reading Quran"
arabic_name: string     # optional
slug: string            # url-safe identifier
description: string     # one-line explanation
order: int              # for display ordering (1–18)

# barakah_prompt
id: string (uuid)
source_ids: array[string]  # one or more related sources
question: string           # e.g., "Did you experience barakah in your time today?"
active: boolean
display_order: int

# barakah_entry
id: string (uuid)
date: date                 # local date of the entry
source_ids: array[string]  # which sources the user affirmed
prompt_id: string          # which prompt triggered this entry (nullable)
intensity: int             # nullable 1–5, only if user opted in
note: string               # optional free-text, max 280 chars
created_at: datetime
updated_at: datetime

# productivity_event
id: string (uuid)
type: enum [task_completed, habit_checked, session_logged]
event_date: date
metadata: json             # e.g., { task_id, habit_id, duration_minutes }
created_at: datetime

# barakah_productivity_link  # computed, not directly user-edited
id: string (uuid)
barakah_entry_id: string
productivity_event_id: string
link_strength: enum [weak, strong]  # weak = same day; strong = same source + same day
```

### 5.2 Relationships and Queries

- **Daily summary:** Group `barakah_entry` by date, count source frequency, compute streak length.
- **Weekly trend:** Aggregate daily summaries by week, show top 3 sources per week.
- **Productivity correlation:** Join `barakah_productivity_link` on same-day entries; compute which sources most frequently co-occur with completed tasks or maintained habits.
- **Prompt rotation:** Select active `barakah_prompt` records weighted by `display_order` and recent exposure (avoid repeating the same prompt within 10 days).

### 5.3 Storage Considerations

- **Offline-first:** All `barakah_entry` records are created and read locally. Sync (if ever added) is append-only.
- **Privacy:** Notes and source selections are personal; no cloud sync in V1.
- **Schema evolution:** Add `version` to `barakah_entry` to allow prompt logic to change without breaking historical data.

---

## 6. Prompting and Reminder Strategy

| Timing | Prompt Type | Example |
|---|---|---|
| Post-Maghrib | Daily reflection | "Did you experience barakah in your time today?" |
| Post-Fajr | Morning intention | "Did you wake up early and make dua?" |
| Weekly (Sunday evening) | Weekly review | "Which source of barakah stood out this week?" |
| After task completion | Micro-prompt | "Did you begin this task with Bismillah?" (optional, opt-in) |

Prompts should be:
- **Opt-in per category.** Users enable daily, weekly, and micro-prompts independently.
- **Quiet-hours aware.** Never prompt during sleep or work hours.
- **Snooze-friendly.** A single "Remind me in 1 hour" per prompt.
- **Non-intrusive.** Use notification channels that do not break focus.

---

## 7. Visualization Specifications

1. **Source Frequency Ring** — A donut chart showing the user's most common sources over the selected time range. Tapping a slice filters the feed.
2. **Barakah Streak Calendar** — A monthly calendar grid; days with at least one entry are colored by source diversity (more sources = deeper color).
3. **Productivity Correlation Card** — "On days you prayed Istikhara, you completed 3.2 more tasks on average." Shown only when data is statistically meaningful (≥14 overlapping days).
4. **Weekly Insight** — A 1-sentence insight generated from the user's own data, e.g., "You logged charity 4 times this week — your most frequent source."

Visualizations should default to a 30-day window and allow 7-day, 90-day, and all-time toggles.

---

## 8. Open Questions for Implementation

1. Should users be able to log multiple entries per day (e.g., one after Fajr, one at night), or is one entry per day sufficient?
2. Do we expose the full 18 sources at all times, or only through prompts?
3. Should the productivity correlation feature be V1 or V2? It requires a task/habit system to already exist.
4. How do we handle users who do not feel barakah on a given day? Should "No" answers be logged with the same weight as "Yes"?

---

## 9. Decision Record

- **Chosen pattern:** Pattern D — Hybrid Contextual Prompt Cards.
- **Chosen data model:** Entities defined in Section 5, stored offline-first with optional append-only sync.
- **Blocking dependencies:** Requires prompt bank content (18 sources mapped to 15–20 prompts), integration with notification scheduler, and a date-picker for weekly review.
