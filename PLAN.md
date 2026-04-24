# Home & nutrition cleanups, AI photo safeguards, and safety disclaimers

## Home screen

- Rename the "Log a Walk" quick action to **"Log Cardio"** so it matches what it actually opens.
- Give Rowing a proper icon in the Log Cardio picker (fix the missing symbol).
- On the **View Workout** sheet, add a clear **"Change Workout"** button that lets the user pick a new workout for today from: **Cardio, Weights, Functional Fitness,** or **Manual Build**. The chosen workout is saved as today's plan and can be logged normally. Keep the existing reset flow but behind a less prominent secondary option.

## Log Meal sheet

- Remove the **Food Search** tile entirely.
- Remove the **Favorites** tile (the big orange one).
- Rebalance the grid so the remaining tiles (Scan Food, Barcode, AI Describe, plus Repeat Yesterday / Templates / Enter Manually) fill the page evenly with no empty gap.

## Profile

- Tapping the **"No Goal Set"** card now opens the **Nutrition Profile builder** (instead of Plan My Training).
- Remove the **"Sync with Apple Health"** row and its toggle entirely. Rebalance the App section so it looks clean.

## Nutrition Profile

- Add a clearly visible disclaimer banner at the top: *"These are estimates only. This is a tracking tool — not medical or nutrition advice. Do not make fitness or dietary changes without consulting a physician and registered nutritionist."*
- Keep the calorie/macro math as-is, but label the results as "Estimated Targets."

## App-wide safety disclaimers

Add short, clear disclaimers in the spots where a user might misread guidance as prescription:

- Top of Workouts tab, Plan My Training, and the Quick Start flow: *"Kinexa is a tracking & accountability tool. Always consult a physician before starting or changing a workout routine."*
- Top of Nutrition tab: *"Tracking tool only — not medical or nutrition advice."*

## AI Scan Food improvements

- Add a **"Tips for a good photo"** helper section on the Scan Food flow with quick do/don't guidance: good lighting, plain background, food centered, one plate at a time, avoid blur/glare, include the whole plate.
- **Don't charge a scan** if the AI fails to analyze the photo — usage is only counted on a successful result.
- When analysis fails, show **specific, actionable feedback** (e.g. "Image too blurry — try again in better light", "Couldn't identify any food — try a plainer background or a closer shot", "Multiple items detected — photograph one plate at a time").
- After **10 failed photo scans**, photo scanning is **locked for 24 hours**. The user is clearly redirected to **AI Describe** as an alternative, with a message: "Photo scanning is paused for 24 hours. Try AI Describe instead, or try photo again tomorrow." Successful scans reset the failure counter.

## Not changing

- No visual theme or color changes beyond what's listed.
- Existing Apple Health entitlement text in legal screens stays (it's historical/legal context only); only the in-app toggle row is removed.

