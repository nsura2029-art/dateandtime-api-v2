/**
 * Input validation helpers — safe parsing for query params, path params, body.
 *
 * Use these instead of raw `parseInt(x, 10)` everywhere.
 */
import { z } from "zod";

/** Parse a string to a positive integer with bounds, returning a default. */
export function parseIntSafe(
  value: string | undefined,
  opts: { default: number; min?: number; max?: number }
): number {
  if (!value) return opts.default;
  const n = Number.parseInt(value, 10);
  if (Number.isNaN(n)) return opts.default;
  if (opts.min !== undefined && n < opts.min) return opts.min;
  if (opts.max !== undefined && n > opts.max) return opts.max;
  return n;
}

/** Parse a string to a non-negative integer offset. */
export function parseOffset(value: string | undefined, defaultOffset = 0): number {
  return parseIntSafe(value, { default: defaultOffset, min: 0, max: 100_000 });
}

/** Parse a string to a positive integer limit. */
export function parseLimit(value: string | undefined, defaultLimit = 50): number {
  return parseIntSafe(value, { default: defaultLimit, min: 1, max: 1000 });
}

/** Parse a string to a float (for lat/lon). */
export function parseFloatSafe(
  value: string | undefined,
  opts: { default?: number; min?: number; max?: number }
): number | null {
  if (!value) return opts.default ?? null;
  const n = Number.parseFloat(value);
  if (Number.isNaN(n)) return opts.default ?? null;
  if (opts.min !== undefined && n < opts.min) return null;
  if (opts.max !== undefined && n > opts.max) return null;
  return n;
}

/** Parse a comma-separated list, trimmed and deduped. */
export function parseCsv(value: string | undefined): string[] {
  if (!value) return [];
  const seen = new Set<string>();
  return value
    .split(",")
    .map((s) => s.trim())
    .filter((s) => s.length > 0 && !seen.has(s) && seen.add(s));
}

// ============================================================================
// Zod schemas for common query params
// ============================================================================

export const PaginationQuery = z.object({
  limit: z.coerce.number().int().min(1).max(1000).optional().default(50),
  offset: z.coerce.number().int().min(0).max(100_000).optional().default(0),
});

export type PaginationQuery = z.infer<typeof PaginationQuery>;

export const LatLonQuery = z.object({
  lat: z.coerce.number().min(-90).max(90),
  lon: z.coerce.number().min(-180).max(180),
});

export type LatLonQuery = z.infer<typeof LatLonQuery>;

/** Validate a numeric ID from a path param. Throws ZodError on bad input. */
export const NumericIdParam = z.coerce.number().int().positive();
export const Cca2Param = z
  .string()
  .length(2)
  .regex(/^[A-Z]{2}$/, "cca2 must be 2 uppercase letters");
export const DateParam = z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "date must be YYYY-MM-DD");
export const MonthDayParam = z.object({
  month: z.coerce.number().int().min(1).max(12),
  day: z.coerce.number().int().min(1).max(31),
});
