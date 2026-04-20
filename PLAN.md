# App Store submission fixes — legal content, HealthKit, Live Activities, and privacy polish

## Summary of audit

Good news: the app is close to App Store-ready. Bundle ID, icon, launch screen, privacy manifest, IAP + Restore Purchases, and all permission usage strings are already in place. Since the app stores everything on-device with no user accounts, **Delete Account is not required** — which removes the biggest blocker.

Here's what needs fixing:

## ❌ Blocker fixes

- **Fill in real Privacy Policy and Terms of Use text.** Today they render blank on the Profile and Paywall screens, which is a guaranteed rejection. I'll embed a full, properly-worded generic privacy policy and terms of use that cover:
  - On-device storage only (no account, no server sync of personal data)
  - AI features that send text/photos to Google Gemini and Groq for processing
  - Nutrition lookups via USDA
  - Subscription billing via Apple and RevenueCat
  - Motion/pedometer, HealthKit, camera, photos, calendar, and location data usage
  - Contact info, user rights, and last-updated date
  - Apple's standard EULA reference for Terms

## ⚠️ Polish fixes

- **Enable Live Activities properly** — add the flag so the existing workout Live Activity code actually runs on real devices.
- **Remove the unused push notification entitlement** — no push code exists in the app, so keeping the development push flag risks an automatic reviewer flag and a provisioning mismatch at upload. If you want real push later, we can add it back with proper server setup.
- **Verify the subscription test/production key split** so real purchases work for reviewers.

## ✨ New feature: HealthKit integration

Add a clean, minimal HealthKit layer:
- Ask permission the first time the user opens the Workouts or Profile screen (with a clear explainer sheet)
- **Read** steps, active energy, and workouts so stats match the Health app
- **Write** completed Kinexa workouts back to Health (so they appear in the Fitness / Health rings)
- A simple toggle in Profile → Settings to enable/disable Health sync
- Proper usage strings: "Kinexa uses Health data to show your steps and active energy, and saves your completed workouts to Health."
- Add the HealthKit capability to the entitlements file

## Pages / Screens affected

- **Profile → Privacy Policy**: now shows full embedded legal text with sections, scroll, and a last-updated date.
- **Profile → Terms of Use**: full embedded terms text with Apple EULA reference.
- **Paywall**: the Privacy and Terms links under the subscribe button now open populated pages.
- **Profile → Settings**: new "Sync with Apple Health" toggle.
- **Workouts**: first-run Health permission sheet; completed workouts auto-save to Health when sync is on.
- **Home/Stats**: step count and active energy can be pulled from Health for accuracy (falls back to the existing pedometer if Health is off).

## Design

- Legal pages keep the existing card/list aesthetic with clean section headings, body text, and comfortable reading width.
- HealthKit permission explainer uses a native-feeling sheet with a heart SF Symbol, two-line value propositions, and a single primary "Connect Health" button plus a "Not now" secondary.
- No new colors or fonts — everything matches the current Kinexa look.

## What I will NOT change

- No changes to the existing tab structure, onboarding, or workout/nutrition logic.
- No account system added (you confirmed local-only).
- No push notifications added.

After the changes, I'll run a build to confirm everything compiles, then you'll be ready to archive and submit to App Store Connect.