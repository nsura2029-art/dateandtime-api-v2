/**
 * D1 row types — hand-written, match the schema in `migrations/`.
 *
 * All optional fields use `?` to match SQLite's nullable behavior.
 * Date fields are ISO strings (YYYY-MM-DD) unless noted.
 */

// ============================================================================
// Core geo tables
// ============================================================================

export interface City {
  geoname_id: number;
  name: string;
  ascii_name: string;
  country_code: string;
  country_name: string;
  admin1_code: string | null;
  admin2_code: string | null;
  admin3_code: string | null;
  admin4_code: string | null;
  latitude: number;
  longitude: number;
  timezone: string;
  population: number | null;
  elevation: number | null;
  feature_code: string;
  is_capital: number; // 0 | 1
  // Optional fields added in later migrations
  state?: string | null;
  state_code?: string | null;
  state_native?: string | null;
  state_iso3166_2?: string | null;
  state_type?: string | null;
  state_dr5hn_id?: number | null;
  slug?: string | null;
}

export interface Country {
  cca2: string;
  cca3: string | null;
  ccn3: string | null;
  cioc: string | null;
  name: string;
  ascii_name: string | null;
  official_name: string | null;
  capital: string | null;
  continent: string | null;
  un_region: string | null;
  un_subregion: string | null;
  languages: string | null; // JSON
  currencies: string | null; // JSON
  phone_code: string | null;
  latitude: number | null;
  longitude: number | null;
  area_km2: number | null;
  population: number | null;
  un_member: number | null;
  landlocked: number | null;
  independent: number | null;
  start_of_week: string | null;
  canonical_timezones: string | null; // JSON array of IANA names
  borders: string | null; // JSON array of cca2
}

export interface Timezone {
  id: string; // IANA name (e.g. "America/New_York")
  region: string | null;
  subregion: string | null;
  city: string | null;
  country_codes: string | null; // JSON array
  countries: string | null; // JSON array
  latitude: number | null;
  longitude: number | null;
  current_offset: number | null; // minutes from UTC
  current_abbreviation: string | null;
  is_dst: number | null;
}

// ============================================================================
// Content tables (added in Phases 2, 4, 6, 7)
// ============================================================================

export interface Holiday {
  id: number;
  country_code: string;
  year: number;
  date: string; // YYYY-MM-DD
  name: string;
  local_name: string | null;
  type: string | null; // public | bank | school | optional | observance
  global: number; // 0 | 1
  launch_year: number | null;
  end_year: number | null;
  source: string | null; // nager_date | manual | religion_holidays
  country_name: string | null;
}

export interface BusinessCalendar {
  id: number;
  country_code: string;
  name: string;
  work_start: string; // HH:MM
  work_end: string; // HH:MM
  work_days: string; // JSON array of weekday numbers (1=Mon, 7=Sun)
  lunch_start: string | null;
  lunch_end: string | null;
  is_default: number;
  source: string | null;
}

export interface OnThisDay {
  id: number;
  month: number;
  day: number;
  year: number | null;
  end_year: number | null;
  category: string; // event | birth | death | holiday | observance
  subcategory: string | null;
  country_codes: string | null; // JSON array
  religion: string | null;
  title: string;
  description: string | null;
  long_description: string | null;
  importance: number; // 1-5
  wikipedia_url: string | null;
  source_url: string | null;
  external_id: string | null;
  image_url: string | null;
  image_alt: string | null;
  image_status: string; // missing | found | cached
  faq_questions: string | null; // JSON
  key_facts: string | null; // JSON
  people_mentioned: string | null; // JSON
  city_id: number | null;
  city_name: string | null;
  country_name: string | null;
}

export interface CityAlias {
  id: number;
  city_id: number;
  alias: string;
  type: string; // common | abbreviation | translation | historical
  locale: string | null;
}

export interface PlaceRedirect {
  id: number;
  city_id: number;
  old_name: string;
  year_from: number;
  year_to: number;
  reason: string | null;
  source: string | null;
  confidence: number;
}

// ============================================================================
// Climate (Phase 4)
// ============================================================================

export interface ClimateSummary {
  id: number;
  city_id: number;
  month: number; // 1-12
  avg_high_c: number | null;
  avg_low_c: number | null;
  avg_precipitation_mm: number | null;
  avg_precipitation_days: number | null;
  climate_zone: string; // tropical | temperate | continental | polar
  source: string; // model_v1
}

// ============================================================================
// DST (Phase 4)
// ============================================================================

export interface DstTransition {
  id: number;
  timezone_id: string;
  year: number;
  transition_date: string; // YYYY-MM-DD
  transition_type: string; // spring_forward | fall_back | none
  offset_before: number;
  offset_after: number;
  source: string; // zoneinfo
}

// ============================================================================
// Governance (Phase 7)
// ============================================================================

export interface DataSource {
  id: number;
  name: string;
  url: string | null;
  license: string | null;
  last_imported_at: string | null;
  row_count: number | null;
  notes: string | null;
}

export interface ImportHistory {
  id: number;
  source_id: number;
  started_at: string;
  completed_at: string | null;
  status: string; // running | success | failed
  rows_imported: number | null;
  notes: string | null;
}

export interface DataQualityCheck {
  id: number;
  name: string;
  query: string;
  description: string | null;
  category: string; // integrity | freshness | completeness
  severity: string; // info | warn | error
  enabled: number;
  last_run_at: string | null;
  last_status: string | null; // pass | fail | warn
}

// ============================================================================
// Feedback (Phase 7)
// ============================================================================

export interface Feedback {
  id: number;
  type: string; // bug | feature | question | praise
  title: string;
  body: string;
  author: string | null;
  email: string | null;
  country_code: string | null;
  page_url: string | null;
  status: string; // open | triaged | in_progress | closed
  votes: number;
  created_at: number; // unix timestamp
  updated_at: number;
}
