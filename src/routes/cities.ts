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
  timezone: TimezoneRef,
  distanceKm: z.number().nullable().describe("Distance from user (if lat/lon provided)"),
  score: z.number().describe("Internal ranking score (higher = better)"),
  matchType: z.enum(["exact", "prefix", "fuzzy"]),
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
  match_type: "exact" | "prefix" | "fuzzy";
  fts_rank: number;
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
      co.id as co_id, co.cca2 as co_cca2, co.cca3 as co_cca3,
      co.name as co_name, co.flag_emoji as co_flag, co.capital as co_capital,
      ar.id as ar_id, ar.name as ar_name, ar.country_id as ar_country_id,
      tz.id as tz_id, tz.current_offset as tz_offset,
      tz.current_abbreviation as tz_abbrev, tz.is_dst as tz_dst
    FROM cities ci
    JOIN countries co ON co.id = ci.country_id
    LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
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
    co_id: number;
    co_cca2: string;
    co_cca3: string | null;
    co_name: string;
    co_flag: string | null;
    co_capital: string | null;
    ar_id: number | null;
    ar_name: string | null;
    ar_country_id: number | null;
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
      },
    },
    200
  );
});

export default cities;
