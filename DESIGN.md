# Productive Muslim — Design System (DESIGN.md)

A modern, serene design language combining classical Islamic sacred geometry with precision mobile productivity UX.

---

## 1. Atmosphere & Visual Philosophy

- **Atmosphere**: Deep, tranquil nocturnal sanctuary (*Layl & Fajr*) accented with warm celestial starlight and living botanical emeralds.
- **Tone**: Meditative, focused, uplifting, disciplined, and reverent. Zero clutter or cognitive overload.
- **Anti-AI-Slop Commitment**:
  - No generic blue/purple SaaS gradients.
  - No empty featureless cards; every hero surface carries subtle sacred geometry (Khatam watermarks or celestial arcs).
  - Authentic Arabic typography (`Amiri`) for Quranic ayahs and du'as, paired with high-legibility tabular numbers.

---

## 2. Color Palette & Functional Tokens

### Dark Mode (Primary Nocturnal Sanctuary)
| Token | Hex | Role |
|-------|-----|------|
| `background` | `#0B1512` | Midnight Forest — primary background |
| `surface` | `#13221C` | Deep Emerald Surface — cards and modals |
| `surfaceSubtle` | `#1B2D26` | Elevated containers, chip backdrops |
| `primary` | `#0F4C3A` | Deep Forest Emerald — primary container base |
| `primaryLight` | `#10B981` | Bright Mint — live indicators, active states, progress |
| `secondary` | `#D4AF37` | Warm Celestial Gold — sacred accents, du'a headers, streaks |
| `secondaryLight` | `#E9C349` | Luminous Gold — glowing timer borders, active pills |
| `warning` | `#F59E0B` | Amber Gold — prayer collision alerts, wind-down warnings |
| `borderDark` | `#1E3A2F` | Subdued structural dividers and glass edges |
| `textPrimary` | `#F9FAFB` | High-contrast body and heading text |
| `textSecondary` | `#9CA3AF` | Subtitles, metadata, inactive indicators |

### Light Mode (Morning Daylight Sanctuary)
| Token | Hex | Role |
|-------|-----|------|
| `background` | `#F8FAF9` | Soft Porcelain Light |
| `surface` | `#FFFFFF` | Crisp white cards with soft elevation |
| `surfaceSubtle` | `#F0F4F2` | Subtle light emerald tint for inputs |
| `primary` | `#0F4C3A` | Deep Forest Emerald — high contrast headers |
| `primaryLight` | `#10B981` | Vibrant Mint for successes and highlights |
| `secondary` | `#92600E` | Deep Warm Amber (WCAG AA compliant on light) |
| `borderLight` | `#E5E7EB` | Soft borders |

---

## 3. Geometry, Elevation & Glassmorphism

### Radii Hierarchy
- **Pills & Badges**: `BorderRadius.circular(20)` to `BorderRadius.circular(9999)`
- **Standard Cards & Modals**: `BorderRadius.circular(16)` to `BorderRadius.circular(20)`
- **Preset Chips & Controls**: `BorderRadius.circular(12)`
- **Action Buttons**: `BorderRadius.circular(30)`

### Glassmorphic Surfaces (`GlassContainer`)
- **Backdrop Blur**: `15.0px`
- **Surface Fill**: `alpha: 0.85` on dark (`#13221C`), `alpha: 0.88` on light (`#FFFFFF`)
- **Border**: `1.2px` with subtle opacity (`0.12` to `0.25`)
- **Shadow**: Whisper-soft diffused shadow (`blurRadius: 16`, `offset: (0, 6)`, `alpha: 0.08`)

### Sacred Geometric Watermarks
- **Khatam (Rub el Hizb)**: Concentric 8-pointed star rosette painted via GPU-accelerated `CustomPainter` at `0.08` opacity behind focal indicators (timers, tasbih rings, dials).

---

## 4. Typography Hierarchy

| Style | Font Family | Weight | Size | Role |
|-------|-------------|--------|------|------|
| **Quranic & Du'a** | `Amiri` | Bold / Regular | 18–24pt | Sacred Arabic text, calligraphy banners |
| **Headline Large** | `Manrope` / `Inter` | Bold (w700) | 22–26pt | Screen titles, hero totals |
| **Headline Medium** | `Manrope` / `Inter` | SemiBold (w600) | 16–18pt | Card titles, section headers |
| **Body Primary** | `Inter` | Regular (w400) | 13–14pt | Explanatory text, task descriptions |
| **Caption / Pill** | `Inter` | Bold (w700) | 10–11pt | Badges, tags, categories |
| **Numeric Countdowns** | Tabular Figures | Bold (w700) | 42–48pt | Timers, Tasbih counts, prayer countdowns |

---

## 5. Micro-Interactions & Haptics ("Design Spells")

1. **Physical Scale Spring**: All interactive cards and buttons use `AppPressable` with pressed scale between `0.92` and `0.95`.
2. **Layered Haptic Feedback**:
   - `AppHaptics.selectionClick()` on chip taps, tab switches, and Tasbih bead clicks.
   - `AppHaptics.mediumImpact()` on play/pause timer toggle and checkmark completions.
   - `AppHaptics.heavyImpact()` on session completion and streak milestones.
3. **Pulsing Ambient Glow**: Timers and live prayer tracking wrap focal elements in `PulsingGlow` (`2400ms` sinusoidal breathing).
4. **Equalizer Soundscape Bars**: 4-bar dynamic audio equalizer indicating live ambient background soundscapes.

---

## 6. Mobile & Touch Ergonomics

- **Thumb Zone Compliance**: High-frequency interactive controls (Start/Pause, Tasbih counter, Quick presets, Create FAB) sit within the lower 40% of the screen.
- **Minimum Touch Target**: Every interactive element has a minimum hit-test area of `44x44pt`.
- **RTL & Arabic Mirroring**: Layouts, chevrons, and progress indicators mirror symmetrically when Arabic locale is selected.
