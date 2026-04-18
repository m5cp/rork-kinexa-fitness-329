# Remove style editor and make Today's Session empty until a plan is chosen

## What will change

**Remove the Style Editor**

- Take out the style editor entirely — it wasn't applying changes and only added clutter.
- The app will continue to fully support System, Light, and Dark mode automatically using Apple's native appearance settings.
- Any entry point to the style editor (from Profile/Settings) will be removed cleanly so nothing feels broken.

**Today's Session empty state**

- When no workout plan has been generated and no session has been chosen, Today's Session will no longer show a default/suggested workout.
- Instead, it will show a clean, friendly empty state with:
  - A subtle icon
  - Headline: "No session yet"
  - Supporting text: "Generate a plan or pick a workout to get started."
  - Two clear buttons: **Generate Plan** and **Browse Workouts**
- Once the user picks a session or generates a plan, Today's Session fills in as it does now.

**Polish**

- Empty state uses the same elevated card styling as the rest of the app for consistency.
- Works seamlessly in Light, Dark, and System appearance.
- No changes to nutrition, tracking, progress, or any other area.

