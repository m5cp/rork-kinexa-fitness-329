# Add how-to descriptions to every exercise across the app

## What will change

Every exercise in Kinexa — weights, functional fitness, and cardio — will have a clear "how to do it" guide attached. Anywhere an exercise appears (workout generator results, planned workouts, manual routines, pre-made plans, body part browser, cardio browser), users can tap it to see instructions, form tips, and alternatives.

## Features

- **Tap any exercise, anywhere, to see how to do it.** Works in the Quick Workout Generator results, today's planned workout, body part exercise lists, pre-made routine day views, functional fitness browser, and cardio browser.
- **Consistent guide format** for every exercise:
  - Short summary of the movement
  - Numbered step-by-step how-to
  - 2–3 form tips / common mistakes to avoid
  - Suggested alternatives (swaps if you don't have the equipment or want variety)
  - Primary muscles worked
- **Cardio entries** get a "how to perform it well" guide — pacing, effort level, warm-up/cool-down notes, and alternative options.
- **Generator results show a small "i" / chevron** on every movement row so users know they can tap for details. A tap opens a clean sheet with the guide.
- **Planned workout cards** (today's workout) get the same tap-to-view behavior for each listed movement.
- Works offline — all guidance is built into the app, no network needed.

## Design

- A single **Exercise Guide sheet** used everywhere: large exercise title, muscle-group tag, clean numbered steps, a tips section with a lightbulb icon, and an "Alternatives" section with tappable chips.
- Medium-height sheet that scrolls if needed, with a grabber so users can drag it away.
- Subtle chevron or small info icon on every exercise row across the app to signal tappability.
- Dark-mode friendly, uses system typography and colors, matches existing Kinexa card styling.

## Coverage

Descriptions will be authored for:

- All 90+ weight-training exercises (chest, back, shoulders, biceps, triceps, legs, glutes, core, full-body)
- All functional fitness movements used in WODs and generated workouts
- All cardio activities (running, cycling, class workouts, low impact, outdoor)
- Any movement referenced by the Quick Workout Generator or pre-made routines

If a user-added custom exercise has no built-in guide, the sheet shows a friendly "No guide available for this custom exercise" state instead of crashing or looking broken.

## Where it shows up

- **Quick Workout Generator result screen** — each generated movement is tappable
- **Today's planned workout card** — each movement is tappable
- **Body Part → exercise list** — each exercise is tappable
- **Pre-made routine day detail** — each exercise is tappable
- **Functional Fitness workout detail** — each movement is tappable
- **Cardio by Type list** — each cardio workout is tappable (also fixes the text-cutoff + no-tap issue previously reported)
- **Manual routine builder exercise rows** — tappable

