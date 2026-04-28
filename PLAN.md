# Fix paywall showing "0 Tokens" by matching App Store Connect product IDs

**The problem**

Your paywall shows "0 Tokens" for every pack because the app is looking for product IDs that don't exist in App Store Connect. Your store has `kinexa_tokens_10`, `kinexa_tokens_30`, and `kinexa_tokens_100`, but the app code was written for older IDs. When it can't find a match, it shows 0.

**The fix**

- Update the app to recognize your three current packs:
  - Starter Token Pack ($3.99) → grants **10 tokens**
  - Plus Token Pack ($9.99) → grants **30 tokens**
  - Power Token Pack ($24.99) → grants **100 tokens**
- Update the "Best Value" highlight to point at the Power pack (100 tokens) and the "Most Popular" badge to point at the Plus pack (30 tokens).
- Clean up the pack subtitles so they just read "Starter Pack", "Plus Pack", and "Power Pack" — no "Save 23%" / "Save 33%" claims.
- Verify the build succeeds.

**Result**

The paywall will correctly display "10 Tokens · $3.99", "30 Tokens · $9.99", and "100 Tokens · $24.99", and purchases will credit the right amount to the user's balance.