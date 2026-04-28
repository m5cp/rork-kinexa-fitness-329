# Make HealthKit usage App Store-compliant

Apple commonly rejects fitness apps for HealthKit issues. I'll add the safeguards reviewers look for so the next submission passes cleanly.

**What will change**

- **Pre-permission explainer screen**: Before the system Health permission popup appears, the app will show a friendly screen explaining exactly what data is read (steps, active energy, workouts), what data is written (completed workouts), and why. Reviewers reject apps that jump straight to the system prompt.
- **Tighter, specific permission text**: The Health usage descriptions will be rewritten so each one names the specific data types and the user-facing benefit, instead of a generic sentence.
- **Health data stays on device**: A short note will be added in the Privacy section of the Profile tab stating that Health data is never uploaded to our servers, never used for advertising, and never shared with third parties — this is required Apple language.
- **Visible disconnect control**: The Profile screen will get a clear "Manage Health Access" row that opens iOS Settings so users can revoke permissions at any time, plus a toggle to stop syncing without revoking.
- **Graceful denial handling**: If the user denies Health access, the app will show a calm message explaining the feature still works manually, with a button to re-open Settings — no nagging, no blocking.
- **No Health data in exports/AI**: Health-derived numbers (steps, active energy from Apple Health) will be excluded from PDF exports and AI prompts, since Apple forbids transmitting HealthKit data off-device for non-health purposes like AI features.
- **Privacy Policy link**: A "Privacy Policy" row will be added in Profile (required by App Review for any app using HealthKit).

**What the user will see**

- **Health Permission screen** (new): Heart icon, title "Connect Apple Health", three rows showing "We read: Steps, Active Energy, Workouts", "We write: Workouts you complete", "Your data: Stays on your device". A primary "Connect" button and a secondary "Not Now" button.
- **Profile → Privacy & Health section** (new): Three rows — "Manage Health Access" (opens Settings), "How we use Health data" (sheet with the Apple-required disclosures), "Privacy Policy" (opens link).
- **Denied state**: If Health is off, the Health row in Profile shows "Access denied — Open Settings" instead of a dead toggle.

**Design**

Matches the existing Kynexa look — same card style, same accent color, SF Symbols (`heart.text.square.fill`, `lock.shield.fill`, `arrow.up.right.square`), same typography. The explainer screen uses a clean centered layout with a soft red-tinted heart icon at the top, consistent with the current Health row styling.

After this is in place I'll send a fresh build to TestFlight.