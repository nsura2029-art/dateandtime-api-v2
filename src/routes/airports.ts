/**
 * dateandtime-api-v2 — airports routes.
 *
 * GET /api/v1/airports/near?lat=&lon=&radius= — Nearest airports
 * GET /api/v1/cities/{id}/airports — Airports serving a city
 *
 * Source: schema ready, data import pending (cron reminder task 426125193814084
 * scheduled for monthly airport data fetch from https://ourairports.com/data/)
 */
import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import type { Env, Variables } from "@/types/env";

const airports = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// ============================================================================
// Schemas
// ============================================================================
const Airport = z.object({
  iata: z.string().nullable().describe("IATA code (e.g. 'JFK')"),
  icao: z.string().nullable().describe("ICAO code (e.g. 'KJFK')"),
  name: z.string().describe("Airport name"),
  type: z.string().nullable().describe("Type: 'large_airport' | 'medium_airport' | 'small_airport' | 'seaplane_base' | 'heliport' | 'closed')"),
  cityId: z.number().nullable().describe("dr5hn city id (may be NULL)"),
  latitude: z.number(),
  longitude: z.number(),
  timezone: z.string().nullable(),
  scheduledService: z.boolean().describe("Has scheduled commercial flights"),
  distanceKm: z.number().nullable().describe("Distance from query point (if lat/lon provided)"),
});

const NearAirportsResponse = z.object({
  success: z.literal(true),
  data: z.object({
    lat: z.number(),
    lon: z.number(),
    radiusKm: z.number(),
    count: z.number(),
    airports: z.array(Airport),
  }),
});

const ErrorResponse = z.object({
  success: z.literal(false),
  error: z.object({ code: z.string(), message: z.string() }),
});

const CityAirportsResponse = z.object({
  success: z.literal(true),
  data: z.object({
    cityId: z.number(),
    count: z.number(),
    airports: z.array(Airport),
  }),
});

// Haversine
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
// GET /api/v1/airports/near
// ============================================================================
const nearAirportsRoute = createRoute({
  method: "get",
  path: "/api/v1/airports/near",
  summary: "Find airports near a point",
  description:
    "Returns airports within a radius (default 100 km, max 500 km) of a lat/lon. " +
    "Sorted by distance. If no airport data has been loaded, returns an empty list " +
    "with a note. Data is imported from OurAirports.com (cron-scheduled).",
  tags: ["Airports"],
  request: {
    query: z.object({
      lat: z.coerce.number().min(-90).max(90).describe("Latitude"),
      lon: z.coerce.number().min(-180).max(180).describe("Longitude"),
      radius: z.coerce.number().min(1).max(500).default(100).describe("Radius in km"),
      limit: z.coerce.number().int().min(1).max(50).default(10),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: NearAirportsResponse } }, description: "Nearest airports" },
    400: { content: { "application/json": { schema: ErrorResponse } }, description: "Invalid query" },
  },
});

airports.openapi(nearAirportsRoute, async (c) => {
  const { lat, lon, radius, limit } = c.req.valid("query");

  // Pre-filter: bounding box to reduce scan set
  // 1 degree lat ≈ 111 km, 1 degree lon ≈ 111 km × cos(lat)
  const latDelta = radius / 111;
  const lonDelta = radius / (111 * Math.cos(lat * Math.PI / 180));
  const minLat = lat - latDelta;
  const maxLat = lat + latDelta;
  const minLon = lon - lonDelta;
  const maxLon = lon + lonDelta;

  // Bounding box query first, then haversine filter (SQLite doesn't have spatial index)
  const result = await c.env.DB.prepare(
    `SELECT iata_code, icao_code, name, type, city_id, latitude, longitude, timezone, is_scheduled
     FROM airports
     WHERE latitude BETWEEN ? AND ?
       AND longitude BETWEEN ? AND ?
       AND type != 'closed'
     ORDER BY
       CASE WHEN is_scheduled = 1 THEN 0 ELSE 1 END,
       (latitude - ?) * (latitude - ?) + (longitude - ?) * (longitude - ?) ASC
     LIMIT 100`
  ).bind(minLat, maxLat, minLon, maxLon, lat, lat, lon, lon).all<{
    iata_code: string | null;
    icao_code: string | null;
    name: string;
    type: string | null;
    city_id: number | null;
    latitude: number;
    longitude: number;
    timezone: string | null;
    is_scheduled: number;
  }>();

  // Filter by haversine distance and sort
  const withDistance = (result.results || [])
    .map((r) => {
      const dist = haversineKm(lat, lon, r.latitude, r.longitude);
      return { ...r, distanceKm: dist };
    })
    .filter((r) => r.distanceKm <= radius)
    .sort((a, b) => {
      if (a.is_scheduled !== b.is_scheduled) {
        return b.is_scheduled - a.is_scheduled; // 1 first
      }
      return a.distanceKm - b.distanceKm;
    })
    .slice(0, limit);

  return c.json(
    {
      success: true as const,
      data: {
        lat,
        lon,
        radiusKm: radius,
        count: withDistance.length,
        airports: withDistance.map((r) => ({
        iata: r.iata_code,
        icao: r.icao_code,
        name: r.name,
        type: r.type,
        cityId: r.city_id,
        latitude: r.latitude,
        longitude: r.longitude,
        timezone: r.timezone,
        scheduledService: r.is_scheduled === 1,
        distanceKm: Math.round(r.distanceKm * 10) / 10,
      })),
      },
    },
    200
  );
});

// ============================================================================
// GET /api/v1/cities/{id}/airports
// ============================================================================
const cityAirportsRoute = createRoute({
  method: "get",
  path: "/api/v1/cities/{id}/airports",
  summary: "Get airports serving a city",
  description:
    "Returns airports with city_id matching the given city. " +
    "Sorted by scheduled service then by name.",
  tags: ["Airports"],
  request: {
    params: z.object({ id: z.coerce.number().int().positive() }),
    query: z.object({
      limit: z.coerce.number().int().min(1).max(50).default(10),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: CityAirportsResponse } }, description: "City airports" },
    404: { content: { "application/json": { schema: ErrorResponse } }, description: "City not found" },
  },
});

airports.openapi(cityAirportsRoute, async (c) => {
  const { id } = c.req.valid("param");
  const { limit } = c.req.valid("query");

  // Verify city
  const city = await c.env.DB.prepare(
    `SELECT id FROM cities WHERE id = ?`
  ).bind(id).first<{ id: number }>();
  if (!city) {
    return c.json(
      { success: false as const, error: { code: "NOT_FOUND", message: `City ${id} not found` } },
      404
    );
  }

  const result = await c.env.DB.prepare(
    `SELECT iata_code, icao_code, name, type, city_id, latitude, longitude, timezone, is_scheduled
     FROM airports
     WHERE city_id = ?
     ORDER BY is_scheduled DESC, name
     LIMIT ?`
  ).bind(id, limit).all<{
    iata_code: string | null;
    icao_code: string | null;
    name: string;
    type: string | null;
    city_id: number | null;
    latitude: number;
    longitude: number;
    timezone: string | null;
    is_scheduled: number;
  }>();

  return c.json(
    {
      success: true as const,
      data: {
        cityId: id,
        count: result.results?.length || 0,
        airports: (result.results || []).map((r) => ({
          iata: r.iata_code,
          icao: r.icao_code,
          name: r.name,
          type: r.type,
          cityId: r.city_id,
          latitude: r.latitude,
          longitude: r.longitude,
          timezone: r.timezone,
          scheduledService: r.is_scheduled === 1,
          distanceKm: null,
        })),
      },
    },
    200
  );
});

export default airports;
