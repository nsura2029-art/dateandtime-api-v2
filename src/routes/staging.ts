/**
 * Staging query endpoints (M11.0)
 *
 *   GET /api/v1/staging/cities        — list staged cities for a release
 *   GET /api/v1/staging/cities/:id    — single staged city
 *   GET /api/v1/staging/summary       — counts per release in cities_staging
 *
 * These are READ-ONLY views into the staging area. Promoting
 * staging → live is a separate Workflow operation (publish_geonames.sh).
 */
import { Hono } from "hono";
import type { Env, Variables } from "@/types/env";

const staging = new Hono<{ Bindings: Env; Variables: Variables }>();

// --------------------------------------------------------------------------
// GET /api/v1/staging/summary
// --------------------------------------------------------------------------
staging.get("/api/v1/staging/summary", async (c) => {
  const sql = `
    SELECT
      release_id,
      COUNT(*) as row_count,
      COUNT(DISTINCT country_code) as countries,
      COUNT(DISTINCT timezone) as timezones,
      COUNT(CASE WHEN timezone IS NULL THEN 1 END) as null_timezone,
      COUNT(CASE WHEN population IS NULL THEN 1 END) as null_population,
      MIN(loaded_at) as loaded_at
    FROM cities_staging
    GROUP BY release_id
    ORDER BY loaded_at DESC
  `;
  const result = await c.env.DB.prepare(sql).all();
  const releases = (result.results || []).map((r: any) => ({
    releaseId: r.release_id,
    rowCount: r.row_count,
    countries: r.countries,
    timezones: r.timezones,
    nullTimezone: r.null_timezone,
    nullPopulation: r.null_population,
    loadedAt: r.loaded_at,
  }));

  return c.json({
    success: true as const,
    data: { releases, count: releases.length },
  });
});

// --------------------------------------------------------------------------
// GET /api/v1/staging/cities
// --------------------------------------------------------------------------
staging.get("/api/v1/staging/cities", async (c) => {
  const releaseId = c.req.query("release_id");
  const country = c.req.query("country");
  const limitStr = c.req.query("limit") || "20";
  const limit = Math.min(100, Math.max(1, parseInt(limitStr, 10) || 20));

  const where: string[] = [];
  const params: unknown[] = [];
  if (releaseId) {
    where.push("release_id = ?");
    params.push(releaseId);
  }
  if (country) {
    where.push("country_code = ?");
    params.push(country.toUpperCase());
  }
  const whereSql = where.length > 0 ? "WHERE " + where.join(" AND ") : "";

  const sql = `
    SELECT
      external_id, name, ascii_name, latitude, longitude,
      country_code, admin1_code, admin2_code,
      feature_class, feature_code, population, elevation,
      timezone, modified_date
    FROM cities_staging
    ${whereSql}
    ORDER BY population DESC NULLS LAST
    LIMIT ?
  `;
  params.push(limit);
  const result = await c.env.DB.prepare(sql).bind(...params).all();
  const cities = (result.results || []).map((r: any) => ({
    externalId: r.external_id,
    name: r.name,
    asciiName: r.ascii_name,
    latitude: r.latitude,
    longitude: r.longitude,
    country: r.country_code,
    admin1: r.admin1_code,
    admin2: r.admin2_code,
    featureClass: r.feature_class,
    featureCode: r.feature_code,
    population: r.population,
    elevation: r.elevation,
    timezone: r.timezone,
    modifiedDate: r.modified_date,
  }));

  return c.json({
    success: true as const,
    data: { cities, count: cities.length, releaseId: releaseId || null },
  });
});

export default staging;
