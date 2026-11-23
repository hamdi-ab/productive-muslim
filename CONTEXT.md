# Context

Productive Muslim — a daily companion that helps Muslims strengthen their remembrance of Allah, organize their responsibilities around Salah, and develop a more intentional and balanced life.

## Core concepts

- **Five Pillars**:
  - **Remember**: Dhikr and authentic morning & evening adhkar
  - **Pray**: Salah timetable, accurate adhan countdowns, and Qibla direction
  - **Intend & Act**: Daily intentions, priority tasks, habits, and focus sessions (My Day)
  - **Reflect**: Gentle evening review, muhasabah, and gratitude without numerical spiritual scores
  - **Grow**: Consistent, humble personal growth and character development
- **Barakah**: divine blessing and spiritual nourishment; daily prompt-card reflections and a qualitative weekly review with factual reflection counts (strictly free from spiritual scoring or gamified points)
- **Habits**: daily routines anchored to prayers and intentional living
- **Tasks**: purposeful daily actions organized around Salah
- **Intentions**: daily intention setting and evening reflection
- **Onboarding**: guided setup of user profile, daily pillars focus, and prayer times

## Architecture notes

Feature-first with clean architecture layers (domain / data / presentation) within each feature. Drift for local SQLite, BLoC for state, GoRouter for navigation, GetIt for DI, Freezed for code generation.
