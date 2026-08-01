/**
 * Error handler middleware — catches all thrown errors, logs them, returns 500.
 *
 * Should be the FIRST middleware (after logger) so it wraps everything.
 */
import type { Context, MiddlewareHandler } from "hono";
import type { Env, Variables } from "@/types/env";
import { Errors, zodErrorResponse } from "@/lib/response";
import { loadEnv } from "@/config/env";

export const errorHandler = (): MiddlewareHandler<{ Bindings: Env; Variables: Variables }> => {
  return async (c, next) => {
    try {
      await next();
    } catch (err) {
      // ZodError → 400 with details
      const zodResp = zodErrorResponse(err);
      if (zodResp) {
        return c.newResponse(zodResp.body, zodResp.status as 400, zodResp.headers);
      }

      // Log unexpected errors with full context
      const env = loadEnv(c.env); // may throw if env is bad, but we tried
      console.error(
        JSON.stringify({
          type: "error",
          requestId: c.get("requestId"),
          method: c.req.method,
          path: c.req.path,
          env: env.API_NAME,
          message: err instanceof Error ? err.message : String(err),
          stack: err instanceof Error ? err.stack : undefined,
        })
      );

      // In dev, include the error message in the response for faster debugging
      if (env.LOG_LEVEL === "debug") {
        const msg = err instanceof Error ? err.message : String(err);
        return c.newResponse(
          JSON.stringify({
            success: false,
            error: { code: "INTERNAL_ERROR", message: msg, stack: err instanceof Error ? err.stack : undefined },
          }),
          500,
          { "Content-Type": "application/json; charset=utf-8" }
        );
      }

      return c.newResponse(Errors.internal().body, 500, { "Content-Type": "application/json; charset=utf-8" });
    }
  };
};

/**
 * 404 fallback — when no route matches.
 */
export function notFoundHandler(c: Context): Response {
  return c.newResponse(
    JSON.stringify({
      success: false,
      error: { code: "NOT_FOUND", message: `Route ${c.req.method} ${c.req.path} not found` },
    }),
    404,
    { "Content-Type": "application/json; charset=utf-8" }
  );
}
