# Remove Nutrition Partner, fix Support contact, hide PT-style routines

## Changes

**Profile screen**

- Remove the "Nutrition Partner" row and the entire "Support & Partners" section header tied to it
- Replace "Contact Support" with a clean support entry that opens a sheet

**Support sheet (new)**

- Tidy sheet showing a mail icon, "Contact Support" title, and the email **[contact@m5cairo.com](mailto:contact@m5cairo.com)**
- Tap-to-copy the email (with haptic + "Copied" confirmation)
- Primary "Send Email" button that opens the Mail composer
- "Done" button to dismiss

**Hide PT-style routines**

- Suppress drill-based routines (Preparation Drill, Conditioning Drill, Sprint, Recovery Drill, and other Army/PT-style templates) from appearing anywhere in the app — Home scheduled card, Workouts library, plan generation, and calendar day details
- Filter these out in the workout generator and any curated template lists so users only see standard fitness workouts
- Remove the "On-Duty Conditioning Drill" style session currently showing on the Home screen
- Keep the underlying plan/workout framework intact so the rest of the app continues to work

## Out of scope

- No changes to subscription, tokens, nutrition logging, or progress screens
- Renaming every "PT" label app-wide is not included — only the drill-style routine content is hidden

