/**
 * City search + detail endpoints.
 *   GET /api/v1/cities/search?q=...   — search by name (FTS5 + ranking)
 *   GET /api/v1/cities/:id            — city detail (full record + country + admin)
 *
 * Search uses SQLite FTS5 (place_names_fts) for fast text matching, then
 * joins with cities, countries, administrative_regions, time_zones to
 * build the result. Ranking is computed in the application layer
 * (see rankResults below) for easy tuning.
 */
import { OpenAPIHono, createRoute } from "@hono/zod-openapi";
import { z } from "zod";
import type { Env, Variables } from "@/types/env";

const cities = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// ============================================================================
// Schemas
// ============================================================================
const CountryRef = z.object({
  id: z.number(),
  cca2: z.string(),
  cca3: z.string().nullable(),
  name: z.string(),
  flag: z.string().nullable(),
  capital: z.string().nullable(),
});

const AdminRegionRef = z.object({
  id: z.number(),
  name: z.string().nullable(),
  country_id: z.number().nullable(),
});

const TimezoneRef = z.object({
  id: z.string().nullable(),
  utc_offset_minutes: z.number().nullable(),
  current_abbreviation: z.string().nullable(),
  is_dst: z.number().nullable(),
});

const CitySearchResult = z.object({
  id: z.number().describe("City ID (dr5hn)"),
  name: z.string().describe("City name (any script)"),
  asciiName: z.string().nullable().describe("ASCII transliteration"),
  native: z.string().nullable().describe("Local name in native script (dr5hn)"),
  stateCode: z.string().nullable().describe("State/province code, e.g. 'FL'"),
  type: z.string().nullable().describe("dr5hn type: city, adm2, district, etc."),
  wikiDataId: z.string().nullable().describe("Wikidata QID"),
  tier: z.string().nullable().describe("tier1 (capital) | tier2 (top 3) | tier3 (rest)"),
  capitalType: z.string().nullable().describe("country_capital | state_capital | both | null"),
  isCountryCapital: z.boolean(),
  isStateCapital: z.boolean(),
  disputed: z.boolean().describe("True if boundary/sovereignty is contested"),
  claimedBy: z.array(z.string()).nullable().describe("ISO country codes that claim this city"),
  latitude: z.number(),
  longitude: z.number(),
  population: z.number().nullable(),
  country: CountryRef,
  adminRegion: AdminRegionRef.nullable(),
  subRegion: AdminRegionRef.nullable().describe("M12: Level-2 admin (county, district, commune). null for cities without admin-2 data."),
  timezone: TimezoneRef,
  distanceKm: z.number().nullable().describe("Distance from user (if lat/lon provided)"),
  score: z.number().describe("Internal ranking score (higher = better)"),
  matchType: z.enum(["exact", "prefix", "fuzzy", "alt_label"]),
});

const SearchResponse = z.object({
  success: z.literal(true),
  data: z.object({
    query: z.string(),
    results: z.array(CitySearchResult),
    total: z.number().int(),
    tookMs: z.number().int(),
  }),
});

const ErrorResponse = z.object({
  success: z.literal(false),
  error: z.object({ code: z.string(), message: z.string() }),
});

// ============================================================================
// Search query schema
// ============================================================================
const searchQuery = z.object({
  q: z.string().min(1).max(100).describe("Search query (city name)"),
  country: z.string().length(2).optional().describe("User country (ISO cca2) — boosts matches in this country"),
  state: z.string().min(1).max(10).optional().describe("User state code (e.g. 'AZ', 'FL', 'NSW') — strong boost for matches in this state"),
  lang: z.string().min(2).max(10).optional().describe("User language (ISO 639-1) — boosts matches translated into this language (e.g. 'ja', 'zh-CN', 'pt-BR')"),
  lat: z.coerce.number().min(-90).max(90).optional().describe("User latitude — proximity boost"),
  lon: z.coerce.number().min(-180).max(180).optional().describe("User longitude — proximity boost"),
  limit: z.coerce.number().int().min(1).max(50).default(10).describe("Max results (default 10)"),
});

// ============================================================================
// City detail schema
// ============================================================================
const PostcodeSample = z.object({
  code: z.string(),
  localityName: z.string().nullable(),
  type: z.string().nullable(),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
});

const CityDetail = z.object({
  id: z.number(),
  name: z.string(),
  asciiName: z.string().nullable(),
  native: z.string().nullable().describe("Local name in native script (dr5hn)"),
  stateCode: z.string().nullable().describe("State/province code, e.g. 'FL' (dr5hn)"),
  type: z.string().nullable().describe("dr5hn type: city, adm2, district, etc."),
  level: z.number().nullable().describe("Administrative level (1, 2, 3)"),
  parentId: z.number().nullable().describe("Parent city id (for hierarchy)"),
  wikiDataId: z.string().nullable().describe("Wikidata QID, e.g. 'Q3459226'"),
  flag: z.boolean().describe("1 = active, 0 = deprecated"),
  tier: z.string().nullable(),
  capitalType: z.string().nullable(),
  isCountryCapital: z.boolean(),
  isStateCapital: z.boolean(),
  latitude: z.number(),
  longitude: z.number(),
  population: z.number().nullable(),
  elevation: z.number().nullable(),
  disputed: z.boolean(),
  claimedBy: z.array(z.string()).nullable(),
  country: CountryRef,
  adminRegion: AdminRegionRef.nullable(),
  subRegion: z.object({
    id: z.number().describe("GeoNames ID of the admin-2 region"),
    name: z.string().nullable().describe("Admin-2 name (e.g. 'Pasco County', 'Bezirk Mitte')"),
    code: z.string().nullable().describe("GeoNames hierarchical code (e.g. 'US.FL.101' = Florida, Pasco County)"),
    type: z.string().nullable().describe("Region type: 'admin2' (counties, districts, communes, etc.)"),
    level: z.number().describe("Admin level (2 for all admin-2 regions)"),
    geonameId: z.number().nullable().describe("GeoNames ID — useful for linking to GeoNames API"),
  }).nullable().describe("M12: Level-2 admin (county, district, commune). 56,293 cities have this populated."),
  timezone: TimezoneRef,
  source: z.object({
    id: z.string().nullable(),
    version: z.string().nullable(),
  }),
  placeNames: z.array(z.object({
    name: z.string(),
    language: z.string().nullable(),
    type: z.string(),
  })).describe("Other names (transliterations, alternates) — Phase 2.5 will add more languages"),
  postcodes: z.object({
    total: z.number().describe("Total postcodes for this city (state-scoped)"),
    sample: z.array(PostcodeSample).describe("First 5 postcodes as preview"),
  }).nullable().describe("Postal codes (M4: dr5hn postcodes.json)"),
  translations: z.object({
    available: z.number().describe("Number of languages this city has been translated to (max 19)"),
    languages: z.array(z.string()).describe("List of available language codes (e.g. ['ja', 'es', 'ar'])"),
  }).describe("Available translations (M5: dr5hn translations.csv). Full text via /cities/{id}/translations"),
  dataQuality: z.object({
    timezoneConfidence: z.enum(["high", "medium", "low", "unresolved"]).nullable()
      .describe("Confidence in timezone assignment: 'high' (polygon-verified), 'medium' (dr5hn), 'low' (manual override), 'unresolved' (Null Island)"),
    timezoneSource: z.string().nullable().describe("Where the timezone was set: 'polygon:timezonefinder', 'dr5hn:default', 'manual:override', etc."),
    flags: z.array(z.string()).describe("Data quality flags: 'null_island', 'no_pop', 'no_wiki', etc."),
  }).describe("Data quality metadata (M8: spec §1, §14, §15, §28)"),
  // M11.2.6: Wikidata description block
  wikidata: z.object({
    label: z.string().nullable().describe("Wikidata canonical English label (may differ from city name for non-English cities)"),
    altLabels: z.array(z.string()).describe("Wikidata alt labels (alternative names, misspellings, common variants)"),
    description: z.string().nullable().describe("One-line description: 'Wikidata label (also known as first alt label)' — useful for SEO meta tags, tooltips, and city page subtitles"),
    // M11.2.8: P-code properties (top 5K cities only)
    instanceOf: z.string().nullable().describe("Wikidata P31: Q-id of what this entity is (e.g. 'Q515' for city, 'Q486972' for human settlement)"),
    countryQid: z.string().nullable().describe("Wikidata P17: Q-id of the country (cross-source validation)"),
    adminQid: z.string().nullable().describe("Wikidata P131: Q-id of the administrative territorial entity"),
    timezoneQid: z.string().nullable().describe("Wikidata P421: Q-id of the timezone"),
  }).nullable().describe("Wikidata enrichment (M11.2.6) — null if city has no wiki_data_id or no Wikidata staging row"),
  // M11.5: US Census block
  census: z.object({
    fips: z.object({
      state: z.string().nullable().describe("2-digit FIPS state code (e.g. '36' for NY)"),
      place: z.string().nullable().describe("5-digit FIPS place code (e.g. '51000' for NYC)"),
      geoid: z.string().nullable().describe("7-digit FIPS GEOID (state+place), e.g. '3651000'"),
    }).nullable(),
    legalClass: z.string().nullable().describe("Legal class: 'city', 'town', 'village', 'CDP', 'borough' (from LSAD)"),
    functionalStatus: z.string().nullable().describe("Census functional status: 'A' (active) or 'S' (statistical)"),
    landAreaSqMi: z.number().nullable().describe("Land area in square miles (from Gazetteer)"),
    waterAreaSqMi: z.number().nullable().describe("Water area in square miles (from Gazetteer)"),
    densityPerSqMi: z.number().nullable().describe("Computed: population_2025 / land_area_sqmi (people per sq mi)"),
    internalLat: z.number().nullable().describe("Gazetteer internal point latitude (more accurate than dr5hn)"),
    internalLon: z.number().nullable().describe("Gazetteer internal point longitude"),
    populationTimeSeries: z.array(z.object({
      year: z.number().int(),
      population: z.number().int().nullable(),
    })).describe("Annual population estimates (2020-2025)"),
    populationLatest: z.number().int().nullable().describe("Most recent population (POPESTIMATE2025)"),
    populationYear: z.number().int().nullable().describe("Year of the latest estimate (2025)"),
    estimatesBase2020: z.number().int().nullable().describe("April 2020 census-day estimates base"),
    vintage: z.string().nullable().describe("Census vintage: 'vintage-2025'"),
  }).nullable().describe("US Census Bureau enrichment (M11.5) — null for non-US cities or US cities not in Census"),
  // M11.6: Eurostat block (LAU + URAU for EU cities)
  eurostat: z.object({
    lau: z.object({
      giscoId: z.string().nullable().describe("Eurostat LAU ID (e.g. 'DE_11000000' for Berlin)"),
      lauName: z.string().nullable().describe("Official LAU name (may differ from dr5hn name)"),
      population: z.number().int().nullable().describe("Population 1 Jan 2024 (null for FR/ES/AL/IS/RS — privacy laws)"),
      populationDensity: z.number().nullable().describe("People per km² (LAU 2024)"),
      areaKm2: z.number().nullable().describe("Area in km² (LAU 2024)"),
      year: z.number().int().nullable().describe("Data vintage (2024)"),
    }).nullable().describe("Eurostat LAU (Local Administrative Units) — null if no match"),
    urau: z.object({
      urauCode: z.string().nullable().describe("URAU City code (e.g. 'FR028C' for Nîmes)"),
      urauName: z.string().nullable().describe("URAU City name"),
      fuaCode: z.string().nullable().describe("Functional Urban Area code (e.g. 'FR028F')"),
      fuaName: z.string().nullable().describe("Functional Urban Area name (the wider metro area)"),
      areaSqKm: z.number().nullable().describe("URAU city area in km²"),
      nuts3Code: z.string().nullable().describe("NUTS 2024 region code"),
    }).nullable().describe("Eurostat URAU (City vs FUA) — null if no URAU match"),
  }).nullable().describe("Eurostat enrichment (M11.6) — null for non-EU cities or EU cities not in LAU/URAU"),
  // M11.7: Census of India 2011 block (Indian cities only)
  censusIndia: z.object({
    censusCode: z.string().nullable().describe("6-digit Census of India town code (e.g. '800013' for Srinagar)"),
    stateCode: z.string().nullable().describe("2-digit Census state code (e.g. '01' for J&K)"),
    districtCode: z.string().nullable().describe("3-digit Census district code"),
    uaCode: z.string().nullable().describe("9-digit Urban Agglomeration code (e.g. '500400100' for Srinagar UA part)"),
    uaName: z.string().nullable().describe("Urban Agglomeration name (e.g. 'Srinagar (M Corp.+OG)')"),
    level: z.number().int().nullable().describe("Hierarchy level: 1=statutory city, 2=sub-town/OG"),
    households: z.number().int().nullable().describe("Number of households (No_HH)"),
    population: z.number().int().nullable().describe("Total population (TOT_P) — 2011 Census"),
    malePopulation: z.number().int().nullable().describe("Male population (TOT_M)"),
    femalePopulation: z.number().int().nullable().describe("Female population (TOT_F)"),
    sexRatio: z.number().int().nullable().describe("Sex ratio: females per 1000 males (TOT_F * 1000 / TOT_M)"),
    childPopulation: z.number().int().nullable().describe("Child population age 0-6 (P_06)"),
    childSexRatio: z.number().int().nullable().describe("Child sex ratio: girls per 1000 boys (F_06 * 1000 / M_06)"),
    scPopulation: z.number().int().nullable().describe("Scheduled Caste population (P_SC)"),
    stPopulation: z.number().int().nullable().describe("Scheduled Tribe population (P_ST)"),
    literacyRate: z.number().nullable().describe("Literacy rate %: P_LIT / TOT_P * 100"),
    workersTotal: z.number().int().nullable().describe("Total workers (TOT_WORK_P)"),
    mainWorkers: z.number().int().nullable().describe("Main workers (MAINWORK_P) — worked >6 months"),
    marginalWorkers: z.number().int().nullable().describe("Marginal workers (MARGWORK_P) — worked <6 months"),
    nonWorkers: z.number().int().nullable().describe("Non-workers (NON_WORK_P)"),
    censusYear: z.number().int().nullable().describe("Census year (2011)"),
  }).nullable().describe("Census of India 2011 enrichment (M11.7) — null for non-Indian cities or cities not in Census"),
  // M11.5.1: ACS 5-year estimates (Sex by Age, B01001)
  acs: z.object({
    fipsGeoid: z.string().nullable().describe("7-digit FIPS GEOID (state+place)"),
    totalPopulation: z.number().int().nullable().describe("ACS 5-year total population (2018-2022)"),
    malePopulation: z.number().int().nullable().describe("ACS 5-year male population"),
    femalePopulation: z.number().int().nullable().describe("ACS 5-year female population"),
    ageBreakdown: z.object({
      under5: z.number().int().nullable().describe("Population under 5 years"),
      age5to17: z.number().int().nullable().describe("Population 5-17 years (school age)"),
      age18to24: z.number().int().nullable().describe("Population 18-24 years (college age)"),
      age25to44: z.number().int().nullable().describe("Population 25-44 years (young adult)"),
      age45to64: z.number().int().nullable().describe("Population 45-64 years (middle age)"),
      age65plus: z.number().int().nullable().describe("Population 65+ years (senior)"),
    }).nullable().describe("Population broken down by major age buckets"),
    acsYear: z.number().int().nullable().describe("End year of ACS 5-year period (2022 for 2018-2022)"),
  }).nullable().describe("US Census ACS 5-year enrichment (M11.5.1) — null for non-US cities"),
  // M11.5.1 expand: ACS 5-year Income (B19013) + Education (B15003)
  acsIncome: z.object({
    fipsGeoid: z.string().nullable().describe("7-digit FIPS GEOID"),
    medianIncome: z.number().int().nullable().describe("Median household income in 2022 inflation-adjusted USD (B19013_E001)"),
    acsYear: z.number().int().nullable().describe("End year of ACS 5-year period (2022)"),
  }).nullable().describe("ACS 5-year median household income (B19013) — null if not available"),
  acsEducation: z.object({
    fipsGeoid: z.string().nullable().describe("7-digit FIPS GEOID"),
    population25Plus: z.number().int().nullable().describe("Population 25+ (B15003_E001)"),
    lessThanHs: z.number().int().nullable().describe("Less than high school (E002-E010)"),
    hsOrGed: z.number().int().nullable().describe("High school or GED (E011-E012)"),
    someCollege: z.number().int().nullable().describe("Some college, no degree (E013-E014)"),
    associateDegree: z.number().int().nullable().describe("Associate's degree (E015)"),
    bachelorDegree: z.number().int().nullable().describe("Bachelor's degree (E016)"),
    graduateDegree: z.number().int().nullable().describe("Graduate or professional degree (E017-E019)"),
    bachelorOrHigher: z.number().int().nullable().describe("Bachelor's degree or higher (E015-E019)"),
    bachelorOrHigherPct: z.number().nullable().describe("Bachelor's or higher as % of 25+ population"),
    acsYear: z.number().int().nullable().describe("End year of ACS 5-year period (2022)"),
  }).nullable().describe("ACS 5-year educational attainment (B15003) — null if not available"),
  // M11.5.1 expand 2: ACS 5-year Tenure (B25003) + Transport (B08301)
  acsTenure: z.object({
    fipsGeoid: z.string().nullable().describe("7-digit FIPS GEOID"),
    totalOccupied: z.number().int().nullable().describe("Total occupied housing units (B25003_E001)"),
    ownerOccupied: z.number().int().nullable().describe("Owner-occupied units (B25003_E002)"),
    renterOccupied: z.number().int().nullable().describe("Renter-occupied units (B25003_E003)"),
    ownerOccupiedPct: z.number().nullable().describe("Owner-occupied %"),
    renterOccupiedPct: z.number().nullable().describe("Renter-occupied %"),
    acsYear: z.number().int().nullable().describe("End year of ACS 5-year period (2022)"),
  }).nullable().describe("ACS 5-year housing tenure (B25003) — null if not available"),
  acsTransport: z.object({
    fipsGeoid: z.string().nullable().describe("7-digit FIPS GEOID"),
    totalWorkers: z.number().int().nullable().describe("Total workers 16+ (B08301_E001)"),
    carOrVan: z.number().int().nullable().describe("Car, truck, or van workers (B08301_E002 — best-guess)"),
    droveAlone: z.number().int().nullable().describe("Drove alone (B08301_E003)"),
    publicTransport: z.number().int().nullable().describe("Public transport (B08301 — best-guess column)"),
    workedAtHome: z.number().int().nullable().describe("Worked at home (B08301 — best-guess column)"),
    acsYear: z.number().int().nullable().describe("End year of ACS 5-year period (2022)"),
  }).nullable().describe("ACS 5-year means of transportation (B08301) — null if not available. Note: B08301 has 21 raw columns stored; this block exposes a few key rollups."),
});

const CityDetailResponse = z.object({
  success: z.literal(true),
  data: CityDetail,
});

// ============================================================================
// Haversine distance (km)
// ============================================================================
function haversineKm(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const toRad = (d: number) => (d * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
}

// ============================================================================
// Edit distance (Levenshtein, cap at 2 for fuzzy match) — currently unused,
// kept for Phase 2.5 when we want true fuzzy match (typo tolerance).
// ============================================================================
// eslint-disable-next-line @typescript-eslint/no-unused-vars
function editDistance(a: string, b: string, cap = 2): number {
  if (Math.abs(a.length - b.length) > cap) return cap + 1;
  const m = a.length, n = b.length;
  let prev = new Array(n + 1).fill(0);
  let curr = new Array(n + 1).fill(0);
  for (let j = 0; j <= n; j++) prev[j] = j;
  for (let i = 1; i <= m; i++) {
    curr[0] = i;
    let rowMin = i;
    for (let j = 1; j <= n; j++) {
      const cost = a[i - 1] === b[j - 1] ? 0 : 1;
      curr[j] = Math.min(curr[j - 1] + 1, prev[j] + 1, prev[j - 1] + cost);
      if (curr[j] < rowMin) rowMin = curr[j];
    }
    if (rowMin > cap) return cap + 1;
    [prev, curr] = [curr, prev];
  }
  return prev[n];
}

// ============================================================================
// Score a single result
// ============================================================================
type RawResult = {
  city_id: number;
  city_name: string;
  ascii_name: string | null;
  native: string | null;
  state_code: string | null;
  type: string | null;
  wiki_data_id: string | null;
  tier: string | null;
  capital_type: string | null;
  is_country_capital: number;
  is_state_capital: number;
  latitude: number;
  longitude: number;
  population: number | null;
  disputed: number;
  claimed_by: string | null;
  country_id: number;
  country_cca2: string;
  country_cca3: string | null;
  country_name: string;
  country_flag: string | null;
  country_capital: string | null;
  admin_id: number | null;
  admin_name: string | null;
  timezone_id: string;
  utc_offset: number | null;
  tz_abbrev: string | null;
  is_dst: number | null;
  match_type: "exact" | "prefix" | "fuzzy" | "alt_label";
  fts_rank: number;
  from_wikidata_alt?: number;  // 1 if matched via wikidata_staging.alt_labels_json (M11.2.5)
};

function scoreResult(
  r: RawResult,
  q: string,
  qLower: string,
  qNorm: string,
  ctx: { userCountry?: string; userState?: string; userLang?: string; userLat?: number; userLon?: number }
): { score: number; distanceKm: number | null } {
  let s = 0;
  const name = r.city_name.toLowerCase();
  const ascii = (r.ascii_name || "").toLowerCase();

  // Text match signals
  if (name === qLower || ascii === qLower) s += 1000;
  else if (name.startsWith(qLower) || ascii.startsWith(qLower)) s += 500;
  else s += 100; // fuzzy

  // FTS5 bm25 (lower rank = better, so negate)
  s += Math.max(0, -r.fts_rank);

  // Capital status
  if (r.is_country_capital) s += 500;
  if (r.is_state_capital) s += 50; // kept at 50; same-name country boost (below) handles disambiguation

  // Tier
  if (r.tier === "tier1") s += 200;
  else if (r.tier === "tier2") s += 80;

  // Population (log scale, only if available) — STRONG weight so big cities
  // outrank small same-name state capitals. Phoenix AZ (1.6M) should beat
  // Phoenix OR (4.5K state capital).
  if (r.population && r.population > 0) {
    s += Math.log10(r.population + 1) * 100;
  }

  // User country boost
  if (ctx.userCountry && r.country_cca2 === ctx.userCountry) {
    s += 300;
  }

  // User state boost (M6) — strong boost when user specifies state.
  // This makes Phoenix AZ rank first when user asks for state=AZ.
  if (ctx.userState && r.state_code && r.state_code.toUpperCase() === ctx.userState.toUpperCase()) {
    s += 1000; // very strong: user explicitly asked for this state
  }

  // User language boost (M6) — small boost for matches translated into user's language
  if (ctx.userLang) {
    s += 50;
  }

  // Proximity (only if user lat/lon provided)
  let distanceKm: number | null = null;
  if (ctx.userLat !== undefined && ctx.userLon !== undefined) {
    distanceKm = haversineKm(ctx.userLat, ctx.userLon, r.latitude, r.longitude);
    s += Math.min(200, 5000 / (distanceKm + 50));
  }

  return { score: Math.round(s), distanceKm };
}

// ============================================================================
// GET /api/v1/cities/search
// ============================================================================
const searchRoute = createRoute({
  method: "get",
  path: "/api/v1/cities/search",
  summary: "Search cities by name",
  description:
    "FTS5 search over 152,970 cities. Returns ranked results with country, " +
    "admin region, timezone, and (if provided) distance from user. " +
    "Ranking factors: exact/prefix/fuzzy text match, capital status, tier, " +
    "user country/state/language context, and proximity. " +
    "When ?lang= is provided and the query is in that language (e.g. 'ja' + '東京'), " +
    "searches the translations table as fallback. " +
    "When ?state= is provided, gives a strong boost to cities in that state. " +
    "When 0 results match, returns a 'suggestions' field with up to 10 substring " +
    "matches (e.g. for misspellings or sub-threshold villages).",
  tags: ["Cities"],
  request: {
    query: searchQuery,
  },
  responses: {
    200: { content: { "application/json": { schema: SearchResponse } }, description: "Search results" },
    400: { content: { "application/json": { schema: ErrorResponse } }, description: "Invalid query" },
  },
});

cities.openapi(searchRoute, async (c) => {
  const start = Date.now();
  const { q, country, state, lang, lat, lon, limit } = c.req.valid("query");

  // --------------------------------------------------------------------------
  // STEP 1: Normalize the query
  // --------------------------------------------------------------------------
  // Two forms:
  //   - qLower: original case lowered (for exact "starts with" matching)
  //   - qNorm:  ASCII-normalized (lowercase + diacritics stripped + alphanum
  //             only) for fuzzy / FTS5 matching
  //
  // For non-ASCII (Hindi, Arabic, Chinese, etc.), we keep the original — we
  // can't transliterate, and FTS5 has the original Unicode strings in
  // place_names, so direct Unicode search works.
  // --------------------------------------------------------------------------
  const qLower = q.toLowerCase().trim();
  const isAscii = /^[\x00-\x7f]+$/.test(qLower);
  const qNorm = isAscii
    ? qLower.normalize("NFKD").replace(/[\u0300-\u036f]/g, "").replace(/[^a-z0-9]/g, "")
    : qLower;

  // --------------------------------------------------------------------------
  // STEP 2: Build the FTS5 query
  // --------------------------------------------------------------------------
  // For queries >= 2 chars, append * for prefix match (partial typing support).
  // FTS5 prefix search uses the `*` suffix, e.g. "tok*" matches "tokyo".
  //
  // D1 LIMITATION: D1 binds parameters as strings, so the FTS5 MATCH operator
  // (the `*` suffix) needs the raw query inlined, not parameterized.
  // We sanitize the query to remove SQL-breaking chars before inlining.
  //
  // Edge case: single-char queries don't get `*` (FTS5 needs ≥2 chars for prefix
  //   to be useful; otherwise we'd return too many false matches).
  // --------------------------------------------------------------------------
  const ftsQuery = qNorm.length >= 2 ? `${qNorm}*` : qNorm;
  const safeFts = ftsQuery
    .replace(/[\\'"`;]/g, '')        // strip SQL-breaking chars
    .replace(/^\*+|\*+$/g, '');     // strip leading/trailing stars

  // --------------------------------------------------------------------------
  // STEP 3: Run the primary FTS5 query
  // --------------------------------------------------------------------------
  // Joins:
  //   place_names_fts (FTS5 index) → place_names (canonical mapping) → cities
  //   → countries → administrative_regions → time_zones
  //
  // Returns up to 200 candidates for the application-level ranking.
  // ORDER BY fts.rank uses BM25 (negative = better) for initial sort.
  //
  // The `ci.is_active = 1` filter excludes deprecated cities (flag=0 in M3).
  // --------------------------------------------------------------------------
  const sql = `
    SELECT
      ci.id as city_id, ci.name as city_name, ci.ascii_name, ci.native,
      ci.state_code, ci.type, ci.wiki_data_id,
      ci.tier, ci.capital_type, ci.is_country_capital, ci.is_state_capital,
      ci.latitude, ci.longitude, ci.population, ci.disputed, ci.claimed_by,
      co.id as country_id, co.cca2 as country_cca2, co.cca3 as country_cca3,
      co.name as country_name, co.flag_emoji as country_flag, co.capital as country_capital,
      ar.id as admin_id, ar.name as admin_name,
      tz.id as timezone_id, tz.current_offset as utc_offset,
      tz.current_abbreviation as tz_abbrev, tz.is_dst,
      fts.rank as fts_rank,
      ci.display_name, ci.short_name, ci.geonames_id,
      ci.source_primary, ci.merge_method,
      ci.wiki_url
    FROM place_names_fts fts
    JOIN place_names pn ON pn.id = fts.rowid
    JOIN cities ci ON ci.id = pn.canonical_place_id
    JOIN countries co ON co.id = ci.country_id
    LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
    LEFT JOIN time_zones tz ON tz.id = ci.timezone
    WHERE place_names_fts MATCH '${safeFts}'
      AND ci.is_active = 1
    ORDER BY fts.rank
    LIMIT 200
  `;

  let ftsResults: RawResult[];
  try {
    const result = await c.env.DB.prepare(sql).all<RawResult>();
    ftsResults = result.results || [];
  } catch (err) {
    // FTS5 may throw on malformed queries (rare since we sanitize).
    // Surface as 400 with the FTS5 error message for debugging.
    return c.json(
      { success: false as const, error: { code: "SEARCH_FAILED", message: String(err) } },
      400
    );
  }

  // --------------------------------------------------------------------------
  // STEP 4: Cross-language fallback (M6)
  // --------------------------------------------------------------------------
  // If FTS5 returns 0 results AND the user provided a language, search the
  // translations table for the city's name in that language.
  //
  // Example: ?q=東京&lang=ja → FTS5 has no match → translations table has
  // Tokyo's Japanese name → return Tokyo.
  //
  // Note: language code is normalized to lowercase for matching (dr5hn uses
  // mixed case 'zh-CN', 'pt-BR').
  // --------------------------------------------------------------------------
  if (ftsResults.length === 0 && lang) {
    const langLower = lang.toLowerCase();
    const translationSql = `
      SELECT
        ci.id as city_id, ci.name as city_name, ci.ascii_name, ci.native,
        ci.state_code, ci.type, ci.wiki_data_id,
        ci.tier, ci.capital_type, ci.is_country_capital, ci.is_state_capital,
        ci.latitude, ci.longitude, ci.population, ci.disputed, ci.claimed_by,
        co.id as country_id, co.cca2 as country_cca2, co.cca3 as country_cca3,
        co.name as country_name, co.flag_emoji as country_flag, co.capital as country_capital,
        ar.id as admin_id, ar.name as admin_name,
        tz.id as timezone_id, tz.current_offset as utc_offset,
        tz.current_abbreviation as tz_abbrev, tz.is_dst,
        -10.0 as fts_rank,
        ci.display_name, ci.short_name, ci.geonames_id,
        ci.wiki_url,
        ci.source_primary, ci.merge_method
      FROM translations t
      JOIN cities ci ON ci.id = t.place_id
      JOIN countries co ON co.id = ci.country_id
      LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
      LEFT JOIN time_zones tz ON tz.id = ci.timezone
      WHERE LOWER(t.language) = ?
        AND t.place_type = 'city'
        AND t.translation LIKE ?
        AND ci.is_active = 1
      ORDER BY LENGTH(t.translation) ASC
      LIMIT 50
    `;
    try {
      // Prefix match (`%` after qLower) to support partial typing.
      // Ordered by translation length to prefer shorter (more canonical) names.
      const tr = await c.env.DB.prepare(translationSql).bind(langLower, `${qLower}%`).all<RawResult>();
      ftsResults = tr.results || [];
    } catch {
      // Translation search errors are non-fatal — we just return empty.
    }
  }

  // --------------------------------------------------------------------------
  // STEP 5: Fuzzy fallback (LIKE-based)
  // --------------------------------------------------------------------------
  // If FTS5 + translations both return nothing, fall back to a LIKE search
  // on place_names.normalized_name. This handles:
  //   - Typos that FTS5 BM25 doesn't catch
  //   - Transliteration mismatches
  //   - Edge cases where FTS5 tokenization fails
  //
  // Only runs for queries ≥3 chars (shorter queries are too noisy).
  // --------------------------------------------------------------------------
  if (ftsResults.length === 0 && qNorm.length >= 3) {
    // ------------------------------------------------------------------------
    // Strategy A: search cities.search_name (M11.1 layer column, pre-normalized)
    // ------------------------------------------------------------------------
    // Tries the M11.1 layer's `search_name` column directly. This is faster
    // than joining place_names (no JOIN, single table) and uses our own
    // normalization rules (lowercase + strip diacritics + alphanum only).
    // Catches queries that FTS5 missed but our normalization matches.
    // ------------------------------------------------------------------------
    const searchNameSql = `
      SELECT
        ci.id as city_id, ci.name as city_name, ci.ascii_name,
        ci.tier, ci.capital_type, ci.is_country_capital, ci.is_state_capital,
        ci.latitude, ci.longitude, ci.population, ci.disputed, ci.claimed_by,
        co.id as country_id, co.cca2 as country_cca2, co.cca3 as country_cca3,
        co.name as country_name, co.flag_emoji as country_flag, co.capital as country_capital,
        ar.id as admin_id, ar.name as admin_name,
        tz.id as timezone_id, tz.current_offset as utc_offset,
        tz.current_abbreviation as tz_abbrev, tz.is_dst,
        0.0 as fts_rank,
        ci.wiki_url,
        ci.display_name, ci.short_name, ci.geonames_id,
        ci.source_primary, ci.merge_method
      FROM cities ci
      JOIN countries co ON co.id = ci.country_id
      LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
      LEFT JOIN time_zones tz ON tz.id = ci.timezone
      WHERE ci.search_name LIKE ?
        AND ci.is_active = 1
      ORDER BY LENGTH(ci.search_name) ASC
      LIMIT 30
    `;
    try {
      const searchNameResult = await c.env.DB.prepare(searchNameSql).bind(`${qNorm}%`).all<RawResult>();
      ftsResults = searchNameResult.results || [];
    } catch {
      // Ignore errors — fallback to place_names next
    }
  }

  if (ftsResults.length === 0 && qNorm.length >= 3) {
    // ------------------------------------------------------------------------
    // Strategy A2: alt_names_staging (GeoNames altNames) (M11.1.5)
    // ------------------------------------------------------------------------
    // Joins alt_names_staging on cities.geonames_id. Catches:
    //   - Cross-language: "Москва" → Moscow, "東京" → Tokyo
    //   - Historic renames: "Bombay" → Mumbai, "Chimkent" → Shymkent
    //   - Colloquial: "Big Apple" → New York
    //   - Short names: "St. Pete" → Saint Petersburg
    //
    // Filtered to English/agnostic only (we don't want to match every
    // language in the same query — that's what ?lang= is for).
    //
    // The release_id is hardcoded to the latest GeoNames altnames release
    // we ingested. Future re-ingestions will increment the date suffix.
    // ------------------------------------------------------------------------
    const altNamesSql = `
      SELECT
        ci.id as city_id, ci.name as city_name, ci.ascii_name,
        ci.tier, ci.capital_type, ci.is_country_capital, ci.is_state_capital,
        ci.latitude, ci.longitude, ci.population, ci.disputed, ci.claimed_by,
        co.id as country_id, co.cca2 as country_cca2, co.cca3 as country_cca3,
        co.name as country_name, co.flag_emoji as country_flag, co.capital as country_capital,
        ar.id as admin_id, ar.name as admin_name,
        tz.id as timezone_id, tz.current_offset as utc_offset,
        tz.current_abbreviation as tz_abbrev, tz.is_dst,
        0.0 as fts_rank,
        ci.display_name, ci.short_name, ci.geonames_id,
        ci.source_primary, ci.merge_method
      FROM alt_names_staging ans
      JOIN cities ci ON ci.geonames_id = ans.geonameid
      JOIN countries co ON co.id = ci.country_id
      LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
      LEFT JOIN time_zones tz ON tz.id = ci.timezone
      WHERE LOWER(ans.alternate_name) LIKE LOWER(?)
        AND ans.isolanguage IN ('', 'en')
        AND ans.release_id = ?
        AND ci.is_active = 1
      ORDER BY LENGTH(ans.alternate_name) ASC
      LIMIT 30
    `;
    try {
      const altNamesResult = await c.env.DB.prepare(altNamesSql)
        .bind(`${qNorm}%`, "geonames-altnames-2026-08-02")
        .all<RawResult>();
      ftsResults = altNamesResult.results || [];
    } catch {
      // Ignore errors — fallback to place_names next
    }
  }

  if (ftsResults.length === 0 && qNorm.length >= 3) {
    // ------------------------------------------------------------------------
    // Strategy A3: wikidata_staging.alt_labels_json (M11.2.5)
    // ------------------------------------------------------------------------
    // Joins wikidata_staging on cities.wiki_data_id. Catches alt labels
    // that dr5hn place_names and GeoNames altNames don't have:
    //   - Historic names: "Yedo" / "Jedo" / "Edo" → Tokyo, "Lundenwic" → London
    //   - Colloquial: "Big Smoke" / "The Smoke" → London, "Beantown" → Boston
    //   - Cross-language transliterations: "Peking" → Beijing, "Tokei" → Tokyo
    //   - Variant spellings: "Bombay" → Mumbai, "Calcutta" → Kolkata
    //   - Disambiguators: "London, UK", "Tokyo (Japan)"
    //
    // The alt_labels_json column is a JSON array of strings. We do an exact
    // quoted-substring match (`%"yedo"%`) to avoid matching substrings of
    // longer alt names (e.g. "Tokyo" should match "Tokyo" but not "Tokyo-to").
    //
    // For multi-word queries (e.g. "big smoke"), use the full qLower string
    // (with spaces) so we match multi-word alt labels as phrases. For
    // single-word queries, both qNorm and qLower are equivalent.
    //
    // Notes:
    //   - 45,517 of 115,731 entities have non-empty alt_labels
    //   - 91,500+ alt labels total across the dataset
    //   - Case-insensitive (LOWER on both sides)
    //   - The release_id is hardcoded to the latest Wikidata release
    // ------------------------------------------------------------------------
    // For multi-word queries, match the full phrase. For single-word, the
    // existing strategies already handle those; this strategy is for what
    // they miss. qLower retains spaces, qNorm does not.
    const wikidataPattern = qLower.includes(" ")
      ? `%"${qLower}"%`
      : `%"${qNorm}"%`;
    const wikidataAltSql = `
      SELECT
        ci.id as city_id, ci.name as city_name, ci.ascii_name,
        ci.tier, ci.capital_type, ci.is_country_capital, ci.is_state_capital,
        ci.latitude, ci.longitude, ci.population, ci.disputed, ci.claimed_by,
        co.id as country_id, co.cca2 as country_cca2, co.cca3 as country_cca3,
        co.name as country_name, co.flag_emoji as country_flag, co.capital as country_capital,
        ar.id as admin_id, ar.name as admin_name,
        tz.id as timezone_id, tz.current_offset as utc_offset,
        tz.current_abbreviation as tz_abbrev, tz.is_dst,
        0.0 as fts_rank,
        ci.wiki_url,
        ci.display_name, ci.short_name, ci.geonames_id,
        ci.source_primary, ci.merge_method,
        1 as from_wikidata_alt
      FROM wikidata_staging ws
      JOIN cities ci ON ci.wiki_data_id = ws.qid
      JOIN countries co ON co.id = ci.country_id
      LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
      LEFT JOIN time_zones tz ON tz.id = ci.timezone
      WHERE LOWER(ws.alt_labels_json) LIKE LOWER(?)
        AND ws.release_id = ?
        AND ci.is_active = 1
      ORDER BY LENGTH(ci.name) ASC
      LIMIT 30
    `;
    try {
      const wikidataAltResult = await c.env.DB.prepare(wikidataAltSql)
        .bind(wikidataPattern, "wikidata-entities-2026-08-02")
        .all<RawResult>();
      ftsResults = wikidataAltResult.results || [];
    } catch {
      // Ignore errors — fallback to place_names next
    }
  }

  if (ftsResults.length === 0 && qNorm.length >= 3) {
    // ------------------------------------------------------------------------
    // Strategy B: place_names.normalized_name (legacy fallback)
    // ------------------------------------------------------------------------
    // Joins to the place_names table for alt-name matching. Slower than
    // search_name but covers more aliases (translations, abbreviations, etc.).
    // ------------------------------------------------------------------------
    const fuzzySql = `
      SELECT
        ci.id as city_id, ci.name as city_name, ci.ascii_name,
        ci.tier, ci.capital_type, ci.is_country_capital, ci.is_state_capital,
        ci.latitude, ci.longitude, ci.population, ci.disputed, ci.claimed_by,
        co.id as country_id, co.cca2 as country_cca2, co.cca3 as country_cca3,
        co.name as country_name, co.flag_emoji as country_flag, co.capital as country_capital,
        ar.id as admin_id, ar.name as admin_name,
        tz.id as timezone_id, tz.current_offset as utc_offset,
        tz.current_abbreviation as tz_abbrev, tz.is_dst,
        0.0 as fts_rank,
        ci.display_name, ci.short_name, ci.geonames_id,
        ci.source_primary, ci.merge_method
      FROM place_names pn
      JOIN cities ci ON ci.id = pn.canonical_place_id
      JOIN countries co ON co.id = ci.country_id
      LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
      LEFT JOIN time_zones tz ON tz.id = ci.timezone
      WHERE pn.normalized_name LIKE ?
        AND ci.is_active = 1
      ORDER BY LENGTH(pn.normalized_name) ASC
      LIMIT 50
    `;
    try {
      const fuzzyResult = await c.env.DB.prepare(fuzzySql).bind(`${qNorm}%`).all<RawResult>();
      ftsResults = fuzzyResult.results || [];
    } catch {
      // Ignore fuzzy errors — FTS5 result is empty anyway
    }
  }

  // Deduplicate by city_id (same city may have multiple place_names matches)
  const byCityId = new Map<number, RawResult>();
  for (const r of ftsResults) {
    if (!byCityId.has(r.city_id)) byCityId.set(r.city_id, r);
    else {
      const existing = byCityId.get(r.city_id)!;
      // Keep the one with better fts_rank (more negative = better)
      if (r.fts_rank < existing.fts_rank) byCityId.set(r.city_id, r);
    }
  }
  const unique = Array.from(byCityId.values());

  // Determine match type
  for (const r of unique) {
    const name = r.city_name.toLowerCase();
    const ascii = (r.ascii_name || "").toLowerCase();
    if (name === qLower || ascii === qLower) r.match_type = "exact";
    else if (name.startsWith(qLower) || ascii.startsWith(qLower)) r.match_type = "prefix";
    else if ((r as any).from_wikidata_alt) r.match_type = "alt_label";
    else r.match_type = "fuzzy";
  }

  // Score and rank
  const ctx = { userCountry: country, userState: state, userLang: lang, userLat: lat, userLon: lon };
  const scored = unique.map((r) => {
    const { score, distanceKm } = scoreResult(r, q, qLower, qNorm, ctx);
    return { ...r, score, distanceKm };
  });

  // Same-name handling: when multiple cities share the same name (e.g. Phoenix,
  // Monterrey, Perth, Hyderabad), apply these rules IN ORDER:
  //   1. If user's state is provided: state match wins (handled by scoreResult state boost)
  //   2. If user's country is provided:
  //      a. Among same-name same-country cities: prefer the one with HIGHER population
  //         (e.g. Phoenix AZ 1.65M beats Phoenix OR 4.5K — even if OR is flagged as
  //         a state capital in dr5hn data, AZ is the "real" Phoenix)
  //      b. If populations are equal/missing, fall back to capital status
  //      c. Strong boost for user-country match, penalty for non-user-country
  //   3. If no user country: all same-name cities are equal (base score)
  const nameCounts = new Map<string, number>();
  for (const r of scored) nameCounts.set(r.city_name, (nameCounts.get(r.city_name) || 0) + 1);

  // Group by (name, country) for same-name same-country analysis
  const groups = new Map<string, typeof scored>();
  for (const r of scored) {
    if ((nameCounts.get(r.city_name) || 0) > 1) {
      const key = `${r.city_name}|${r.country_cca2}`;
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key)!.push(r);
    }
  }

  // For each same-name same-country group, find max population and apply bonus
  for (const [, group] of groups) {
    const maxPop = Math.max(0, ...group.map((r) => r.population || 0));
    for (const r of group) {
      // Population-based ranking within group: the city with max pop gets +600,
      // others get proportional share. Cities with no pop get 0.
      if (r.population && r.population > 0) {
        const ratio = r.population / maxPop;
        r.score += Math.round(600 * ratio);
      }
      // Capital status as a smaller tiebreaker: +100 (was dominant at 800, demoted
      // because dr5hn data has some is_state_capital errors)
      if (r.is_country_capital) r.score += 100;
      if (r.is_state_capital) r.score += 50;
    }
  }

  // Cross-country same-name boost (only for user country)
  for (const r of scored) {
    const cnt = nameCounts.get(r.city_name) || 1;
    if (cnt > 1 && country) {
      if (r.country_cca2 === country) {
        r.score += 200; // user-country match
      } else {
        r.score -= 150; // non-user-country same-name
      }
    }
  }

  // Sort by score desc
  scored.sort((a, b) => b.score - a.score);

  // Take top N
  const top = scored.slice(0, limit);

  // Build response
  const results = top.map((r) => ({
    id: r.city_id,
    name: r.city_name,
    asciiName: r.ascii_name,
    native: r.native,
    stateCode: r.state_code,
    type: r.type,
    wikiDataId: r.wiki_data_id,
    tier: r.tier,
    capitalType: r.capital_type,
    isCountryCapital: r.is_country_capital === 1,
    isStateCapital: r.is_state_capital === 1,
    disputed: r.disputed === 1,
    claimedBy: r.claimed_by ? String(r.claimed_by).split(",").map((s: string) => s.trim()) : null,
    latitude: r.latitude,
    longitude: r.longitude,
    population: r.population,
    country: {
      id: r.country_id,
      cca2: r.country_cca2,
      cca3: r.country_cca3,
      name: r.country_name,
      flag: r.country_flag,
      capital: r.country_capital,
    },
    adminRegion: r.admin_id
      ? { id: r.admin_id, name: r.admin_name, country_id: r.country_id }
      : null,
    timezone: {
      id: r.timezone_id,
      utc_offset_minutes: r.utc_offset,
      current_abbreviation: r.tz_abbrev,
      is_dst: r.is_dst,
    },
    distanceKm: r.distanceKm,
    score: r.score,
    matchType: r.match_type,
    // M11.1 layer fields
    displayName: r.display_name ?? null,
    shortName: r.short_name ?? null,
    geonamesId: r.geonames_id ?? null,
    sourcePrimary: r.source_primary ?? null,
    mergeMethod: r.merge_method ?? null,
    // M11.2 Wikidata
    wikiUrl: r.wiki_url ?? null,
  }));

  // --------------------------------------------------------------------------
  // STEP 8: "Did you mean" suggestions when 0 results (M10+)
  // --------------------------------------------------------------------------
  // When the search returns no exact/prefix/fuzzy matches, return suggestions
  // to help the user find what they meant. Three strategies, in order:
  //
  //   1. Substring match (LIKE %q%) — finds cities containing the query as
  //      a substring (e.g. "Tok" → Tokyo, Tokat, Tokushima).
  //   2. Trigram match — for very long or unusual queries (e.g. "vinjanam-
  //      padu" → cities sharing 3-grams like "vin", "inj", "nja", "jan").
  //   3. Same-country fallback — if user provided ?country=, return top
  //      cities in that country. Useful for villages below the dataset
  //      threshold (e.g. searching "vinjanampadu" with ?country=IN returns
  //      nearby major Indian cities).
  //
  // Each suggestion is tagged with its matchType so the caller can show
  // "did you mean" UI.
  //
  // Suggestions are returned in `data.suggestions` ONLY when results=0.
  // When results>0, this field is omitted to keep the response clean.
  // --------------------------------------------------------------------------
  let suggestions: { query: string; count: number; results: unknown[] } | null = null;
  if (unique.length === 0 && qNorm.length >= 2) {
    // ----- Strategy 1: Substring match -----
    let sugRows: any[] = [];
    if (isAscii) {
      const substringSql = `
        SELECT
          ci.id as city_id, ci.name as city_name, ci.ascii_name, ci.latitude, ci.longitude,
          co.id as country_id, co.cca2 as country_cca2, co.name as country_name,
          ar.id as admin_id, ar.name as admin_name,
          tz.id as timezone_id, tz.current_offset, tz.current_abbreviation, tz.is_dst,
          'substring' as match_type,
          LENGTH(ci.name) as name_len
        FROM cities ci
        JOIN countries co ON co.id = ci.country_id
        LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
        LEFT JOIN time_zones tz ON tz.id = ci.timezone
        WHERE ci.is_active = 1
          AND (
            LOWER(ci.name) LIKE ?1
            OR LOWER(COALESCE(ci.ascii_name, '')) LIKE ?1
          )
        ORDER BY
          CASE WHEN LOWER(ci.name) LIKE ?2 THEN 0 ELSE 1 END,
          LENGTH(ci.name) ASC,
          ci.population DESC NULLS LAST
        LIMIT 5
      `;
      try {
        const sugResult = await c.env.DB.prepare(substringSql)
          .bind(`%${qLower}%`, `${qLower}%`)
          .all();
        sugRows = sugResult.results || [];
      } catch {
        // Ignore
      }
    }

    // ----- Strategy 2: Trigram match (for long/unique queries) -----
    // For queries >= 6 chars that got 0 substring matches, use 4-grams from
    // the start of the query to find cities sharing that prefix chunk.
    // We use 4-grams (not 3) for higher precision and only the first 2
    // trigrams to avoid noise.
    //
    // Example: "vinjanampadu" → trigrams ["vinj", "anja"] → cities starting
    // with "vinj" (Vinja, Vinjani) or containing "anja" (Anjan, Anja).
    //
    // This catches sub-threshold villages that share a chunk with a known
    // city, and misspellings.
    //
    // We append these as additional suggestions rather than replacing the
    // country fallback, so a query like "vinjanampadu" with ?country=IN
    // returns BOTH "Vinjani" (similar name) AND "Mumbai/Delhi" (country top
    // cities). Order: substring → trigram → country-fallback.
    if (isAscii && qNorm.length >= 6) {
      // Take 2 trigrams: from start (most distinguishing) and from middle
      const trigrams: string[] = [];
      if (qNorm.length >= 4) trigrams.push(qNorm.substring(0, 4));
      if (qNorm.length >= 8) trigrams.push(qNorm.substring(4, 8));
      // Filter to trigrams that contain at least one vowel (skip consonant-only)
      // This eliminates noise like "xyz" matching "xyzzy"
      const meaningfulTrigrams = trigrams.filter((t) => /[aeiouy]/.test(t));
      if (meaningfulTrigrams.length > 0) {
        const triConditions = meaningfulTrigrams.map(() => `LOWER(ci.name) LIKE ?`).join(" OR ");
        const triParams = meaningfulTrigrams.map((t) => `%${t}%`);
        const trigramSql = `
          SELECT
            ci.id as city_id, ci.name as city_name, ci.ascii_name, ci.latitude, ci.longitude,
            co.id as country_id, co.cca2 as country_cca2, co.name as country_name,
            ar.id as admin_id, ar.name as admin_name,
            tz.id as timezone_id, tz.current_offset, tz.current_abbreviation, tz.is_dst,
            'trigram' as match_type,
            LENGTH(ci.name) as name_len
          FROM cities ci
          JOIN countries co ON co.id = ci.country_id
          LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
          LEFT JOIN time_zones tz ON tz.id = ci.timezone
          WHERE ci.is_active = 1
            AND (${triConditions})
          ORDER BY
            LENGTH(ci.name) ASC,
            ci.population DESC NULLS LAST
          LIMIT 2
        `;
        try {
          const sugResult = await c.env.DB.prepare(trigramSql).bind(...triParams).all();
          // Append trigram results (limit 2 so country fallback still runs)
          sugRows = [...sugRows, ...((sugResult.results || []) as any[])];
        } catch {
          // Ignore
        }
      }
    }

    // ----- Strategy 3: Same-country fallback (always run if ?country=) -----
    // If user provided ?country=, ALWAYS append the top cities in that
    // country (deduped). This ensures "no exact match for your village"
    // still gives the user something useful — the major cities in their
    // country. We dedupe by city_id so the trigram + country-fallback
    // never returns the same city twice.
    if (country) {
      // Dedupe by city_id
      const seenIds = new Set(sugRows.map((r: any) => r.city_id));
      const countryFallbackSql = `
        SELECT
          ci.id as city_id, ci.name as city_name, ci.ascii_name, ci.latitude, ci.longitude,
          co.id as country_id, co.cca2 as country_cca2, co.name as country_name,
          ar.id as admin_id, ar.name as admin_name,
          tz.id as timezone_id, tz.current_offset, tz.current_abbreviation, tz.is_dst,
          'country-fallback' as match_type,
          ci.population
        FROM cities ci
        JOIN countries co ON co.id = ci.country_id
        LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
        LEFT JOIN time_zones tz ON tz.id = ci.timezone
        WHERE ci.is_active = 1
          AND co.cca2 = ?
          AND ci.tier IN ('tier1', 'tier2', 'tier3')
        ORDER BY
          ci.is_country_capital DESC,
          ci.is_state_capital DESC,
          ci.population DESC NULLS LAST
        LIMIT 5
      `;
      try {
        const sugResult = await c.env.DB.prepare(countryFallbackSql).bind(country.toUpperCase()).all();
        for (const r of (sugResult.results || []) as any[]) {
          if (!seenIds.has(r.city_id)) {
            sugRows.push(r);
            seenIds.add(r.city_id);
          }
        }
      } catch {
        // Ignore
      }
    }

    if (sugRows.length > 0) {
      suggestions = {
        query: q,
        count: sugRows.length,
        results: sugRows.map((r: any) => ({
          id: r.city_id,
          name: r.city_name,
          asciiName: r.ascii_name,
          latitude: r.latitude,
          longitude: r.longitude,
          matchType: r.match_type,
          country: {
            id: r.country_id,
            cca2: r.country_cca2,
            name: r.country_name,
          },
          adminRegion: r.admin_id
            ? { id: r.admin_id, name: r.admin_name }
            : null,
          timezone: {
            id: r.timezone_id,
            utc_offset_minutes: r.current_offset,
            current_abbreviation: r.current_abbreviation,
            is_dst: r.is_dst,
          },
        })),
      };
    }
  }

  return c.json(
    {
      success: true as const,
      data: {
        query: q,
        results,
        total: unique.length,
        tookMs: Date.now() - start,
        ...(suggestions ? { suggestions } : {}),
      },
    },
    200
  );
});

// ============================================================================
// GET /api/v1/cities/:id
// ============================================================================
const cityDetailRoute = createRoute({
  method: "get",
  path: "/api/v1/cities/{id}",
  summary: "Get city detail by ID",
  description:
    "Returns the full record for a single city: name, country, admin region, " +
    "timezone, capital status, tier, dr5hn enrichment (type, native, stateCode, " +
    "wikiDataId, parentId), known place names, and postcodes (sample + total).",
  tags: ["Cities"],
  request: {
    params: z.object({ id: z.coerce.number().int().positive() }),
  },
  responses: {
    200: { content: { "application/json": { schema: CityDetailResponse } }, description: "City detail" },
    404: { content: { "application/json": { schema: ErrorResponse } }, description: "City not found" },
  },
});

cities.openapi(cityDetailRoute, async (c) => {
  const { id } = c.req.valid("param");

  // --------------------------------------------------------------------------
  // STEP 1: Fetch the main city row + joined country, admin region, timezone
  // --------------------------------------------------------------------------
  // Single query that pulls everything we need for the city record:
  //   - cities.* (dr5hn enrichment: native, type, state_code, wiki_data_id, etc.)
  //   - countries.* (name, flag, capital, ISO codes)
  //   - administrative_regions.* (state/province) — LEFT JOIN because some
  //     cities (e.g. Vatican City, dependencies) don't have an admin region
  //   - time_zones.* (current offset, abbreviation, DST) — LEFT JOIN for safety
  //   - data quality fields (M8): timezone_confidence, source, flags
  //
  // .first() returns undefined if no row matches → we 404 below.
  // --------------------------------------------------------------------------
  const sql = `
    SELECT
      ci.id, ci.name, ci.ascii_name, ci.native, ci.state_code, ci.type, ci.level,
      ci.parent_id, ci.wiki_data_id, ci.flag, ci.tier, ci.capital_type,
      ci.is_country_capital, ci.is_state_capital,
      ci.latitude, ci.longitude, ci.population, ci.elevation,
      ci.disputed, ci.claimed_by, ci.source_id, ci.source_version,
      ci.timezone_confidence, ci.timezone_source, ci.data_quality_flags,
      ci.display_name, ci.short_name, ci.search_name,
      ci.geonames_id, ci.elevation_m, ci.wiki_url,
      ci.source_primary, ci.source_merged_with, ci.merge_method, ci.merge_run_id, ci.merged_at,
      ci.fips_geoid, ci.gisco_id, ci.in_census_code,
      co.id as co_id, co.cca2 as co_cca2, co.cca3 as co_cca3,
      co.name as co_name, co.flag_emoji as co_flag, co.capital as co_capital,
      ar.id as ar_id, ar.name as ar_name, ar.country_id as ar_country_id,
      sub.id as sub_id, sub.name as sub_name, sub.code as sub_code,
      sub.type as sub_type, sub.level as sub_level, sub.geoname_id as sub_geoname_id,
      tz.id as tz_id, tz.current_offset as tz_offset,
      tz.current_abbreviation as tz_abbrev, tz.is_dst as tz_dst
    FROM cities ci
    JOIN countries co ON co.id = ci.country_id
    LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
    LEFT JOIN administrative_regions sub ON sub.id = ci.admin2_id
    LEFT JOIN time_zones tz ON tz.id = ci.timezone
    WHERE ci.id = ?
  `;

  // CityRow type: all columns the SQL returns. Used for type-safe access below.
  // The `?` makes it nullable; .first() returns CityRow | null.
  type CityRow = {
    id: number;
    name: string;
    ascii_name: string | null;
    native: string | null;
    state_code: string | null;
    type: string | null;
    level: number | null;
    parent_id: number | null;
    wiki_data_id: string | null;
    flag: number | null;
    tier: string | null;
    capital_type: string | null;
    is_country_capital: number;
    is_state_capital: number;
    latitude: number;
    longitude: number;
    population: number | null;
    elevation: number | null;
    disputed: number;
    claimed_by: string | null;
    source_id: string | null;
    source_version: string | null;
    timezone_confidence: string | null;
    timezone_source: string | null;
    data_quality_flags: string | null;
    fips_geoid: string | null;
    gisco_id: string | null;
    in_census_code: string | null;
    co_id: number;
    co_cca2: string;
    co_cca3: string | null;
    co_name: string;
    co_flag: string | null;
    co_capital: string | null;
    ar_id: number | null;
    ar_name: string | null;
    ar_country_id: number | null;
    sub_id: number | null;
    sub_name: string | null;
    sub_code: string | null;
    sub_type: string | null;
    sub_level: number | null;
    sub_geoname_id: number | null;
    tz_id: string | null;
    tz_offset: number | null;
    tz_abbrev: string | null;
    tz_dst: number | null;
  };
  const row = await c.env.DB.prepare(sql).bind(id).first<CityRow>();
  if (!row) {
    // City not found — return 404 with the requested ID for debugging.
    return c.json(
      { success: false as const, error: { code: "NOT_FOUND", message: `City ${id} not found` } },
      404
    );
  }

  // --------------------------------------------------------------------------
  // STEP 2: Fetch place_names (English + alt names, no translations)
  // --------------------------------------------------------------------------
  // place_names is the canonical name index populated in migrations 110/111
  // (~451K rows from GeoNames). For each city, we get all known names:
  //   - Official name, ASCII transliteration, alt spellings
  //   - Language code (e.g. 'en', 'ru', 'ja')
  //   - name_type: 'official' | 'ascii' | 'alias' | etc.
  //
  // NOTE: For 19-language translations, use /cities/{id}/translations (M5).
  // This endpoint only shows historical/English-canonical names.
  // --------------------------------------------------------------------------
  const namesResult = await c.env.DB.prepare(
    `SELECT name, language_code, name_type FROM place_names WHERE canonical_place_id = ? ORDER BY is_preferred DESC, name_type ASC`
  ).bind(id).all<{ name: string; language_code: string | null; name_type: string }>();
  const placeNames = (namesResult.results || []).map((n) => ({
    name: n.name,
    language: n.language_code,
    type: n.name_type,
  }));

  // --------------------------------------------------------------------------
  // STEP 3: Fetch postcodes (M4) — state-scoped
  // --------------------------------------------------------------------------
  // Postcodes are joined to state (not city) because dr5hn postcodes have
  // NULL city_id. We return:
  //   - total: count of postcodes in the same state (1-50K depending on country)
  //   - sample: first 5 (full list via /cities/{id}/postcodes?page=N)
  //
  // Cities without a state (state_id IS NULL) get null postcodes.
  // --------------------------------------------------------------------------
  let postcodesData: { total: number; sample: Array<{ code: string; localityName: string | null; type: string | null; latitude: number | null; longitude: number | null }> } | null = null;
  if (row.ar_id && row.co_id) {
    const totalResult = await c.env.DB.prepare(
      `SELECT COUNT(*) as n FROM postcodes WHERE country_id = ? AND state_id = ?`
    ).bind(row.co_id, row.ar_id).first<{ n: number }>();
    const sampleResult = await c.env.DB.prepare(
      `SELECT code, locality_name, type, latitude, longitude
       FROM postcodes
       WHERE country_id = ? AND state_id = ?
       ORDER BY id
       LIMIT 5`
    ).bind(row.co_id, row.ar_id).all<{ code: string; locality_name: string | null; type: string | null; latitude: number | null; longitude: number | null }>();
    postcodesData = {
      total: totalResult?.n ?? 0,
      sample: (sampleResult.results || []).map((p) => ({
        code: p.code,
        localityName: p.locality_name,
        type: p.type,
        latitude: p.latitude,
        longitude: p.longitude,
      })),
    };
  }

  // --------------------------------------------------------------------------
  // STEP 4: Fetch translations count + language list (M5)
  // --------------------------------------------------------------------------
  // Lightweight query: just the language codes, not the translations themselves.
  // For full translations, use /cities/{id}/translations (returns the actual text).
  // Ordered alphabetically for consistent client display.
  // --------------------------------------------------------------------------
  const translationsResult = await c.env.DB.prepare(
    `SELECT language FROM translations WHERE place_id = ? AND place_type = 'city' ORDER BY language`
  ).bind(id).all<{ language: string }>();
  const translations = {
    available: translationsResult.results?.length || 0,
    languages: (translationsResult.results || []).map((t) => t.language),
  };

  // --------------------------------------------------------------------------
  // STEP 4.5: Fetch Wikidata description (M11.2.6)
  // --------------------------------------------------------------------------
  // For cities with a wiki_data_id, look up the Wikidata staging row to get:
  //   - english_label: canonical Wikidata English name (may differ from dr5hn name)
  //   - alt_labels_json: JSON array of alt labels (alternative names, misspellings)
  //
  // The "description" field combines these for SEO/tooltip use:
  //   "Wikidata label" if no alts
  //   "Wikidata label (also known as first alt)" if alts exist
  //
  // Only fires for ~85% of cities (those with wiki_data_id). The query is O(1)
  // because wiki_data_id is unique per city in our join.
  //
  // We do NOT add wikidata to the search endpoint — that would add latency
  // to every search query. Description is for the detail page only.
  // --------------------------------------------------------------------------
  let wikidataBlock: {
    label: string | null;
    altLabels: string[];
    description: string | null;
  } | null = null;
  if (row.wiki_data_id) {
    const wikiRow = await c.env.DB.prepare(
      `SELECT english_label, alt_labels_json FROM wikidata_staging WHERE qid = ? LIMIT 1`
    ).bind(row.wiki_data_id).first<{ english_label: string | null; alt_labels_json: string | null }>();
    if (wikiRow) {
      let altLabels: string[] = [];
      if (wikiRow.alt_labels_json && wikiRow.alt_labels_json !== "[]") {
        try {
          const parsed = JSON.parse(wikiRow.alt_labels_json);
          if (Array.isArray(parsed)) {
            // Limit to first 5 alt labels to keep response size reasonable
            altLabels = parsed.slice(0, 5).map((s: any) => String(s));
          }
        } catch {
          // Malformed JSON, ignore
        }
      }
      const label = wikiRow.english_label ?? row.name;
      const firstAlt = altLabels[0];
      // Build description: "Label" or "Label (also known as First Alt)"
      const description = firstAlt ? `${label} (also known as ${firstAlt})` : label;
      wikidataBlock = {
        label: wikiRow.english_label,
        altLabels,
        description,
        instanceOf: null,
        countryQid: null,
        adminQid: null,
        timezoneQid: null,
      };
    } else {
      // City has wiki_data_id but no wikidata_staging row (3,618 cases —
      // wikidata ingestion didn't fetch every QID). Return an empty block
      // with label=NULL so the client can tell this apart from "no wiki data".
      wikidataBlock = {
        label: null,
        altLabels: [],
        description: null,
        instanceOf: null,
        countryQid: null,
        adminQid: null,
        timezoneQid: null,
      };
    }

    // M11.2.8: Look up Wikidata P-code properties (P31, P17, P131, P421)
    const wikiQid = row.wiki_data_id;
    if (wikiQid) {
      const propsRow = await c.env.DB.prepare(
        `SELECT instance_of, country_qid, admin_qid, timezone_qid
         FROM wikidata_properties
         WHERE qid = ? LIMIT 1`
      ).bind(wikiQid).first<{
        instance_of: string | null;
        country_qid: string | null;
        admin_qid: string | null;
        timezone_qid: string | null;
      }>();
      if (propsRow && wikidataBlock) {
        wikidataBlock.instanceOf = propsRow.instance_of;
        wikidataBlock.countryQid = propsRow.country_qid;
        wikidataBlock.adminQid = propsRow.admin_qid;
        wikidataBlock.timezoneQid = propsRow.timezone_qid;
      }
    }
  }

  // --------------------------------------------------------------------------
  // STEP 4.6: Fetch US Census data (M11.5)
  // --------------------------------------------------------------------------
  // For US cities with a FIPS geoid, look up the Census attributes:
  //   - fips_state/place/geoid: 2/5/7-digit FIPS codes
  //   - legal_class: "city", "town", "CDP", "borough", "village"
  //   - land_area_sqmi, water_area_sqmi: from Gazetteer
  //   - internal_lat, internal_lon: gazetteer internal point
  //   - pop_2020..pop_2025: annual population estimates
  //   - estimates_base_2020: April 2020 anchor
  //
  // This block is only populated for US cities that the Census Bureau tracks
  // (~14,500 of our 17,055 US cities). For non-US cities or US cities without
  // a FIPS code, this block is null.
  //
  // Performance: O(1) lookup by city_id. Adds ~5-10ms to detail calls.
  // --------------------------------------------------------------------------
  let censusBlock: {
    fips: { state: string | null; place: string | null; geoid: string | null };
    legalClass: string | null;
    functionalStatus: string | null;
    landAreaSqMi: number | null;
    waterAreaSqMi: number | null;
    densityPerSqMi: number | null;
    internalLat: number | null;
    internalLon: number | null;
    populationTimeSeries: Array<{ year: number; population: number | null }>;
    populationLatest: number | null;
    populationYear: number | null;
    estimatesBase2020: number | null;
    vintage: string | null;
  } | null = null;
  if (row.fips_geoid) {
    const censusRow = await c.env.DB.prepare(
      `SELECT
        fips_state, fips_place, fips_geoid, lsad_code, legal_class, funcstat,
        land_area_sqmi, water_area_sqmi, internal_lat, internal_lon,
        pop_2020, pop_2021, pop_2022, pop_2023, pop_2024, pop_2025,
        estimates_base_2020, release_id
       FROM us_census_attributes
       WHERE city_id = ? LIMIT 1`
    ).bind(id).first<any>();
    if (censusRow) {
      const pop2025 = censusRow.pop_2025 as number | null;
      const landArea = censusRow.land_area_sqmi as number | null;
      const density = (pop2025 && landArea && landArea > 0)
        ? Math.round((pop2025 / landArea) * 10) / 10
        : null;
      // Build population time series (only include years with non-null data)
      const popSeries: Array<{ year: number; population: number | null }> = [];
      for (const [year, key] of [
        [2020, "pop_2020"], [2021, "pop_2021"], [2022, "pop_2022"],
        [2023, "pop_2023"], [2024, "pop_2024"], [2025, "pop_2025"]
      ] as const) {
        popSeries.push({ year, population: censusRow[key] as number | null });
      }
      // Determine vintage from release_id (e.g. "us-census-sub-est-2025-..." → "vintage-2025")
      const vintageMatch = censusRow.release_id?.match(/sub-est-(\d{4})/);
      const vintage = vintageMatch ? `vintage-${vintageMatch[1]}` : null;
      censusBlock = {
        fips: {
          state: censusRow.fips_state,
          place: censusRow.fips_place,
          geoid: censusRow.fips_geoid,
        },
        legalClass: censusRow.legal_class,
        functionalStatus: censusRow.funcstat,
        landAreaSqMi: landArea,
        waterAreaSqMi: censusRow.water_area_sqmi as number | null,
        densityPerSqMi: density,
        internalLat: censusRow.internal_lat as number | null,
        internalLon: censusRow.internal_lon as number | null,
        populationTimeSeries: popSeries,
        populationLatest: pop2025,
        populationYear: pop2025 !== null ? 2025 : null,
        estimatesBase2020: censusRow.estimates_base_2020 as number | null,
        vintage,
      };
    }
  }

  // --------------------------------------------------------------------------
  // STEP 4.7: Fetch Eurostat LAU + URAU data (M11.6)
  // --------------------------------------------------------------------------
  // For EU cities with a gisco_id, look up the Eurostat LAU attributes:
  //   - lau: official LAU ID, name, population (2024), density, area
  //   - urau: URAU city code, name, FUA (Functional Urban Area) code+name
  //
  // LAU is pan-EU (30 countries, ~98K records). URAU is pan-EU for the
  // ~739 cities that have a FUA classification. Population is null for
  // FR/ES/AL/IS/RS due to national privacy laws.
  //
  // This block is only populated for EU cities (~80K in our DB). For non-EU
  // cities or EU cities without a gisco_id, this block is null.
  // --------------------------------------------------------------------------
  let eurostatBlock: {
    lau: {
      giscoId: string | null;
      lauName: string | null;
      population: number | null;
      populationDensity: number | null;
      areaKm2: number | null;
      year: number | null;
    } | null;
    urau: {
      urauCode: string | null;
      urauName: string | null;
      fuaCode: string | null;
      fuaName: string | null;
      areaSqKm: number | null;
      nuts3Code: string | null;
    } | null;
  } | null = null;
  if (row.gisco_id) {
    // Fetch both LAU and URAU in parallel (but Cloudflare Workers D1 doesn't
    // have native parallel; we just await sequentially — fast enough)
    const lauRow = await c.env.DB.prepare(
      `SELECT gisco_id, lau_name, pop_2024, pop_density_2024, area_km2, year
       FROM eu_lau_attributes
       WHERE city_id = ? LIMIT 1`
    ).bind(id).first<any>();

    const urauRow = await c.env.DB.prepare(
      `SELECT urau_code, urau_name, fua_code, fua_name, area_sqm, nuts3_code
       FROM eu_urau_attributes
       WHERE city_id = ? LIMIT 1`
    ).bind(id).first<any>();

    eurostatBlock = {
      lau: lauRow
        ? {
            giscoId: lauRow.gisco_id,
            lauName: lauRow.lau_name,
            population: lauRow.pop_2024 as number | null,
            populationDensity: lauRow.pop_density_2024 as number | null,
            areaKm2: lauRow.area_km2 as number | null,
            year: lauRow.year as number | null,
          }
        : null,
      urau: urauRow
        ? {
            urauCode: urauRow.urau_code,
            urauName: urauRow.urau_name,
            fuaCode: urauRow.fua_code as string | null,
            fuaName: urauRow.fua_name as string | null,
            // area_sqm is in km² (despite name), per Eurostat docs
            areaSqKm: urauRow.area_sqm as number | null,
            nuts3Code: urauRow.nuts3_code as string | null,
          }
        : null,
    };
  }

  // --------------------------------------------------------------------------
  // STEP 4.8: Fetch Census of India 2011 data (M11.7)
  // --------------------------------------------------------------------------
  // For Indian cities, look up the Census of India 2011 attributes:
  //   - population (TOT_P), sex ratio, literacy rate, workers
  //   - ua_code + ua_name: parent Urban Agglomeration
  //   - census_code: 6-digit town code (the join key)
  //
  // This block is only populated for IN cities that were matched to the
  // 2011 Census PCA-UA dataset (1,946 statutory cities + 902 OGs).
  // For non-Indian cities or unmatched Indian cities, this block is null.
  // --------------------------------------------------------------------------
  let censusIndiaBlock: {
    censusCode: string | null;
    stateCode: string | null;
    districtCode: string | null;
    uaCode: string | null;
    uaName: string | null;
    level: number | null;
    households: number | null;
    population: number | null;
    malePopulation: number | null;
    femalePopulation: number | null;
    sexRatio: number | null;
    childPopulation: number | null;
    childSexRatio: number | null;
    scPopulation: number | null;
    stPopulation: number | null;
    literacyRate: number | null;
    workersTotal: number | null;
    mainWorkers: number | null;
    marginalWorkers: number | null;
    nonWorkers: number | null;
    censusYear: number | null;
  } | null = null;
  if (row.in_census_code) {
    const censusRow = await c.env.DB.prepare(
      `SELECT census_code, state_code, district_code, ua_code, ua_name, level,
              households, population, male_population, female_population,
              child_population, child_male, child_female,
              sc_population, st_population,
              literate_population, workers_total, main_workers, marginal_workers, non_workers,
              census_year
       FROM in_census_attributes
       WHERE city_id = ? LIMIT 1`
    ).bind(id).first<any>();

    if (censusRow) {
      // Compute derived metrics
      const sexRatio = censusRow.male_population && censusRow.male_population > 0
        ? Math.round((censusRow.female_population * 1000) / censusRow.male_population)
        : null;
      const childSexRatio = censusRow.child_male && censusRow.child_male > 0
        ? Math.round((censusRow.child_female * 1000) / censusRow.child_male)
        : null;
      const literacyRate = censusRow.population && censusRow.population > 0 && censusRow.literate_population
        ? Math.round((censusRow.literate_population * 1000) / censusRow.population) / 10  // percentage to 1 decimal
        : null;

      censusIndiaBlock = {
        censusCode: censusRow.census_code,
        stateCode: censusRow.state_code,
        districtCode: censusRow.district_code,
        uaCode: censusRow.ua_code,
        uaName: censusRow.ua_name,
        level: censusRow.level as number | null,
        households: censusRow.households as number | null,
        population: censusRow.population as number | null,
        malePopulation: censusRow.male_population as number | null,
        femalePopulation: censusRow.female_population as number | null,
        sexRatio,
        childPopulation: censusRow.child_population as number | null,
        childSexRatio,
        scPopulation: censusRow.sc_population as number | null,
        stPopulation: censusRow.st_population as number | null,
        literacyRate,
        workersTotal: censusRow.workers_total as number | null,
        mainWorkers: censusRow.main_workers as number | null,
        marginalWorkers: censusRow.marginal_workers as number | null,
        nonWorkers: censusRow.non_workers as number | null,
        censusYear: censusRow.census_year as number | null,
      };
    }
  }

  // --------------------------------------------------------------------------
  // STEP 4.9: Fetch ACS 5-year estimates (M11.5.1)
  // --------------------------------------------------------------------------
  // For US cities with a FIPS GEOID, look up the 2018-2022 ACS 5-year
  // Sex by Age data (B01001):
  //   - total population, male, female
  //   - age breakdown: under 5, 5-17, 18-24, 25-44, 45-64, 65+
  //
  // This block is only populated for US cities matched to the ACS Summary File
  // (~14,450 of our 17,055 US cities).
  // For non-US cities or unmatched US cities, this block is null.
  // --------------------------------------------------------------------------
  let acsBlock: {
    fipsGeoid: string | null;
    totalPopulation: number | null;
    malePopulation: number | null;
    femalePopulation: number | null;
    ageBreakdown: {
      under5: number | null;
      age5to17: number | null;
      age18to24: number | null;
      age25to44: number | null;
      age45to64: number | null;
      age65plus: number | null;
    } | null;
    acsYear: number | null;
  } | null = null;
  // M11.5.1 expand: ACS Income + Education blocks
  let acsIncomeBlock: {
    fipsGeoid: string | null;
    medianIncome: number | null;
    acsYear: number | null;
  } | null = null;
  let acsEducationBlock: {
    fipsGeoid: string | null;
    population25Plus: number | null;
    lessThanHs: number | null;
    hsOrGed: number | null;
    someCollege: number | null;
    associateDegree: number | null;
    bachelorDegree: number | null;
    graduateDegree: number | null;
    bachelorOrHigher: number | null;
    bachelorOrHigherPct: number | null;
    acsYear: number | null;
  } | null = null;
  // M11.5.1 expand 2: Tenure (B25003) + Transport (B08301)
  let acsTenureBlock: {
    fipsGeoid: string | null;
    totalOccupied: number | null;
    ownerOccupied: number | null;
    renterOccupied: number | null;
    ownerOccupiedPct: number | null;
    renterOccupiedPct: number | null;
    acsYear: number | null;
  } | null = null;
  let acsTransportBlock: {
    fipsGeoid: string | null;
    totalWorkers: number | null;
    carOrVan: number | null;
    droveAlone: number | null;
    publicTransport: number | null;
    workedAtHome: number | null;
    acsYear: number | null;
  } | null = null;
  if (row.fips_geoid) {
    // M11.5.1 expand: Combine all 3 ACS queries into one for performance.
    // 3-way LEFT JOIN: us_acs_attributes (Sex by Age) + us_acs_income_attributes (B19013) + us_acs_education_attributes (B15003)
    // Joined on fips_geoid (us_acs_attributes uses city_id for the join, but fips_geoid is unique)
    const acsCombined = await c.env.DB.prepare(
      `SELECT
         a.fips_geoid, a.total_population, a.male_population, a.female_population,
         a.under_5, a.age_5_to_17, a.age_18_to_24, a.age_25_to_44, a.age_45_to_64, a.age_65_plus,
         a.acs_year,
         i.median_income,
         e.population_25_plus, e.less_than_hs, e.hs_or_ged, e.some_college,
         e.associate_degree, e.bachelor_degree, e.graduate_degree, e.bachelor_or_higher,
         t.total_occupied, t.owner_occupied, t.renter_occupied,
         t.owner_occupied_pct, t.renter_occupied_pct,
         tr.e001, tr.e002, tr.e003, tr.e010, tr.e021,
         tr.car_or_van, tr.public_transport_guess, tr.worked_at_home_guess
       FROM us_acs_attributes a
       LEFT JOIN us_acs_income_attributes i ON i.fips_geoid = a.fips_geoid
       LEFT JOIN us_acs_education_attributes e ON e.fips_geoid = a.fips_geoid
       LEFT JOIN us_acs_tenure_attributes t ON t.fips_geoid = a.fips_geoid
       LEFT JOIN us_acs_transport_attributes tr ON tr.fips_geoid = a.fips_geoid
       WHERE a.city_id = ? LIMIT 1`
    ).bind(id).first<any>();

    if (acsCombined) {
      // Sex by Age block
      acsBlock = {
        fipsGeoid: acsCombined.fips_geoid,
        totalPopulation: acsCombined.total_population as number | null,
        malePopulation: acsCombined.male_population as number | null,
        femalePopulation: acsCombined.female_population as number | null,
        ageBreakdown: {
          under5: acsCombined.under_5 as number | null,
          age5to17: acsCombined.age_5_to_17 as number | null,
          age18to24: acsCombined.age_18_to_24 as number | null,
          age25to44: acsCombined.age_25_to_44 as number | null,
          age45to64: acsCombined.age_45_to_64 as number | null,
          age65plus: acsCombined.age_65_plus as number | null,
        },
        acsYear: acsCombined.acs_year as number | null,
      };

      // Income block
      if (acsCombined.median_income != null) {
        acsIncomeBlock = {
          fipsGeoid: acsCombined.fips_geoid,
          medianIncome: acsCombined.median_income as number | null,
          acsYear: acsCombined.acs_year as number | null,
        };
      }

      // Education block
      if (acsCombined.population_25_plus != null) {
        const pop25plus = acsCombined.population_25_plus as number | null;
        const bachHigher = acsCombined.bachelor_or_higher as number | null;
        const bachPct = (pop25plus != null && pop25plus > 0 && bachHigher != null)
          ? Math.round((bachHigher * 100 * 10) / pop25plus) / 10
          : null;
        acsEducationBlock = {
          fipsGeoid: acsCombined.fips_geoid,
          population25Plus: pop25plus,
          lessThanHs: acsCombined.less_than_hs as number | null,
          hsOrGed: acsCombined.hs_or_ged as number | null,
          someCollege: acsCombined.some_college as number | null,
          associateDegree: acsCombined.associate_degree as number | null,
          bachelorDegree: acsCombined.bachelor_degree as number | null,
          graduateDegree: acsCombined.graduate_degree as number | null,
          bachelorOrHigher: bachHigher,
          bachelorOrHigherPct: bachPct,
          acsYear: acsCombined.acs_year as number | null,
        };
      }

      // Tenure block (M11.5.1 expand 2: B25003)
      if (acsCombined.total_occupied != null) {
        acsTenureBlock = {
          fipsGeoid: acsCombined.fips_geoid,
          totalOccupied: acsCombined.total_occupied as number | null,
          ownerOccupied: acsCombined.owner_occupied as number | null,
          renterOccupied: acsCombined.renter_occupied as number | null,
          ownerOccupiedPct: acsCombined.owner_occupied_pct as number | null,
          renterOccupiedPct: acsCombined.renter_occupied_pct as number | null,
          acsYear: acsCombined.acs_year as number | null,
        };
      }

      // Transport block (M11.5.1 expand 2: B08301)
      if (acsCombined.e001 != null) {
        acsTransportBlock = {
          fipsGeoid: acsCombined.fips_geoid,
          totalWorkers: acsCombined.e001 as number | null,
          carOrVan: acsCombined.car_or_van as number | null,
          droveAlone: acsCombined.e003 as number | null,
          publicTransport: acsCombined.public_transport_guess as number | null,
          workedAtHome: acsCombined.worked_at_home_guess as number | null,
          acsYear: acsCombined.acs_year as number | null,
        };
      }
    }
  }

  // --------------------------------------------------------------------------
  // STEP 5: Build the response
  // --------------------------------------------------------------------------
  // Field mapping notes:
  //   - flag is stored as INTEGER (0/1), converted to boolean here
  //   - is_country_capital and is_state_capital same
  //   - claimedBy is stored as comma-separated string → split to array
  //   - dataQuality flags is comma-separated string → split to array
  //   - country, adminRegion, timezone are nested objects for cleaner client code
  //
  // Edge cases handled:
  //   - adminRegion can be null (some cities don't have a state) → null
  //   - timezone is non-null (every city has a TZ per M1)
  //   - population can be null (some dr5hn cities have no pop)
  //   - claimedBy only included for disputed cities
  // --------------------------------------------------------------------------
  return c.json(
    {
      success: true as const,
      data: {
        id: row.id,
        name: row.name,
        asciiName: row.ascii_name,
        native: row.native,
        stateCode: row.state_code,
        type: row.type,
        level: row.level,
        parentId: row.parent_id,
        wikiDataId: row.wiki_data_id,
        flag: row.flag === 1,
        tier: row.tier,
        capitalType: row.capital_type,
        isCountryCapital: row.is_country_capital === 1,
        isStateCapital: row.is_state_capital === 1,
        latitude: row.latitude,
        longitude: row.longitude,
        population: row.population,
        elevation: row.elevation,
        disputed: row.disputed === 1,
        claimedBy: row.claimed_by ? String(row.claimed_by).split(",").map((s: string) => s.trim()) : null,
        country: {
          id: row.co_id,
          cca2: row.co_cca2,
          cca3: row.co_cca3,
          name: row.co_name,
          flag: row.co_flag,
          capital: row.co_capital,
        },
        adminRegion: row.ar_id
          ? { id: row.ar_id, name: row.ar_name, country_id: row.ar_country_id }
          : null,
        subRegion: row.sub_id
          ? {
              id: row.sub_id,
              name: row.sub_name,
              code: row.sub_code,
              type: row.sub_type,
              level: row.sub_level,
              geonameId: row.sub_geoname_id,
            }
          : null,
        timezone: {
          id: row.tz_id,
          utc_offset_minutes: row.tz_offset,
          current_abbreviation: row.tz_abbrev,
          is_dst: row.tz_dst,
        },
        source: {
          id: row.source_id,
          version: row.source_version,
        },
        placeNames,
        postcodes: postcodesData,
        translations,
        dataQuality: {
          timezoneConfidence: row.timezone_confidence as "high" | "medium" | "low" | "unresolved" | null,
          timezoneSource: row.timezone_source,
          flags: row.data_quality_flags ? row.data_quality_flags.split(",") : [],
        },
        // M11.1 layer fields
        displayName: row.display_name ?? null,
        shortName: row.short_name ?? null,
        searchName: row.search_name ?? null,
        geonamesId: row.geonames_id ?? null,
        elevationM: row.elevation_m ?? null,
        sourcePrimary: row.source_primary ?? null,
        sourceMergedWith: row.source_merged_with ?? null,
        mergeMethod: row.merge_method ?? null,
        // M11.2 Wikidata
        wikiUrl: row.wiki_url ?? null,
        mergeRunId: row.merge_run_id ?? null,
        mergedAt: row.merged_at ?? null,
        // M11.2.6 Wikidata description
        wikidata: wikidataBlock,
        // M11.5 US Census
        census: censusBlock,
        // M11.6 Eurostat
        eurostat: eurostatBlock,
        // M11.7 Census of India
        censusIndia: censusIndiaBlock,
        // M11.5.1 ACS 5-year (Sex by Age, B01001)
        acs: acsBlock,
        // M11.5.1 expand: ACS Income (B19013) + Education (B15003)
        acsIncome: acsIncomeBlock,
        acsEducation: acsEducationBlock,
        // M11.5.1 expand 2: Tenure (B25003) + Transport (B08301)
        acsTenure: acsTenureBlock,
        acsTransport: acsTransportBlock,
      },
    },
    200
  );
});

export default cities;
