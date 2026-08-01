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
  lang: z.string().length(2).optional().describe("User language (ISO 639-1) — boosts matches in this language"),
  lat: z.coerce.number().min(-90).max(90).optional().describe("User latitude — proximity boost"),
  lon: z.coerce.number().min(-180).max(180).optional().describe("User longitude — proximity boost"),
  limit: z.coerce.number().int().min(1).max(50).default(10).describe("Max results (default 10)"),
});

// ============================================================================
// City detail schema
// ============================================================================
const CityDetail = z.object({
  id: z.number(),
  name: z.string(),
  asciiName: z.string().nullable(),
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
  ctx: { userCountry?: string; userLang?: string; userLat?: number; userLon?: number }
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
  if (r.is_state_capital) s += 50;

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

  // User language boost
  if (ctx.userLang) {
    s += 50; // small boost, language is fuzzy
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
    "user country/language context, and proximity.",
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
  const { q, country, lang, lat, lon, limit } = c.req.valid("query");

  // Normalize query for matching
  const qLower = q.toLowerCase().trim();
  // For ASCII queries, build a normalized form (lowercase, no diacritics, alphanum only)
  // For non-ASCII queries (Hindi, Arabic, Chinese, etc.), keep the original — we can't
  // transliterate, and FTS5 has the original Unicode strings in place_names.
  const isAscii = /^[\x00-\x7f]+$/.test(qLower);
  const qNorm = isAscii
    ? qLower.normalize("NFKD").replace(/[\u0300-\u036f]/g, "").replace(/[^a-z0-9]/g, "")
    : qLower;

  // FTS5 query: use prefix match for partial typing
  // NOTE: D1 binds parameters as strings, so the FTS5 MATCH operator needs
  // the raw query string inlined, not parameterized. (The FTS5 `?` binding
  // does NOT correctly pass MATCH operators like `*`.)
  const ftsQuery = qNorm.length >= 2 ? `${qNorm}*` : qNorm;
  // Sanitize: keep ASCII alphanumeric + *, or pass Unicode through as-is for non-ASCII
  // The FTS5 tokenizer handles Unicode, so we just need to remove SQL-breaking chars
  const safeFts = ftsQuery
    .replace(/[\\'"`;]/g, '')  // strip SQL-breaking chars
    .replace(/^\*+|\*+$/g, '');  // strip leading/trailing stars

  // Query: FTS5 → place_names → cities → country → admin → timezone
  // NOTE: FTS5 MATCH is inlined (not bound) because D1's parameter binding
  // escapes the * wildcard. The query is already sanitized above.
  const sql = `
    SELECT
      ci.id as city_id, ci.name as city_name, ci.ascii_name,
      ci.tier, ci.capital_type, ci.is_country_capital, ci.is_state_capital,
      ci.latitude, ci.longitude, ci.population, ci.disputed, ci.claimed_by,
      co.id as country_id, co.cca2 as country_cca2, co.cca3 as country_cca3,
      co.name as country_name, co.flag_emoji as country_flag, co.capital as country_capital,
      ar.id as admin_id, ar.name as admin_name,
      tz.id as timezone_id, tz.current_offset as utc_offset,
      tz.current_abbreviation as tz_abbrev, tz.is_dst,
      fts.rank as fts_rank
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
    return c.json(
      { success: false as const, error: { code: "SEARCH_FAILED", message: String(err) } },
      400
    );
  }

  // Fuzzy fallback: if FTS5 returns nothing (e.g. typo, transliteration mismatch),
  // try a LIKE-based search on normalized_name.
  if (ftsResults.length === 0 && qNorm.length >= 3) {
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
        0.0 as fts_rank
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
  const ctx = { userCountry: country, userLang: lang, userLat: lat, userLon: lon };
  const scored = unique.map((r) => {
    const { score, distanceKm } = scoreResult(r, q, qLower, qNorm, ctx);
    return { ...r, score, distanceKm };
  });

  // Same-name handling: if multiple cities share the same name (e.g. Hyderabad),
  //   - Boost the one in user's country (if known)
  //   - Penalize the others
  // Without user country, all same-name cities stay at base score.
  const nameCounts = new Map<string, number>();
  for (const r of scored) nameCounts.set(r.city_name, (nameCounts.get(r.city_name) || 0) + 1);
  for (const r of scored) {
    const cnt = nameCounts.get(r.city_name) || 1;
    if (cnt > 1) {
      if (country && r.country_cca2 === country) {
        r.score += 500; // strong boost for user's country
      } else if (country) {
        r.score -= 400; // penalty for non-user country
      }
      // If no user country, all same-name cities are equal (base score)
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
  }));

  return c.json(
    {
      success: true as const,
      data: {
        query: q,
        results,
        total: unique.length,
        tookMs: Date.now() - start,
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
    "timezone, capital status, tier, and known place names.",
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

  const sql = `
    SELECT
      ci.id, ci.name, ci.ascii_name, ci.tier, ci.capital_type,
      ci.is_country_capital, ci.is_state_capital,
      ci.latitude, ci.longitude, ci.population, ci.elevation,
      ci.disputed, ci.claimed_by, ci.source_id, ci.source_version,
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

  type CityRow = {
    id: number;
    name: string;
    ascii_name: string | null;
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
    return c.json(
      { success: false as const, error: { code: "NOT_FOUND", message: `City ${id} not found` } },
      404
    );
  }

  // Get all place_names for this city
  const namesResult = await c.env.DB.prepare(
    `SELECT name, language_code, name_type FROM place_names WHERE canonical_place_id = ? ORDER BY is_preferred DESC, name_type ASC`
  ).bind(id).all<{ name: string; language_code: string | null; name_type: string }>();
  const placeNames = (namesResult.results || []).map((n) => ({
    name: n.name,
    language: n.language_code,
    type: n.name_type,
  }));

  return c.json(
    {
      success: true as const,
      data: {
        id: row.id,
        name: row.name,
        asciiName: row.ascii_name,
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
      },
    },
    200
  );
});

export default cities;
