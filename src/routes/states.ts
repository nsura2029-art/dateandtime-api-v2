/**
 * src/routes/states.ts
 *
 * Spec Phase 3 endpoints:
 *   GET /api/v1/countries/{cca2}/states — list states/provinces for a country
 *   GET /api/v1/states/{id}              — single state detail
 *
 * Table: administrative_regions (5,308 rows, includes states/provinces/regions)
 *
 * Filter: type='state' or type='province' for the typical user-facing
 * list. Some countries use 'region' or 'department' instead, so we
 * include all level-1 administrative divisions.
 */
import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import type { Env, Variables } from "@/types/env";

const State = z.object({
  id: z.number().int().describe("Administrative region ID"),
  countryId: z.number().int().describe("Parent country ID"),
  cca2: z.string().describe("ISO 3166-1 alpha-2 code"),
  code: z.string().nullable().describe("State/province code (varies by country)"),
  name: z.string().describe("State/province name"),
  asciiName: z.string().nullable().describe("ASCII name (no diacritics)"),
  type: z.string().nullable().describe("Type: 'state', 'province', 'region', etc."),
  level: z.number().int().nullable().describe("Admin level (1=state, 2=county, 3=city)"),
  latitude: z.number().nullable().describe("Center latitude"),
  longitude: z.number().nullable().describe("Center longitude"),
  iso2: z.string().nullable().describe("ISO 3166-2 code (e.g. 'US-CA')"),
  population: z.number().int().nullable().describe("State population"),
  timezone: z.string().nullable().describe("Primary timezone"),
  cityCount: z.number().int().describe("Number of cities in this state"),
});

const StateDetail = State.extend({
  parentId: z.number().int().nullable().describe("Parent admin region ID"),
  country: z.object({
    cca2: z.string().describe("ISO 3166-1 alpha-2 code"),
    cca3: z.string().nullable().describe("ISO 3166-1 alpha-3 code"),
    name: z.string().describe("Country name"),
  }).nullable().describe("Parent country info"),
});

// ============================================================================
// GET /api/v1/countries/{cca2}/states
// ============================================================================
const listStatesRoute = createRoute({
  method: "get",
  path: "/api/v1/countries/{cca2}/states",
  summary: "List states/provinces for a country",
  description: "Returns all level-1 administrative regions (states, provinces, regions, departments) for the specified country. Pass ?type=state to filter by type. Pass ?lang=xx for localized names (limited support).",
  tags: ["states"],
  request: {
    params: z.object({
      cca2: z.string().describe("ISO 3166-1 alpha-2 code (e.g. 'US', 'DE', 'IN')"),
    }),
    query: z.object({
      type: z.string().optional().describe("Filter by type: 'state', 'province', 'region', 'department'"),
      limit: z.coerce.number().int().min(1).max(500).optional().default(100),
    }),
  },
  responses: {
    200: {
      description: "List of states",
      content: { "application/json": { schema: z.object({
        success: z.literal(true),
        data: z.object({
          country: z.object({
            cca2: z.string(),
            cca3: z.string().nullable(),
            name: z.string(),
          }),
          count: z.number().int(),
          states: z.array(State),
        }),
      })}},
    },
    404: { description: "Country not found" },
  },
});

// ============================================================================
// GET /api/v1/states/{id}
// ============================================================================
const stateDetailRoute = createRoute({
  method: "get",
  path: "/api/v1/states/{id}",
  summary: "Get a single state/province",
  description: "Returns detail for one administrative region, including the parent country and number of cities.",
  tags: ["states"],
  request: {
    params: z.object({
      id: z.coerce.number().int().describe("Administrative region ID"),
    }),
  },
  responses: {
    200: {
      description: "State detail",
      content: { "application/json": { schema: z.object({
        success: z.literal(true),
        data: StateDetail,
      })}},
    },
    404: { description: "State not found" },
  },
});

const app = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// ---- GET /api/v1/countries/{cca2}/states ----
app.openapi(listStatesRoute, async (c) => {
  const cca2 = c.req.param("cca2");
  const type = c.req.query("type");
  const limit = c.req.query("limit") || 100;

  const country = await c.env.DB.prepare(
    `SELECT id, cca2, cca3, name FROM countries WHERE cca2 = ? LIMIT 1`
  ).bind(cca2).first<{ id: number; cca2: string; cca3: string | null; name: string }>();

  if (!country) {
    return c.json({ success: false, error: { code: "COUNTRY_NOT_FOUND", message: `Country ${cca2} not found` } }, 404);
  }

  let sql = `
    SELECT
      ar.id, ar.country_id, ? AS cca2, ar.code, ar.name, ar.ascii_name, ar.type, ar.level,
      ar.latitude, ar.longitude, ar.iso2, ar.population, ar.timezone,
      COUNT(DISTINCT ci.id) AS city_count
    FROM administrative_regions ar
    LEFT JOIN cities ci ON ci.state_id = ar.id
    WHERE ar.country_id = ? AND ar.level = 1
  `;
  const params: any[] = [cca2, country.id];
  if (type) {
    sql += ` AND ar.type = ?`;
    params.push(type);
  }
  sql += ` GROUP BY ar.id ORDER BY ar.name LIMIT ?`;
  params.push(limit);

  const result = await c.env.DB.prepare(sql).bind(...params).all<{
    id: number; country_id: number; cca2: string; code: string | null; name: string;
    ascii_name: string | null; type: string | null; level: number | null;
    latitude: number | null; longitude: number | null; iso2: string | null;
    population: number | null; timezone: string | null; city_count: number;
  }>();

  const states = (result.results || []).map((s) => ({
    id: s.id,
    countryId: s.country_id,
    cca2: s.cca2,
    code: s.code,
    name: s.name,
    asciiName: s.ascii_name,
    type: s.type,
    level: s.level,
    latitude: s.latitude,
    longitude: s.longitude,
    iso2: s.iso2,
    population: s.population,
    timezone: s.timezone,
    cityCount: s.city_count ?? 0,
  }));

  return c.json({
    success: true,
    data: {
      country: { cca2: country.cca2, cca3: country.cca3, name: country.name },
      count: states.length,
      states,
    },
  }, 200);
});

// ---- GET /api/v1/states/{id} ----
app.openapi(stateDetailRoute, async (c) => {
  const id = c.req.param("id");

  const row = await c.env.DB.prepare(`
    SELECT
      ar.id, ar.country_id, ar.parent_id, ar.code, ar.name, ar.ascii_name, ar.type, ar.level,
      ar.latitude, ar.longitude, ar.iso2, ar.population, ar.timezone,
      co.cca2, co.cca3, co.name AS country_name,
      COUNT(DISTINCT ci.id) AS city_count
    FROM administrative_regions ar
    LEFT JOIN countries co ON co.id = ar.country_id
    LEFT JOIN cities ci ON ci.state_id = ar.id
    WHERE ar.id = ?
    GROUP BY ar.id
  `).bind(id).first<{
    id: number; country_id: number; parent_id: number | null; code: string | null; name: string;
    ascii_name: string | null; type: string | null; level: number | null;
    latitude: number | null; longitude: number | null; iso2: string | null;
    population: number | null; timezone: string | null; city_count: number;
    cca2: string; cca3: string | null; country_name: string;
  }>();

  if (!row) {
    return c.json({ success: false, error: { code: "STATE_NOT_FOUND", message: `State ${id} not found` } }, 404);
  }

  return c.json({
    success: true,
    data: {
      id: row.id,
      countryId: row.country_id,
      parentId: row.parent_id,
      cca2: row.cca2,
      code: row.code,
      name: row.name,
      asciiName: row.ascii_name,
      type: row.type,
      level: row.level,
      latitude: row.latitude,
      longitude: row.longitude,
      iso2: row.iso2,
      population: row.population,
      timezone: row.timezone,
      cityCount: row.city_count ?? 0,
      country: row.cca2 ? { cca2: row.cca2, cca3: row.cca3, name: row.country_name } : null,
    },
  }, 200);
});

export default app;
