/**
 * src/routes/regions.ts
 *
 * Spec Phase 3 endpoints:
 *   GET /api/v1/regions                      — list 6 regions
 *   GET /api/v1/regions/{code}/subregions    — sub-regions in a region
 *   GET /api/v1/subregions/{code}/countries  — countries in a sub-region
 *
 * Tables: regions (6), subregions (22), countries (250)
 */
import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import type { Env, Variables } from "@/types/env";

const Region = z.object({
  id: z.number().int().describe("Region ID"),
  code: z.string().nullable().describe("Region code (AF, AM, AS, EU, OC, AN)"),
  name: z.string().describe("Region name"),
  unM49Code: z.string().nullable().describe("UN M49 region code"),
  subregionCount: z.number().int().describe("Number of sub-regions in this region"),
  countryCount: z.number().int().describe("Total countries across all sub-regions"),
});

const Subregion = z.object({
  id: z.number().int().describe("Sub-region ID"),
  code: z.string().nullable().describe("UN M49 sub-region code"),
  name: z.string().describe("Sub-region name"),
  regionId: z.number().int().describe("Parent region ID"),
  regionCode: z.string().nullable().describe("Parent region code"),
  countryCount: z.number().int().describe("Number of countries in this sub-region"),
});

const CountrySummary = z.object({
  cca2: z.string().describe("ISO 3166-1 alpha-2 code"),
  cca3: z.string().nullable().describe("ISO 3166-1 alpha-3 code"),
  name: z.string().describe("English country name"),
  officialName: z.string().nullable().describe("Official country name"),
  capital: z.string().nullable().describe("Capital city name"),
  regionId: z.number().int().nullable().describe("Region ID"),
  subregionId: z.number().int().nullable().describe("Sub-region ID"),
  population: z.number().int().nullable().describe("Country population"),
  areaKm2: z.number().nullable().describe("Area in km²"),
  flagEmoji: z.string().nullable().describe("Flag emoji (e.g. 🇺🇸)"),
  localized: z.object({
    language: z.string().describe("Language code used for localization"),
    name: z.string().describe("Localized country name"),
    shortName: z.string().nullable().describe("Localized short name"),
    languageFallback: z.boolean().describe("True if fell back to English"),
  }).nullable().describe("Localized country name (or null if no lang)"),
});

// ============================================================================
// GET /api/v1/regions — list all 6 regions
// ============================================================================
const listRegionsRoute = createRoute({
  method: "get",
  path: "/api/v1/regions",
  summary: "List all UN regions",
  description: "Returns all 6 UN M49 regions (Africa, Americas, Asia, Europe, Oceania, Polar) with subregion and country counts.",
  tags: ["regions"],
  responses: {
    200: {
      description: "List of regions",
      content: { "application/json": { schema: z.object({
        success: z.literal(true),
        data: z.object({
          count: z.number().int(),
          regions: z.array(Region),
        }),
      })}},
    },
  },
});

// ============================================================================
// GET /api/v1/regions/{code}/subregions — sub-regions in a region
// ============================================================================
const listSubregionsRoute = createRoute({
  method: "get",
  path: "/api/v1/regions/{code}/subregions",
  summary: "List sub-regions for a region",
  description: "Returns all UN M49 sub-regions within the specified region. Use region codes: AF, AM, AS, EU, OC, AN.",
  tags: ["regions"],
  request: {
    params: z.object({
      code: z.string().describe("Region code (AF, AM, AS, EU, OC, AN)"),
    }),
  },
  responses: {
    200: {
      description: "List of sub-regions",
      content: { "application/json": { schema: z.object({
        success: z.literal(true),
        data: z.object({
          region: z.object({
            id: z.number().int(),
            code: z.string().nullable(),
            name: z.string(),
            unM49Code: z.string().nullable(),
          }),
          count: z.number().int(),
          subregions: z.array(Subregion),
        }),
      })}},
    },
    404: { description: "Region not found" },
  },
});

// ============================================================================
// GET /api/v1/subregions/{code}/countries — countries in a sub-region
// ============================================================================
const listSubregionCountriesRoute = createRoute({
  method: "get",
  path: "/api/v1/subregions/{code}/countries",
  summary: "List countries in a sub-region",
  description: "Returns all countries within the specified UN M49 sub-region. Pass ?lang=xx to get localized names (default: en).",
  tags: ["regions"],
  request: {
    params: z.object({
      code: z.string().describe("UN M49 sub-region code (e.g. '155' for Western Africa, '034' for Southern Asia)"),
    }),
    query: z.object({
      lang: z.string().optional().describe("ISO 639-1 language code for localized names (e.g. 'es', 'fr', 'zh')"),
      limit: z.coerce.number().int().min(1).max(500).optional().default(250),
    }),
  },
  responses: {
    200: {
      description: "List of countries",
      content: { "application/json": { schema: z.object({
        success: z.literal(true),
        data: z.object({
          subregion: z.object({
            id: z.number().int(),
            code: z.string().nullable(),
            name: z.string(),
            regionId: z.number().int(),
          }),
          count: z.number().int(),
          countries: z.array(CountrySummary),
        }),
      })}},
    },
    404: { description: "Sub-region not found" },
  },
});

const app = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// ---- GET /api/v1/regions ----
app.openapi(listRegionsRoute, async (c) => {
  const result = await c.env.DB.prepare(`
    SELECT
      r.id, r.code, r.name, r.un_m49_code,
      COUNT(DISTINCT s.id) AS subregion_count,
      COUNT(DISTINCT co.id) AS country_count
    FROM regions r
    LEFT JOIN subregions s ON s.region_id = r.id
    LEFT JOIN countries co ON co.subregion_id = s.id
    GROUP BY r.id, r.code, r.name, r.un_m49_code
    ORDER BY r.id
  `).all<{
    id: number; code: string | null; name: string; un_m49_code: string | null;
    subregion_count: number; country_count: number;
  }>();

  const regions = (result.results || []).map((r) => ({
    id: r.id,
    code: r.code,
    name: r.name,
    unM49Code: r.un_m49_code,
    subregionCount: r.subregion_count ?? 0,
    countryCount: r.country_count ?? 0,
  }));

  return c.json({ success: true, data: { count: regions.length, regions } }, 200);
});

// ---- GET /api/v1/regions/{code}/subregions ----
app.openapi(listSubregionsRoute, async (c) => {
  const code = c.req.param("code");
  const region = await c.env.DB.prepare(
    `SELECT id, code, name, un_m49_code FROM regions WHERE code = ? LIMIT 1`
  ).bind(code).first<{ id: number; code: string | null; name: string; un_m49_code: string | null }>();

  if (!region) {
    return c.json({ success: false, error: { code: "REGION_NOT_FOUND", message: `Region ${code} not found` } }, 404);
  }

  const result = await c.env.DB.prepare(`
    SELECT
      s.id, s.code, s.name, s.region_id,
      r.code AS region_code,
      COUNT(DISTINCT co.id) AS country_count
    FROM subregions s
    LEFT JOIN regions r ON r.id = s.region_id
    LEFT JOIN countries co ON co.subregion_id = s.id
    WHERE s.region_id = ?
    GROUP BY s.id, s.code, s.name, s.region_id, r.code
    ORDER BY s.name
  `).bind(region.id).all<{
    id: number; code: string | null; name: string; region_id: number; region_code: string | null;
    country_count: number;
  }>();

  const subregions = (result.results || []).map((s) => ({
    id: s.id,
    code: s.code,
    name: s.name,
    regionId: s.region_id,
    regionCode: s.region_code,
    countryCount: s.country_count ?? 0,
  }));

  return c.json({
    success: true,
    data: {
      region: { id: region.id, code: region.code, name: region.name, unM49Code: region.un_m49_code },
      count: subregions.length,
      subregions,
    },
  }, 200);
});

// ---- GET /api/v1/subregions/{code}/countries ----
app.openapi(listSubregionCountriesRoute, async (c) => {
  const code = c.req.param("code");
  const lang = c.req.query("lang") || "en";
  const limit = c.req.query("limit") || 250;

  const subregion = await c.env.DB.prepare(
    `SELECT id, code, name, region_id FROM subregions WHERE code = ? LIMIT 1`
  ).bind(code).first<{ id: number; code: string | null; name: string; region_id: number }>();

  if (!subregion) {
    return c.json({ success: false, error: { code: "SUBREGION_NOT_FOUND", message: `Sub-region ${code} not found` } }, 404);
  }

  const result = await c.env.DB.prepare(`
    SELECT
      c.id AS country_id, c.cca2, c.cca3, c.name, c.official_name, c.capital,
      c.region_id, c.subregion_id, c.population, c.area_km2, c.flag_emoji
    FROM countries c
    WHERE c.subregion_id = ?
    ORDER BY c.name
    LIMIT ?
  `).bind(subregion.id, limit).all<{
    country_id: number; cca2: string; cca3: string | null; name: string; official_name: string | null;
    capital: string | null; region_id: number | null; subregion_id: number | null;
    population: number | null; area_km2: number | null; flag_emoji: string | null;
  }>();

  // Pre-fetch localized names in one query (avoid N+1)
  let localizedMap = new Map<number, { name: string; short_name: string | null }>();
  if (lang && lang !== "en" && result.results && result.results.length > 0) {
    const countryIds = (result.results as any[]).map((r) => r.country_id).filter((id) => id != null);
    if (countryIds.length > 0) {
      const placeholders = countryIds.map(() => "?").join(",");
      const locRes = await c.env.DB.prepare(
        `SELECT country_id, name, short_name FROM country_names
         WHERE language = ? AND country_id IN (${placeholders})`
      ).bind(lang, ...countryIds).all<{ country_id: number; name: string; short_name: string | null }>();
      for (const r of (locRes.results || [])) {
        localizedMap.set(r.country_id, { name: r.name, short_name: r.short_name });
      }
    }
  }

  // Localize if requested
  const countries = (result.results || []).map((row: any) => {
    let localized: {
      language: string; name: string; shortName: string | null; languageFallback: boolean;
    };

    const loc = localizedMap.get(row.country_id);
    if (loc) {
      localized = {
        language: lang,
        name: loc.name,
        shortName: loc.short_name,
        languageFallback: false,
      };
    } else {
      localized = { language: "en", name: row.name, shortName: null, languageFallback: lang !== "en" };
    }

    return {
      cca2: row.cca2,
      cca3: row.cca3,
      name: row.name,
      officialName: row.official_name,
      capital: row.capital,
      regionId: row.region_id,
      subregionId: row.subregion_id,
      population: row.population,
      areaKm2: row.area_km2,
      flagEmoji: row.flag_emoji,
      localized,
    };
  });

  return c.json({
    success: true,
    data: {
      subregion: { id: subregion.id, code: subregion.code, name: subregion.name, regionId: subregion.region_id },
      count: countries.length,
      countries,
    },
  }, 200);
});

export default app;
