# Keep tab bar visible everywhere + full app speed-up

## What you'll notice

**Navigation**
- The bottom tab bar stays visible on every screen, even deep inside premade workouts, routine editors, exercise pickers, meal logging, and detail views.
- Every screen that goes more than one level deep gets a clear back button in the top-left so you always have a way out — plus you can tap the current tab icon to jump straight back to the top.
- Deep pages slide in as proper pushed pages instead of popping up as full-height sheets that cover the tab bar.
- A few screens that truly need to be modal (quick confirmations, sharing) stay as sheets, but they sit above the tab bar so Home is always one tap away.

**Speed & smoothness**
- The premade workout editor opens instantly and responds immediately when you tap swap, add, or remove. Right now it rebuilds the whole list on every tap — this will be fixed so only the changed row updates.
- The exercise swap picker loads the full library lazily (only what's on screen), so scrolling is smooth even with hundreds of exercises.
- Shadows on elevated cards are rendered more efficiently — same look, but lighter on the GPU so scrolling stays at 60fps on older devices.
- Large lists on Home, Workouts, and Progress switch to lazy loading so they only render what's visible.
- Heavy data (routines, cardio programs, exercise library, food database) loads once and stays cached instead of being rebuilt every time a screen appears.
- Tab switches no longer reload their content — each tab keeps its state so returning to it is instant.
- Animations are tuned to shorter, snappier springs so the app feels more responsive.
- Images and icons get proper sizing so nothing overflows or causes layout thrash.

## Screens being touched

- **Premade Routines** — editor becomes a pushed page with a back button; row updates are instant
- **Exercise Swap / Add picker** — pushed page with back button; lazy-loaded list
- **Manual Routine Builder** — pushed page with back button
- **Cardio Programs** — detail views pushed instead of sheeted
- **Meal Log & Food Detail** — detail views pushed with back button
- **Workout Detail / Edit** — pushed with back button
- **Home, Progress, Profile** — lazy loading pass, lighter shadows, cached data

Tab bar remains pinned at the bottom throughout. You can always tap Home or any other tab to escape a deep flow in one tap.