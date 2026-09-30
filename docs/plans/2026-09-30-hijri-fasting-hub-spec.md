# Hijri Calendar & Sunnah Fasting Hub Specification

## Overview
A dedicated Islamic temporal and fasting hub that combines Hijri calendar conversion with Sunnah fasting tracking (Mondays, Thursdays, and the 13th, 14th, 15th White Days / *Ayyam al-Beed*).

## Key Features
1. **`HijriService`**:
   - Converts `DateTime` to Hijri dates (`year`, `month`, `day`, `monthName`, `isWhiteDay`, `isSunnahFastingDay`).
   - Identifies White Days (13th, 14th, 15th of Hijri month) and Sunnah days (Mon/Thu).
   - Generates monthly calendar data with Hijri and Gregorian mappings.
2. **Sunnah Fasting Hub UI**:
   - Interactive Hijri Month Calendar grid highlighting White Days and Mon/Thu Sunnah fasts.
   - Live Fasting Status card with Suhoor / Iftar prayer-time countdowns.
   - Sunnah Iftar Du'a modal/card with Arabic, transliteration, and English translation.
   - Fasting history and streak counter integrated with `SettingsService`.
3. **Bilingual Localization (English & Arabic)**:
   - Full localization of Hijri months (Muharram, Safar, Rabi' al-Awwal, ..., Ramadan, Shawwal, Dhu al-Qi'dah, Dhu al-Hijjah).
   - Localized fasting descriptions, du'as, and motivations.
4. **Testing**:
   - Unit tests for `HijriService` (accurate conversions, White Day detection, Sunnah classification).
   - Widget tests for Hijri Calendar View, Fasting Tracker, Iftar Du'a dialog, and Arabic RTL layout.
