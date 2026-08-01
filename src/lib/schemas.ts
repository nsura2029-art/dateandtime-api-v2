/**
 * Zod schemas for OpenAPI request/response types.
 *
 * Every route uses these schemas via @hono/zod-openapi's `createRoute()`.
 * The OpenAPI 3.1 spec is auto-generated from them and served at /openapi.json.
 * Swagger UI is served at /docs.
 *
 * Naming convention:
 *   - <Resource>Response       — single-resource response
 *   - <Resource>ListResponse   — paginated list response
 *   - <Resource>Query          — query params schema
 *   - <Resource>Params         — path params schema
 *   - ErrorResponse            — generic error
 */
import { z } from "zod";

// ============================================================================
// Common / shared schemas
// ============================================================================

/** Generic error body. Returned for all 4xx/5xx responses. */
export const ErrorResponse = z.object({
  success: z.literal(false),
  error: z.object({
    code: z.string().describe("SCREAMING_SNAKE_CASE error code, e.g. CITY_NOT_FOUND"),
    message: z.string().describe("Human-readable error message"),
    details: z.unknown().optional().describe("Optional extra context (e.g. Zod issues)"),
  }),
});

/** Pagination metadata. Returned with every list endpoint. */
export const Pagination = z.object({
  total: z.number().int().min(0).describe("Total matching rows across all pages"),
  limit: z.number().int().min(1).max(1000).describe("Items returned in this page"),
  offset: z.number().int().min(0).describe("Items skipped"),
  hasMore: z.boolean().describe("True if more items exist beyond this page"),
});

/** Standard pagination query params. Use for all list endpoints. */
export const PaginationQuery = z.object({
  limit: z.coerce.number().int().min(1).max(1000).default(50).describe("Max items to return (1-1000)"),
  offset: z.coerce.number().int().min(0).max(100_000).default(0).describe("Items to skip"),
});

/** Field selection — `?fields=id,name,timezone` to limit response payload. */
export const FieldsQuery = z.object({
  fields: z.string().optional().describe("Comma-separated list of fields to return"),
});

// ============================================================================
// City schemas
// ============================================================================

export const City = z.object({
  geoname_id: z.number().int().describe("GeoNames ID (primary key)"),
  name: z.string().describe("City name"),
  ascii_name: z.string().describe("ASCII-folded name"),
  country_code: z.string().length(2).describe("ISO 3166-1 alpha-2 country code"),
  country_name: z.string().describe("Full country name"),
  admin1_code: z.string().nullable().optional(),
  admin2_code: z.string().nullable().optional(),
  latitude: z.number().describe("Decimal degrees"),
  longitude: z.number().describe("Decimal degrees"),
  timezone: z.string().describe("IANA timezone (e.g. America/New_York)"),
  population: z.number().int().nullable().optional(),
  elevation: z.number().int().nullable().optional(),
  feature_code: z.string().describe("GeoNames feature code (PPL, PPLA, PPLC, etc.)"),
  is_capital: z.number().int().min(0).max(1).describe("1 if national/provincial capital, else 0"),
  state: z.string().nullable().optional(),
  state_code: z.string().nullable().optional(),
  state_iso3166_2: z.string().nullable().optional().describe("ISO 3166-2 state code (e.g. US-NY)"),
  slug: z.string().nullable().optional().describe("URL-friendly slug"),
});
export type CityT = z.infer<typeof City>;

export const CityListItem = City; // Same as City for now

export const CityQuery = PaginationQuery.extend({
  country: z.string().length(2).optional().describe("Filter by ISO 3166-1 alpha-2 country code"),
  tz: z.string().optional().describe("Filter by IANA timezone (e.g. America/New_York)"),
  sort: z.enum(["name", "population"]).default("name").describe("Sort field"),
  order: z.enum(["asc", "desc"]).default("asc").describe("Sort direction"),
});

export const CityParams = z.object({
  id: z.coerce.number().int().positive().describe("GeoNames ID of the city"),
});

export const CitiesNearQuery = z.object({
  lat: z.coerce.number().min(-90).max(90).describe("Latitude in decimal degrees"),
  lon: z.coerce.number().min(-180).max(180).describe("Longitude in decimal degrees"),
  r: z.coerce.number().min(1).max(20_000).default(100).describe("Search radius in km (max 20,000)"),
  limit: z.coerce.number().int().min(1).max(1000).default(50),
});

export const CitySearchQuery = z.object({
  q: z.string().min(1).max(200).describe("Search query (matches name + ascii_name)"),
  limit: z.coerce.number().int().min(1).max(1000).default(50),
  offset: z.coerce.number().int().min(0).max(100_000).default(0),
});

// ============================================================================
// Health + Status schemas
// ============================================================================

export const DatabaseStats = z.object({
  cities: z.number().int().min(0).describe("Row count in `cities` table"),
  countries: z.number().int().min(0),
  timezones: z.number().int().min(0),
  onthisday: z.number().int().min(0).describe("Row count in `onthisday` table"),
  cityAliases: z.number().int().min(0),
});

export const HealthResponse = z.object({
  success: z.literal(true),
  data: z.object({
    status: z.literal("ok").describe("Always 'ok' if the API is reachable and DB responds"),
    db: DatabaseStats,
    dbVersion: z.string().describe("Schema version (matches D1 migrations)"),
    apiVersion: z.string().describe("API code version (semver)"),
    env: z.string().describe("Worker name (e.g. dt-api-v2 or dt-api-v2-dev)"),
    latencyMs: z.number().int().describe("Time taken to query the DB in milliseconds"),
  }),
});

export const StatusResponse = z.object({
  success: z.literal(true),
  data: z.object({
    status: z.enum(["operational", "degraded", "down"]).describe("Overall API status"),
    timestamp: z.string().datetime().describe("ISO 8601 UTC timestamp of this response"),
    api: z.object({
      name: z.string().describe("Worker name"),
      version: z.string().describe("API semver version"),
      environment: z.enum(["dev", "production"]).describe("Deployment environment"),
    }),
    runtime: z.object({
      platform: z.literal("cloudflare-workers").describe("Runtime platform"),
      region: z.string().nullable().describe("Cloudflare colo code (e.g. 'IAD', 'SFO'), null if unknown"),
      colo: z.string().nullable().describe("Three-letter IATA airport code for the colo"),
    }),
    build: z.object({
      commit: z.string().nullable().describe("Git commit SHA (short) of the deployed code, null if unset"),
      deployedAt: z.string().datetime().nullable().describe("ISO 8601 deploy timestamp, null if unset"),
    }),
    database: z.object({
      binding: z.literal("timeandtimepro-full").describe("D1 database name bound to this Worker"),
      connected: z.boolean().describe("True if the DB responded to the test query"),
      version: z.string().nullable().describe("Schema version (from data_sources table if present)"),
      tables: DatabaseStats,
    }),
    features: z.object({
      openapi: z.boolean().describe("True if OpenAPI spec is available at /openapi.json"),
      docs: z.boolean().describe("True if Swagger UI is available at /docs"),
      cors: z.boolean().describe("True if CORS is enabled"),
      rateLimit: z.boolean().describe("True if rate limiting is enforced"),
    }),
    endpoints: z.object({
      openapi: z.string().describe("Path to the OpenAPI 3.1 JSON spec"),
      docs: z.string().describe("Path to the interactive Swagger UI"),
      health: z.string().describe("Path to the health check endpoint"),
      status: z.string().describe("Path to this endpoint"),
    }),
  }),
});
export type StatusResponseT = z.infer<typeof StatusResponse>;

// ============================================================================
// List-response helper
// ============================================================================

/**
 * Generic list response: `{ success: true, data: { items, pagination } }`.
 * Use with any resource type: `ListResponse(City)` → `{ items: City[], pagination }`.
 */
export function listResponse<T extends z.ZodType>(item: T) {
  return z.object({
    success: z.literal(true),
    data: z.object({
      items: z.array(item),
      pagination: Pagination,
    }),
  });
}

/** Generic single-item response: `{ success: true, data: { <resource>: T } }`. */
export function singleResponse<T extends z.ZodType>(name: string, item: T) {
  return z.object({
    success: z.literal(true),
    data: z.object({ [name]: item }),
  });
}
