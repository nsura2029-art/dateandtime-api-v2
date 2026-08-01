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
// Geographic schemas (regions, subregions, countries, administrative_regions)
// ============================================================================

export const Region = z.object({
  id: z.number().int().describe("Region ID (1-6)"),
  code: z.string().describe("Short code (AF, AM, AS, EU, OC, AN)"),
  name: z.string().describe("Region name (Africa, Americas, Asia, Europe, Oceania, Polar)"),
  un_m49_code: z.string().describe("UN M49 code (002, 019, 142, 150, 009, AQ)"),
});
export type RegionT = z.infer<typeof Region>;

export const Subregion = z.object({
  id: z.number().int().describe("Sub-region ID"),
  code: z.string().describe("UN M49 code (e.g. '021' for Northern America)"),
  name: z.string().describe("Sub-region name"),
  region_id: z.number().int().describe("Parent region ID"),
});
export type SubregionT = z.infer<typeof Subregion>;

export const Country = z.object({
  id: z.number().int().describe("Country ID (dr5hn)"),
  cca2: z.string().length(2).describe("ISO 3166-1 alpha-2 code (e.g. 'US', 'IN')"),
  cca3: z.string().nullable().describe("ISO 3166-1 alpha-3 code"),
  ccn3: z.string().nullable().describe("ISO 3166-1 numeric code"),
  cioc: z.string().nullable().describe("IOC Olympic code"),
  name: z.string().describe("Country name (e.g. 'United States')"),
  official_name: z.string().nullable().describe("Official name (e.g. 'United States of America')"),
  capital: z.string().nullable().describe("Capital city name"),
  region_id: z.number().int().describe("Parent region ID"),
  subregion_id: z.number().int().describe("Parent sub-region ID"),
  currency_code: z.string().nullable().describe("ISO 4217 currency code (USD, INR, JPY)"),
  currency_name: z.string().nullable().describe("Currency name"),
  currency_symbol: z.string().nullable().describe("Currency symbol ($ ₹ ¥)"),
  phone_code: z.string().nullable().describe("International calling code (+1, +91)"),
  languages: z.string().nullable().describe("Comma-separated ISO 639-1 codes (en, hi,en)"),
  latitude: z.number().nullable().describe("Country center latitude"),
  longitude: z.number().nullable().describe("Country center longitude"),
  area_km2: z.number().nullable().describe("Area in square kilometers"),
  population: z.number().int().nullable().describe("Population"),
  flag_emoji: z.string().nullable().describe("Flag emoji (🇺🇸)"),
  tld: z.string().nullable().describe("Top-level domain (.us, .in)"),
  un_member: z.number().int().min(0).max(1).describe("1 if UN member"),
  landlocked: z.number().int().min(0).max(1).describe("1 if landlocked"),
  independent: z.number().int().min(0).max(1).describe("1 if independent"),
  start_of_week: z.string().nullable().describe("'monday' or 'sunday'"),
  borders: z.string().nullable().describe("Comma-separated cca2 of neighbors"),
  canonical_timezones: z.string().nullable().describe("Comma-separated IANA timezones"),
});
export type CountryT = z.infer<typeof Country>;

export const AdminRegion = z.object({
  id: z.number().int().describe("Admin region ID (dr5hn)"),
  country_id: z.number().int().describe("Parent country ID"),
  parent_id: z.number().int().nullable().describe("Parent admin region (for counties in states)"),
  code: z.string().nullable().describe("Short code (CA, NY, ON)"),
  name: z.string().describe("Region name"),
  ascii_name: z.string().nullable().describe("ASCII name"),
  type: z.string().nullable().describe("state | province | territory | region | county | district"),
  level: z.number().int().describe("1=state/province, 2=county/district"),
  latitude: z.number().nullable().describe("Center latitude"),
  longitude: z.number().nullable().describe("Center longitude"),
  iso2: z.string().nullable().describe("Full ISO 3166-2 code (e.g. 'US-CA')"),
  population: z.number().int().nullable().describe("Population"),
  timezone: z.string().nullable().describe("IANA timezone"),
});
export type AdminRegionT = z.infer<typeof AdminRegion>;

// ============================================================================
// City schemas
// ============================================================================

export const City = z.object({
  id: z.number().int().describe("Canonical place ID (dr5hn, primary key)"),
  name: z.string().describe("City name (any script)"),
  ascii_name: z.string().nullable().describe("ASCII transliteration"),
  country_id: z.number().int().describe("FK to countries.id"),
  state_id: z.number().int().nullable().describe("FK to administrative_regions.id (state)"),
  district_id: z.number().int().nullable().describe("FK to administrative_regions.id (county)"),
  latitude: z.number().describe("Decimal degrees"),
  longitude: z.number().describe("Decimal degrees"),
  timezone: z.string().describe("IANA timezone (e.g. America/New_York)"),
  population: z.number().int().nullable().describe("Population"),
  elevation: z.number().int().nullable().describe("Elevation in meters"),
  feature_code: z.string().nullable().describe("GeoNames feature code (PPL, PPLA, PPLC)"),
  place_type: z.string().nullable().describe("city | town | village | neighborhood | district"),
  capital_type: z.string().nullable().describe("none | state_capital | country_capital | both"),
  is_active: z.number().int().min(0).max(1).describe("0=historical, 1=active"),
  is_capital: z.number().int().min(0).max(1).describe("Legacy capital flag"),
  is_state_capital: z.number().int().min(0).max(1),
  is_country_capital: z.number().int().min(0).max(1),
  disputed: z.number().int().min(0).max(1).describe("1 if boundary/label disputed"),
  claimed_by: z.string().nullable().describe("Comma-separated country codes that claim this place"),
  source_id: z.string().nullable().describe("Original source ID (e.g. dr5hn:1326573)"),
  source_version: z.string().nullable().describe("Source version (e.g. dr5hn-2026-07-29)"),
  created_at: z.string().describe("ISO 8601 timestamp"),
  updated_at: z.string().describe("ISO 8601 timestamp"),
});
export type CityT = z.infer<typeof City>;

export const CityListItem = City;

export const CityQuery = PaginationQuery.extend({
  country: z.string().length(2).optional().describe("Filter by ISO 3166-1 alpha-2 country code"),
  region: z.coerce.number().int().optional().describe("Filter by region ID (1-6)"),
  subregion: z.coerce.number().int().optional().describe("Filter by sub-region ID"),
  state: z.coerce.number().int().optional().describe("Filter by state/admin region ID"),
  tz: z.string().optional().describe("Filter by IANA timezone (e.g. America/New_York)"),
  sort: z.enum(["name", "population"]).default("name").describe("Sort field"),
  order: z.enum(["asc", "desc"]).default("asc").describe("Sort direction"),
});

export const CityParams = z.object({
  id: z.coerce.number().int().positive().describe("City ID (dr5hn)"),
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
// Timezone schemas
// ============================================================================

export const Timezone = z.object({
  id: z.string().describe("IANA name (e.g. 'America/New_York')"),
  canonical_id: z.string().nullable().describe("Points to canonical IANA name (NULL if id is canonical)"),
  region: z.string().nullable().describe("Continent/region (America, Europe, Asia)"),
  subregion: z.string().nullable().describe("Sub-region (Northern America, Western Europe)"),
  city: z.string().nullable().describe("Representative city"),
  country_codes: z.string().nullable().describe("Comma-separated cca2"),
  countries: z.string().nullable().describe("Comma-separated country names"),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
  current_offset: z.number().int().nullable().describe("UTC offset in MINUTES (e.g. -300 for EST)"),
  current_abbreviation: z.string().nullable().describe("EST, EDT, GMT+5:30, etc."),
  is_dst: z.number().int().min(0).max(1).nullable().describe("0/1 whether currently in DST"),
  description: z.string().nullable(),
});
export type TimezoneT = z.infer<typeof Timezone>;

// ============================================================================
// Health + Status schemas
// ============================================================================

export const DatabaseStats = z.object({
  regions: z.number().int().min(0).describe("Row count in `regions` table (6)"),
  subregions: z.number().int().min(0).describe("Row count in `subregions` table (22)"),
  countries: z.number().int().min(0).describe("Row count in `countries` table (250)"),
  administrativeRegions: z.number().int().min(0).describe("Row count in `administrative_regions` (5,308)"),
  cities: z.number().int().min(0).describe("Row count in `cities` table (152,970)"),
  timezones: z.number().int().min(0).describe("Row count in `time_zones` table (~450)"),
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
      binding: z.literal("timeandtimepro-full-v2").describe("D1 database name bound to this Worker"),
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
