/**
 * dateandtime-api-v2 — postcodes routes.
 *
 * GET /api/v1/cities/{id}/postcodes — All postcodes for a city (paginated)
 * GET /api/v1/postcodes/search?code=&country= — Find cities by postcode
 *
 * Source: dr5hn postcodes.json (844,248 rows)
 */
import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import type { Env, Variables } from "@/types/env";

const postcodes = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// ============================================================================
// Schemas
// ============================================================================
const Postcode = z.object({
  code: z.string().describe("Postal/ZIP code"),
  localityName: z.string().nullable().describe("Local neighborhood/district name"),
  type: z.string().nullable().describe("dr5hn type: 'full' or other"),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
  source: z.string().nullable().describe("Data source (e.g. 'us-census', 'pt-codigos-postais')"),
});

const CityPostcodesResponse = z.object({
  success: z.literal(true),
  data: z.object({
    cityId: z.number(),
    total: z.number().describe("Total postcodes in the same state as this city"),
    page: z.number(),
    limit: z.number(),
    results: z.array(Postcode),
  }),
});

const ErrorResponse = z.object({
  success: z.literal(false),
  error: z.object({ code: z.string(), message: z.string() }),
});

const CityPostcodesQuery = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

const PostcodeSearchQuery = z.object({
  code: z.string().min(1).max(20).describe("Postal code (exact or prefix)"),
  country: z.string().length(2).describe("ISO cca2 country code"),
  exact: z.coerce.boolean().default(false).describe("If true, exact match; otherwise prefix"),
  limit: z.coerce.number().int().min(1).max(20).default(5),
});

const PostcodeSearchResult = z.object({
  postcode: Postcode,
  cities: z.array(z.object({
    id: z.number(),
    name: z.string(),
    stateCode: z.string().nullable(),
    countryCode: z.string(),
    isStateCapital: z.boolean(),
  })).describe("Cities in the same state as this postcode"),
});

const PostcodeSearchResponse = z.object({
  success: z.literal(true),
  data: z.object({
    query: z.string(),
    country: z.string(),
    results: z.array(PostcodeSearchResult),
  }),
});

// ============================================================================
// GET /api/v1/cities/{id}/postcodes
// ============================================================================
const cityPostcodesRoute = createRoute({
  method: "get",
  path: "/api/v1/cities/{id}/postcodes",
  summary: "Get all postcodes for a city",
  description:
    "Returns postcodes in the same state as the city, paginated. " +
    "Postcodes are state-scoped (not strictly city-scoped) because dr5hn " +
    "postcodes have NULL city_id. Default limit 20, max 100.",
  tags: ["Postcodes"],
  request: {
    params: z.object({ id: z.coerce.number().int().positive() }),
    query: z.object({
      page: z.coerce.number().int().min(1).default(1),
      limit: z.coerce.number().int().min(1).max(100).default(20),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: CityPostcodesResponse } }, description: "City postcodes" },
    404: { content: { "application/json": { schema: ErrorResponse } }, description: "City not found" },
  },
});

postcodes.openapi(cityPostcodesRoute, async (c) => {
  const { id } = c.req.valid("param");
  const { page, limit } = c.req.valid("query");

  // Verify city exists and get its country/state
  const city = await c.env.DB.prepare(
    `SELECT ci.id, ci.country_id, ci.state_id
     FROM cities ci WHERE ci.id = ?`
  ).bind(id).first<{ id: number; country_id: number; state_id: number | null }>();
  if (!city) {
    return c.json(
      { success: false as const, error: { code: "NOT_FOUND", message: `City ${id} not found` } },
      404
    );
  }
  if (!city.state_id) {
    return c.json(
      { success: false as const, error: { code: "NO_STATE", message: "City has no state" } },
      400
    );
  }

  const totalResult = await c.env.DB.prepare(
    `SELECT COUNT(*) as n FROM postcodes WHERE country_id = ? AND state_id = ?`
  ).bind(city.country_id, city.state_id).first<{ n: number }>();

  const offset = (page - 1) * limit;
  const results = await c.env.DB.prepare(
    `SELECT code, locality_name, type, latitude, longitude, source
     FROM postcodes
     WHERE country_id = ? AND state_id = ?
     ORDER BY id
     LIMIT ? OFFSET ?`
  ).bind(city.country_id, city.state_id, limit, offset).all<{
    code: string;
    locality_name: string | null;
    type: string | null;
    latitude: number | null;
    longitude: number | null;
    source: string | null;
  }>();

  return c.json(
    {
      success: true as const,
      data: {
        cityId: id,
        total: totalResult?.n ?? 0,
        page,
        limit,
        results: (results.results || []).map((p) => ({
          code: p.code,
          localityName: p.locality_name,
          type: p.type,
          latitude: p.latitude,
          longitude: p.longitude,
          source: p.source,
        })),
      },
    },
    200
  );
});

// ============================================================================
// GET /api/v1/postcodes/search?code=&country=
// ============================================================================
const searchPostcodesRoute = createRoute({
  method: "get",
  path: "/api/v1/postcodes/search",
  summary: "Find cities by postal code",
  description:
    "Search postcodes by code (exact or prefix) within a country. " +
    "Returns matching postcodes with their associated cities (state-scoped). " +
    "Example: ?code=32501&country=US finds Pensacola FL.",
  tags: ["Postcodes"],
  request: {
    query: z.object({
      code: z.string().min(1).max(20).describe("Postal code (exact or prefix)"),
      country: z.string().length(2).describe("ISO cca2 country code"),
      exact: z.coerce.boolean().default(false).describe("If true, exact match; otherwise prefix"),
      limit: z.coerce.number().int().min(1).max(20).default(5),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: PostcodeSearchResponse } }, description: "Matching postcodes + cities" },
  },
});

postcodes.openapi(searchPostcodesRoute, async (c) => {
  const { code, country, exact, limit } = c.req.valid("query");

  // Find country
  const countryRow = await c.env.DB.prepare(
    `SELECT id FROM countries WHERE cca2 = ?`
  ).bind(country.toUpperCase()).first<{ id: number }>();
  if (!countryRow) {
    return c.json(
      { success: false as const, error: { code: "INVALID_COUNTRY", message: `Unknown country: ${country}` } },
      400
    );
  }

  // Find matching postcodes
  const matchOp = exact ? "=" : "LIKE";
  const matchVal = exact ? code : `${code}%`;
  const pcResults = await c.env.DB.prepare(
    `SELECT p.id, p.code, p.state_id, p.locality_name, p.type, p.latitude, p.longitude, p.source
     FROM postcodes p
     WHERE p.country_id = ? AND p.code ${matchOp} ?
     ORDER BY p.code
     LIMIT ?`
  ).bind(countryRow.id, matchVal, limit).all<{
    id: number;
    code: string;
    state_id: number;
    locality_name: string | null;
    type: string | null;
    latitude: number | null;
    longitude: number | null;
    source: string | null;
  }>();

  // For each postcode, find cities in the same state
  const results = [];
  for (const pc of pcResults.results || []) {
    const cities = await c.env.DB.prepare(
      `SELECT ci.id, ci.name, ci.state_code, ci.is_state_capital
       FROM cities ci
       WHERE ci.country_id = ? AND ci.state_id = ?
       ORDER BY ci.is_state_capital DESC, ci.population DESC NULLS LAST, ci.tier ASC
       LIMIT 3`
    ).bind(countryRow.id, pc.state_id).all<{
      id: number;
      name: string;
      state_code: string | null;
      is_state_capital: number;
    }>();

    results.push({
      postcode: {
        code: pc.code,
        localityName: pc.locality_name,
        type: pc.type,
        latitude: pc.latitude,
        longitude: pc.longitude,
        source: pc.source,
      },
      cities: (cities.results || []).map((ci) => ({
        id: ci.id,
        name: ci.name,
        stateCode: ci.state_code,
        countryCode: country.toUpperCase(),
        isStateCapital: ci.is_state_capital === 1,
      })),
    });
  }

  return c.json(
    {
      success: true as const,
      data: {
        query: code,
        country: country.toUpperCase(),
        results,
      },
    },
    200
  );
});

export default postcodes;
