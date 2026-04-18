# Add Repeat Meals & Meal Templates to Nutrition

Your nutrition section already has AI photo scan (camera + gallery), confirmation before saving, editable results, and calorie/protein/carbs/fat/alcohol tracking. I'll keep all of that untouched and layer on the missing pieces.

**What's new**

- **Repeat Yesterday's Meal** — one-tap button at the top of the Log Meal sheet that brings back yesterday's meals with their macros preloaded, ready to confirm or tweak.
- **Log Again from history** — every past meal in the meal detail view gets a "Log Again to Today" action that copies it into today's log instantly.
- **Frequent & Recent Foods row** — a quick-tap strip at the top of the Log Meal sheet showing your most-used and most-recent foods for one-tap logging (already partly exists; I'll surface it more prominently).
- **Meal Templates** — save any logged meal as a named template (e.g. "High Protein Breakfast", "Recovery Shake", "Weekend Drinks"). Templates live in a new "Templates" section inside the Log Meal sheet and can be applied with one tap.
- **Serving size adjuster** — when repeating a food or template, a simple slider (0.5x / 1x / 1.5x / 2x / custom) scales the macros before saving.

**Design & behavior**

- Clean, minimal cards matching the existing green Nutrition look — no new dashboards.
- Repeat / template actions take 1–2 taps max.
- Nothing saves until you confirm; duplicate-tap protection on save buttons.
- All preloaded values stay editable, including alcohol.
- Existing manual, barcode, AI text, USDA, and AI photo scan flows are left exactly as they are.
- Scanned / repeated items flow into the same daily log and totals you already have — no parallel tracker.

**Screens touched**

- **Log Meal sheet** — adds "Repeat Yesterday", "Templates" row, and a more prominent Recent/Frequent strip.
- **Meal detail sheet** — adds "Log Again to Today" and "Save as Template" buttons.
- **New Templates picker sheet** — shows saved templates with macros; tap to apply, swipe to delete.
- **New Serving Adjuster sheet** — quick serving multiplier before confirming a repeat/template.

No data migration needed — new fields (template id, last used, times repeated) are optional and won't affect your existing meals.