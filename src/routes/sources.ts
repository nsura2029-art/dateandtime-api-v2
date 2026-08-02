/**
 * Source registry endpoints (M11.0)
 *
 *   GET /api/v1/sources           — list all registered sources
 *   GET /api/v1/sources/:key      — get one source + its releases
 *   GET /api/v1/sources/:key/releases — list releases for a source
 *
 * The source registry is the catalog of every external data source the
 * platform knows about. GeoNames is the first one (active). 9 more are
 * registered as inactive (planned).
 */
import { Hono } from "hono";
import type { Env, Variables } from "@/types/env";

const sources = new Hono<{ Bindings: Env; Variables: Variables }>();

// --------------------------------------------------------------------------
// Schemas
// --------------------------------------------------------------------------
const SourceSchema = {
  type: "object",
  properties: {
    sourceKey: { type: "string" },
    publisher: { type: "string" },
    dataset: { type: "string" },
    coverage: { type: "string", nullable: true },
    accessMethod: { type: "string", nullable: true },
    endpointUrl: { type: "string", nullable: true },
    license: { type: "string", nullable: true },
    licenseUrl: { type: "string", nullable: true },
    attribution: { type: "string", nullable: true },
    refreshPolicy: { type: "string", nullable: true },
    knownLimitations: { type: "string", nullable: true },
    isActive: { type: "boolean" },
    createdAt: { type: "integer" },
    updatedAt: { type: "integer" },
  },
} as const;

const ReleaseSchema = {
  type: "object",
  properties: {
    releaseId: { type: "string" },
    sourceKey: { type: "string" },
    releaseDate: { type: "string" },
    discoveredAt: { type: "integer" },
    status: {
      type: "string",
      enum: [
        "discovered", "downloading", "raw-stored", "parsing",
        "normalized", "staging", "published", "rejected", "superseded",
      ],
    },
    rawSha256: { type: "string", nullable: true },
    rawSizeBytes: { type: "integer", nullable: true },
    rawR2Key: { type: "string", nullable: true },
    normalizedR2Key: { type: "string", nullable: true },
    rowCountIn: { type: "integer", nullable: true },
    rowCountAccepted: { type: "integer", nullable: true },
    rowCountRejected: { type: "integer", nullable: true },
    manifestR2Key: { type: "string", nullable: true },
    workflowRunId: { type: "string", nullable: true },
    errorMessage: { type: "string", nullable: true },
    startedAt: { type: "integer", nullable: true },
    finishedAt: { type: "integer", nullable: true },
    publishedAt: { type: "integer", nullable: true },
  },
} as const;

// --------------------------------------------------------------------------
// GET /api/v1/sources
// --------------------------------------------------------------------------
sources.get("/api/v1/sources", async (c) => {
    const activeParam = c.req.query("active");
    let sql = "SELECT * FROM source_registry";
    const params: unknown[] = [];
    if (activeParam === "true") {
      sql += " WHERE is_active = 1";
    } else if (activeParam === "false") {
      sql += " WHERE is_active = 0";
    }
    sql += " ORDER BY is_active DESC, source_key ASC";

    const result = await c.env.DB.prepare(sql).bind(...params).all();
    const sources = (result.results || []).map((r: any) => ({
      sourceKey: r.source_key,
      publisher: r.publisher,
      dataset: r.dataset,
      coverage: r.coverage,
      accessMethod: r.access_method,
      endpointUrl: r.endpoint_url,
      license: r.license,
      licenseUrl: r.license_url,
      attribution: r.attribution,
      refreshPolicy: r.refresh_policy,
      knownLimitations: r.known_limitations,
      isActive: r.is_active === 1,
      createdAt: r.created_at,
      updatedAt: r.updated_at,
    }));

    return c.json({
      success: true as const,
      data: {
        sources,
        count: sources.length,
        activeCount: sources.filter((s: any) => s.isActive).length,
      },
    });
  }
);

// --------------------------------------------------------------------------
// GET /api/v1/sources/:key
// --------------------------------------------------------------------------
sources.get("/api/v1/sources/:key", async (c) => {
    const key = c.req.param("key");
    const sourceResult = await c.env.DB.prepare(
      "SELECT * FROM source_registry WHERE source_key = ?"
    ).bind(key).first();
    if (!sourceResult) {
      return c.json(
        { success: false as const, error: { code: "NOT_FOUND", message: `Source '${key}' not found` } },
        404
      );
    }
    const r = sourceResult as any;
    const source = {
      sourceKey: r.source_key,
      publisher: r.publisher,
      dataset: r.dataset,
      coverage: r.coverage,
      accessMethod: r.access_method,
      endpointUrl: r.endpoint_url,
      license: r.license,
      licenseUrl: r.license_url,
      attribution: r.attribution,
      refreshPolicy: r.refresh_policy,
      knownLimitations: r.known_limitations,
      isActive: r.is_active === 1,
      createdAt: r.created_at,
      updatedAt: r.updated_at,
    };

    // Get most recent 5 releases
    const releasesResult = await c.env.DB.prepare(
      "SELECT * FROM source_releases WHERE source_key = ? ORDER BY release_date DESC LIMIT 5"
    ).bind(key).all();
    const releases = (releasesResult.results || []).map((rr: any) => mapRelease(rr));

    return c.json({
      success: true as const,
      data: { ...source, recentReleases: releases },
    });
  }
);

// --------------------------------------------------------------------------
// GET /api/v1/sources/:key/releases
// --------------------------------------------------------------------------
sources.get("/api/v1/sources/:key/releases", async (c) => {
    const key = c.req.param("key");
    const status = c.req.query("status");
    const limitStr = c.req.query("limit") || "20";
    const limit = Math.min(100, Math.max(1, parseInt(limitStr, 10) || 20));

    let sql = "SELECT * FROM source_releases WHERE source_key = ?";
    const params: unknown[] = [key];
    if (status) {
      sql += " AND status = ?";
      params.push(status);
    }
    sql += " ORDER BY release_date DESC LIMIT ?";
    params.push(limit);

    const result = await c.env.DB.prepare(sql).bind(...params).all();
    const releases = (result.results || []).map((r: any) => mapRelease(r));

    return c.json({
      success: true as const,
      data: {
        sourceKey: key,
        releases,
        count: releases.length,
        filter: status ? { status } : null,
      },
    });
  }
);

function mapRelease(r: any) {
  return {
    releaseId: r.release_id,
    sourceKey: r.source_key,
    releaseDate: r.release_date,
    discoveredAt: r.discovered_at,
    status: r.status,
    rawSha256: r.raw_sha256,
    rawSizeBytes: r.raw_size_bytes,
    rawR2Key: r.raw_r2_key,
    normalizedR2Key: r.normalized_r2_key,
    rowCountIn: r.row_count_in,
    rowCountAccepted: r.row_count_accepted,
    rowCountRejected: r.row_count_rejected,
    manifestR2Key: r.manifest_r2_key,
    workflowRunId: r.workflow_run_id,
    errorMessage: r.error_message,
    startedAt: r.started_at,
    finishedAt: r.finished_at,
    publishedAt: r.published_at,
  };
}

export default sources;
