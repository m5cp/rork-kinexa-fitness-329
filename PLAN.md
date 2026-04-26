# Stop the Motion & Fitness permission popup on launch

**What's happening**

The popup you're seeing is iOS asking for **Motion & Fitness** access (used to read your daily step count from the iPhone's motion sensor). It's not HealthKit — HealthKit is only used later when you explicitly tap "Sync to Apple Health" on the Profile screen.

The reason it's showing up right when the app opens is that the app is asking for step data the moment the Home screen loads, which triggers the system prompt.

**Fix**

- Stop asking for Motion & Fitness access automatically when the app launches.
- Show steps as "—" (or 0) until the user does something that actually needs them.
- Only request access the first time the user taps the Move ring or opens the steps card on the Progress screen — with a clear in-app explanation first ("Allow Motion & Fitness so we can count your steps"), and then the system prompt.
- If the user declines, the app keeps working normally and just shows manual logging instead of step tracking.

**Result**

When you open the app fresh, no permission popups appear. Permissions only appear when the user takes an action that genuinely needs them, and only once.