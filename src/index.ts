/**
 * dateandtime-api-v2 — entry point.
 *
 * Uses OpenAPIHono (extends Hono) so all routes can be introspected
 * for the /openapi.json spec and /docs Swagger UI.
 */
import { OpenAPIHono } from "@hono/zod-openapi";
import { logger } from "@/middleware/logger";
import { errorHandler, notFoundHandler } from "@/middleware/error-handler";
import { handleCorsPreflight, getCorsHeaders } from "@/config/cors";
import { loadEnv } from "@/config/env";
import health from "@/routes/health";
import status from "@/routes/status";
import cities from "@/routes/cities";
import citiesList from "@/routes/cities-list";
import cityResources from "@/routes/city-resources";
import translations from "@/routes/translations";
import postcodes from "@/routes/postcodes";
import airports from "@/routes/airports";
import dq from "@/routes/data-quality";
import sources from "@/routes/sources";
import staging from "@/routes/staging";
import countries from "@/routes/countries";
import regions from "@/routes/regions";
import states from "@/routes/states";
import time from "@/routes/time";
import { registerDocs } from "@/routes/docs";

import type { Env, Variables } from "@/types/env";

const app = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// ============================================================================
// Middleware (order matters)
// ============================================================================
app.use("*", errorHandler());
app.use("*", logger());

// CORS preflight (OPTIONS) — must come before routes
app.options("*", (c) => {
  const env = loadEnv(c.env);
  const preflight = handleCorsPreflight(c.req.raw, env);
  return preflight ?? new Response(null, { status: 204 });
});

// ============================================================================
// Routes
// ============================================================================
app.route("/", health); // GET / and GET /api/v1/health
app.route("/", status); // GET /api/v1/status
// IMPORTANT: citiesList (/cities/near) must come BEFORE cities (/cities/{id})
// so that "near" doesn't get matched as a city ID
app.route("/", citiesList); // GET /api/v1/cities (list) + /api/v1/cities/near
app.route("/", cityResources); // GET /api/v1/cities/:id/aliases + /api/v1/cities/:id/climate
app.route("/", cities); // GET /api/v1/cities/search and /api/v1/cities/:id
app.route("/", translations); // GET /api/v1/cities/:id/translations[/:lang] + /api/v1/translations/search
app.route("/", postcodes); // GET /api/v1/cities/:id/postcodes + /api/v1/postcodes/search
app.route("/", airports); // GET /api/v1/airports/near + /api/v1/cities/:id/airports
app.route("/", dq); // GET /api/v1/data-quality + /api/v1/data-quality/issues
app.route("/", sources); // GET /api/v1/sources + /api/v1/sources/:key + /api/v1/sources/:key/releases
app.route("/", staging); // GET /api/v1/staging/summary + /api/v1/staging/cities
// IMPORTANT: states (/countries/:cca2/states) must come BEFORE countries (/countries/{cca2})
// so that "/countries/US/states" doesn't get matched as cca2="US" with extra path
app.route("/", states); // GET /api/v1/countries/:cca2/states + /api/v1/states/:id
app.route("/", countries); // GET /api/v1/countries + /api/v1/countries/{cca2}
app.route("/", regions); // GET /api/v1/regions + /api/v1/regions/:code/subregions + /api/v1/subregions/:code/countries
app.route("/", time); // GET /api/v1/time/now + /api/v1/time/convert

// OpenAPI + Swagger UI
registerDocs(app);

// ============================================================================
// CORS headers on every response
// ============================================================================
app.use("*", async (c, next) => {
  await next();
  const env = loadEnv(c.env);
  const corsHeaders = getCorsHeaders(c.req.raw, env);
  corsHeaders.forEach((value, key) => {
    c.res.headers.set(key, value);
  });
});

// ============================================================================
// 404 fallback
// ============================================================================
app.all("*", notFoundHandler);

export default app;
