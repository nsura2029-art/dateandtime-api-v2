/**
 * Health check endpoints.
 *   GET /                      — API root, version, endpoint manifest
 *   GET /api/v1/health         — DB stats, latency, version
 *   HEAD /api/v1/health        — for probe-on-boot checks
 */
import { Hono } from "hono";
import { success } from "@/lib/response";
import { Cities, Countries, Timezones, OnThisDay, CityAliases } from "@/lib/db";
import type { Env, Variables } from "@/types/env";

const health = new Hono<{ Bindings: Env; Variables: Variables }>();

// ============================================================================
// GET / — API root
// ============================================================================
health.get("/", async (c) => {
  return success({
    name: c.env.API_NAME,
    version: c.env.API_VERSION,
    description: "dateandtime.live API v2",
    docs: "/docs",
    openapi: "/openapi.json",
    endpoints: {
      health: "/api/v1/health",
      cities: "/api/v1/cities",
      citiesById: "/api/v1/cities/:id",
      citiesSearch: "/api/v1/cities/search",
      citiesNear: "/api/v1/cities/near",
      citiesClimate: "/api/v1/cities/:id/climate",
      citiesAliases: "/api/v1/cities/:id/aliases",
      countries: "/api/v1/countries",
      countryByCca2: "/api/v1/countries/:cca2",
      countryCities: "/api/v1/countries/:cca2/cities",
      countryWorkingHours: "/api/v1/countries/:cca2/working-hours",
      timezones: "/api/v1/timezones",
      timezoneById: "/api/v1/timezones/:id",
      timeNow: "/api/v1/time/now",
      timeSun: "/api/v1/time/sun",
      holidays: "/api/v1/holidays",
      holidaysToday: "/api/v1/holidays/today",
      holidaysUpcoming: "/api/v1/holidays/upcoming",
      onthisday: "/api/v1/onthisday",
      dstUpcoming: "/api/v1/dst/upcoming",
      popularCities: "/api/v1/popular/cities",
      popularDefaults: "/api/v1/popular/defaults",
      search: "/api/v2/search",
    },
  });
});

// ============================================================================
// GET /api/v1/health — DB stats + latency
// ============================================================================
health.get("/api/v1/health", async (c) => {
  const start = Date.now();
  const [cities, countries, tzs, otd, aliases] = await Promise.all([
    Cities.count(c.env.DB),
    Countries.count(c.env.DB),
    Timezones.count(c.env.DB),
    OnThisDay.count(c.env.DB),
    CityAliases.count(c.env.DB),
  ]);
  const latencyMs = Date.now() - start;

  return success({
    status: "ok",
    db: {
      cities,
      countries,
      timezones: tzs,
      onthisday: otd,
      cityAliases: aliases,
    },
    dbVersion: c.env.API_VERSION,
    apiVersion: c.env.API_VERSION,
    env: c.env.API_NAME,
    latencyMs,
  });
});

// HEAD probe for feature detection
health.on("HEAD", "/api/v1/health", () => new Response(null, { status: 200 }));

export default health;
