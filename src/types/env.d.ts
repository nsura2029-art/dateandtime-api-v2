/**
 * Cloudflare Workers environment bindings.
 *
 * Add new bindings to the `Env` interface when you add them to wrangler.toml.
 * For secrets, use `c.env.SECRET_NAME` — they're typed as `string | undefined`.
 */
export interface Env {
  // D1 database binding (from [[d1_databases]] in wrangler.toml)
  DB: D1Database;

  // KV namespace binding (from [[kv_namespaces]] in wrangler.toml) — optional
  CACHE?: KVNamespace;

  // Environment variables (from [vars] in wrangler.toml)
  API_VERSION: string;
  API_NAME: string;
  LOG_LEVEL: "debug" | "info" | "warn" | "error";
  ALLOWED_ORIGINS: string;

  // Secrets (set via `wrangler secret put NAME`) — typed as optional
  ADMIN_API_KEY?: string;
  RATE_LIMIT_TOKEN?: string;
}

/**
 * Hono context variables (set by middleware, available in handlers as c.var.X).
 */
export type Variables = {
  requestId: string;
  startTime: number;
};
