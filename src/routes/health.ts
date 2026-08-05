/**
 * Health check endpoints.
 *   GET  /                      — API root, version, endpoint manifest
 *   GET  /api/v1/health         — DB stats, latency, version
 *   HEAD /api/v1/health         — for probe-on-boot checks
 *
 * Both GETs are documented in the OpenAPI spec (visible in Swagger UI).
 * The HEAD probe is a raw route — Swagger UI doesn't document HEAD.
 */
import { OpenAPIHono, createRoute } from "@hono/zod-openapi";
import { z } from "zod";
import { HealthResponse, ErrorResponse } from "@/lib/schemas";
import { Regions, Subregions, Countries, AdminRegions, Cities, Timezones } from "@/lib/db";
import type { Env, Variables } from "@/types/env";

const health = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// ============================================================================
// Schema for the API root response
// ============================================================================
const ApiRootResponse = z.object({
  success: z.literal(true),
  data: z.object({
    name: z.string().describe("Worker name (e.g. dt-api-v2 or dt-api-v2-dev)"),
    version: z.string().describe("API semver version"),
    description: z.string().describe("Short description of what the API is"),
    docs: z.string().describe("Path to the Swagger UI"),
    openapi: z.string().describe("Path to the OpenAPI 3.1 spec"),
    endpoints: z
      .record(z.string(), z.string())
      .describe("Map of endpoint name to path (for quick discovery — see /docs for full schema)"),
  }),
});

// ============================================================================
// GET / — API root
// ============================================================================
const rootRoute = createRoute({
  method: "get",
  path: "/",
  summary: "API root",
  description:
    "Returns the API name, version, and a flat list of all known endpoints. " +
    "Use this for quick 'is the API up?' checks. For full schema documentation, see /docs.",
  tags: ["Meta"],
  responses: {
    200: {
      content: { "application/json": { schema: ApiRootResponse } },
      description: "API metadata + endpoint manifest",
    },
  },
});

health.openapi(rootRoute, async (c) => {
  return c.json(
    {
      success: true as const,
      data: {
        name: c.env.API_NAME,
        version: c.env.API_VERSION,
        description: "dateandtime.live API v2",
        docs: "/docs",
        openapi: "/openapi.json",
        endpoints: {
          health: "/api/v1/health",
          status: "/api/v1/status",
          // Phase 1 (data layer)
          regions: "/api/v1/regions",
          regionsSubregions: "/api/v1/regions/:code/subregions",
          subregionsCountries: "/api/v1/subregions/:code/countries",
          countries: "/api/v1/countries",
          countryByCca2: "/api/v1/countries/:cca2",
          countryStates: "/api/v1/countries/:cca2/states",
          cityById: "/api/v1/cities/:id",
          cities: "/api/v1/cities",
          citiesSearch: "/api/v1/cities/search",
          citiesNear: "/api/v1/cities/near",
          // Phase 2+
          search: "/api/v1/search",
          timezones: "/api/v1/timezones",
          timezoneById: "/api/v1/timezones/:id",
        },
      },
    },
    200
  );
});

// ============================================================================
// GET /api/v1/health — DB stats + latency
// ============================================================================
const healthRoute = createRoute({
  method: "get",
  path: "/api/v1/health",
  summary: "Health check (DB stats + latency)",
  description:
    "Returns the API's liveness + row counts for each main table " +
    "(`regions`, `subregions`, `countries`, `administrative_regions`, `cities`, `time_zones`) " +
    "and the round-trip query latency in ms.\n\n" +
    "For deeper runtime/build info, use /api/v1/status.",
  tags: ["Meta"],
  responses: {
    200: {
      content: { "application/json": { schema: HealthResponse } },
      description: "API is healthy, DB responded within the call",
    },
    503: {
      content: { "application/json": { schema: ErrorResponse } },
      description: "DB unreachable or tables missing",
    },
  },
});

health.openapi(healthRoute, async (c) => {
  const start = Date.now();
  const [regions, subregions, countries, adminRegions, cities, timezones] = await Promise.all([
    Regions.count(c.env.DB),
    Subregions.count(c.env.DB),
    Countries.count(c.env.DB),
    AdminRegions.count(c.env.DB),
    Cities.count(c.env.DB),
    Timezones.count(c.env.DB),
  ]);
  const latencyMs = Date.now() - start;

  return c.json(
    {
      success: true as const,
      data: {
        status: "ok" as const,
        db: {
          regions,
          subregions,
          countries,
          administrativeRegions: adminRegions,
          cities,
          timezones,
        },
        dbVersion: c.env.API_VERSION,
        apiVersion: c.env.API_VERSION,
        env: c.env.API_NAME,
        latencyMs,
      },
    },
    200
  );
});

// ============================================================================
// HEAD /api/v1/health — probe (no body)
// ============================================================================
/** Health check probe — returns 200 if API is up (no body, for monitoring agents). */
health.on("HEAD", "/api/v1/health", () => new Response(null, { status: 200 }));

export default health;
