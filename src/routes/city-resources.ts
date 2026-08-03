/**
 * src/routes/city-resources.ts
 *
 * Spec Phase 3 endpoints:
 *   GET /api/v1/cities/{id}/aliases    — historical + alternate names
 *   GET /api/v1/cities/{id}/climate    — climate summary (simplified model)
 *
 * Source tables:
 *   alt_names_staging — 767,572 GeoNames alternateNamesV2 entries
 *                       (geographic ID join, isHistoric flag)
 *   Climate model — simplified lat-based classification (tropical/temperate/etc)
 *                   We have no climate data in D1 yet, so use a deterministic
 *                   lat-based estimate and clearly document it as a placeholder.
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

const Alias = z.object({
  name: z.string().describe("Alternate name"),
  language: z.string().nullable().describe("ISO 639 language code (null for script-only)"),
  isPreferred: z.boolean().describe("Is the preferred name for this language"),
  isShort: z.boolean().describe("Is a short name (abbreviation)"),
  isColloquial: z.boolean().describe("Colloquial / slang name"),
  isHistoric: z.boolean().describe("Historic / former name"),
});

const ClimateMonth = z.object({
  month: z.number().int().min(1).max(12).describe("Month (1-12)"),
  monthName: z.string().describe("Month name"),
  avgHighC: z.number().describe("Average high temperature (°C)"),
  avgLowC: z.number().describe("Average low temperature (°C)"),
  precipitationMm: z.number().describe("Average precipitation (mm)"),
  classification: z.string().describe("Climate classification for this month"),
});

const ClimateSummary = z.object({
  cityId: z.number().int(),
  latitude: z.number().describe("Latitude (drives classification)"),
  longitude: z.number().describe("Longitude"),
  climateZone: z.string().describe("Dominant climate zone"),
  hemisphere: z.enum(["north", "south", "equator"]).describe("Hemisphere"),
  months: z.array(ClimateMonth).describe("Monthly climate estimates"),
  notes: z.string().describe("Data source and caveats"),
});

// ============================================================================
// GET /api/v1/cities/{id}/aliases
// ============================================================================
const aliasesRoute = createRoute({
  method: "get",
  path: "/api/v1/cities/{id}/aliases",
  summary: "Get alternate / historical names for a city",
  description: "Returns up to 100 alternate names from GeoNames alternateNamesV2, including historic names, abbreviations, and transliterations. Filter by ?historic=true to get only historic names.",
  tags: ["cities"],
  request: {
    params: z.object({ id: z.coerce.number().int().positive() }),
    query: z.object({
      historic: z.coerce.boolean().optional().describe("Only historic (former) names"),
      language: z.string().optional().describe("Filter by ISO 639 language code"),
      limit: z.coerce.number().int().min(1).max(500).optional().default(100),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: z.object({
      success: z.literal(true),
      data: z.object({
        cityId: z.number().int(),
        cityName: z.string().describe("Canonical city name"),
        count: z.number().int(),
        aliases: z.array(Alias),
      }),
    })}}, description: "List of alternate names" },
    404: { content: { "application/json": { schema: ErrorResponse } }, description: "City not found" },
  },
});

// ============================================================================
// GET /api/v1/cities/{id}/climate
// ============================================================================
const climateRoute = createRoute({
  method: "get",
  path: "/api/v1/cities/{id}/climate",
  summary: "Get climate summary for a city",
  description: "Returns a simplified climate model based on latitude. NOTE: This is a placeholder using a deterministic lat-based classification. For production climate data, integrate a real source (e.g. World Bank CCKP, NOAA).",
  tags: ["cities"],
  request: {
    params: z.object({ id: z.coerce.number().int().positive() }),
  },
  responses: {
    200: { content: { "application/json": { schema: z.object({
      success: z.literal(true),
      data: ClimateSummary,
    })}}, description: "Climate summary" },
    404: { content: { "application/json": { schema: ErrorResponse } }, description: "City not found" },
    400: { content: { "application/json": { schema: ErrorResponse } }, description: "City has no coordinates" },
  },
});

const app = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

const MONTH_NAMES = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

// M11.8: Classify month based on real temperature/precipitation
function classifyMonth(avgHighC: number, precipMm: number): string {
  // Hot: avg high > 30°C
  if (avgHighC >= 30) return "hot";
  // Cold: avg high < 10°C
  if (avgHighC < 10) return "cold";
  // Wet: high precipitation (> 100mm)
  if (precipMm > 100) return "wet";
  // Dry: low precipitation (< 30mm)
  if (precipMm < 30) return "dry";
  return "temperate";
}

// Simplified climate model (placeholder until we integrate a real source).
// Based on latitude, generates monthly avg high/low temps + precipitation
// following standard climatic patterns (tropical/temperate/continental/polar).
function climateModel(latitude: number, longitude: number): {
  zone: string;
  hemisphere: "north" | "south" | "equator";
  months: { month: number; monthName: string; avgHighC: number; avgLowC: number; precipitationMm: number; classification: string; }[];
} {
  const absLat = Math.abs(latitude);
  const hemisphere: "north" | "south" | "equator" =
    absLat < 5 ? "equator" : latitude >= 0 ? "north" : "south";

  let zone: string;
  let baseHighC: number;  // annual avg high
  let amplitudeC: number;  // seasonal swing
  let precipBase: number;  // base precipitation
  let isMonsoon = false;

  if (absLat < 23.5) {
    zone = "tropical";
    baseHighC = 30;
    amplitudeC = 3;
    precipBase = 150;
    isMonsoon = (longitude > 60 && longitude < 150) || (longitude > -170 && longitude < -50 && absLat < 15);
  } else if (absLat < 40) {
    zone = "subtropical";
    baseHighC = 22;
    amplitudeC = 12;
    precipBase = 90;
  } else if (absLat < 60) {
    zone = "temperate";
    baseHighC = 14;
    amplitudeC = 16;
    precipBase = 70;
  } else if (absLat < 75) {
    zone = "subarctic";
    baseHighC = 2;
    amplitudeC = 22;
    precipBase = 40;
  } else {
    zone = "polar";
    baseHighC = -10;
    amplitudeC = 18;
    precipBase = 20;
  }

  // For Southern Hemisphere, shift the season by 6 months
  const seasonShift = hemisphere === "south" ? 6 : 0;

  const months = MONTH_NAMES.map((monthName, i) => {
    const month = i + 1;
    // Sin wave for temperature: peak at month 7 (Jul) in N hemisphere
    // cos((month - 7) * π/6) at month 7 = cos(0) = 1 (peak)
    // at month 1 = cos(-π) = -1 (trough)
    const seasonal = Math.cos(((month - 7 + seasonShift + 12) % 12) * Math.PI / 6);
    const highC = Math.round((baseHighC + amplitudeC * seasonal) * 10) / 10;
    const lowC = Math.round((highC - 8 - amplitudeC * 0.3) * 10) / 10;
    // Precipitation: more in summer for most zones, but monsoon reverses for tropical Asia
    const isMonsoonPeak = isMonsoon && (month >= 6 && month <= 9);
    const isSummer = (hemisphere === "north" && month >= 6 && month <= 8) ||
                     (hemisphere === "south" && (month <= 2 || month >= 12));
    let precip = precipBase;
    if (isMonsoon) {
      precip = month >= 6 && month <= 9 ? precipBase * 3 : precipBase * 0.3;
    } else if (zone === "tropical") {
      precip = isSummer ? precipBase * 1.5 : precipBase;
    } else if (zone === "subtropical" || zone === "temperate") {
      precip = isSummer ? precipBase * 1.3 : precipBase * 0.8;
    }
    return {
      month,
      monthName,
      avgHighC: highC,
      avgLowC: Math.max(lowC, -50),  // floor at -50C
      precipitationMm: Math.round(precip),
      classification: zone,
    };
  });

  return { zone, hemisphere, months };
}

// ---- GET /api/v1/cities/{id}/aliases ----
app.openapi(aliasesRoute, async (c) => {
  const id = c.req.valid("param").id;
  const q = c.req.valid("query");

  // Get city with geonames_id
  const city = await c.env.DB.prepare(
    `SELECT id, name, geonames_id FROM cities WHERE id = ? LIMIT 1`
  ).bind(id).first<{ id: number; name: string; geonames_id: number | null }>();

  if (!city) {
    return c.json({ success: false, error: { code: "CITY_NOT_FOUND", message: `City ${id} not found` } }, 404);
  }

  if (!city.geonames_id) {
    return c.json({
      success: true,
      data: { cityId: id, cityName: city.name, count: 0, aliases: [] },
    }, 200);
  }

  const where: string[] = ["geonameid = ?"];
  const params: any[] = [city.geonames_id];
  if (q.historic) {
    where.push("is_historic = 1");
  }
  if (q.language) {
    where.push("isolanguage = ?");
    params.push(q.language);
  }

  const result = await c.env.DB.prepare(`
    SELECT alternate_name, isolanguage, is_preferred, is_short, is_colloquial, is_historic
    FROM alt_names_staging
    WHERE ${where.join(" AND ")}
    ORDER BY is_preferred DESC, is_historic DESC, alternate_name
    LIMIT ?
  `).bind(...params, q.limit).all<{
    alternate_name: string; isolanguage: string | null;
    is_preferred: number; is_short: number; is_colloquial: number; is_historic: number;
  }>();

  const aliases = (result.results || []).map((r) => ({
    name: r.alternate_name,
    language: r.isolanguage,
    isPreferred: r.is_preferred === 1,
    isShort: r.is_short === 1,
    isColloquial: r.is_colloquial === 1,
    isHistoric: r.is_historic === 1,
  }));

  return c.json({
    success: true,
    data: {
      cityId: id,
      cityName: city.name,
      count: aliases.length,
      aliases,
    },
  }, 200);
});

// ---- GET /api/v1/cities/{id}/climate ----
app.openapi(climateRoute, async (c) => {
  const id = c.req.valid("param").id;

  const city = await c.env.DB.prepare(
    `SELECT id, name, latitude, longitude FROM cities WHERE id = ? LIMIT 1`
  ).bind(id).first<{ id: number; name: string; latitude: number | null; longitude: number | null }>();

  if (!city) {
    return c.json({ success: false, error: { code: "CITY_NOT_FOUND", message: `City ${id} not found` } }, 404);
  }

  if (city.latitude == null || city.longitude == null) {
    return c.json({ success: false, error: { code: "NO_COORDINATES", message: "City has no coordinates" } }, 400);
  }

  // Try real climate data first (M11.8: Open-Meteo 2020-2023)
  const realRows = await c.env.DB.prepare(
    `SELECT month, avg_high_c, avg_low_c, precipitation_mm, data_years, source
     FROM climate_real
     WHERE city_id = ?
     ORDER BY month`
  ).bind(id).all<{
    month: number; avg_high_c: number; avg_low_c: number;
    precipitation_mm: number; data_years: string; source: string;
  }>();

  if (realRows.results && realRows.results.length === 12) {
    // Real data available
    const dataYears = realRows.results[0].data_years;
    const source = realRows.results[0].source;
    const months = realRows.results.map((r) => ({
      month: r.month,
      monthName: MONTH_NAMES[r.month - 1],
      avgHighC: r.avg_high_c,
      avgLowC: r.avg_low_c,
      precipitationMm: r.precipitation_mm,
      classification: classifyMonth(r.avg_high_c, r.precipitation_mm),
    }));
    return c.json({
      success: true,
      data: {
        cityId: id,
        latitude: city.latitude,
        longitude: city.longitude,
        months,
        dataYears,
        source,
        notes: `Real climate data from ${source} (${dataYears} monthly normals).`,
      },
    }, 200);
  }

  // Fallback to lat-based model
  const model = climateModel(city.latitude, city.longitude);
  return c.json({
    success: true,
    data: {
      cityId: id,
      latitude: city.latitude,
      longitude: city.longitude,
      climateZone: model.zone,
      hemisphere: model.hemisphere,
      months: model.months,
      dataYears: null,
      source: "lat-based-model",
      notes: "Simplified lat-based climate model (no real data for this city). For real data, see cities with top-30K population.",
    },
  }, 200);
});

export default app;
