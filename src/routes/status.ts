/**
 * Status endpoint — comprehensive service info.
 *   GET /api/v1/status          — build, runtime, DB, features, endpoints
 *   HEAD /api/v1/status         — for probe-on-boot checks
 *
 * More detailed than /api/v1/health (which is just "is the DB reachable?").
 * Designed for: dashboards, monitoring tools, "is the API up?" check pages.
 */
import { OpenAPIHono, createRoute } from "@hono/zod-openapi";
import { z } from "zod";
import { StatusResponse, ErrorResponse, DatabaseStats } from "@/lib/schemas";
import { Cities, Countries, Timezones, Regions, Subregions, AdminRegions } from "@/lib/db";
import type { Env, Variables } from "@/types/env";

const status = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// ============================================================================
// GET /api/v1/status — comprehensive service info
// ============================================================================
const statusRoute = createRoute({
  method: "get",
  path: "/api/v1/status",
  summary: "API status and service info",
  description:
    "Returns comprehensive service information: API metadata, runtime details (region, build), database connection + row counts, and feature flags. More detailed than `/api/v1/health`.",
  tags: ["Meta"],
  responses: {
    200: {
      content: { "application/json": { schema: StatusResponse } },
      description: "Status response",
    },
    503: {
      content: { "application/json": { schema: ErrorResponse } },
      description: "API is degraded (DB unreachable or other critical issue)",
    },
  },
});

status.openapi(statusRoute, async (c) => {
  // Query DB — if it fails, return 503
  let tables: z.infer<typeof DatabaseStats> = {
    regions: 0,
    subregions: 0,
    countries: 0,
    administrativeRegions: 0,
    cities: 0,
    timezones: 0,
  };
  let dbConnected = false;
  try {
    const [regions, subregions, countries, adminRegions, cities, timezones] = await Promise.all([
      Regions.count(c.env.DB),
      Subregions.count(c.env.DB),
      Countries.count(c.env.DB),
      AdminRegions.count(c.env.DB),
      Cities.count(c.env.DB),
      Timezones.count(c.env.DB),
    ]);
    tables = { regions, subregions, countries, administrativeRegions: adminRegions, cities, timezones };
    dbConnected = true;
  } catch (err) {
    console.error(JSON.stringify({ type: "status.db_error", message: String(err) }));
  }

  if (!dbConnected) {
    return c.json(
      {
        success: false,
        error: {
          code: "DATABASE_UNREACHABLE",
          message: "Database is not reachable",
        },
      },
      503
    );
  }

  // Pull runtime info from Cloudflare headers
  const cfRay = c.req.header("cf-ray") ?? "";
  const colo = cfRay.split("-").pop() ?? null;
  const region = c.req.header("cf-ipcountry") ?? null;

  // Determine environment from API_NAME
  const isDev = c.env.API_NAME.includes("dev");
  const environment: "dev" | "production" = isDev ? "dev" : "production";

  // Build info (set as Worker vars; null if unset)
  const commit = (c.env as { GIT_COMMIT?: string }).GIT_COMMIT ?? null;
  const deployedAt = (c.env as { DEPLOYED_AT?: string }).DEPLOYED_AT ?? null;

  return c.json(
    {
      success: true as const,
      data: {
        status: "operational" as const,
        timestamp: new Date().toISOString(),
        api: {
          name: c.env.API_NAME,
          version: c.env.API_VERSION,
          environment,
        },
        runtime: {
          platform: "cloudflare-workers" as const,
          region,
          colo,
        },
        build: {
          commit,
          deployedAt,
        },
        database: {
          binding: "timeandtimepro-full-v2" as const,
          connected: true,
          version: c.env.API_VERSION,
          tables,
        },
        features: {
          openapi: true,
          docs: true,
          cors: true,
          rateLimit: false,
        },
        endpoints: {
          openapi: "/openapi.json",
          docs: "/docs",
          health: "/api/v1/health",
          status: "/api/v1/status",
        },
      },
    },
    200
  );
});

/** Status probe — returns 200 if API is up (no body) */
status.on("HEAD", "/api/v1/status", () => new Response(null, { status: 200 }));

export default status;
