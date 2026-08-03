/**
 * src/routes/cities-list.ts
 *
 * Spec Phase 3 endpoints:
 *   GET /api/v1/cities            — list cities with filters
 *   GET /api/v1/cities/near       — proximity search (Haversine)
 *
 * Note: the existing /cities/search endpoint is the search-by-name API.
 * This new /cities endpoint is for browsing/filtering (region/country/state).
 */
import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import type { Env, Variables } from "@/types/env";

const ErrorResponse = z.object({
  success: z.literal(false),
  error: z.object({
    code: z.string(),
    message: z.string(),
  }),
});

const CityListItem = z.object({
  id: z.number().int().describe("City ID"),
  name: z.string().describe("City name"),
  asciiName: z.string().nullable().describe("ASCII name (no diacritics)"),
  country: z.object({
    cca2: z.string().describe("ISO 3166-1 alpha-2 code"),
    name: z.string().describe("Country name"),
  }).nullable().describe("Country (joined)"),
  adminRegion: z.object({
    id: z.number().int().nullable(),
    code: z.string().nullable(),
    name: z.string().nullable(),
  }).nullable().describe("State/province (joined)"),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
  population: z.number().int().nullable(),
  timezone: z.string().nullable().describe("IANA timezone"),
  type: z.string().nullable().describe("City type (city, town, village, etc.)"),
  countryCapital: z.number().int().nullable().describe("0/1 — is country capital"),
  regionCapital: z.number().int().nullable().describe("0/1 — is state/region capital"),
  tier: z.number().int().nullable().describe("City tier (1-7)"),
  distanceKm: z.number().nullable().describe("Distance from query point (for /near)"),
});

const CityList = z.object({
  success: z.literal(true),
  data: z.object({
    count: z.number().int().describe("Total matching cities"),
    limit: z.number().int().describe("Limit applied"),
    offset: z.number().int().describe("Offset applied"),
    cities: z.array(CityListItem),
  }),
});

// ============================================================================
// GET /api/v1/cities — list with filters
// ============================================================================
const listCitiesRoute = createRoute({
  method: "get",
  path: "/api/v1/cities",
  summary: "List cities with filters",
  description: "Browse cities by region, sub-region, country, state, type, or population range. Use this for hierarchical browsing. For text search, use /cities/search instead.",
  tags: ["cities"],
  request: {
    query: z.object({
      region: z.string().optional().describe("UN M49 region code: AF, AM, AS, EU, OC, AN"),
      subregion: z.string().optional().describe("UN M49 sub-region code (e.g. '155' for Western Africa)"),
      country: z.string().optional().describe("ISO 3166-1 alpha-2 code (e.g. 'US', 'DE', 'IN')"),
      state: z.string().optional().describe("Admin region ID or ISO 3166-2 code"),
      type: z.string().optional().describe("City type filter (city, town, village, etc.)"),
      minPopulation: z.coerce.number().int().optional().describe("Minimum population"),
      maxPopulation: z.coerce.number().int().optional().describe("Maximum population"),
      tier: z.coerce.number().int().optional().describe("City tier (1-7)"),
      capital: z.coerce.boolean().optional().describe("Only capitals (true) or non-capitals (false)"),
      sort: z.enum(["name", "population", "id"]).optional().default("name").describe("Sort order"),
      order: z.enum(["asc", "desc"]).optional().default("asc"),
      limit: z.coerce.number().int().min(1).max(1000).optional().default(50),
      offset: z.coerce.number().int().min(0).optional().default(0),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: CityList } }, description: "List of cities" },
  },
});

// ============================================================================
// GET /api/v1/cities/near — proximity search
// ============================================================================
const nearCitiesRoute = createRoute({
  method: "get",
  path: "/api/v1/cities/near",
  summary: "Find cities near a point",
  description: "Returns cities within a given radius (km) of a lat/lon point. Default radius 100 km, default limit 50. Uses Haversine distance.",
  tags: ["cities"],
  request: {
    query: z.object({
      lat: z.coerce.number().min(-90).max(90).describe("Latitude (-90 to 90)"),
      lon: z.coerce.number().min(-180).max(180).describe("Longitude (-180 to 180)"),
      radiusKm: z.coerce.number().positive().optional().default(100).describe("Radius in km (default 100)"),
      minPopulation: z.coerce.number().int().optional().describe("Minimum city population"),
      limit: z.coerce.number().int().min(1).max(500).optional().default(50),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: z.object({
      success: z.literal(true),
      data: z.object({
        query: z.object({
          lat: z.number(),
          lon: z.number(),
          radiusKm: z.number(),
        }),
        count: z.number().int(),
        cities: z.array(CityListItem),
      }),
    })}}, description: "Cities near the point" },
    400: { content: { "application/json": { schema: ErrorResponse } }, description: "Invalid coordinates" },
  },
});

const app = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// Haversine distance (km) — duplicated here for self-containment
function haversineKm(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const toRad = (d: number) => (d * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
}

// ---- GET /api/v1/cities ----
app.openapi(listCitiesRoute, async (c) => {
  const q = c.req.valid("query");

  // Build WHERE clause
  const where: string[] = [];
  const params: any[] = [];

  if (q.region) {
    where.push("r.code = ?");
    params.push(q.region);
  }
  if (q.subregion) {
    where.push("s.code = ?");
    params.push(q.subregion);
  }
  if (q.country) {
    where.push("co.cca2 = ?");
    params.push(q.country);
  }
  if (q.state) {
    // Accept either numeric ID or ISO 3166-2 code
    if (/^\d+$/.test(q.state)) {
      where.push("ar.id = ?");
      params.push(parseInt(q.state));
    } else {
      // ISO 3166-2 code is in administrative_regions.iso2
      where.push("ar.iso2 = ?");
      params.push(q.state);
    }
  }
  if (q.type) {
    where.push("ci.type = ?");
    params.push(q.type);
  }
  if (q.minPopulation != null) {
    where.push("ci.population >= ?");
    params.push(q.minPopulation);
  }
  if (q.maxPopulation != null) {
    where.push("ci.population <= ?");
    params.push(q.maxPopulation);
  }
  if (q.tier != null) {
    where.push("ci.tier = ?");
    params.push(q.tier);
  }
  if (q.capital === true) {
    where.push("ci.is_country_capital = 1");
  } else if (q.capital === false) {
    where.push("ci.is_country_capital = 0 OR ci.is_country_capital IS NULL");
  }

  const whereSql = where.length > 0 ? `WHERE ${where.join(" AND ")}` : "";

  // Sort
  const orderBy = q.sort === "population" ? "ci.population" : q.sort === "id" ? "ci.id" : "ci.name";
  const order = q.order === "desc" ? "DESC" : "ASC";

  // Count
  const countResult = await c.env.DB.prepare(`
    SELECT COUNT(*) as n
    FROM cities ci
    LEFT JOIN countries co ON co.id = ci.country_id
    LEFT JOIN subregions s ON s.id = co.subregion_id
    LEFT JOIN regions r ON r.id = co.region_id
    LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
    ${whereSql}
  `).bind(...params).first<{ n: number }>();

  // List
  const listResult = await c.env.DB.prepare(`
    SELECT
      ci.id, ci.name, ci.ascii_name, ci.latitude, ci.longitude, ci.population, ci.timezone,
      ci.type, ci.is_country_capital, ci.is_state_capital, ci.tier,
      co.cca2 AS country_cca2, co.name AS country_name,
      ar.id AS admin_id, ar.code AS admin_code, ar.name AS admin_name
    FROM cities ci
    LEFT JOIN countries co ON co.id = ci.country_id
    LEFT JOIN subregions s ON s.id = co.subregion_id
    LEFT JOIN regions r ON r.id = co.region_id
    LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
    ${whereSql}
    ORDER BY ${orderBy} ${order} NULLS LAST
    LIMIT ? OFFSET ?
  `).bind(...params, q.limit, q.offset).all<any>();

  const cities = (listResult.results || []).map((r) => ({
    id: r.id,
    name: r.name,
    asciiName: r.ascii_name,
    country: r.country_cca2 ? { cca2: r.country_cca2, name: r.country_name } : null,
    adminRegion: r.admin_id ? { id: r.admin_id, code: r.admin_code, name: r.admin_name } : null,
    latitude: r.latitude,
    longitude: r.longitude,
    population: r.population,
    timezone: r.timezone,
    type: r.type,
    countryCapital: r.is_country_capital,
    regionCapital: r.is_state_capital,
    tier: r.tier,
    distanceKm: null,
  }));

  return c.json({
    success: true,
    data: {
      count: countResult?.n ?? 0,
      limit: q.limit,
      offset: q.offset,
      cities,
    },
  }, 200);
});

// ---- GET /api/v1/cities/near ----
app.openapi(nearCitiesRoute, async (c) => {
  const q = c.req.valid("query");
  const { lat, lon, radiusKm, minPopulation, limit } = q;

  // Bounding box pre-filter (avoid full scan)
  // 1 degree lat ≈ 111 km, 1 degree lon ≈ 111 * cos(lat) km
  const latDelta = radiusKm / 111;
  const lonDelta = radiusKm / (111 * Math.max(Math.cos((lat * Math.PI) / 180), 0.001));

  const minLat = lat - latDelta;
  const maxLat = lat + latDelta;
  const minLon = lon - lonDelta;
  const maxLon = lon + lonDelta;

  const where: string[] = [
    "ci.latitude IS NOT NULL",
    "ci.longitude IS NOT NULL",
    "ci.latitude BETWEEN ? AND ?",
    "ci.longitude BETWEEN ? AND ?",
  ];
  const params: any[] = [minLat, maxLat, minLon, maxLon];

  if (minPopulation != null) {
    where.push("ci.population >= ?");
    params.push(minPopulation);
  }

  const result = await c.env.DB.prepare(`
    SELECT
      ci.id, ci.name, ci.ascii_name, ci.latitude, ci.longitude, ci.population, ci.timezone,
      ci.type, ci.is_country_capital, ci.is_state_capital, ci.tier,
      co.cca2 AS country_cca2, co.name AS country_name,
      ar.id AS admin_id, ar.code AS admin_code, ar.name AS admin_name
    FROM cities ci
    LEFT JOIN countries co ON co.id = ci.country_id
    LEFT JOIN administrative_regions ar ON ar.id = ci.state_id
    WHERE ${where.join(" AND ")}
  `).bind(...params).all<any>();

  // Calculate exact Haversine distance and filter
  const nearby = (result.results || [])
    .map((r) => ({
      ...r,
      distanceKm: haversineKm(lat, lon, r.latitude, r.longitude),
    }))
    .filter((r) => r.distanceKm <= radiusKm)
    .sort((a, b) => a.distanceKm - b.distanceKm)
    .slice(0, limit);

  const cities = nearby.map((r) => ({
    id: r.id,
    name: r.name,
    asciiName: r.ascii_name,
    country: r.country_cca2 ? { cca2: r.country_cca2, name: r.country_name } : null,
    adminRegion: r.admin_id ? { id: r.admin_id, code: r.admin_code, name: r.admin_name } : null,
    latitude: r.latitude,
    longitude: r.longitude,
    population: r.population,
    timezone: r.timezone,
    type: r.type,
    countryCapital: r.is_country_capital,
    regionCapital: r.is_state_capital,
    tier: r.tier,
    distanceKm: Math.round(r.distanceKm * 10) / 10,
  }));

  return c.json({
    success: true,
    data: {
      query: { lat, lon, radiusKm },
      count: cities.length,
      cities,
    },
  }, 200);
});

export default app;
