# Make Gemini AI Describe & Scan Meal more reliable

Targeted fix to the existing Gemini flow only. No changes to USDA search, barcode, manual entry, or meal logging.

**What will improve**

- AI Describe a meal and Scan Meal photo will succeed far more often, even when the AI response isn't perfectly clean.
- Clearer on-screen error messages when something genuinely fails, instead of silent failure or a vague message.
- Photo analysis will correctly handle JPEG, PNG, and HEIC images rather than assuming every image is JPEG.
- Repeated taps on the Analyze/Estimate button while a request is in flight will no longer fire duplicate requests.

**Changes under the hood (behavior-level)**

1. **Smarter response reading** — if the AI returns extra text or wraps the JSON in ```json code fences, the app will:
  - try a direct read first,
  - then strip code fences and whitespace and try again,
  - then extract the first `{ ... }` block from the text and try once more,
  - only show an error if all three attempts fail.
2. **Correct image type detection** — the app will detect whether the captured/selected photo is PNG, JPEG, or HEIC from the file's signature bytes and tell Gemini the right type. Falls back safely to JPEG if undetectable.
3. **Clearer errors** on the meal logging screen, mapped from the real cause:
  - "AI is not configured — missing Gemini API key."
  - "AI request failed. Check your connection and try again."
  - "AI response couldn't be read. Please try again."
  - "AI didn't return any usable food data. Try rewording or retaking the photo."
  - "Could not analyze this image. Try a clearer, well-lit photo."
4. **No duplicate requests** — the Estimate / Analyze action is ignored while one is already running.
5. **Graceful partial results** — if Gemini returns some foods with missing fields, the app fills safe defaults (0) so the user can review and edit before saving. The existing review/confirm step before saving is preserved.

**What stays the same**

- All current screens, buttons, and navigation.
- USDA search, barcode scanner, manual entry, meal logging.
- The review-before-save confirmation flow (no auto-save).
- The daily AI insight and per-meal AI analysis features continue to work as today but also benefit from the smarter response reading.

