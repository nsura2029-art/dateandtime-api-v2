/**
 * dateandtime-api-v2 — entry point.
 *
 * Routes are registered as sub-apps; each owns its prefix.
 * See `src/routes/*` for the actual handlers.
 */
import { Hono } from "hono";
import { logger } from "@/middleware/logger";
import { errorHandler, notFoundHandler } from "@/middleware/error-handler";
import { handleCorsPreflight, getCorsHeaders } from "@/config/cors";
import { loadEnv } from "@/config/env";
import health from "@/routes/health";

import type { Env, Variables } from "@/types/env";

const app = new Hono<{ Bindings: Env; Variables: Variables }>();

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
app.route("/", health); // / and /api/v1/health

// Future: app.route("/", cities); app.route("/", countries); etc.

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
