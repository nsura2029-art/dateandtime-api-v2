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
import translations from "@/routes/translations";
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
app.route("/", cities); // GET /api/v1/cities/search and /api/v1/cities/:id
app.route("/", translations); // GET /api/v1/cities/:id/translations[/:lang] + /api/v1/translations/search

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
