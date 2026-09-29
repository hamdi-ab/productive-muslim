# Specification: Interactive Qibla Compass & Visual Solar Prayer Times Dial

## 1. Overview
This feature introduces an offline-capable, interactive **Qibla Compass** and **24-hour Solar Prayer Dial**:
- **Qibla Compass**: Calculates great-circle azimuth and distance to Kaaba in Makkah (21.4225° N, 39.8262° E) from current GPS coordinates using `adhan_dart.Qibla`. Includes cardinal rose, smooth directional alignment indicator, and manual calibration guidance.
- **Visual Solar Prayer Times Dial**: Circular visual arc that graphs the sun's trajectory across Fajr, Sunrise, Dhuhr, Asr, Maghrib, and Isha. Highlights the current active Barakah slot and counts down to the next prayer.
- **Bilingual & Responsive**: Arabic and English support with RTL layout and dark/light themes.

---

## 2. Architecture & Components
- `lib/data/services/qibla_service.dart`: Great circle Kaaba bearing & distance calculations.
- `lib/features/prayer_times/presentation/widgets/qibla_compass_view.dart`: Interactive compass UI with degree readouts and Kaaba alignment feedback.
- `lib/features/prayer_times/presentation/widgets/solar_prayer_dial.dart`: 24-hour circular prayer progression arc widget.
- `lib/features/prayer_times/presentation/screens/prayer_times_screen.dart`: Tabbed interface for Prayer Times / Solar Dial and Qibla Compass.
