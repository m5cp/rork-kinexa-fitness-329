# Don't count failed AI requests against the user

## The issue

Right now the meal scan already plays it safe — if the AI call fails, no scan is deducted. But the **Coach chat does the opposite**: it counts the message *before* the AI responds, so when the network drops or the model errors out (like the "I couldn't reach the coach right now" screenshot), the user still loses 1 of their 5 daily messages.

## How the fix protects the user

**Coach chat**
- Only count a message after the coach actually replies successfully.
- If the request fails (network error, AI service down, timeout, empty reply), the message is free — the daily counter stays exactly where it was.
- The "I couldn't reach the coach right now" message still appears so the user knows what happened, but their quota is untouched.

**Meal scan & photo analysis**
- Already correct — confirm and keep that behavior. No token or daily scan is consumed unless the AI returns a real result.

**Bonus tokens (paid)**
- Same rule applied across the board: a purchased token is *only* spent on a successful AI response. Any internal/AI/network failure is on us, not the user.

**What the user sees on a failure**
- A small, friendly inline note ("Didn't go through — that one's on us, try again") instead of silently losing a credit.
- The remaining count visible in the header (e.g. "4 of 5 messages left today") will not tick down on errors.

## Principle going forward

Every AI-powered feature in the app follows one rule: **charge on success, never on failure**. Increment counters and deduct tokens *after* the AI returns valid content — never before the call, and never inside an error path.