# Add Light, Dark & System appearance with per-palette light variants

## What you'll get

A premium appearance system that respects Apple's standards — the app can follow the device setting, or be forced Light or Dark, and every color palette will look polished in both modes.

## Features

- **Appearance toggle** with three options: System, Light, and Dark
- The toggle lives in **two places**: at the top of the Style Editor, and inside Profile → App settings
- **System** mode automatically follows the iPhone's own Light/Dark setting and flips instantly when the user changes it in Control Center
- **All 8 color palettes** (Ocean, Sunset, Berry, Sage, Slate, Ember, Lavender, Midnight) get a hand-tuned Light variant — soft off-white backgrounds, proper card tints, readable text, and accent colors adjusted for contrast on light surfaces
- Switching appearance or palette animates smoothly with a subtle haptic tap
- Text, icons, dividers, and card surfaces throughout the app adapt correctly — no more stark white text on a white background

## Design

- **Style Editor** gets a new section at the very top called "Appearance" with a clean three-option segmented control (System / Light / Dark), each with an SF Symbol icon (iPhone, sun, moon)
- Below it, the existing palette grid now shows each palette's preview in the currently-selected appearance, so users see exactly what they'll get
- **Profile → App** gets a new row "Appearance" that shows the current choice and opens a compact picker
- Light mode uses warm off-whites (not pure white) for a premium editorial feel, with soft shadows and properly tinted cards — inspired by Apple Fitness, Health, and Journal
- Dark mode stays exactly as it is today, so nothing looks different for current users
- System mode badge shows a tiny live indicator so users know it's tracking their device

## Screens touched

- **Style Editor** — new Appearance section at top, palette previews become appearance-aware
- **Profile → App settings** — new Appearance row with inline picker
- **Every screen in the app** — backgrounds, cards, text, borders, and dividers automatically adapt because the theme system now returns the right color for the active mode

## Stability & safety

- The existing dark experience is preserved byte-for-byte as the Dark variant
- Your saved palette choice carries over — no reset, no lost preferences
- All hardcoded white text is replaced with adaptive text colors in one pass so nothing ends up invisible in Light mode
- No new dependencies, no architectural changes to nutrition, workouts, or any other feature

