/**
 * dateandtime-api-v2 — data quality routes.
 *
 * GET /api/v1/data-quality — Overall data quality summary
 * GET /api/v1/data-quality/issues — List data quality issues
 * GET /api/v1/data-quality/confidence — Confidence distribution
 *
 * Tracks provenance and quality of timezone assignments per spec §1, §14, §15, §28.
 */
import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import type { Env, Variables } from "@/types/env";

const dq = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// ============================================================================
// Schemas
// ============================================================================
const ConfidenceCounts = z.object({
  high: z.number(),
  medium: z.number(),
  low: z.number(),
  unresolved: z.number(),
  total: z.number(),
});

const QualityFlagCount = z.object({
  flag: z.string(),
  count: z.number(),
});

const DataQualitySummary = z.object({
  success: z.literal(true),
  data: z.object({
    cities: z.object({
      total: z.number(),
      confidence: ConfidenceCounts,
      sources: z.array(z.object({ source: z.string(), count: z.number() })),
      flags: z.array(QualityFlagCount),
    }),
    timezoneZones: z.object({
      total: z.number(),
      deprecatedEtcGmt: z.number().describe("Cities using banned Etc/GMT* timezones (spec §8.2)"),
    }),
    dataSources: z.array(z.object({
      id: z.string(),
      name: z.string(),
      type: z.string(),
      recordCount: z.number().nullable(),
    })).describe("External data sources (per migration 127+)"),
    migrations: z.array(z.object({
      version: z.string(),
      description: z.string(),
    })).describe("Applied migrations (audit trail)"),
  }),
});

const QualityIssue = z.object({
  type: z.enum([
    "null_island", "no_pop", "no_wiki", "no_tz", "etc_gmt_deprecated", "low_confidence", "manual_override"
  ]),
  severity: z.enum(["info", "warning", "error"]),
  cityId: z.number(),
  cityName: z.string(),
  detail: z.string(),
});

const QualityIssuesResponse = z.object({
  success: z.literal(true),
  data: z.object({
    total: z.number(),
    issues: z.array(QualityIssue),
  }),
});

const ErrorResponse = z.object({
  success: z.literal(false),
  error: z.object({ code: z.string(), message: z.string() }),
});

// ============================================================================
// GET /api/v1/data-quality
// ============================================================================
const summaryRoute = createRoute({
  method: "get",
  path: "/api/v1/data-quality",
  summary: "Data quality summary",
  description:
    "Returns overall data quality metrics: timezone confidence distribution, " +
    "data sources, applied migrations, and known issues. " +
    "Useful for monitoring data drift and audit.",
  tags: ["Data Quality"],
  responses: {
    200: { content: { "application/json": { schema: DataQualitySummary } }, description: "Data quality summary" },
  },
});

dq.openapi(summaryRoute, async (c) => {
  // Confidence counts
  // Post M11.1: GeoNames-only cities (source_primary='geonames', merge_method='geonames_only')
  // have no timezone_confidence — they default to 'medium' (we have timezone + pop + coords verified).
  const confResult = await c.env.DB.prepare(
    `SELECT
       SUM(CASE WHEN timezone_confidence = 'high' THEN 1 ELSE 0 END) as high,
       SUM(CASE WHEN timezone_confidence = 'medium' OR (timezone_confidence IS NULL AND source_primary = 'geonames') THEN 1 ELSE 0 END) as medium,
       SUM(CASE WHEN timezone_confidence = 'low' THEN 1 ELSE 0 END) as low,
       SUM(CASE WHEN timezone_confidence = 'unresolved' THEN 1 ELSE 0 END) as unresolved,
       SUM(CASE WHEN timezone_confidence IS NULL AND source_primary IS NULL THEN 1 ELSE 0 END) as unclassified,
       COUNT(*) as total
     FROM cities`
  ).first<{ high: number; medium: number; low: number; unresolved: number; unclassified: number; total: number }>();

  // Source counts
  const sourceResult = await c.env.DB.prepare(
    `SELECT timezone_source as source, COUNT(*) as count
     FROM cities WHERE timezone_source IS NOT NULL
     GROUP BY timezone_source ORDER BY count DESC`
  ).all<{ source: string; count: number }>();

  // Quality flags
  const flagResult = await c.env.DB.prepare(
    `SELECT
       data_quality_flags as flag,
       COUNT(*) as count
     FROM cities
     WHERE data_quality_flags IS NOT NULL
     GROUP BY data_quality_flags
     ORDER BY count DESC`
  ).all<{ flag: string; count: number }>();

  // Etc/GMT banned timezones (spec §8.2)
  const etcResult = await c.env.DB.prepare(
    `SELECT COUNT(*) as n FROM cities WHERE timezone LIKE 'Etc/GMT%'`
  ).first<{ n: number }>();

  // Time zones count
  const tzResult = await c.env.DB.prepare(
    `SELECT COUNT(*) as n FROM time_zones`
  ).first<{ n: number }>();

  // Data sources
  const sourcesResult = await c.env.DB.prepare(
    `SELECT id, name, version, license FROM data_sources ORDER BY id`
  ).all<{ id: string; name: string; version: string; license: string | null }>();

  // Migrations (last 30)
  const migrationsResult = await c.env.DB.prepare(
    `SELECT version, description FROM migrations ORDER BY applied_at DESC LIMIT 30`
  ).all<{ version: string; description: string }>();

  return c.json(
    {
      success: true as const,
      data: {
        cities: {
          total: confResult?.total || 0,
          confidence: {
            high: confResult?.high || 0,
            medium: confResult?.medium || 0,
            low: confResult?.low || 0,
            unresolved: confResult?.unresolved || 0,
            unclassified: confResult?.unclassified || 0,
            total: confResult?.total || 0,
          },
          sources: (sourceResult.results || []).map((s) => ({ source: s.source, count: s.count })),
          flags: (flagResult.results || []).map((f) => ({ flag: f.flag, count: f.count })),
        },
        timezoneZones: {
          total: tzResult?.n || 0,
          deprecatedEtcGmt: etcResult?.n || 0,
        },
        dataSources: (sourcesResult.results || []).map((s) => ({
          id: s.id,
          name: s.name,
          type: s.license || "unknown",
          recordCount: null,
        })),
        migrations: (migrationsResult.results || []).map((m) => ({ version: m.version, description: m.description })),
      },
    },
    200
  );
});

// ============================================================================
// GET /api/v1/data-quality/issues
// ============================================================================
const issuesRoute = createRoute({
  method: "get",
  path: "/api/v1/data-quality/issues",
  summary: "List data quality issues",
  description:
    "Returns cities with data quality concerns: Null Island coordinates, " +
    "missing population, missing wiki, etc.",
  tags: ["Data Quality"],
  request: {
    query: z.object({
      type: z.enum(["null_island", "no_pop", "no_wiki", "no_tz", "etc_gmt_deprecated", "low_confidence", "manual_override"]).optional(),
      limit: z.coerce.number().int().min(1).max(500).default(100),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: QualityIssuesResponse } }, description: "Data quality issues" },
  },
});

dq.openapi(issuesRoute, async (c) => {
  const { type, limit } = c.req.valid("query") as { type?: string; limit: number };

  let cities: Array<{
    id: number; name: string; latitude: number; longitude: number; timezone: string | null;
    population: number | null; wiki_data_id: string | null;
    timezone_confidence: string | null; timezone_source: string | null;
    data_quality_flags: string | null;
  }> = [];

  // Build the query based on the filter
  if (type === "null_island") {
    cities = (await c.env.DB.prepare(
      `SELECT id, name, latitude, longitude, timezone, population, wiki_data_id,
              timezone_confidence, timezone_source, data_quality_flags
       FROM cities WHERE data_quality_flags LIKE '%null_island%' LIMIT ?`
    ).bind(limit).all<typeof cities[0]>()).results || [];
  } else if (type === "no_pop") {
    cities = (await c.env.DB.prepare(
      `SELECT id, name, latitude, longitude, timezone, population, wiki_data_id,
              timezone_confidence, timezone_source, data_quality_flags
       FROM cities WHERE data_quality_flags LIKE '%no_pop%' LIMIT ?`
    ).bind(limit).all<typeof cities[0]>()).results || [];
  } else if (type === "no_wiki") {
    cities = (await c.env.DB.prepare(
      `SELECT id, name, latitude, longitude, timezone, population, wiki_data_id,
              timezone_confidence, timezone_source, data_quality_flags
       FROM cities WHERE data_quality_flags LIKE '%no_wiki%' LIMIT ?`
    ).bind(limit).all<typeof cities[0]>()).results || [];
  } else if (type === "etc_gmt_deprecated") {
    cities = (await c.env.DB.prepare(
      `SELECT id, name, latitude, longitude, timezone, population, wiki_data_id,
              timezone_confidence, timezone_source, data_quality_flags
       FROM cities WHERE timezone LIKE 'Etc/GMT%' LIMIT ?`
    ).bind(limit).all<typeof cities[0]>()).results || [];
  } else if (type === "low_confidence") {
    cities = (await c.env.DB.prepare(
      `SELECT id, name, latitude, longitude, timezone, population, wiki_data_id,
              timezone_confidence, timezone_source, data_quality_flags
       FROM cities WHERE timezone_confidence IN ('low', 'unresolved') LIMIT ?`
    ).bind(limit).all<typeof cities[0]>()).results || [];
  } else if (type === "manual_override") {
    cities = (await c.env.DB.prepare(
      `SELECT id, name, latitude, longitude, timezone, population, wiki_data_id,
              timezone_confidence, timezone_source, data_quality_flags
       FROM cities WHERE timezone_source = 'manual:override' LIMIT ?`
    ).bind(limit).all<typeof cities[0]>()).results || [];
  } else {
    // No filter: all cities with any quality concern, sorted by severity
    cities = (await c.env.DB.prepare(
      `SELECT id, name, latitude, longitude, timezone, population, wiki_data_id,
              timezone_confidence, timezone_source, data_quality_flags
       FROM cities
       WHERE data_quality_flags IS NOT NULL
          OR timezone_confidence IN ('low', 'unresolved')
       ORDER BY CASE timezone_confidence
                  WHEN 'unresolved' THEN 0
                  WHEN 'low' THEN 1
                  WHEN 'medium' THEN 2
                  WHEN 'high' THEN 3
                END,
                data_quality_flags
       LIMIT ?`
    ).bind(limit).all<typeof cities[0]>()).results || [];
  }

  const allIssues: Array<{
    type: "null_island" | "no_pop" | "no_wiki" | "no_tz" | "etc_gmt_deprecated" | "low_confidence" | "manual_override";
    severity: "info" | "warning" | "error";
    cityId: number;
    cityName: string;
    detail: string;
  }> = [];

  for (const c of cities) {
    if (c.data_quality_flags?.includes("null_island")) {
      allIssues.push({
        type: "null_island",
        severity: "error",
        cityId: c.id,
        cityName: c.name,
        detail: `Coordinates are at (${c.latitude}, ${c.longitude}) — likely bad data`,
      });
    }
    if (c.population == null) {
      allIssues.push({
        type: "no_pop", severity: "info", cityId: c.id, cityName: c.name,
        detail: "Population is NULL",
      });
    }
    if (!c.wiki_data_id) {
      allIssues.push({
        type: "no_wiki", severity: "info", cityId: c.id, cityName: c.name,
        detail: "No Wikidata QID",
      });
    }
    if (!c.timezone) {
      allIssues.push({
        type: "no_tz", severity: "error", cityId: c.id, cityName: c.name,
        detail: "Timezone is NULL",
      });
    }
    if (c.timezone?.startsWith("Etc/GMT")) {
      allIssues.push({
        type: "etc_gmt_deprecated",
        severity: "warning",
        cityId: c.id,
        cityName: c.name,
        detail: `Using banned Etc/GMT* timezone (spec §8.2): ${c.timezone}`,
      });
    }
    if (c.timezone_confidence === "low" || c.timezone_confidence === "unresolved") {
      allIssues.push({
        type: "low_confidence",
        severity: c.timezone_confidence === "unresolved" ? "error" : "warning",
        cityId: c.id,
        cityName: c.name,
        detail: `Timezone confidence: ${c.timezone_confidence} (source: ${c.timezone_source})`,
      });
    }
    if (c.timezone_source === "manual:override") {
      allIssues.push({
        type: "manual_override",
        severity: "info",
        cityId: c.id,
        cityName: c.name,
        detail: "Timezone set by manual override (spec §28)",
      });
    }
  }

  // Filter by type if specified
  const filtered = type ? allIssues.filter((i) => i.type === type) : allIssues;

  return c.json(
    {
      success: true as const,
      data: {
        total: filtered.length,
        issues: filtered.slice(0, limit),
      },
    },
    200
  );
});

export default dq;
