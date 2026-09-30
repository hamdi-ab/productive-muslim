# Specification: Prayer-Aware Khushu' Focus Timer & Post-Session Barakah Reflection

**Issue:** [#44](https://github.com/hamdi-ab/productive-muslim/issues/44)  
**Date:** 2026-09-30

## 1. Problem Statement
Users practicing deep work / study sessions (Khushu' focus mode) may inadvertently run past prayer times or start a 60-minute session when Salah is only 15 minutes away. Furthermore, completing a deep work session represents a prime opportunity for Islamic intention renewal (*Niyyah*), gratitude (*Alhamdulillah*), and task completion without context-switching.

## 2. Functional Requirements
1. **Prayer-Aware Collision Detection**:
   - Query `PrayerTimeService` for upcoming prayer times and time remaining until next prayer.
   - If selected focus duration (`_selectedDurationMinutes`) exceeds time until next prayer, display a smart warning card: *"Next prayer ({prayerName}) is in {timeRemaining}. Your session will overlap with Salah."*
   - Provide a quick one-tap suggestion chip (e.g. *"Set {mins} min to finish before {prayerName}"*).

2. **Salah Approaching Wind-Down Indicator**:
   - When running a focus session and next prayer is `< 10` minutes away, display a gentle reminder badge to allow the user to wind down smoothly.

3. **Post-Session Gratitude & Task Action Flow**:
   - Congratulatory Islamic completion dialog (*"Alhamdulillah! Session Complete"*).
   - If a task was linked, allow 1-tap completion: *"Mark '{task.title}' as completed"*.
   - Option to log a quick Barakah reflection note directly from dialog.

4. **Localization & Testing**:
   - Full English and Arabic localization strings for all new alerts, actions, and dialog elements.
   - Comprehensive widget and unit tests for collision detection and completion dialog.
