# Add lightweight 4-screen onboarding to Kinexa Fitness

## Overview
Replace the existing long 5-step onboarding with a fast, fully-skippable 4-screen flow that gets users into the app in under 30 seconds. Keeps all existing nutrition, workouts, and RevenueCat logic untouched.

## Features
- Shows only on first launch — afterward goes straight into the app.
- Every screen has a **Skip** button in the top-right that drops the user into the app immediately.
- Stores the user's goal and tracking preference so other parts of the app can use them later.
- If the user skips, sensible defaults are set (Stay Consistent + Calories + Protein).
- No personal body data, no gender, no forced steps.
- After onboarding, the user lands on the Home tab with a gentle nudge to log their first meal or start a workout.

## Screens

**Screen 1 — Hook**
- Title: "Train hard. Fuel smarter. Stay consistent."
- Subtitle: "Track workouts, log meals, and stay on track without overthinking it."
- Primary button: **Get Started**
- Top-right: **Skip**

**Screen 2 — Goal**
- Question: "What are you focused on right now?"
- Options as tappable cards: Lose Fat · Build Muscle · Improve Performance · Stay Consistent
- Light haptic on tap, selection auto-advances
- Top-right: **Skip**

**Screen 3 — Tracking Style**
- Question: "How do you want to track meals?"
- Options: Calories Only · Calories + Protein (default) · Full Macros
- Top-right: **Skip**

**Screen 4 — Instant Value**
- Title: "You're ready to start."
- Subtitle: "Log your first meal or start your first workout."
- Two primary buttons: **Log Meal** · **Start Workout**
- Secondary: **Explore App**

## Design
- Dark Kinexa theme, matching the rest of the app (same background, accent gradient, typography).
- Large bold title, soft secondary subtitle, generous spacing.
- Slim progress bar across the top of screens 2–3 only.
- Option cards use rounded corners, subtle borders, and a glowing accent outline when selected.
- Smooth spring transitions between screens.
- Bottom CTA buttons use the existing hero gradient for consistency.

## Soft Paywall
- The existing upgrade screen stays as-is and is **not** shown during onboarding.
- It only appears after a value moment (meal scan, AI feature use) — unchanged from current behavior.
- Already loads dynamic RevenueCat pricing, has Restore Purchases, and a close button.

## Skip & Data Behavior
- Skipping from any screen immediately enters the app.
- Defaults applied if skipped mid-flow: goal = Stay Consistent, tracking = Calories + Protein.
- Onboarding completion flag saved locally so it never shows again.
- Partial selections are preserved if the user skips mid-flow.

## Post-Onboarding
- User lands on the Home tab.
- A subtle one-time highlight card suggests "Log your first meal" or "Start a workout".

## What stays untouched
- Nutrition tracking, workout tracking, navigation, liquid-glass tab bar, floating chat button, RevenueCat integration, splash screen, and all existing views remain exactly as they are.