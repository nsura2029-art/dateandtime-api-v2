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

  // --------------------------------------------------------------------------
  // STEP 1: Verify city exists and get its country/state
  // --------------------------------------------------------------------------
  // We need country_id + state_id to scope the postcode query.
  // Cities without a state (state_id NULL) can't have postcodes returned.
  //
  // Edge case: cities in special territories or Vatican-like entities
  // (state_id NULL) return 400 with explicit "NO_STATE" code.
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // STEP 2: Get total count for pagination metadata
  // --------------------------------------------------------------------------
  // Single COUNT(*) query for the total. For most states this is fast (indexed
  // on country_id, state_id). Florida = ~1K, New York = ~1.7K, Tokyo = ~4K.
  // --------------------------------------------------------------------------
  const totalResult = await c.env.DB.prepare(
    `SELECT COUNT(*) as n FROM postcodes WHERE country_id = ? AND state_id = ?`
  ).bind(city.country_id, city.state_id).first<{ n: number }>();

  // --------------------------------------------------------------------------
  // STEP 3: Fetch the page of postcodes
  // --------------------------------------------------------------------------
  // SQL OFFSET/LIMIT pagination. For large states (e.g. California with 2.5K
  // postcodes), page 5+ is still fast because of the (country_id, state_id)
  // index. ORDER BY id for stable pagination (not random access).
  //
  // .all() returns up to `limit` rows. If page > total/limit, returns empty.
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // STEP 4: Build response
  // --------------------------------------------------------------------------
  // Return:
  //   - cityId: input
  //   - total: total count (for client to know how many pages)
  //   - page, limit: echo back for clarity
  //   - results: array of postcodes with snake_case → camelCase translation
  // --------------------------------------------------------------------------
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
      // Note: z.coerce.boolean() coerces any non-empty string to true (including "false"!).
      // Use enum + transform for proper string-to-boolean conversion.
      exact: z.enum(["true", "false"]).default("false").transform((v) => v === "true")
        .describe("If true, exact match; otherwise prefix match"),
      limit: z.coerce.number().int().min(1).max(20).default(5),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: PostcodeSearchResponse } }, description: "Matching postcodes + cities" },
  },
});

postcodes.openapi(searchPostcodesRoute, async (c) => {
  const { code, country, exact, limit } = c.req.valid("query");

  // --------------------------------------------------------------------------
  // STEP 1: Resolve country cca2 → internal id
  // --------------------------------------------------------------------------
  // cca2 is normalized to uppercase (US, GB, etc.).
  // Unknown countries return 400 with INVALID_COUNTRY (avoids silent empty result).
  // --------------------------------------------------------------------------
  const countryRow = await c.env.DB.prepare(
    `SELECT id FROM countries WHERE cca2 = ?`
  ).bind(country.toUpperCase()).first<{ id: number }>();
  if (!countryRow) {
    return c.json(
      { success: false as const, error: { code: "INVALID_COUNTRY", message: `Unknown country: ${country}` } },
      400
    );
  }

  // --------------------------------------------------------------------------
  // STEP 2: Find matching postcodes
  // --------------------------------------------------------------------------
  // Two modes:
  //   - exact=true:    `code = '32501'`        (one postcode only)
  //   - exact=false:   `code LIKE '325%'`      (prefix, partial typing)
  //
  // D1 note: the `${matchOp}` is inlined (not bound) because `=` and `LIKE`
  // are SQL operators, not values. Safe because we control the operator string
  // via a boolean, not user input.
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // STEP 3: For each postcode, find associated cities
  // --------------------------------------------------------------------------
  // Since dr5hn postcodes have NULL city_id, we associate via state.
  // Returns up to 3 cities per postcode, sorted by:
  //   1. State capitals first (so Tallahassee wins for FL)
  //   2. Higher population next
  //   3. Tier (tier1 > tier2 > tier3) as final tiebreaker
  //
  // Trade-off: this is N+1 queries (one per postcode). For 5 postcodes = 5
  // extra queries, ~50ms total. Acceptable for the use case (max 20 postcodes).
  // --------------------------------------------------------------------------
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
