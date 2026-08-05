# Weather Data — Future Roadmap (M15+)

> **Status**: Deferred (post-M14)
> **Owner**: TBD
> **Target**: M15.0 (after M14 holidays stabilize)

## What we want

Add per-city, per-month weather data so:
- Trip planner can recommend destinations by climate match
- City detail can show monthly averages (temp, precipitation, sun hours)
- "Best time to visit" answers
- Long weekend "is it monsoon / snow season?" warnings

## Data sources under consideration

### Option A: Open-Meteo (self-hosted)
- **URL**: https://open-meteo.com/
- **License**: Free, open-source, no API key required
- **Coverage**: Global, 5-11 km resolution
- **Historical**: ERA5 reanalysis 1940-present
- **Forecast**: 16 days ahead, hourly
- **Climate**: 30-year monthly averages (1991-2020)
- **Setup**: Docker image available
  ```bash
  docker run -d -p 8080:8080 openmeteo/openmeteo
  ```
- **Pros**: Free, self-hosted, no rate limits, no API key
- **Cons**: Storage cost, devops overhead, monthly updates

### Option B: WeatherAPI.com
- **URL**: https://www.weatherapi.com/pricing.aspx
- **License**: Paid (free tier: 1M calls/month)
- **Coverage**: Global
- **Historical**: 2010-present, hourly
- **Forecast**: 14 days
- **Climate**: Monthly averages
- **Setup**: API key only
- **Pros**: Simple, reliable, includes astronomy/UV/air quality
- **Cons**: $0/month free, $4/month for 10M calls (overkill for our scale)

### Option C: NOAA NCEI GSOM (already in DB!)
- **URL**: https://www.ncei.noaa.gov/products/land-based-station/global-summary-of-the-month
- **License**: Public domain
- **Coverage**: Global (15K stations, ~10K with 30+ year records)
- **Historical**: Up to 200+ years
- **Setup**: We already loaded 87,808 records in M11.8!
- **Pros**: FREE, real observed data, no API key
- **Cons**: Only land stations (no ocean/coastal accuracy), monthly granularity

## Recommendation

**Hybrid approach**:
1. **M11.8 NOAA NCEI GSOM** (already loaded) — primary for historical climate (monthly temp/precip)
2. **Open-Meteo self-hosted** (defer to M15.1) — for forecast + hourly
3. **WeatherAPI.com** (defer to M15.2) — for any gaps (UV, air quality, marine)

## Schema (target)

```sql
-- Per-city, per-month climate averages (from NOAA NCEI or Open-Meteo)
CREATE TABLE city_climate_normals (
  city_id INTEGER NOT NULL,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  temp_avg_c REAL,           -- mean temperature
  temp_min_c REAL,           -- mean of daily mins
  temp_max_c REAL,           -- mean of daily maxes
  precip_mm REAL,            -- total precipitation
  precip_days INTEGER,       -- days with > 1mm
  sun_hours REAL,            -- mean daily sun hours
  uv_index REAL,             -- mean UV index
  source TEXT,               -- 'noaa_ncei_gsom', 'open_meteo', 'weatherapi'
  fetched_at TEXT,
  PRIMARY KEY (city_id, month, source),
  FOREIGN KEY (city_id) REFERENCES cities(id)
);

-- Per-city, per-day forecast (from Open-Meteo or WeatherAPI)
CREATE TABLE city_forecast (
  city_id INTEGER NOT NULL,
  forecast_date TEXT NOT NULL,
  temp_high_c REAL,
  temp_low_c REAL,
  precip_mm REAL,
  wind_kph REAL,
  conditions TEXT,
  uv_index REAL,
  source TEXT,
  fetched_at TEXT,
  PRIMARY KEY (city_id, forecast_date, source)
);
```

## Endpoint additions (target)

```
GET /api/v1/cities/{id}/climate?month=6            # monthly normals
GET /api/v1/cities/{id}/forecast?days=14           # 14-day forecast
GET /api/v1/cities?warm_in=January&max_distance_km=2000   # climate filter
```

## Use cases unlocked

1. **"Where can I go for warm weather in February?"**
   - Filter cities by temp_max_c > 25 AND distance from home < 5000km
2. **"When is the best time to visit Tokyo?"**
   - Return months with: temp_avg_c ∈ [15, 25] AND precip_days < 10
3. **"Is monsoon season in Mumbai in July?"**
   - Yes if precip_mm > 200 AND month=7
4. **"Pack list generator"** — if temp_avg_c < 5 → suggest warm clothes
5. **"Climate match score"** — score 0-100 of city vs user's preferred climate
6. **LW warning** — "Long weekend in Dec but Caribbean hurricane season"

## Cost analysis

### Open-Meteo self-hosted
- Server: $5-20/mo (Hetzner or DO)
- Storage: 1GB (5-km grid, monthly)
- Bandwidth: minimal
- **Total**: ~$10/mo at our scale

### WeatherAPI.com
- 1M calls/mo free (more than enough)
- $4/mo for 10M (overkill)
- **Total**: $0-4/mo

### NOAA NCEI
- $0/mo (already have it!)

## Decision timeline

- **M14 (now)**: Holidays only. Defer weather.
- **M14.6 (now)**: Trip planner with destinations but no climate scoring.
- **M15.0 (Q3 2026?)**: Climate normals from NOAA NCEI (already loaded).
- **M15.1**: Open-Meteo self-hosted for forecast + hourly.
- **M15.2**: WeatherAPI.com for any premium data (UV, marine, air quality).

## Open questions

- [ ] Do we need 30-year normals or just 10-year is enough?
- [ ] Do we want hour-by-hour or just daily summary?
- [ ] Do we need air quality / pollen / UV for trip planning?
- [ ] Is self-hosting Open-Meteo worth the devops cost, or just use WeatherAPI?

## Action items

- [ ] Decide on data sources (likely NOAA + Open-Meteo, skip WeatherAPI)
- [ ] Set up M15.0 milestone with schema + endpoint
- [ ] Document M11.8 NOAA data we already have (87,808 records)
- [ ] Add climate column to city detail endpoint
- [ ] Update trip planner with climate match scoring

## Related docs

- `docs/SPEC-master-data-architecture.md` — overall data architecture
- `docs/m14.6-trip-planner/USE_CASES.md` — use cases 12-20 (discover by climate)
- `preview/trip-planner.html` — trip planner (climate filter placeholder exists)
- Memory: M11.8 milestone (NOAA NCEI GSOM loaded)
