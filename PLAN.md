# Rename project from Kinexa to Kynexa everywhere

I'll do a complete project-wide rename so the spelling **Kynexa** is consistent everywhere — including folders, the Xcode project, and every line of code. This way if you push to GitHub, everything transfers correctly with the right name.

## What will change

**Project & folder names**
- `KinexaFitness/` folder → `KynexaFitness/`
- `KinexaFitness.xcodeproj` → `KynexaFitness.xcodeproj`
- Test folders renamed to `KynexaFitnessTests` and `KynexaFitnessUITests`
- Entitlements file renamed to `KynexaFitness.entitlements`

**Xcode targets & build settings**
- App target, test target, and UI test target all renamed to `KynexaFitness*`
- Bundle path references and test host paths updated
- Permission descriptions updated to say "Kynexa Fitness" (Health, etc.)

**Code identifiers**
- `KinexaTheme` → `KynexaTheme` everywhere it's used
- `KinexaFitnessApp` → `KynexaFitnessApp`
- All `@testable import KinexaFitness` → `KynexaFitness`
- Any other `Kinexa*` type names, variables, and comments

**User-facing text**
- App display name: **Kynexa Fitness**
- All visible strings throughout the app
- Settings deep-link text ("Settings → Kynexa Fitness → Calendars")
- Disclaimers, paywall copy, onboarding text

**Project metadata**
- `rork.json` app name → "Kynexa Fitness"

## What stays the same
- Your bundle identifier (so TestFlight/App Store builds keep working without resubmitting under a new app record)
- Your RevenueCat product IDs and API keys
- All app functionality, designs, and assets

After the rename I'll run a full build to confirm everything still compiles, then you can safely push to GitHub with the correct **Kynexa** spelling throughout.