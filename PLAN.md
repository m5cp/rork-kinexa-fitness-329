# Add Gemini diagnostic button to Scan screen

## What I'll add

A small **"Run Gemini Diagnostic"** button on the Scan screen that helps us pinpoint exactly why Gemini isn't working — without needing TestFlight.

## What it does

When tapped, it runs three checks in order and shows the results right on screen:

1. **Key check** — Confirms the Gemini API key is present (shows ✅ or ❌, plus the key length so we know it's not empty/truncated).
2. **Text-only ping** — Sends a tiny "say hi" request to `gemini-2.5-flash` and shows the raw HTTP status code and response body.
3. **Vision ping** — Sends a 1×1 pixel image to the same model and shows the raw status + response.

From the three results we'll instantly know:
- ❌ on step 1 → the key isn't being read
- ❌ on step 2 → auth or model issue (bad key, wrong model name, billing)
- ✅ step 2 but ❌ step 3 → vision-specific problem (image format, region, quota)
- ✅ all three → Gemini works and the bug is elsewhere in our scan flow

## Design

- Button placed discreetly at the bottom of the Scan screen (not in the main flow).
- Tapping opens a sheet that streams results live as each check completes, with color-coded status icons and a copyable raw-response block for each step.
- Clean, monospaced output so HTTP errors are easy to read.

## Shipping to TestFlight

The entire button and diagnostic sheet will be wrapped so it **only appears in development builds** — testers and App Store users will never see it. When we're ready to ship, nothing needs to be removed manually; it's automatically hidden in release builds.
