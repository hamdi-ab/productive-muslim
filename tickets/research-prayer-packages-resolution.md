# Prayer Times & Adhan Notifications: Flutter Package Research

## 1. Prayer Time Calculation Packages

### 1.1 adhan_dart (v2.0.1)
- **Publisher:** farend.net (verified)
- **Last updated:** 4 months ago
- **Downloads:** ~12.3k total
- **GitHub:** https://github.com/prayer-timetable/adhan_dart (23 stars, 12 forks, 0 open issues)
- **License:** MIT
- **Platforms:** Android, iOS, Linux, macOS, Web, Windows

**Strengths:**
- Most actively maintained prayer-time library in the Dart ecosystem
- Port of the battle-tested Adhan JavaScript library (batoulapps/Adhan)
- High-precision astronomical calculations from Jean Meeus's "Astronomical Algorithms"
- 20+ calculation presets: Muslim World League, Egyptian, Karachi, Umm al-Qura, Dubai, Kuwait, Qatar, Singapore, Turkey, Tehran, North America (ISNA), Moonsighting Committee, Morocco, Russia, Tunisia, Portugal, France, Gulf Region, Indonesian, Algerian, Jordan
- Madhab support (Shafi/Hanafi) for Asr calculation
- High latitude rules (middleOfTheNight, seventhOfTheNight, twilightAngle)
- Per-prayer manual adjustments
- Second-precision option via `precision: true`
- Wraparound logic for post-midnight / next-Fajr scenarios
- Sunnah times (middleOfTheNight, lastThirdOfTheNight)
- Qibla direction calculation
- Zero runtime dependencies (library itself); timezone used only for tests
- Well-documented with API reference, examples, and changelog
- Dart SDK 3.10+ only for development; library works on older SDKs

**Weaknesses:**
- Requires manual timezone handling (returns UTC DateTime, app must convert)
- No built-in location services or offline geocoding
- No built-in Hijri calendar (must pair with another package)
- No jamaah/congregation time management
- No built-in notification scheduling

**Android compatibility:** Full support. No platform-specific native code.

**Documentation quality:** Excellent. Comprehensive README, API docs, examples, and a clear changelog.

**API ease of use:** Very straightforward. Simple constructor with coordinates, date, and parameters.

---

### 1.2 adhan (v2.0.0+1)
- **Publisher:** riajul.dev (verified)
- **Last updated:** 2 years ago
- **Downloads:** ~75 total (very low adoption)
- **GitHub:** https://github.com/iamriajul/adhan-dart (107 stars, 44 forks, 16 open issues)
- **License:** MIT
- **Platforms:** Android, iOS, Linux, macOS, Web, Windows

**Strengths:**
- Also ports the batoulapps/Adhan library
- Simple API with `PrayerTimes.today()` convenience constructor
- Coordinate validation option
- UTC offset support via Duration
- Includes SunnahTimes and Qibla
- 12 calculation methods

**Weaknesses:**
- **Stale maintenance:** Last published 2 years ago; GitHub shows some recent commits but package version hasn't advanced
- Very low pub.dev adoption compared to adhan_dart
- 16 open issues on GitHub suggest unaddressed bugs
- Uses `DateComponents` instead of native DateTime, adding friction
- No precision parameter (always minute-rounded)
- Less comprehensive high-latitude handling than adhan_dart
- No polarCircleResolution option
- Missing newer methods present in adhan_dart (e.g., Morocco, Russia, Portugal, France, Gulf Region, Indonesian, Algerian, Jordan)

**Android compatibility:** Full support. Pure Dart.

**Documentation quality:** Good, but less comprehensive than adhan_dart.

**API ease of use:** Simple, but slightly less idiomatic Dart than adhan_dart.

---

### 1.3 prayer_timetable (v2.3.2)
- **Publisher:** Unverified
- **Last updated:** 2 months ago
- **Downloads:** ~34 total
- **GitHub:** https://github.com/prayer-timetable/prayer_timetable_dart
- **License:** MIT
- **Platforms:** Android, iOS, Linux, macOS, Web, Windows
- **Dependencies:** adhan_dart ^2.0.1, hijri ^3.0.0, timezone ^0.11.0

**Strengths:**
- Built on top of adhan_dart, inheriting its calculation accuracy
- **Jamaah (congregation) time management** — unique feature for mosque/community apps
- Three calculation modes: astronomical, pre-calculated maps, list-based timetables
- Full timezone support with automatic DST adjustments via timezone package
- **Hijri calendar integration** — date conversions, month operations, Arabic/English month names
- Monthly timetable generation for both Gregorian and Hijri months
- Current prayer detection, countdown timers, completion percentages
- Qibla direction included
- Friday-aware Jumuah labeling

**Weaknesses:**
- Very low adoption (34 downloads)
- Unverified publisher
- API is more complex due to jamaah and timetable features
- Documentation is decent but not as polished as adhan_dart
- Heavier dependency footprint (adhan_dart + hijri + timezone)
- Some README examples appear to have formatting issues

**Android compatibility:** Full support. Pure Dart.

**Documentation quality:** Moderate. README has examples but API reference is basic.

**API ease of use:** Moderate. More configuration options than adhan_dart, which adds complexity.

---

### 1.4 persis_times (v1.0.45)
- **Publisher:** Unverified
- **Last updated:** 7 days ago (very recent)
- **Downloads:** ~356 total
- **GitHub:** https://github.com/abusabda/PERSIS-TIMES
- **License:** Unknown
- **Platforms:** Android, iOS, Linux, macOS, Web, Windows
- **Dependencies:** decimal ^3.2.4

**Strengths:**
- Scientific-grade astronomical calculations using VSOP87D (solar) and ELPMPP02 (lunar) theories
- 38,326 correction terms for high precision
- Includes prayer times, Qibla, Hijri calendar, and eclipse calculations
- Pure Dart, no heavy dependencies
- Recently updated (7 days ago)

**Weaknesses:**
- Very low adoption (356 downloads)
- Unknown license
- Unverified publisher
- Documentation is sparse and academic rather than practical
- No obvious calculation method presets (requires understanding of astronomical angles)
- No Madhab support mentioned
- No high-latitude rules mentioned
- No convenience utilities like currentPrayer/nextPrayer
- No examples for common use cases

**Android compatibility:** Full support. Pure Dart.

**Documentation quality:** Poor for practical use. Academic focus, no quick-start guide.

**API ease of use:** Poor. Requires deep understanding of astronomical parameters.

---

### 1.5 muslim_data_flutter (v1.5.0)
- **Publisher:** myprayers.io (verified)
- **Last updated:** 9 months ago
- **Downloads:** ~189 total
- **GitHub:** https://github.com/kosratdev/muslim-data-flutter
- **License:** Apache-2.0
- **Platforms:** Android, iOS, Linux, macOS, Web, Windows
- **Dependencies:** drift, drift_flutter, path, path_provider, sqlite3, sqlite3_flutter_libs

**Strengths:**
- Comprehensive Muslim data suite: prayer times, offline geocoding, reverse geocoding, location search, Azkars (Hisnul Muslim), 99 Names of Allah
- Includes fixed prayer times for many cities worldwide
- Native Android and iOS libraries available
- Multi-language support (en, ar, ckb, ckb_BADINI, fa, ru)

**Weaknesses:**
- Heavy dependency footprint (SQLite, Drift ORM) — overkill if you only need prayer times
- Last updated 9 months ago
- Low adoption
- Prayer times are secondary feature in a data library
- Requires native platform setup
- No calculation method flexibility beyond what the native libs provide

**Android compatibility:** Full support, but requires native library integration.

**Documentation quality:** Moderate. Good for the broader library, less focused on prayer times.

**API ease of use:** Moderate. Repository-based API is more abstract.

---

## 2. Adhan Notification / Scheduling Packages

### 2.1 awqat (v0.1.14)
- **Publisher:** Unverified
- **Last updated:** 3 months ago
- **Downloads:** ~44 total
- **GitHub:** https://github.com/ssoad/awqat (6 stars, 0 forks)
- **License:** MIT
- **Platforms:** Android, iOS only
- **Dependencies:** flutter, plugin_platform_interface ^2.0.2

**Strengths:**
- **Native notification scheduling** — uses AlarmManager.setAlarmClock() on Android and UNCalendarNotificationTrigger on iOS
- Zero Dart isolate overhead; works when app is closed
- Battery-efficient system-level APIs
- Survives device reboots (Android)
- Works with Doze mode
- Built-in prayer time calculation (12 methods, Madhab support)
- Adhan sound support with toggle and custom sound names
- Jumuah (Friday) support
- Simple API: initialize → getPrayerTimes → scheduleReminders
- Handles permissions (POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM)

**Weaknesses:**
- Very low adoption (44 downloads)
- Unverified publisher
- Android and iOS only (no Web, Desktop)
- Requires exact alarm permission on Android 14+
- Small community; limited track record
- No open issues on GitHub (could mean few users or good quality)

**Android compatibility:** Excellent. Uses native AlarmManager for reliability.

**Documentation quality:** Good. Clear README with setup instructions and API reference.

**API ease of use:** Excellent. One-stop API for both calculation and notifications.

---

### 2.2 flutter_local_notifications (v22.3.0)
- **Publisher:** dexterx.dev (verified)
- **Last updated:** 31 days ago
- **Downloads:** Very high (7.3k likes)
- **GitHub:** https://github.com/MaikuB/flutter_local_notifications (Flutter Favorite)
- **License:** MIT
- **Platforms:** Android, iOS, macOS, Linux, Windows, Web

**Strengths:**
- Industry-standard notification plugin for Flutter
- Extremely well-maintained (updated monthly)
- Massive adoption and community trust
- Cross-platform (all Flutter targets)
- Full scheduling support: one-shot, periodic, daily, weekly
- Custom notification sounds, icons, vibration patterns
- Notification actions and categories
- Foreground service support
- Full-screen intent notifications
- Permission handling
- Active notifications retrieval
- Handles bootCompleted rescheduling

**Weaknesses:**
- Requires separate prayer time calculation (doesn't calculate times)
- Dart isolate overhead for scheduled callbacks
- Android OEM battery optimizations can kill scheduled notifications (Xiaomi, Huawei)
- More complex setup than awqat for prayer-specific use
- Requires manual integration with a prayer time library

**Android compatibility:** Good, but subject to OEM restrictions. Samsung limits to 500 alarms.

**Documentation quality:** Excellent. Extensive docs with platform-specific caveats.

**API ease of use:** Moderate. Powerful but requires more boilerplate for prayer-specific scheduling.

---

### 2.3 android_alarm_manager_plus (v5.1.1)
- **Publisher:** fluttercommunity.dev (verified)
- **Last updated:** 46 days ago
- **Downloads:** ~17.9k
- **GitHub:** https://github.com/fluttercommunity/plus_plugins
- **License:** BSD-3-Clause
- **Platforms:** Android only

**Strengths:**
- Official Flutter Community plugin
- Reliable Android AlarmManager access
- Background Dart code execution
- Boot completion handling
- Alarm clock intents

**Weaknesses:**
- Android only (no iOS support)
- Requires SCHEDULE_EXACT_ALARM permission on Android 14+
- Dart isolate startup overhead (1-3 seconds)
- Battery impact compared to native notifications
- Subject to OEM kill-switches
- Requires pairing with flutter_local_notifications for actual notification display
- No built-in adhan sound or Islamic-specific features

**Android compatibility:** Excellent for alarm scheduling, but notification delivery is separate concern.

**Documentation quality:** Good. Clear setup instructions.

**API ease of use:** Simple for alarms, but incomplete for notifications.

---

## 3. Comparison Matrix

| Package | Type | Maintenance | Downloads | Methods | Madhab | Timezone | Hijri | Jamaah | Notifications | Android | iOS | Web |
|---------|------|-------------|-----------|---------|--------|----------|-------|--------|---------------|---------|-----|-----|
| adhan_dart | Calc | Active (4 mo) | 12.3k | 20+ | Yes | Manual | No | No | No | Yes | Yes | Yes |
| adhan | Calc | Stale (2 yr) | 75 | 12 | Yes | UTC offset | No | No | No | Yes | Yes | Yes |
| prayer_timetable | Calc | Active (2 mo) | 34 | Inherited | Yes | Auto | Yes | Yes | No | Yes | Yes | Yes |
| persis_times | Calc | Active (7d) | 356 | Custom | ? | Manual | Yes | No | No | Yes | Yes | Yes |
| muslim_data_flutter | Suite | 9 mo | 189 | Fixed+Calc | Yes | ? | No | No | No | Native | Native | No |
| awqat | Calc+Notify | Active (3 mo) | 44 | 12 | Yes | Auto | No | No | Native | Yes | Yes | No |
| flutter_local_notifications | Notify | Active (31d) | High | N/A | N/A | N/A | N/A | N/A | Full | Yes | Yes | Yes |
| android_alarm_manager_plus | Alarm | Active (46d) | 17.9k | N/A | N/A | N/A | N/A | N/A | Alarm only | Yes | No | No |

## 4. Recommended Stack

### Primary Recommendation: **adhan_dart + flutter_local_notifications**

**Rationale:**
1. **adhan_dart** is the most mature, well-tested, and actively maintained prayer time library in the Dart ecosystem. It has 12.3k downloads, zero open issues, and a verified publisher. The astronomical calculations are scientifically rigorous and it supports every major calculation method needed for a global audience.

2. **flutter_local_notifications** is the industry-standard notification plugin (Flutter Favorite, 7.3k likes). It provides full scheduling capabilities, custom sounds (including adhan), and cross-platform support. While it requires more setup than awqat, its reliability, documentation, and community support are unmatched.

3. **Separation of concerns:** Keeping calculation and notification as separate libraries follows single-responsibility principle and gives maximum flexibility. If you later want to add in-app features (countdown, Qibla, Sunnah times), adhan_dart provides them without notification bloat.

4. **Risk mitigation:** Both packages have massive adoption and are unlikely to be abandoned. awqat is promising but has only 44 downloads and an unverified publisher — a risk for a production app.

**Implementation approach:**
- Use adhan_dart for all prayer time calculations
- Use timezone package for proper timezone handling
- Use flutter_local_notifications for scheduling adhan reminders
- Schedule notifications daily for each prayer, with offset (e.g., 5 minutes before)
- Handle Android 13+ POST_NOTIFICATIONS permission
- Handle Android 14+ SCHEDULE_EXACT_ALARM permission
- Add RECEIVE_BOOT_COMPLETED for rescheduling after reboot
- Bundle adhan audio files in native resources

### Alternative: **awqat** (if you prefer all-in-one)

**When to consider:**
- You want the simplest possible integration
- You only target Android and iOS
- You value native alarm reliability over cross-platform reach
- You accept the risk of a less-established package

**Caveats:**
- Only 44 downloads and unverified publisher
- No Web/Desktop support
- Smaller community means slower bug fixes
- Less flexible if your requirements grow (no Hijri, no Qibla, no Sunnah times)

### Complementary Packages

- **timezone** (^0.11.0): Essential for proper timezone-aware prayer times with adhan_dart
- **hijri** (^3.0.0): If you need Hijri calendar dates (pair with prayer_timetable or standalone)
- **location** or **geolocator**: For GPS-based coordinate detection
- **permission_handler**: For Android 13+ notification and exact alarm permissions

## 5. Key Implementation Considerations

1. **Timezone handling:** adhan_dart returns UTC DateTime. Always convert using the timezone package with IANA timezone names (e.g., "America/New_York").

2. **Android 14 exact alarms:** Starting Android 14, SCHEDULE_EXACT_ALARM is denied by default. You must request this permission at runtime. Consider USE_EXACT_ALARM if your app qualifies as an alarm clock.

3. **Battery optimizations:** Some OEMs (Xiaomi, Huawei, Samsung) aggressively kill background processes. flutter_local_notifications handles this better than pure Dart solutions, but users may still need to whitelist the app.

4. **Adhan audio:** Store adhan audio files in `android/app/src/main/res/raw/` and `ios/Runner/`. Use custom notification sound support in flutter_local_notifications.

5. **Daily rescheduling:** Recalculate and reschedule prayer times daily (or when location changes significantly). Use a daily alarm or app lifecycle hooks.

6. **Precision:** Use `precision: true` in adhan_dart for second-accurate times, then round to minutes for display and notifications.

7. **High latitudes:** Use `HighLatitudeRule.recommended(coordinates)` for locations above 48° latitude to avoid invalid Fajr/Isha times.
