# Calmer meal search + clearer AI meal entry screens

## Food Search (USDA)

- Don't start searching until you've typed at least **3 characters**
- Slower, calmer debounce (~600ms) so it doesn't fire on every keystroke
- Show only **~8 results** instead of a long list
- Rank results so clean, generic foods appear above noisy branded items (branded items still show when clearly relevant)
- Cancel stale searches when the query changes — no flicker or overlap
- Cleaner empty / loading / no-match states:
  - "Start typing to search meals"
  - "Searching meals…"
  - "No matches found"

## AI Describe Screen

- Bigger, more obvious meal description box with a friendlier placeholder
- Helper text: *"Describe your meal in plain language and I'll estimate the calories and macros."*
- Clear primary button "Estimate with AI" — disabled when the box is empty
- Loading state while estimating; friendly error if it fails
- Prevent duplicate requests from repeat taps
- Subtle "2 of 5 AI scans used today" indicator stays visible

## Scan Meal Screen

- Two clearly separated options: **Take Photo** and **Choose from Gallery**
- Short explainer: AI identifies the items and estimates nutrition
- Loading state during analysis; friendly error if the image can't be read
- Subtle daily scan usage indicator

## Confirmation / Save

- Always land on a clean review screen after AI returns
- Edit values before saving
- Save button only active when there's usable data
- No blank success screens or broken-looking empty states

## What stays the same

- USDA search remains
- Meal logging, saving, barcode, manual entry, favorites all unchanged
- Overall visual style and navigation unchanged

