/**
 * D1 row types — match the schema in `migrations/101_create_schema.sql`.
 *
 * All optional fields use `?` to match SQLite's nullable behavior.
 * Date fields are ISO strings (YYYY-MM-DD) unless noted.
 *
 * Schema source: docs/SPEC-master-data-architecture.md (Phase 1 of
 * docs/PLAN-phased-implementation.md).
 */

// ============================================================================
// Geographic hierarchy (countries / regions / administrative_regions)
// ============================================================================

/** Row in `regions` table — 6 UN M49 regions. */
export interface Region {
  id: number;
  code: string;          // 'AF', 'AM', 'AS', 'EU', 'OC', 'AN'
  name: string;          // 'Africa', 'Americas', 'Asia', 'Europe', 'Oceania', 'Polar'
  un_m49_code: string;   // '002', '019', '142', '150', '009', 'AQ'
}

/** Row in `subregions` table — 22 UN M49 sub-regions. */
export interface Subregion {
  id: number;
  code: string;          // UN M49 code, e.g. '021' (Northern America)
  name: string;
  region_id: number;
}

/** Row in `countries` table — 250 ISO 3166-1 countries. */
export interface Country {
  id: number;                 // dr5hn ID
  cca2: string;               // 'US', 'IN', 'JP' (ISO 3166-1 alpha-2)
  cca3: string | null;        // 'USA', 'IND', 'JPN'
  ccn3: string | null;        // '840', '356', '392'
  cioc: string | null;        // 'USA', 'IND', 'JPN' (Olympic)
  name: string;
  official_name: string | null;
  capital: string | null;
  region_id: number;
  subregion_id: number;
  currency_code: string | null;
  currency_name: string | null;
  currency_symbol: string | null;
  phone_code: string | null;
  languages: string | null;          // comma-separated ISO 639-1 codes: 'en', 'hi,en'
  latitude: number | null;
  longitude: number | null;
  area_km2: number | null;
  population: number | null;
  flag_emoji: string | null;          // '🇺🇸', '🇮🇳', '🇯🇵'
  tld: string | null;
  un_member: number;                  // 0 | 1
  landlocked: number;                 // 0 | 1
  independent: number;                // 0 | 1
  start_of_week: string | null;       // 'monday' / 'sunday'
  borders: string | null;             // comma-separated cca2: 'CA,MX'
  canonical_timezones: string | null; // comma-separated IANA names
}

/** Row in `administrative_regions` table — 5,308 states/provinces/counties. */
export interface AdminRegion {
  id: number;                // dr5hn ID
  country_id: number;
  parent_id: number | null;  // for nested regions (e.g., county in state)
  code: string | null;       // 'CA', 'NY', 'ON' (ISO 3166-2)
  name: string;
  ascii_name: string | null;
  type: string | null;       // 'state' | 'province' | 'territory' | 'region' | 'county' | 'district'
  level: number;             // 1=state/province, 2=county/district
  latitude: number | null;
  longitude: number | null;
  iso2: string | null;       // full ISO 3166-2 code, e.g. 'US-CA'
  population: number | null;
  timezone: string | null;   // IANA timezone
}

/** Row in `cities` table — 152,970 canonical place records. */
export interface City {
  id: number;                // dr5hn ID (canonical place ID)
  name: string;              // official name (any script)
  ascii_name: string | null; // ASCII transliteration
  country_id: number;
  state_id: number | null;   // FK to administrative_regions
  district_id: number | null;// FK to administrative_regions (county)
  latitude: number;
  longitude: number;
  timezone: string;          // IANA timezone
  population: number | null;
  elevation: number | null;
  feature_code: string | null;        // GeoNames feature code
  place_type: string | null;          // 'city' | 'town' | 'village' | 'neighborhood' | 'district'
  capital_type: string | null;        // 'none' | 'state_capital' | 'country_capital' | 'both'
  is_active: number;                 // 0=historical, 1=active
  is_capital: number;                // legacy
  is_state_capital: number;
  is_country_capital: number;
  tier: string | null;               // 'tier1' | 'tier2' | 'tier3' (Phase 2)
  disputed: number;                  // 1 if boundary/label disputed
  claimed_by: string | null;         // comma-separated country codes
  source_id: string | null;          // e.g. "dr5hn:1326573" or "geonames:5128581"
  source_version: string | null;     // e.g. "dr5hn-2026-07-29"
  created_at: string;
  updated_at: string;
}

/** Row in `place_names` table — multi-language searchable names (Phase 2). */
export interface PlaceName {
  id: number;
  canonical_place_id: number;
  name: string;
  normalized_name: string;            // lowercase + diacritics removed
  language_code: string | null;       // ISO 639-1: "de", "en", "ru"
  script: string | null;              // "Latn", "Cyrl", "Arab", "Hans"
  name_type: string;                  // 'official' | 'ascii' | 'local' | 'transliteration' | 'abbreviation' | 'alternate' | 'historical' | 'colloquial'
  is_preferred: number;               // 1 = use for display when multiple exist
  is_historical: number;              // 1 = historical name, no longer in use
  source: string | null;              // "dr5hn" | "geonames" | "wikipedia" | "manual"
}

// ============================================================================
// Time zones
// ============================================================================

/** Row in `time_zones` table — IANA canonical + aliases. */
export interface Timezone {
  id: string;                          // IANA name, e.g. 'America/New_York'
  canonical_id: string | null;         // points to canonical IANA name (NULL if id is canonical)
  region: string | null;               // 'America', 'Europe', 'Asia', etc.
  subregion: string | null;            // 'Northern America', 'Western Europe', etc.
  city: string | null;                 // representative city
  country_codes: string | null;        // comma-separated cca2
  countries: string | null;            // comma-separated country names
  latitude: number | null;
  longitude: number | null;
  current_offset: number | null;       // UTC offset in MINUTES (e.g., -300 for EST)
  current_abbreviation: string | null; // 'EST', 'EDT', 'GMT+5:30'
  is_dst: number | null;               // 0 | 1
  description: string | null;
}

/** Row in `city_time_zones` table — M2M cities ↔ timezones. */
export interface CityTimezone {
  city_id: number;
  timezone_id: string;
  is_primary: number;                  // 1 = main timezone
}

/** Row in `country_time_zones` table — M2M countries ↔ timezones. */
export interface CountryTimezone {
  country_id: number;
  timezone_id: string;
  is_primary: number;                  // 1 = main timezone
}

// ============================================================================
// Data lineage (governance)
// ============================================================================

/** Row in `data_sources` table — track which source/version each data came from. */
export interface DataSource {
  id: number;
  name: string;                        // "dr5hn" | "geonames" | "iana_tzdb" | "cldr" | "natural_earth"
  url: string | null;
  version: string;                     // "2026-07-29"
  license: string | null;              // "MIT" | "CC-BY-4.0" | "public-domain"
  last_fetched_at: string | null;
  last_fetched_rows: number | null;
  notes: string | null;
}

/** Row in `import_history` table — every import run. */
export interface ImportHistory {
  id: number;
  data_source_id: number | null;
  started_at: string;
  completed_at: string | null;
  rows_imported: number;
  rows_skipped: number;
  rows_errored: number;
  error_message: string | null;
  notes: string | null;
}

/** Row in `place_redirects` table — historical renamings / merged cities. */
export interface PlaceRedirect {
  id: number;
  from_id: number;                     // old city ID
  to_id: number;                       // new city ID
  reason: string | null;               // 'renamed' | 'merged' | 'absorbed' | 'duplicate'
  year_from: number | null;            // e.g. 1995
  year_to: number | null;              // e.g. 2000
  created_at: string;
}

// ============================================================================
// Composite / API response types
// ============================================================================

/** City with full live data — used by `/cities/:id` endpoint. */
export interface CityWithLiveData extends City {
  // Joined from countries
  country: {
    id: number;
    cca2: string;
    name: string;
    flag_emoji: string | null;
    region_id: number;
    subregion_id: number;
  };
  // Joined from administrative_regions (state)
  state: Pick<AdminRegion, 'id' | 'name' | 'code' | 'iso2' | 'type'> | null;
  // Joined from time_zones
  timezone_info: Pick<Timezone, 'id' | 'current_offset' | 'current_abbreviation' | 'is_dst'>;
  // Computed at query time
  live: {
    local_time: string;            // ISO 8601
    formatted: string;            // "Friday, 31 July 2026, 23:32:03.74 EDT"
    abbreviation: string;
    gmt_offset: string;           // "UTC/GMT -4.00 hours"
    is_dst: boolean;
    day: 'today' | 'yesterday' | 'tomorrow';
  };
}
