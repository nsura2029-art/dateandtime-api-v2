# Plan: Align our DB to dr5hn source counts

## TL;DR

Our DB uses **different source datasets** than `dr5hn/countries-states-cities-database`. The counts differ because the sources differ — not because of bugs. Where it makes sense, we should align; where it doesn't, document why.

| Data | Current source | dr5hn has | Plan |
|---|---|---|---|
| **Regions** | denormalized on countries | separate table | Add `regions` + `subregions` tables (Phase 4 — admin) |
| **Sub-regions** | denormalized on countries | separate table | same as above |
| **Countries** | mledoze/countries (242) | dr5hn (250) | Add the 8 missing territories (one migration) |
| **States** | not loaded | 5,308 | Add a `states` table (Phase 2.5, after cities) |
| **Cities** | GeoNames cities15000 (33,945) | dr5hn (152,970) | **Keep GeoNames** — better data quality for geocoding |
| **Timezones** | IANA zoneinfo (408) | dr5hn (371 in cities) | **No change** — 408 > 371, we're good |

## Phase 1: Add the 8 missing countries (1 hour)

Source the 8 missing countries from dr5hn and add to our `countries` table. They are territories we don't have:

```
Antarctica (AQ)
Bouvet Island (BV)  
French Southern Territories (TF)
Heard Island and McDonald Islands (HM)
South Georgia and the South Sandwich Islands (GS)
United States Minor Outlying Islands (UM)
Western Sahara (EH)
Svalbard and Jan Mayen (SJ)  [we may have partial]
```

**Implementation:** single migration `009_add_8_countries.sql` + a tiny seed script.

**Risk:** low. These are territories with no major cities in our cities15000 dataset, so no foreign-key issues.

## Phase 2: Document the difference (15 min)

Update `KNOWN_ISSUES.md` with a clear explanation:
- Why we use GeoNames for cities (not dr5hn)
- Why we use mledoze for countries
- Why we have 408 timezones (not 371 or 427)
- This becomes the source-of-truth for "why are our numbers different"

## Phase 3: Add `regions` + `subregions` tables (1-2 days)

If we want API endpoints like `GET /api/v1/regions` and `GET /api/v1/regions/:code/subregions`:
1. Add `regions` table: `code, name`
2. Add `subregions` table: `code, name, region_code`
3. Backfill from current `countries.un_region` / `countries.un_subregion` data
4. Migrate `countries` to FK to `subregions` (optional, not required)
5. Add the 2 API endpoints

This is more work — do it as a separate feature branch after Phase 2 (cities).

## Phase 4: Add `states` table (2-3 days)

The biggest addition. We have 5,308 states/regions in the source repo. The schema would be:
```sql
CREATE TABLE states (
  id INTEGER PRIMARY KEY,
  country_code TEXT NOT NULL,  -- FK to countries
  code TEXT,                    -- state code (e.g., "CA" for California)
  name TEXT NOT NULL,
  ascii_name TEXT,
  latitude REAL,
  longitude REAL,
  timezone TEXT,                 -- FK to timezones
  population INTEGER,
  FOREIGN KEY (country_code) REFERENCES countries(cca2),
  FOREIGN KEY (timezone) REFERENCES timezones(id)
);
```

This unlocks:
- `GET /api/v1/states?country=US` (list states in a country)
- `GET /api/v1/states/:id` (one state)
- `GET /api/v1/countries/:cca2/states` (already in our endpoint manifest!)
- Better city filtering by state
- A "states" tab on country pages in the UI

## Decision: which phases to do?

My recommendation: **Phase 1 (8 countries) now, Phases 2-4 after Phase 2 (cities API).**

Rationale:
- Phase 1 is 1 hour and unblocks data completeness
- Phases 2-4 are bigger and should be their own feature branches
- Cities API is the actual product work — let's not block on it

## File changes for Phase 1

1. `migrations/009_add_8_countries.sql` — new migration with the 8 INSERTs
2. `scripts/seed/008_add_8_countries.py` — script that generates the migration from dr5hn data
3. `tests/countries.test.ts` — test that confirms 250 countries (after migration)
4. Updated `KNOWN_ISSUES.md` to remove the 8-country gap
5. Re-deploy: `npm run deploy:dev`

## Risks and mitigations

- **Risk:** The 8 countries might have cities in our cities15000 that we don't have countries for.
  - **Mitigation:** Pre-check by joining cities to countries; if any are missing, add them too.
- **Risk:** Some of the 8 might be territories that conflict with existing country codes.
  - **Mitigation:** Use dr5hn's exact cca2/cca3 codes; check for uniqueness before INSERT.
- **Risk:** Loading from dr5hn requires reading 4MB JSON.
  - **Mitigation:** Hard-code the 8 INSERT statements; no script-to-script dependence.

## Open questions for you

1. Do you want to also add the **states table** in a separate branch? (Phase 4 — bigger)
2. Do you want to switch to **dr5hn for cities** (152K instead of 34K)? (Quality vs quantity tradeoff)
3. Do you want **separate regions/subregions tables**? (Phase 3)
4. Should we just **document the differences** and stop? (Phase 2 only)
