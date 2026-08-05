/**
 * Environment variable validation and access.
 *
 * Use `loadEnv(c.env)` to get a validated env object with parsed values.
 * Throws if any required var is missing or malformed.
 */
import { z } from "zod";
import type { Env as RawEnv } from "@/types/env";

const EnvSchema = z.object({
  API_VERSION: z.string().min(1),
  API_NAME: z.string().min(1),
  LOG_LEVEL: z.enum(["debug", "info", "warn", "error"]).default("info"),
  ALLOWED_ORIGINS: z.string().min(1),
  ADMIN_API_KEY: z.string().optional(),
  RATE_LIMIT_TOKEN: z.string().optional(),
});

export type ValidatedEnv = z.infer<typeof EnvSchema> & {
  DB: D1Database;
  CACHE?: KVNamespace;
  allowedOrigins: string[]; // parsed from ALLOWED_ORIGINS
};

/**
 * Load and validate env from a Hono context. Throws ZodError on bad config.
 */
export function loadEnv(raw: RawEnv): ValidatedEnv {
  const parsed = EnvSchema.parse(raw);

  // Parse ALLOWED_ORIGINS into a list, trim whitespace, drop empty
  const allowedOrigins = parsed.ALLOWED_ORIGINS.split(",")
    .map((s) => s.trim())
    .filter(Boolean);

  return {
    ...parsed,
    DB: raw.DB,
    CACHE: raw.CACHE,
    allowedOrigins,
  };
}

/**
 * Check whether an origin is allowed for CORS.
 *
 * Supports three patterns per entry in `allowedOrigins`:
 *   1. "*"             — allow ALL origins (dev only — never use in prod!)
 *   2. "https://x.com" — exact origin match
 *   3. "http://localhost:*" or "http://127.0.0.1:*" — port wildcard for local dev
 *
 * Examples:
 *   ALLOWED_ORIGINS = "https://dateandtime.live,http://localhost:*"
 *     → allows the prod site + any localhost port (for Swagger UI testing)
 */
export function isOriginAllowed(origin: string | null, allowedOrigins: string[]): boolean {
  if (!origin) return false;
  if (allowedOrigins.includes("*")) return true;
  if (allowedOrigins.includes(origin)) return true;

  // Port-wildcard pattern: "http://localhost:*" matches "http://localhost:8787"
  for (const allowed of allowedOrigins) {
    if (allowed.endsWith(":*")) {
      const prefix = allowed.slice(0, -2); // "http://localhost"
      if (origin === prefix || origin.startsWith(prefix + ":")) {
        return true;
      }
    }
    // Also support 127.0.0.1 in addition to localhost if you want
  }

  return false;
}
