# Make AI tokens enforce correctly across the whole app

## What's wrong today

- Only the two main meal-scan flows (AI Describe and Photo Scan) check the token cap. Three other AI features — **Analyze Meal**, **AI Daily Analysis**, and **What should I eat next?** — call the AI without checking or deducting tokens, so they keep working forever even at zero balance.
- When a user runs out, the message says "They refresh tomorrow." That's misleading for free users (who need a subscription or a token pack) and for subscribers who already burned their daily 15 (who can buy a token pack).
- Token deduction order is mostly correct, but I'll lock in the rule: **deduct only after the AI returns a usable result; never deduct on network/processing failures.**

## What I'll change

**1) Gate every AI feature at zero tokens (and deduct only on success)**
- [x] "Analyze" button on a meal in Meal Detail — guards with `canUseAI`, deducts on success in `NutritionViewModel.analyzeMeal`
- [x] "AI Daily Analysis" button on the Nutrition tab — guards with `canUseAI`, deducts on success in `generateDailyInsight`
- [x] "What should I eat next?" suggestion card — guards with `canUseAI`, deducts on success in `generateMealSuggestion`
- [x] Confirmed AI Describe and Photo Scan already deduct only on success
- [x] All failure paths (network error, empty result, exception) do not consume a token

**2) Fix the out-of-tokens copy and add a clear next step**
- [x] Adaptive `limitReachedMessage` in `AIUsageTracker` — free vs premium copy
- [x] `OutOfTokensSheet` replaces single-button alert with **Buy Tokens** + **Subscribe** (subscribe hidden for premium users)
- [x] Sheet wired into `MealDetailSheet`, `NutritionTabView`, and Log Meal flows
- [x] Inline limit banner in `LogMealSheet` now uses `limitReachedTitle` for consistency
- [x] Profile screen shows `totalRemaining` scans + bonus token breakdown

## What stays the same
- Token costs: 1 token per AI action (meal scan, photo scan, meal analysis, daily insight, meal suggestion).
- Pack contents: 50 → 10 tokens, 150 → 30 tokens, 500 → 100 tokens (no change).
- Daily reset at midnight, bonus tokens never expire, success-only deduction.
- No changes to RevenueCat product IDs, pricing, or the Token Store layout.

## How you'll verify it works
1. Burn through your daily scans → tap "Analyze" on a meal → blocks with the new sheet.
2. Tap "AI Daily Analysis" at zero balance → blocked with Buy Tokens / Subscribe options.
3. Buy a token pack → all five AI features work again until the bonus balance hits zero.
4. Force a network failure during a scan → token count stays the same.
