/**
 * src/routes/subregions.ts
 *
 * M12: Admin-2 (counties, districts, communes) endpoints
 *   GET /api/v1/countries/{cca2}/admin2?admin1=XX     — list admin-2 in a country/state
 *   GET /api/v1/admin2/{id}                          — admin-2 detail
 *   GET /api/v1/cities/{id}/admin2                   — admin-2 for a city (same as subRegion in /cities/{id})
 */
import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import type { Env, Variables } from "@/types/env";

const Admin2Ref = z.object({
  id: z.number().int().describe("Admin-2 region ID (administrative_regions.id)"),
  countryId: z.number().int().describe("Country ID"),
  countryCca2: z.string().describe("ISO 3166-1 alpha-2 country code"),
  parentId: z.number().int().nullable().describe("Parent admin-1 region ID"),
  code: z.string().nullable().describe("GeoNames hierarchical code (CC.A1.A2)"),
  name: z.string().describe("Admin-2 name (e.g. 'Pasco County', 'Bezirk Mitte')"),
  asciiName: z.string().nullable().describe("ASCII-folded name"),
  type: z.string().nullable().describe("Region type: 'admin2'"),
  level: z.number().int().describe("Admin level (always 2)"),
  geonameId: z.number().int().nullable().describe("GeoNames ID"),
  cityCount: z.number().int().describe("Number of cities mapped to this admin-2"),
});

const CountryRef = z.object({
  cca2: z.string().describe("ISO 3166-1 alpha-2"),
  cca3: z.string().nullable().describe("ISO 3166-1 alpha-3"),
  name: z.string().describe("Country name"),
});

const Admin2ListRoute = createRoute({
  method: "get",
  path: "/api/v1/countries/{cca2}/admin2",
  tags: ["Admin-2"],
  summary: "List admin-2 regions (counties, districts, communes) for a country",
  description: "Returns admin-2 regions for a country. Optionally filter by admin-1 ISO code (state/province).",
  request: {
    params: z.object({
      cca2: z.string().length(2).describe("ISO 3166-1 alpha-2 country code (e.g. 'US', 'DE', 'BR')"),
    }),
    query: z.object({
      admin1: z.string().optional().describe("Filter by admin-1 ISO code (e.g. 'FL' for Florida)"),
      limit: z.coerce.number().int().min(1).max(500).default(100).describe("Max results (1-500, default 100)"),
      offset: z.coerce.number().int().min(0).default(0).describe("Pagination offset"),
    }),
  },
  responses: {
    200: {
      content: { "application/json": { schema: z.object({
        success: z.boolean(),
        data: z.object({
          country: CountryRef,
          total: z.number().int().describe("Total admin-2 regions matching filter"),
          count: z.number().int().describe("Number of admin-2 in this response"),
          admin2: z.array(Admin2Ref),
        }),
      })}},
      description: "List of admin-2 regions"
    },
    404: { content: { "application/json": { schema: z.object({ success: z.boolean(), error: z.object({ code: z.string(), message: z.string() }) })}}, description: "Country not found" },
  },
});

const Admin2DetailRoute = createRoute({
  method: "get",
  path: "/api/v1/admin2/{id}",
  tags: ["Admin-2"],
  summary: "Get admin-2 region detail",
  description: "Returns full details for an admin-2 region (county, district, commune, etc.).",
  request: {
    params: z.object({
      id: z.coerce.number().int().describe("Admin-2 region ID"),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: z.object({ success: z.boolean(), data: Admin2Ref })}}, description: "Admin-2 detail" },
    404: { content: { "application/json": { schema: z.object({ success: z.boolean(), error: z.object({ code: z.string(), message: z.string() }) })}}, description: "Admin-2 not found" },
  },
});

const app = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// List admin-2 for a country
app.openapi(Admin2ListRoute, async (c) => {
  const { cca2 } = c.req.valid("param");
  const q = c.req.valid("query");

  // Get country
  const country = await c.env.DB.prepare(
    "SELECT id, cca2, cca3, name FROM countries WHERE cca2 = ? LIMIT 1"
  ).bind(cca2.toUpperCase()).first<{ id: number; cca2: string; cca3: string | null; name: string }>();

  if (!country) {
    return c.json({ success: false, error: { code: "COUNTRY_NOT_FOUND", message: `Country ${cca2} not found` } }, 404);
  }

  // Build query for admin-2
  let where = "ar.country_id = ? AND ar.level = 2";
  const params: any[] = [country.id];
  if (q.admin1) {
    where += " AND ar.parent_id IN (SELECT id FROM administrative_regions WHERE level = 1 AND iso2 = ?)";
    params.push(q.admin1.toUpperCase());
  }

  // Total count
  const totalResult = await c.env.DB.prepare(
    `SELECT COUNT(*) as n FROM administrative_regions ar WHERE ${where}`
  ).bind(...params).first<{ n: number }>();
  const total = totalResult?.n ?? 0;

  // Page of results with city count
  const rows = await c.env.DB.prepare(
    `SELECT
       ar.id, ar.country_id, ar.parent_id, ar.code, ar.name, ar.ascii_name,
       ar.type, ar.level, ar.geoname_id,
       (SELECT COUNT(*) FROM cities c WHERE c.admin2_id = ar.id) as city_count
     FROM administrative_regions ar
     WHERE ${where}
     ORDER BY ar.name
     LIMIT ? OFFSET ?`
  ).bind(...params, q.limit, q.offset).all<{
    id: number; country_id: number; parent_id: number | null; code: string | null;
    name: string; ascii_name: string | null; type: string | null; level: number;
    geoname_id: number | null; city_count: number;
  }>();

  const admin2 = (rows.results || []).map((r) => ({
    id: r.id,
    countryId: r.country_id,
    countryCca2: country.cca2,
    parentId: r.parent_id,
    code: r.code,
    name: r.name,
    asciiName: r.ascii_name,
    type: r.type,
    level: r.level,
    geonameId: r.geoname_id,
    cityCount: r.city_count,
  }));

  return c.json({
    success: true,
    data: {
      country: { cca2: country.cca2, cca3: country.cca3, name: country.name },
      total,
      count: admin2.length,
      admin2,
    },
  }, 200);
});

// Detail for an admin-2
app.openapi(Admin2DetailRoute, async (c) => {
  const id = c.req.valid("param").id;
  const row = await c.env.DB.prepare(
    `SELECT
       ar.id, ar.country_id, ar.parent_id, ar.code, ar.name, ar.ascii_name,
       ar.type, ar.level, ar.geoname_id, c.cca2 as country_cca2,
       (SELECT COUNT(*) FROM cities ci WHERE ci.admin2_id = ar.id) as city_count
     FROM administrative_regions ar
     JOIN countries c ON c.id = ar.country_id
     WHERE ar.id = ? AND ar.level = 2
     LIMIT 1`
  ).bind(id).first<{
    id: number; country_id: number; parent_id: number | null; code: string | null;
    name: string; ascii_name: string | null; type: string | null; level: number;
    geoname_id: number | null; country_cca2: string; city_count: number;
  }>();

  if (!row) {
    return c.json({ success: false, error: { code: "ADMIN2_NOT_FOUND", message: `Admin-2 region ${id} not found` } }, 404);
  }

  return c.json({
    success: true,
    data: {
      id: row.id,
      countryId: row.country_id,
      countryCca2: row.country_cca2,
      parentId: row.parent_id,
      code: row.code,
      name: row.name,
      asciiName: row.ascii_name,
      type: row.type,
      level: row.level,
      geonameId: row.geoname_id,
      cityCount: row.city_count,
    },
  }, 200);
});

export default app;
