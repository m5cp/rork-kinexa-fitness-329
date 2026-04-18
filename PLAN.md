# Fix onboarding layout and make the paywall the final step

**What's wrong right now**

- Text and buttons are bleeding off the right edge of the screen.
- The Kinexa logo appears on the first onboarding screen — you don't want it there.
- The last onboarding screen currently offers "Log Meal / Start Workout" — you want it to be the subscription screen instead.

**Fixes**

- **Screen 1 (Hook)** — Remove the Kinexa logo. Replace it with a clean icon-based hero (e.g. a subtle SF Symbol badge) with the headline "Train hard. Fuel smarter. Stay consistent." and the Get Started button.
- **Layout** — Rewrite the onboarding so nothing overflows: titles auto-shrink to fit, proper horizontal padding, content scales to the device width. Works on every iPhone size.
- **Screen 2 (Goal)** — Same 4 options (Lose Fat, Build Muscle, Improve Performance, Stay Consistent), tappable cards that fit the screen.
- **Screen 3 (Tracking Style)** — Same 3 options, properly sized.
- **Screen 4 (Subscription)** — This becomes the final step:
  - Headline: "Unlock Kinexa Pro"
  - Short list of Pro benefits
  - **Monthly** and **Annual** options side-by-side, with prices pulled live from App Store / RevenueCat (never hardcoded). Shows free trial text only if Apple returns one.
  - Big primary button: "Start Free Trial" / "Subscribe" (text adapts to what Apple returns).
  - Below the buttons: a clearly visible "**Continue with Free**" link that drops them into the app.
  - Restore Purchases link + legal links.
  - If prices fail to load, the Continue Free link is still shown so the user is never blocked.

**Paywall enforcement (Pro gating)**

- Every Pro feature (AI meal scans beyond free limit, AI workout generation beyond free limit, Coach messages beyond free limit, Full Plan Builder, Advanced Progress, PDF/Calendar Export) checks `isPremium` before running.
- If a non-subscriber taps a Pro feature, the subscription sheet appears. Free trial users and paid subscribers pass through normally.
- Free users keep their existing free allowances — nothing new gets blocked that wasn't already, we just make sure nothing Pro slips through.

**Skip behavior**

- A small "Skip" in the top-right of every screen still works and sends the user straight into the app as a free user.
- Defaults if skipped: goal = Stay Consistent, tracking = Calories + Protein.

**After onboarding**

- Land on Home tab. First-meal hint shown as before.
- Onboarding never shows again (stored locally).

