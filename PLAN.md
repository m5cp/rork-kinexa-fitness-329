# Add daily AI food scan limit with subtle usage indicator

Add a simple, reliable daily cap on AI food scans (photo + AI describe) without touching the rest of the nutrition flow or existing AI usage system used for recipes.

**How it works**

- Each day, you get a set number of AI food scans (default: **5 per day**).
- A small counter shows "3 / 5 AI scans used today" under the Scan Food and AI Describe buttons in the Log Meal sheet.
- The counter resets automatically at midnight (based on your phone's local date).
- When you run out, the Scan Food and AI Describe buttons show a friendly message: "You've used all 5 AI scans today. They refresh tomorrow."
- Below the message you get instant alternatives:
  - Enter manually
  - Repeat yesterday's meals
  - Scan barcode
  - USDA search
  - Favorites

**Where it shows up**

- Log Meal sheet → Scan Food card and AI Describe card get a subtle "X left today" pill.
- When the limit is hit, the photo/describe input sections show the friendly message and fallback buttons (keeping all existing alternatives visible).
- Everything else in nutrition stays exactly the same.

**Behind the scenes**

- Saved locally on device (no backend, no account required).
- Safe defaults if anything fails to load — never crashes the nutrition section.
- The daily limit value is a single setting that's easy to change later (e.g. raise to 10, or make it unlimited for premium users in the future).
- Structure is ready for a future free-vs-premium split, but no paywall is added now.

**What doesn't change**

- Existing manual entry, barcode scan, USDA search, text-describe flow, favorites, meal templates, repeat meals, and recipe generation all keep working as they do today.
- The existing AI usage tracker (used for recipes) is untouched — this is a separate, simpler daily counter just for food scans.

