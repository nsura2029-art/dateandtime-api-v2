/**
 * Request logger middleware — logs method, path, status, latency.
 *
 * Outputs structured JSON so Cloudflare Workers Logs can parse it.
 */
import type { MiddlewareHandler } from "hono";
import type { Env, Variables } from "@/types/env";

export const logger = (): MiddlewareHandler<{ Bindings: Env; Variables: Variables }> => {
  return async (c, next) => {
    const start = Date.now();
    const requestId = c.get("requestId") || crypto.randomUUID();
    c.set("requestId", requestId);
    c.set("startTime", start);

    // Log incoming request
    console.log(
      JSON.stringify({
        type: "request",
        id: requestId,
        method: c.req.method,
        path: c.req.path,
        url: c.req.url,
        ip: c.req.header("cf-connecting-ip") ?? null,
        ua: c.req.header("user-agent") ?? null,
        ts: start,
      })
    );

    await next();

    // Log response
    const latencyMs = Date.now() - start;
    console.log(
      JSON.stringify({
        type: "response",
        id: requestId,
        status: c.res.status,
        latencyMs,
        ts: Date.now(),
      })
    );
  };
};
