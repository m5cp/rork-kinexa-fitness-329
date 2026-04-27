# Make AI tokens enforce correctly across the whole app

## What's wrong today

- Only the two main meal-scan flows (AI Describe and Photo Scan) check the token cap. Three other AI features — **Analyze Meal**, **AI Daily Analysis**, and **What should I eat next?** — call the AI without checking or deducting tokens, so they keep working forever even at zero balance.
- When a user runs out, the message says "They refresh tomorrow." That's misleading for free users (who need a subscription or a token pack) and for subscribers who already burned their daily 15 (who can buy a token pack).
- Token deduction order is mostly correct, but I'll lock in the rule: **deduct only after the AI returns a usable result; never deduct on network/processing failures.**

## What I'll change

**1) Gate every AI feature at zero tokens (and deduct only on success)**
- Add the same token check + deduct-on-success pattern to:
  - "Analyze" button on a meal in Meal Detail
  - "AI Daily Analysis" button on the Nutrition tab
  - "What should I eat next?" suggestion card
- Confirm AI Describe and Photo Scan already deduct only on success (they do — leaving as-is).
- If a call fails (network error, empty result, exception), no token is consumed.

**2) Fix the out-of-tokens copy and add a clear next step**
- Replace the "refresh tomorrow" message with smarter text that adapts to the user's state:
  - Free user, zero tokens → "You've used all your free AI scans. Subscribe for 15/day or buy a token pack."
  - Subscriber, daily limit hit, zero bonus tokens → "You've used today's 15 AI scans. Buy a token pack to keep going, or come back tomorrow."
  - Subscriber, still has bonus tokens → silent pass-through (already working).
- Replace the single "OK" alert with a sheet that shows **two buttons side-by-side**: **Buy Tokens** (opens Token Store) and **Subscribe** (opens paywall). Free users see both; subscribers see only **Buy Tokens**.
- Update the Profile screen scan-counter copy and the inline limit banners in Log Meal so they read consistently.

## What stays the same
- Token costs: 1 token per AI action (meal scan, photo scan, meal analysis, daily insight, meal suggestion).
- Pack contents: 50 → 10 tokens, 150 → 30 tokens, 500 → 100 tokens (no change).
- Daily reset at midnight, bonus tokens never expire, success-only deduction.
- No changes to RevenueCat product IDs, pricing, or the Token Store layout.

## How you'll verify it works
After I build, you can test:
1. Burn through your daily scans → tap "Analyze" on a meal → it should now block with the new sheet (before, it would silently call AI).
2. Tap "AI Daily Analysis" at zero balance → blocked with Buy Tokens / Subscribe options.
3. Buy a token pack → all five AI features work again until the bonus balance hits zero.
4. Force a network failure during a scan → token count stays the same.