# Kinexa Fitness — Complete Premium Fitness Tracking App

## Features

**Home Tab**
- Personalized greeting with time-of-day awareness (Good morning/afternoon/evening)
- Today's training session hero card with amber gradient and play button
- Quick Start cards for Run, Bike, Hike, and General Fitness with GPS tracking for outdoor activities
- Daily fitness stats: streak, weekly workouts, cardio minutes
- Recent cardio session history
- Daily step counter synced from device pedometer
- Calendar view for browsing past and upcoming sessions

**Workouts Tab**
- "Build My Training Plan" button with smart plan generation
- Browse Functional Fitness templates (AMRAP, EMOM, For Time, Interval, Circuit, Ladder, Tabata) organized by intensity
- Browse Weight Training routines (Beginner/Intermediate/Advanced) with day-based structure
- Browse Cardio programs by skill level and type (treadmill, rowing, running, cycling, etc.)
- Generate session and import PDF buttons
- All workout names are 100% generic — no trademarks, brands, or proprietary names

**Progress Tab**
- Date header with streak badge
- Primary metrics: steps, total workouts, weekly sessions
- Interactive 7-day week strip with color-coded dots (completed/planned/missed/today)
- Activity stats: steps, streak, completed count, average steps
- Quick Start history
- 4-week training bar chart
- AI Insights card (on-device Apple Intelligence when available, graceful fallback)
- Auto-generated performance highlights

**Profile Tab**
- Editable avatar (photo picker or symbol choices) and display name
- Stats row: workouts, streak, cardio minutes
- Subscription management: Upgrade to Pro, Restore Purchases, Manage
- Current training goal with week progress
- Daily reminder toggle with time picker
- Reset options (weekly plan, all data)
- Full legal section: Privacy Policy, Terms, Disclaimer, Risks, EULA, Accessibility

**Onboarding (5 steps)**
- Welcome screen with app branding
- Training setup: focus area + equipment selection
- Schedule: days per week, session length, fitness level
- Legal disclaimer with acknowledge/skip options
- Review & build summary that generates initial weekly plan

**Quick Start Activity Tracker**
- Timer-based tracking for Run, Bike, Hike, General Fitness
- GPS tracking for outdoor activities (Run, Bike, Hike)
- Live elapsed time, distance, and pace display
- Saves duration, distance, date, and type

**Smart Plan Builder**
- Goal selection (General Fitness, Endurance, Power, Speed, Cardio, Hypertrophy)
- Duration (4–16 weeks), frequency (2–6 days), style preference
- Intelligent workout selection avoiding repeats, balancing muscle groups
- Progressive overload and smart rest day distribution
- Full weekly plan with week navigation

**Monetization (RevenueCat)**
- Free tier: basic workout generation, plan access, step tracking, quick start, basic progress
- Premium tier: unlimited plan generation, AI insights, advanced analytics, all routines, premium export/share
- Beautiful paywall triggered after value moments (3, 5, 8, 12 workouts)
- Annual plan highlighted with trial option
- Before vs. after comparison framing
- Restore purchases always available

**Retention & Growth**
- Streak tracking with milestone celebrations at 7, 30, 90 days
- Workout completion banners and recap
- Smart review prompts at positive milestones (max 3 ever, 30-day cooldown)
- Visual share cards for progress and milestones
- Weekly summary notifications, inactivity nudge, daily reminders

**Additional Features**
- Exercise weight memory (remembers last weights used)
- Calendar export via EventKit
- QR code share/scan for workout plans
- PDF export for training plans and progress
- Share cards rendered as images
- "Why Kinexa?" comparison/value page

---

## Design

- **Dark-first theme** with rich custom color palette: deep green-black background (#0C0F0E), dark card surfaces (#141917), green accents (#2E7D52), amber hero (#C4833B)
- Ambient radial glows on backgrounds for depth and premium feel
- Custom tab bar (not system TabView) with filled SF Symbols
- Press-scale button style throughout with spring animations
- Haptic feedback on all key interactions
- Symbol bounce effects on icons
- Numeric text transitions on counters
- Premium card modifier with subtle borders and glow effects
- Hero gradient cards for workouts (amber, green, indigo, pink)
- Clean typography using SF Pro with weight hierarchy
- Full dark mode with light mode compatibility
- Supports both iPhone and iPad layouts

---

## Screens

1. **Splash Screen** — App logo with spring dismiss animation
2. **Onboarding Flow** — 5-step flow with progress capsules
3. **Home Tab** — Greeting, today's session, quick start, stats, recent cardio, steps
4. **Workouts Tab** — Plan builder, browse functional/weights/cardio
5. **Functional Fitness Browser** — Hero cards by intensity (Low/Moderate/High/Extreme)
6. **Weight Training Browser** — Hero cards by level (Beginner/Intermediate/Advanced)
7. **Cardio Browser** — Programs by skill level + cardio by type
8. **Training Plan Builder Sheet** — Goal, duration, frequency, style inputs → generated plan
9. **Progress Tab** — Metrics, week strip, charts, insights, highlights
10. **Profile Tab** — Avatar, stats, subscription, settings, legal
11. **Workout Detail** — Full exercise list with sets, reps, notes
12. **Active Session** — Timer, exercise tracking, weight logging
13. **Quick Start** — Timer with GPS tracking for outdoor activities
14. **Training Calendar** — Calendar view with session markers
15. **Paywall** — Premium upgrade with comparison table and trial
16. **Legal Screens** — Privacy Policy, Terms, Disclaimer, Risks, EULA, Accessibility
17. **Why Kinexa?** — Value comparison page
18. **Workout Completion** — Recap banner with share option
19. **QR Scanner/Share** — Scan or share workout plans via QR

---

## App Icon

- Dark green-to-black gradient background
- Abstract "K" letterform or stylized motion lines suggesting upward movement
- Clean, modern, premium feel matching the app's dark green accent palette
- Minimal and bold — Apple-quality icon design

---

## Platform Extensions

**Home Screen Widget**
- Shows today's workout, current streak, and daily steps
- Small and medium widget families
- Shared data via App Groups

**watchOS Companion App**
- Quick workout timer
- Current stats at a glance
- Quick launch for sessions

**Live Activities**
- Active workout timer on Lock Screen and Dynamic Island
- Shows elapsed time and current exercise during sessions

---

## Compliance & Legal

- All workout names are 100% generic — no trademarks, brands, military terms, or celebrity names
- Disclaimers on every workout browser screen
- Primary disclaimer during onboarding
- No coaching claims, medical claims, or exercise instruction
- Privacy-first: all data stored locally, no tracking
- Full legal screens: Privacy Policy, Terms, Disclaimer, Risks, EULA, Accessibility
- VoiceOver support, Dynamic Type, proper contrast, 44pt tap targets
- Permissions requested contextually with clear explanations (Motion, Location, Notifications, Calendar, Photos)
