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
 * "*" in the env list allows all origins (dev only).
 */
export function isOriginAllowed(origin: string | null, allowedOrigins: string[]): boolean {
  if (!origin) return false;
  if (allowedOrigins.includes("*")) return true;
  return allowedOrigins.includes(origin);
}
