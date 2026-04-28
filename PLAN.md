# Fix PDF colors, add Log Sleep button, and sync data across all tabs

**The root cause of the sync issue:** Each screen (Home, Nutrition, Profile, Activity Journal, Journal Day Detail) was creating its own separate copy of the nutrition and rings data. So logging a meal on Home updated Home's copy only, and Nutrition still showed empty until you logged again there. Same for water, sleep, and workouts.

### Fixes

**1. One shared source of truth for everything**

- Create one shared Nutrition store and one shared Reflection Rings store at the top of the app, and pass them down to every screen.
- Now logging a meal, water, sleep, or workout anywhere instantly updates Home, Nutrition, Workouts, Progress, and the Reflection Rings — no double-logging.

**2. Add a Log Sleep button on Home**

- Add a fourth quick action tile so Home has: Log Cardio · Log Meals & Water · Log Sleep · View Workout.
- Tapping Log Sleep opens the same sleep check-in sheet used by the Rest ring.

**3. Fix the white-on-white PDF export**

- The daily journal PDF was using system text colors that turned white in dark mode, making the PDF unreadable.
- Switch all PDF text and lines to fixed black/dark gray and the page background to white so the PDF always looks the same — black text on a white page — when shared, printed, or opened in Files.

