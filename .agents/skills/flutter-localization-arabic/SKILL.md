---
name: flutter-localization-arabic
description: Configure Arabic + English localization with RTL support for this Flutter app. Covers flutter_localizations, intl, ARB files, Arabic-specific gotchas (font fallback, date formatting, directionality), and Islamic terminology. Use when adding, modifying, or reviewing localized strings or RTL-safe widgets.
package: intl
aliases: [arabic, rtl, localization, l10n, i18n]
sources: [chat, code]
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 09 Sep 2026 14:54:00 GMT
  versions:
    flutter_localizations: sdk:flutter
    intl: ^0.20.3
---

# Arabic + English Localization with RTL Support

This app supports English and Arabic with full RTL layout. All user-facing strings are localized. Islamic terminology must be accurate and consistent across both languages.

## Core Rules

1. All user-facing strings must be in ARB files, never hardcoded in Dart.
2. English is the base language (`app_en.arb`). Arabic is `app_ar.arb`.
3. Use `flutter_localizations` + `intl` packages. Do not use third-party localization packages.
4. All Arabic strings use proper Arabic script. Do not use transliteration.
5. RTL layout must work for every screen. Test with `Directionality` widget during development.
6. Use `TextDirection.rtl` explicitly when building custom widgets that depend on directionality.
7. Islamic terms use consistent spelling across both languages.
8. Date and time formatting respects the current locale.
9. Pluralization and gender rules follow Arabic grammar, not English grammar patterns.
10. Never concatenate localized strings. Use ICU message format for dynamic content.

## Project Structure

```text
lib/
├── l10n/
│   ├── app_en.arb
│   ├── app_ar.arb
│   └── l10n.yaml
├── core/
│   └── localization/
│       └── app_localizations.dart   # Generated — do not edit
```

## ARB File Structure

```json
{
  "@@locale": "en",
  "appTitle": "Productive Muslim",
  "homeGreeting": "Good morning, {name}",
  "prayerTimes": "Prayer Times",
  "taskTitle": "Task Title",
  "@taskTitle": {
    "description": "Label for the task title input field"
  },
  "tasksCount": "{count, plural, =0{No tasks} =1{1 task} other{{count} tasks}}",
  "intentionSet": "Your intention has been set",
  "@intentionSet": {
    "description": "Confirmation message after setting a primary intention"
  }
}
```

```json
{
  "@@locale": "ar",
  "appTitle": "المسلم المنتج",
  "homeGreeting": "صباح الخير، {name}",
  "prayerTimes": "مواقيت الصلاة",
  "taskTitle": "عنوان المهمة",
  "@taskTitle": {
    "description": "Label for the task title input field"
  },
  "tasksCount": "{count, plural, =0{لا توجد مهام} =1{مهمة واحدة} other{{count} مهام}}",
  "intentionSet": "تم تحديد نيتك",
  "@intentionSet": {
    "description": "Confirmation message after setting a primary intention"
  }
}
```

## Setup

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true
```

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
synthetic-package: true
```

```dart
// main.dart
MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('en'),
    Locale('ar'),
  ],
)
```

## RTL-Safe Widget Patterns

```dart
// CORRECT — use Directionality-aware widgets
Text(
  context.tr.prayerTimes,
  textDirection: Directionality.of(context) == TextDirection.rtl
      ? TextDirection.rtl
      : TextDirection.ltr,
)

// CORRECT — use start/end instead of left/right
Padding(
  padding: EdgeInsetsDirectional.only(start: 16, end: 16),
)

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  textDirection: Directionality.of(context), // CORRECT — respects RTL
  children: [
    Text(context.tr.taskTitle),
    Icon(Icons.arrow_forward_ios),
  ],
)

// WRONG — hardcoded left/right
EdgeInsets.only(left: 16, right: 16); // WRONG in RTL

// WRONG — ignoring directionality
mainAxisAlignment: MainAxisAlignment.end; // WRONG — flips in RTL
```

## Arabic Font and Typography

```dart
// CORRECT — font fallback for Arabic
Theme(
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontFamily: 'SFProDisplay'),
    bodyMedium: TextStyle(fontFamily: 'SFProDisplay'),
  ),
  fontFamilyFallback: const [
    'NotoNaskhArabic',
    'Amiri',
    'Scheherazade New',
  ],
)

// WRONG — no Arabic font fallback
Text('مرحبا') // May render incorrectly without Arabic font fallback
```

## Date and Time Formatting

```dart
// CORRECT — locale-aware formatting
import 'package:intl/intl.dart';

String formatDate(DateTime date, BuildContext context) {
  final locale = Localizations.localeOf(context).languageCode;
  final formatter = DateFormat.yMMMMd(locale);
  return formatter.format(date);
}

// CORRECT — Arabic date format
DateFormat.yMMMMd('ar').format(date); // "٩ سبتمبر ٢٠٢٥"

// WRONG — hardcoded English format
DateFormat('MMMM dd, yyyy').format(date); // WRONG — ignores locale
```

## Islamic Terminology Glossary

Use these exact translations consistently across all ARB files:

| English | Arabic | Context |
|---------|--------|---------|
| Prayer | الصلاة | General reference to salah |
| Fajr | الفجر | Dawn prayer |
| Dhuhr | الظهر | Noon prayer |
| Asr | العصر | Afternoon prayer |
| Maghrib | المغرب | Sunset prayer |
| Isha | العشاء | Night prayer |
| Adhan | الأذان | Call to prayer |
| Barakah | بركة | Divine blessing |
| Intention | النية | Niyyah |
| Dhikr | ذكر | Remembrance of Allah |
| Dua | دعاء | Supplication |
| Quran | القرآن | The Quran |
| Sunnah | السنة | Prophet's way |
| Istikhara | استخارة | Seeking guidance |
| Halal | حلال | Permissible |
| Rakah | ركعة | Unit of prayer |

## ICU Message Format for Arabic

```json
{
  "prayerReminder": "{prayer, select, Fajr{الفجر} Dhuhr{الظهر} Asr{العصر} Maghrib{المغرب} Isha{العشاء} other{الصلاة}} في {time}",
  "streakMessage": "{count, plural, =0{لم تبدأ بعد} =1{يوم واحد متتالي} other{{count} أيام متتالية}}"
}
```

## Testing RTL

```dart
// Test widget in RTL mode
testWidgets('renders correctly in RTL', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const TaskScreen(),
    ),
  );
  expect(find.text('مواقيت الصلاة'), findsOneWidget);
});
```

## What This Skill Does Not Cover

- Complex bidirectional text editing (e.g., mixed Arabic/English input fields)
- Arabic-specific accessibility (TalkBack with Arabic)
- Web RTL issues (Flutter web RTL has known quirks; test thoroughly)
- Arabic numerals vs. Eastern Arabic numerals (this app uses Eastern Arabic numerals for Arabic locale)
