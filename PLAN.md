# Revamp Pro offering, fix scan limits, restructure Log Meal flow, and polish UI

## 1. Fix AI Scan Limits (Free 5/day, Pro 15/day)

- Unify the AI scan tracking so there's **one** counter: **5 scans per day on Free, 15 per day on Pro** — both reset at midnight.
- Remove the confusing "3 lifetime" free trial system. The home screen pill and the in-meal badge will now show the same number (e.g. "5 left today").
- Bonus token packs continue to work on top of the daily limit.
- Reset logic stays automatic based on local device date.

## 2. Revamp Kinexa Pro Positioning

Remove all "PT" language. New Pro feature tiles:

- **Expanded Workout Library** — full access to Moderate, High, and Extreme functional fitness, all weight training splits, and all cardio plans.
- **Custom Plan Generator** — build 4 / 8 / 12-week training plans across weights, cardio, and functional fitness.
- **Advanced Progress Tracking** — long-term trends, PR history, volume charts, and calendar view.
- **Full Nutrition Suite** — 15 AI food scans per day + macro insights (kept).
- **AI Insights** — on-device intelligence for smarter training (kept).
- **PDF & Calendar Export** — export plans and schedules (kept).

Updated tagline and Pro page copy to focus on planning, tracking, and performance — no coaching / PT language anywhere.

## 3. Free vs Pro Split (Workout Planning & Tracking)

Designed to maximize conversions while keeping free genuinely useful:

**Free tier gets:**

- Log unlimited workouts manually (weights, cardio, functional)
- Full Beginner level in every category (including one new **Basic Bodyweight** functional workout)
- Browse-only access to Moderate/High/Extreme (locked preview)
- Basic weekly progress (current week view)
- 5 AI food scans / day
- Quick Start, Log a Walk, Log Food, Start a Workout

**Pro unlocks:**

- Full functional fitness library (Moderate, High, Extreme)
- Weight training full splits + beginner-to-advanced progressions
- Cardio plans including walking plans and interval progressions
- Multi-week plan generator (4/8/12 weeks)
- Advanced progress tracking (trends, history, calendar)
- 15 AI scans / day + bonus token packs
- Exports + share cards

## 4. Add Basic Bodyweight Workout (Beginner Functional)

- Add a new **"Basic"** intensity tier above Moderate, containing 1 starter bodyweight workout (the previous "Low" tier will be renamed and surfaced). Example: "Foundation 20" — 20-min bodyweight circuit, 4 simple movements (air squats, wall push-ups, glute bridges, marching in place).
- Shown as the first card in the functional fitness browser, with a friendly "Start Here" label.

## 5. Log Meal — Cards Push to Full Screens

Currently tapping a Log Meal card expands a section below the grid. Instead:

- **Scan Food** → pushes to dedicated full-screen "Scan Food" page with camera/gallery, loading, confirmation, and edit-before-save.
- **Barcode** → pushes to full barcode scanner + result confirmation screen.
- **AI Describe** → pushes to full-screen text-entry page with AI analysis.
- **USDA Search** → pushes to full search screen.
- **Favorites** → pushes to favorites list screen.
- **Templates** → already opens full — keep.
- **Repeat Yesterday** → one-tap action (no screen change).
- **Enter Manually** → pushes to existing manual entry screen.

Each pushed screen has its own Cancel/Save flow and returns to Log Meal with the added food.

## 6. Fix Low-Contrast Gray Button

- The disabled **Repeat Yesterday** card (when no meals yesterday) currently shows light gray + white text → unreadable.
- Replace with a soft **indigo/blue** muted gradient that keeps white text clearly legible, with a subtle "No meals yesterday" helper label.
- Apply same fix anywhere else white-on-light-gray appears.

## 7. Elevated Card Styling (Match Progress Page)

- Apply the **elevated shadow style** from the Progress page cards to:
  - Home screen action bubbles (Log a Walk, Log Food, Start a Workout)
  - Log Meal grid cards (Scan Food, Barcode, AI Describe, USDA Search, Favorites)
  - Functional fitness intensity cards
- Cards will have a consistent soft drop shadow, crisp rounded corners, and a subtle border for depth — matching the Progress page look.

## 8. Stability & Data

- Keep all existing nutrition data, templates, and favorites intact.
- Migrate any existing lifetime-scan state gracefully (treat users as starting fresh on the new 5/day counter).
- No new dependencies. No changes to recipe code (already removed).

