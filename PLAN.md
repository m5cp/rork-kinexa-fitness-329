# Add water logging, rework Start Workout card, add Quick Workout generator, fix tokens page

## Home screen

**Log Meals tile becomes "Log Meals & Water"**

- The middle tile in the quick action row changes its label to **Log Meals & Water** with a fork + droplet icon.
- Tapping it opens a small submenu (action sheet) with two options: **Log Meal** and **Log Water**.
- **Log Meal** opens the existing meal logging sheet.
- **Log Water** opens a quick-add sheet with 8 oz / 16 oz / 24 oz buttons and a custom amount field, same behavior as the existing Nutrition tab water tracker.

**Hydrate ring → tappable water quick-add**

- On the Reflection Rings card and the Rings Detail sheet, tapping the **Hydrate** row opens the same water quick-add sheet (instead of silently adding 8 oz).
- Users can choose 8 / 16 / 24 oz or type a custom amount.

**"Start a Workout" tile becomes "View Workout"**

- Third tile in the quick action row is renamed **View Workout** with a calendar/dumbbell icon.
- Tapping it opens a sheet showing **today's planned workout** (from the weekly plan or today's FunctionFitness WOD if no plan).
- The sheet shows the workout title, movements, and duration, plus:
  - **Start Workout** button (launches the active session)
  - **Reset Today's Workout** button — clears today's logged progress and opens the planner so the user can regenerate a new workout for today.
- If no workout is scheduled, the card shows "No workout today" with a button to open the planner.

**Reset from the planner / manual builder**

- The "Reset Today" action is also available inside the Training Plan screen and the Manual Build screen, so today's card can be reset from either place.

## Quick Workout generator

The **Quick Workout** tile on the Workouts tab now opens a small setup screen before generating:

1. **Choose type** — three large tiles: Functional Fitness, Free Weights, Cardio.
2. **Choose duration** — preset chips: **15 / 30 / 45 / 60 min**.
3. **Generate** button — creates a workout matching the type and time.
4. On the result screen, a **Refresh** button generates a different workout using the same type + duration. The user can also tap **Log Workout** to save it.

## Token page

- Bottom info section updated to:
  - ✓ Requires an active subscription
  - ✓ Tokens extend your daily scan limit
  - ✓ Tokens never expire
- If the user is not subscribed, the token packs are shown but purchase is gated — tapping a pack prompts them to subscribe first, with a clear "Subscribe to unlock tokens" message.
- Subscribers can buy tokens freely; tokens are used automatically once the daily scan limit is hit.
- "Unable to load token packs" retry state is preserved.

## Design notes

- Water quick-add sheet matches the existing Nutrition tab styling — blue droplet, rounded amount buttons, medium detent.
- View Workout sheet uses the same card styling as the existing WOD detail view for visual consistency.
- Quick Workout setup uses the same colored tiles (orange / purple / pink) already on the Workouts tab.
- All haptics and press animations kept consistent with the rest of the app.

