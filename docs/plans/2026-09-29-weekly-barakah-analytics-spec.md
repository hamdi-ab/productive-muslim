# Specification: Weekly Barakah Analytics & Spiritual Growth Insights

## 1. Overview
The **Weekly Barakah Analytics & Spiritual Growth Insights** feature extends the existing Barakah Review with rich visual intelligence:
- **7-Day Barakah Consistency Matrix**: A visual heat/activity strip displaying daily Barakah prompt responses, Dhikr completions, and intention follow-through across the selected week.
- **Holistic Energy Triad (Spiritual, Physical, Mental)**: Aggregated averages and multi-line/bar visual comparison of the user's daily energy ratings over the 7 days.
- **Barakah Correlation Insights**: Practical coaching observations linking high-energy days to regular Dhikr and Sunnah habits (e.g., *"On days with Morning Adhkar & Qaylulah, your mental focus was 42% higher"*).
- **Weekly Growth Export / Reflection**: Ability to capture weekly summary notes and reflections directly into local storage.

---

## 2. Architecture & Domain Changes

### 2.1 Models & Calculations
- `BarakahAnalyticsSummary`:
  - `double averagePhysicalEnergy`
  - `double averageSpiritualEnergy`
  - `double averageMentalEnergy`
  - `int totalDhikrCompleted`
  - `int totalIntentionsCompleted`
  - `int activeDaysCount`
  - `List<DayBarakahSnapshot> dailySnapshots`
  - `List<String> coachingInsights`

### 2.2 UI Components
- `BarakahConsistencyGrid`: Compact, accessible 7-day visual block tracker.
- `EnergyTriadBreakdown`: Visual bar indicators comparing Spiritual (Emerald), Mental (Indigo), and Physical (Amber) energy.
- `CoachingInsightCard`: Coach-like actionable Islamic productivity observations.

### 2.3 Localization
- Full bilingual copy in English (`app_en.arb`) and Arabic (`app_ar.arb`).
