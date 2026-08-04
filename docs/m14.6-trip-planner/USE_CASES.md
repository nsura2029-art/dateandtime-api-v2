# Long Weekend Trip Planner — M14.6 Design

## 1. User Intents & Actions (30+ real-time use cases)

### A. Plan Mode — "Help me plan my year"

| # | Intent | Action | UI Component | Data Needed |
|---|---|---|---|---|
| 1 | "I want a year plan" | Show all 26 LWs in a year grid | Year calendar (Absentify style) | Country, year, PTO budget |
| 2 | "What's my best LW?" | Rank by trip value | Recommendation card | Home city, prefs, budget |
| 3 | "When to use 1 PTO day?" | Show all 1-PTO extensions | Filter chip + list | PTO budget |
| 4 | "Plan with 5 PTO days" | Greedy year plan | Plan card with calendar | PTO budget |
| 5 | "Stack 2 LWs" | Find adjacent LWs | "Cluster" badge | PTO budget ≥ 5 |
| 6 | "Avoid summer" | Filter by season | Season filter chips | Season preference |
| 7 | "Skip December" | Month filter | Month chip toggle | - |
| 8 | "Best for my kids" | School break overlay | Color-coded school breaks | Kid's grade |
| 9 | "Plan around Diwali" | Religious-aware filter | Tradition filter | Religion |
| 10 | "Compare two LWs" | Side-by-side cards | Comparison modal | Selected 2 LWs |

### B. Discover Mode — "Where should I go?"

| # | Intent | Action | UI Component | Data Needed |
|---|---|---|---|---|
| 11 | "Nearby getaways" | Cities within X km of home | Map + list | Home city, max distance |
| 12 | "Beach in winter" | Climate-match filter | Climate card | Month, climate pref |
| 13 | "Visa-free for me" | Country filter by passport | Country chips | Passport |
| 14 | "Same time-zone" | TZ overlap | TZ badge | Home TZ |
| 15 | "Cheap destinations" | Cost-of-living filter | Price card | Budget |
| 16 | "Trending now" | Popular LWs worldwide | Trending list | - |
| 17 | "Family-friendly" | Kids activities filter | Activity icons | Kids age |
| 18 | "Pet-friendly" | Pet filter | Pet icon | Has pet |
| 19 | "Eco-friendly" | Sustainability score | Leaf icon | - |
| 20 | "Solo travel safe" | Safety score | Shield icon | - |

### C. Trip Mode — "I'm taking this LW, what now?"

| # | Intent | Action | UI Component | Data Needed |
|---|---|---|---|---|
| 21 | "Show itinerary" | Day-by-day plan | Timeline | Destination, dates |
| 22 | "Find hotels" | Booking links | Hotel cards | Destination |
| 23 | "Find flights" | Flight search | Flight cards | Home, dest, dates |
| 24 | "Weather forecast" | Climate data | Weather card | Destination, month |
| 25 | "Pack list" | Auto-generate | Checklist | Destination, month |
| 26 | "Add to calendar" | ICS export | Button | Trip |
| 27 | "Share with partner" | Share link | Button | Trip |
| 28 | "Set budget" | Expense tracker | Budget card | Trip |
| 29 | "Local events" | Concerts, festivals | Event list | Destination, dates |
| 30 | "Tour ideas" | Top activities | Activity cards | Destination, theme |

### D. Track Mode — "What have I done?"

| # | Intent | Action | UI Component | Data Needed |
|---|---|---|---|---|
| 31 | "Days used" | Stats | Donut chart | Trips history |
| 32 | "Days remaining" | Counter | Stat tile | PTO budget − used |
| 33 | "Next LW countdown" | Days until | Hero stat | Today + next LW |
| 34 | "Cost YTD" | Sum | Money stat | Trip expenses |
| 35 | "Most visited" | Ranking | Bar chart | Trip history |

## 2. User Data We Need (Onboarding)

### Critical (block recommendations)
- **Home city** — drives "near me" + flight cost
- **Home country** — drives holiday calendar
- **Available PTO days** — drives trip planning budget
- **Work schedule** — Mon-Fri / Sun-Thu / Fri-Sat / Sat-Wed

### High value (sharper recommendations)
- **Travel party** — Solo / Couple / Family w/ kids / Group
- **Kid ages** (if family) — drives activity filter
- **Passport country** — drives visa filter
- **Budget per LW** — $ / $$ / $$$ / $$$$
- **Trip vibes** — Beach / City / Mountain / Culture / Adventure / Food / Relax

### Optional (nice to have)
- **Climate preference** — Warm / Cold / Mild / Snow
- **Max flight time** — 2h / 4h / 6h+
- **Pets** — drives pet-friendly filter
- **Dietary** — drives restaurant filter
- **Past trips** — drives "visited" badge
- **Wishlist** — drives "saved" badge

## 3. Revised Algorithm

### Trip Value Score (0-100)
```
score = (daysOff × 10)            // Base: 3d=30, 5d=50
      + seasonQuality(week)       // +20 spring/fall, +10 summer, +0 winter
      + climateMatch(month, pref) // +15 if matches
      + distanceScore(km)         // +15 <500km, +10 <2000km, +5 <5000km
      + clusterBonus              // +20 if part of cluster
      - blackoutPenalty           // -50 if in blackout
      - weatherPenalty            // -20 if monsoon
```

### Travel Buffer
- Drive (<500km): 0 day
- Short flight (500-2000km): 0.5 day
- Long flight (2000-5000km): 1 day
- International (5000+): 1.5 days

### Min Trip Duration
- 2-3 days = "long weekend" (local)
- 4-5 days = "short trip" (regional)
- 6-9 days = "vacation" (with flights)
- 10+ days = "long trip" (rare)

### Cluster Detection
- If two LWs are within 5 workdays, mark as "stackable"
- Required PTO = (gap) − existing days off

### Greedy Year Plan
```
sort LWs by score desc
for each LW:
  if fits in remaining PTO:
    add to plan
    subtract PTO used
```

## 4. UI Architecture

### Layout (Absentify + 21st.dev hybrid)
```
┌────────────────────────────────────────────────────────────┐
│  🏠 Long Weekend Planner   [Country▼][Year▼][PTO:15] [👤]  │  Topbar (sticky)
├──────────┬─────────────────────────────────────────────────┤
│          │                                                 │
│ 📊 Plan  │  [Plan] [Discover] [My Trips] [Insights]        │  Tabs
│ 🔍 Disc  │  ─────────────────────────────────────────────  │
│ ✈️ Trips │                                                 │
│ 💡 Insi  │  ┌──────┬──────┬──────┬──────┬──────┐          │
│          │  │ Hero │ KPIs │ Count│ Map  │  ROI │          │  Bento grid
│ ──────── │  │ Nxt  │ Days │ 26   │ Pin  │ Card │          │
│ ⚙️ Set   │  │ LW   │ Off  │ LWs  │ Home │      │          │
│          │  └──────┴──────┴──────┴──────┴──────┘          │
│ PTO: 15  │                                                 │
│ Used: 3  │  ┌──────────────────────────────────────┐      │
│ Left: 12 │  │  Year Calendar (Absentify style)    │      │  Year view
│          │  │  Jan  Feb  Mar  Apr  May  Jun ...    │      │
│ Home:    │  │  LWs highlighted, school breaks     │      │
│ NYC      │  └──────────────────────────────────────┘      │
│          │                                                 │
│ Prefs:   │  ┌──────────────────┬─────────────────────┐    │
│ 🌊🏖️     │  │ Top LW Pick      │ Trip Recommendations │    │  AI recs
│ Family   │  │ Memorial Day wknd │ Mexico City (3h)    │    │
│ $$$      │  │ May 22-25 (4d)    │ Tulum (4h)          │    │
│          │  │ Score: 87/100     │ Costa Rica (5h)     │    │
│          │  │ [Plan this trip]  │ [View all 12 →]    │    │
│          │  └──────────────────┴─────────────────────┘    │
└──────────┴─────────────────────────────────────────────────┘
```

### Visual Style (21st.dev inspired)
- **Color palette**: White/light bg, indigo primary (#4f46e5), 
  red holidays (#ef4444), green LWs (#10b981), amber optionals (#f59e0b)
- **Typography**: Inter / system-ui, clean hierarchy
- **Cards**: Rounded-lg, subtle shadow, hover lift
- **Chips**: Pill-shaped, color-coded by category
- **Animations**: Subtle (150ms ease-out), no bouncy
- **Dark mode**: Auto via prefers-color-scheme

### Component Library (build vs buy)
- **Build**: Calendar grid, LW card, modals, recommendation cards
- **Use API**: Country/city data, holiday data, climate, time zones
- **External**: Map tiles (OSM), flight links (Skyscanner), hotel links (Booking)
- **No npm deps**: pure HTML/CSS/JS for max portability

## 5. Data Sources (API Integration)

### Internal (our Worker)
- `GET /api/v1/holidays?country=X&year=Y` — holiday list
- `GET /api/v1/countries/{cca2}/long-weekends/{year}?pto=N` — LW with PTO
- `GET /api/v1/countries/{cca2}/pto-strategy/{year}?available_pto=N` — greedy plan
- `GET /api/v1/cities/{id}` — city info
- `GET /api/v1/cities?near=X&lat=Y&lon=Z&limit=10` — nearby cities
- `GET /api/v1/countries` — country list
- `GET /api/v1/countries/{cca2}/filters` — applicable filters

### External (free tier)
- **OpenStreetMap** — Map tiles
- **Nominatim** — Geocoding (city → lat/lon)
- **Open-Meteo** — Weather/climate
- **Wikipedia REST** — Destination descriptions
- **Skyscanner/Booking** — Deep links (no API, just URL)

### Client-side (no API)
- **localStorage** — User prefs, saved trips
- **sessionStorage** — Last viewed tab
- **URL params** — Shareable state
- **File API** — ICS import/export

## 6. What to Build (Phase 1 = this iteration)

### Pages
1. **Plan** — Year view + recommendations + greedy plan
2. **Discover** — Browse destinations by LW opportunity
3. **My Trips** — Saved trips with itineraries
4. **Insights** — Stats from past trips

### Modal
- **Onboarding** — Collect home city, PTO, prefs (5 questions)
- **Day detail** — Holidays + LW + weather + nearby
- **Trip planner** — Pick destination, dates, see itinerary
- **Compare** — 2 LWs side-by-side

### Components
- Year calendar (Absentify-style)
- LW card (with trip value score)
- Recommendation card (with city, distance, cost, climate)
- Bento grid dashboard
- Filter chips
- Map embed
- Timeline (itinerary)
- Stat tiles

### Logic
- Trip value scoring
- Greedy PTO optimizer
- Nearby cities finder
- Travel buffer calculator
- Cluster detection

## 7. What to Defer (Phase 2+)

- ❌ Real flight API integration (use Skyscanner deep links)
- ❌ Real hotel API (use Booking deep links)
- ❌ User accounts (localStorage only for MVP)
- ❌ Multi-user / family sharing
- ❌ Trip photo upload
- ❌ Email notifications
- ❌ Mobile app (PWA only)
- ❌ Booking integration
- ❌ Reviews/ratings
