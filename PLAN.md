# Strengthen AI nutrition verification and remove all USDA branding

The AI meal flow already quietly cross-checks Gemini estimates against the nutrition database behind the scenes. This plan tightens that verification and strips every visible mention of "USDA" so the app no longer implies any affiliation.

**How the AI flow will behave**

- When you Describe a meal with AI or Scan a meal photo, the AI identifies the items and produces a first estimate.
- The app then silently looks up each item in the nutrition database and, when a confident match is found, replaces the macros with the more accurate values.
- If a lookup is slow, missing, or returns nothing usable, the AI estimate is kept so you always see a result.
- One bad lookup never blocks the rest — each item is verified independently.
- The review screen looks exactly the same for every item (no source labels, badges, or technical details). You can still edit any value before saving.

**Reliability improvements**

- Verification has a short time limit per item so the confirm screen never stalls.
- Duplicate taps while verifying are ignored.
- If the network is down, the flow falls back cleanly to the AI estimate.
- Existing manual entry, barcode scanning, food search, favorites, and meal logging stay exactly as they are.

**Removing USDA references across the app**

- Remove the "Food Data Source" screen in Profile that credits USDA.
- Remove the "Food Data Source" row from the Profile settings list.
- Rename the in-app food search from anything USDA-flavored to a neutral "Food Search" / "Nutrition Database" everywhere it appears.
- Replace the "Verified nutrition database" empty-state copy with neutral wording (e.g. "Search our nutrition database").
- Remove the USDA mention from the Privacy / Legal screen's third-party services section.
- Remove USDA wording from internal AI prompts so Gemini is no longer told to base estimates on USDA data.
- Keep the underlying lookup service working — only the user-visible branding changes.

**What stays the same**

- Save flow, confirmation screen, and editing behavior are unchanged.
- Daily AI scan limits, token store, and subscription gating are untouched.
- Barcode scanning via Open Food Facts is unchanged.

