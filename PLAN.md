# Auto-verify AI food logs against USDA for accurate numbers

## How it will work

When you log a meal by photo or text, the AI identifies the foods as it does today. In the background — at the same time — the app quietly looks up each identified food in the USDA nutrition database. If a confident match is found, the app silently swaps in the verified USDA numbers. If not, it keeps the AI's estimate.

No badges, no labels, no USDA branding. Just better numbers.

## Speed guarantees

- The USDA lookups run **in parallel** with each other (all foods at once), not one-by-one.
- A **2-second cap** per food — if USDA is slow or unreachable, the app instantly falls back to the AI estimate so you're never stuck waiting.
- Results are **cached in memory** for the session, so logging "banana" twice only hits USDA once.
- The search is tuned to prefer common/whole-food database entries first (faster, more reliable matches than branded items).

## How it decides if a match is "confident"

- The food name from the AI is normalized (lowercased, common words like "grilled", "fresh", "cooked" stripped for matching).
- A USDA result only wins if its name clearly contains the food's core term (e.g. AI says "grilled chicken breast" → matches USDA "Chicken, breast").
- The AI's portion size (e.g. "150g", "1 cup") is preserved — only the per-gram nutrition profile is replaced, so the calories scale to what you actually ate.
- If USDA's numbers are wildly off from the AI's (>3× difference), it's treated as a bad match and the AI numbers stay.

## What you'll notice

- **Nothing visually different.** No new UI, no popups, no badges.
- Logged meals will have slightly more accurate calorie and macro numbers for common foods (fruits, vegetables, meats, grains, dairy).
- Logging feels the same speed as today — the extra lookup happens while the AI result is being processed.
- If USDA is down or your API key is missing, logging continues to work exactly as it does now.

## Scope

- Applies to **photo logging** and **text logging**.
- Does **not** change barcode logging (those already use a product database).
- Does **not** change the manual USDA search tab (that stays as-is for direct searches).

