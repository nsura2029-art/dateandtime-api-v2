/**
 * src/routes/holidays.ts
 *
 * M13: Holidays API (MVP) — 10 endpoints
 *
 *   GET /api/v1/filters                                      — filter catalog
 *   GET /api/v1/countries/{cca2}/filters                     — per-country filter list with counts
 *   GET /api/v1/holidays                                     — main list with filters + date range
 *   GET /api/v1/holidays/{id}                                — single occurrence detail
 *   GET /api/v1/countries/{cca2}/holidays                    — country-scoped shortcut
 *   GET /api/v1/holidays/today?country=US                    — today's holidays
 *   GET /api/v1/holidays/upcoming?country=US&days=30         — next N days
 *   GET /api/v1/long-weekends?country=US&year=2026          — long weekend finder
 *   GET /api/v1/calendars/holidays.ics?country=US&year=2026  — ICS export
 *   POST /api/v1/feedback                                    — submit correction
 *
 * 3 product modes per spec: country | international | combined
 * Per-country filter variance: US = 18, NL = 4 (per spec section 6.4)
 */
import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import type { Env, Variables } from "@/types/env";
import type { D1Database } from "@cloudflare/workers-types";

// =====================================================================
// Schemas
// =====================================================================

const FilterRef = z.object({
  code: z.string().describe("Filter code (e.g. 'PUBLIC_NATIONAL')"),
  label: z.string().describe("English label (e.g. 'Federal/National Holidays')"),
  state: z.enum(["unsupported", "supported_empty", "available", "degraded"]).describe("Per-country applicability"),
  rangeCount: z.number().int().describe("Count in requested date range"),
  annualCount: z.number().int().describe("Count in full year"),
  defaultSelected: z.boolean().describe("Pre-selected in UI by default"),
  displayOrder: z.number().int(),
});

const CountryFilterListResponse = z.object({
  success: z.boolean(),
  data: z.object({
    countryCode: z.string().describe("ISO 3166-1 alpha-2"),
    mode: z.enum(["country", "international", "combined"]),
    year: z.number().int().nullable(),
    from: z.string().nullable(),
    to: z.string().nullable(),
    total: z.number().int().describe("Total filters in this country's applicable list"),
    filters: z.array(FilterRef),
  }),
});

const OccurrenceRef = z.object({
  id: z.number().int(),
  conceptId: z.number().int().describe("Holiday concept ID (e.g., 'Christmas Day' = 1)"),
  conceptName: z.string().describe("Concept name (e.g. 'Christmas Day')"),
  conceptNameLocal: z.string().nullable(),
  countryCode: z.string().describe("ISO 3166-1 alpha-2"),
  countryName: z.string(),
  subdivisionCode: z.string().nullable().describe("ISO 3166-2 or NULL for national"),
  startDate: z.string().describe("ISO 8601 date (actual date)"),
  endDate: z.string().nullable().describe("ISO 8601 date or NULL for single-day"),
  observedDate: z.string().nullable().describe("Observed date (e.g. observed Monday)"),
  dateRole: z.enum(["actual", "observed", "substitute", "in_lieu", "working_day_swap"]),
  legalStatus: z.enum(["public", "de_facto", "optional", "observance", "half_day", "working_day_override", "school", "bank", "authorities"]),
  eventDomain: z.string().nullable(),
  dateStatus: z.enum(["confirmed", "official_announced", "calculated", "tentative", "moon_sighting_pending", "estimated", "canceled"]),
  filters: z.array(z.string()).describe("Filter codes this occurrence belongs to"),
  sources: z.array(z.string()).describe("Source keys that contributed to this occurrence"),
});

const HolidaysListResponse = z.object({
  success: z.boolean(),
  data: z.object({
    countryCode: z.string().nullable(),
    mode: z.enum(["country", "international", "combined"]),
    year: z.number().int().nullable(),
    from: z.string().nullable(),
    to: z.string().nullable(),
    total: z.number().int(),
    count: z.number().int(),
    holidays: z.array(OccurrenceRef),
  }),
});

// =====================================================================
// Routes
// =====================================================================

const app = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// -------------------------------------------------------------------------
// Helpers — batch fetch filters and sources to avoid N+1 queries
// -------------------------------------------------------------------------

/**
 * Batch fetch filters and sources for many occurrences in 2 queries.
 * Returns Map<occurrenceId, {filters: string[], sources: string[]}>.
 *
 * Why: each occurrence can be in many filters and contributed by many sources.
 *      Naive per-row loops do 2N queries for N rows. This does 2 total.
 */
async function attachFiltersAndSources(
  db: D1Database,
  occurrenceIds: number[]
): Promise<Map<number, { filters: string[]; sources: string[] }>> {
  const out = new Map<number, { filters: string[]; sources: string[] }>();
  if (occurrenceIds.length === 0) return out;

  // Initialize empty arrays for each id
  for (const id of occurrenceIds) {
    out.set(id, { filters: [], sources: [] });
  }

  // D1 has a 100-var limit per statement; batch in chunks of 50 ids (50 placeholders)
  const chunkSize = 50;
  for (let i = 0; i < occurrenceIds.length; i += chunkSize) {
    const chunk = occurrenceIds.slice(i, i + chunkSize);
    const placeholders = chunk.map(() => "?").join(",");

    const fRes = await db
      .prepare(
        `SELECT occurrence_id, filter_code FROM holiday_occurrence_filter
         WHERE occurrence_id IN (${placeholders})`
      )
      .bind(...chunk)
      .all<{ occurrence_id: number; filter_code: string }>();
    for (const r of fRes.results || []) {
      const entry = out.get(r.occurrence_id);
      if (entry) entry.filters.push(r.filter_code);
    }

    const sRes = await db
      .prepare(
        `SELECT occurrence_id, source_key FROM holiday_occurrence_source
         WHERE occurrence_id IN (${placeholders})`
      )
      .bind(...chunk)
      .all<{ occurrence_id: number; source_key: string }>();
    for (const r of sRes.results || []) {
      const entry = out.get(r.occurrence_id);
      if (entry) entry.sources.push(r.source_key);
    }
  }

  return out;
}

// -------------------------------------------------------------------------
// GET /api/v1/filters — full filter catalog
// -------------------------------------------------------------------------
app.openapi(createRoute({
  method: "get",
  path: "/api/v1/filters",
  tags: ["Holidays"],
  summary: "List all holiday filter codes (global catalog)",
  description: "Returns the complete holiday filter catalog (36 codes). Does not vary by country — use /countries/{cca2}/filters for per-country applicability.",
  responses: {
    200: { content: { "application/json": { schema: z.object({
      success: z.boolean(),
      data: z.object({
        total: z.number().int(),
        filters: z.array(z.object({
          code: z.string(),
          label: z.string(),
          atomicDimensions: z.object({
            legalStatus: z.string().nullable(),
            scopeLevel: z.string().nullable(),
            observanceRank: z.string().nullable(),
            tradition: z.string().nullable(),
            eventDomain: z.string().nullable(),
            operationalEffect: z.string().nullable(),
          }),
          displayOrder: z.number().int(),
        })),
      }),
    })}}, description: "Filter catalog" },
  },
}), async (c) => {
  const r = await c.env.DB.prepare(
    `SELECT code, label_en, atomic_legal_status, atomic_scope_level, atomic_observance_rank,
            atomic_tradition, atomic_event_domain, atomic_op_effect, display_order
     FROM holiday_filter
     ORDER BY display_order, code`
  ).all();
  const filters = (r.results || []).map((row: any) => ({
    code: row.code,
    label: row.label_en,
    atomicDimensions: {
      legalStatus: row.atomic_legal_status,
      scopeLevel: row.atomic_scope_level,
      observanceRank: row.atomic_observance_rank,
      tradition: row.atomic_tradition,
      eventDomain: row.atomic_event_domain,
      operationalEffect: row.atomic_op_effect,
    },
    displayOrder: row.display_order,
  }));
  return c.json({ success: true, data: { total: filters.length, filters } });
});

// -------------------------------------------------------------------------
// GET /api/v1/countries/{cca2}/filters — per-country filter list with counts
// -------------------------------------------------------------------------
app.openapi(createRoute({
  method: "get",
  path: "/api/v1/countries/{cca2}/filters",
  tags: ["Holidays"],
  summary: "Per-country filter list with live counts (the variance endpoint)",
  description: "Returns the filter list applicable to a country with rangeCount (in requested range) and annualCount (in full year). Filter count varies by country (US=22, NL=7, IN=8, GB=7, NZ=6 in M14).",
  request: {
    params: z.object({ cca2: z.string().length(2) }),
    query: z.object({
      mode: z.enum(["country", "international", "combined"]).default("country"),
      year: z.coerce.number().int().optional(),
      from: z.string().optional(),
      to: z.string().optional(),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: CountryFilterListResponse } }, description: "Per-country filter list" },
    404: { content: { "application/json": { schema: z.object({ success: z.boolean(), error: z.object({ code: z.string(), message: z.string() }) })}}, description: "Country not found" },
  },
}), async (c) => {
  const cca2 = c.req.valid("param").cca2.toUpperCase();
  const q = c.req.valid("query");
  // Get country
  const country = await c.env.DB.prepare(
    "SELECT id, cca2, name FROM countries WHERE cca2 = ? LIMIT 1"
  ).bind(cca2).first<{ id: number; cca2: string; name: string }>();
  if (!country) {
    return c.json({ success: false, error: { code: "COUNTRY_NOT_FOUND", message: `Country ${cca2} not found` } }, 404);
  }

  // Determine date range
  const year = q.year || new Date().getFullYear();
  const from = q.from || `${year}-01-01`;
  const to = q.to || `${year}-12-31`;

  // Get country policy (per-country applicable filters)
  const policyRes = await c.env.DB.prepare(
    `SELECT p.filter_code, p.state, p.default_selected, p.display_order, f.label_en
     FROM country_filter_policy p
     JOIN holiday_filter f ON f.code = p.filter_code
     WHERE p.country_code = ? AND p.state != 'unsupported'
     ORDER BY p.display_order, f.label_en`
  ).bind(cca2).all<{ filter_code: string; state: string; default_selected: number; display_order: number; label_en: string }>();

  // Batch count occurrences for all filters in 2 queries (no N+1)
  // rangeCount: in requested date range
  const rangeCountsRes = await c.env.DB.prepare(
    `SELECT of.filter_code, COUNT(DISTINCT occ.id) as n
     FROM holiday_occurrence occ
     JOIN holiday_occurrence_filter of ON of.occurrence_id = occ.id
     WHERE occ.country_id = ?
       AND occ.start_date <= ? AND COALESCE(occ.end_date, occ.start_date) >= ?
     GROUP BY of.filter_code`
  ).bind(country.id, to, from).all<{ filter_code: string; n: number }>();
  const rangeCounts = new Map((rangeCountsRes.results || []).map((r) => [r.filter_code, r.n]));

  // annualCount: in full year
  const annualCountsRes = await c.env.DB.prepare(
    `SELECT of.filter_code, COUNT(DISTINCT occ.id) as n
     FROM holiday_occurrence occ
     JOIN holiday_occurrence_filter of ON of.occurrence_id = occ.id
     WHERE occ.country_id = ?
       AND substr(occ.start_date, 1, 4) = ?
     GROUP BY of.filter_code`
  ).bind(country.id, String(year)).all<{ filter_code: string; n: number }>();
  const annualCounts = new Map((annualCountsRes.results || []).map((r) => [r.filter_code, r.n]));

  // Build response from policy + counts
  const filters = (policyRes.results || []).map((p: any) => ({
    code: p.filter_code,
    label: p.label_en,
    state: p.state,
    rangeCount: rangeCounts.get(p.filter_code) ?? 0,
    annualCount: annualCounts.get(p.filter_code) ?? 0,
    defaultSelected: p.default_selected === 1,
    displayOrder: p.display_order,
  }));

  return c.json({
    success: true,
    data: {
      countryCode: cca2,
      mode: q.mode,
      year,
      from,
      to,
      total: filters.length,
      filters,
    },
  });
});

// -------------------------------------------------------------------------
// GET /api/v1/holidays — main list
// -------------------------------------------------------------------------
const HolidaysListRoute = createRoute({
  method: "get",
  path: "/api/v1/holidays",
  tags: ["Holidays"],
  summary: "List holidays with filters and date range",
  request: {
    query: z.object({
      country: z.string().length(2).optional().describe("ISO 3166-1 alpha-2"),
      mode: z.enum(["country", "international", "combined"]).default("country"),
      year: z.coerce.number().int().optional(),
      from: z.string().optional(),
      to: z.string().optional(),
      filters: z.string().optional().describe("Comma-separated filter codes"),
      language: z.string().default("en"),
      include_tentative: z.coerce.boolean().default(false),
      limit: z.coerce.number().int().min(1).max(500).default(100),
      offset: z.coerce.number().int().min(0).default(0),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: HolidaysListResponse } }, description: "Holiday list" },
  },
});

app.openapi(HolidaysListRoute, async (c) => {
  const q = c.req.valid("query");
  const year = q.year || new Date().getFullYear();
  const from = q.from || `${year}-01-01`;
  const to = q.to || `${year}-12-31`;
  const filterCodes = q.filters ? q.filters.split(",").map((s) => s.trim()) : null;

  // Build query
  const where: string[] = ["occ.start_date <= ?", "COALESCE(occ.end_date, occ.start_date) >= ?"];
  const params: any[] = [to, from];
  const joins: string[] = ["JOIN holiday_concept c ON c.id = occ.concept_id", "JOIN countries co ON co.id = occ.country_id"];

  if (q.country) {
    const country = await c.env.DB.prepare("SELECT id FROM countries WHERE cca2 = ?").bind(q.country.toUpperCase()).first<{ id: number }>();
    if (!country) {
      return c.json({ success: false, error: { code: "COUNTRY_NOT_FOUND", message: `Country ${q.country} not found` } }, 404);
    }
    where.push("occ.country_id = ?");
    params.push(country.id);
  } else if (q.mode === "international") {
    // Only global observances
    where.push("occ.event_domain IN ('UN', 'worldwide', 'astronomical', 'time_zone')");
  } else if (q.mode === "combined") {
    // Country events + global
    // Already filtered by country if specified; otherwise all
  }

  if (!q.include_tentative) {
    where.push("occ.date_status NOT IN ('tentative', 'canceled', 'moon_sighting_pending')");
  }

  if (filterCodes && filterCodes.length > 0) {
    const filterPlaceholders = filterCodes.map(() => "?").join(",");
    joins.push("JOIN holiday_occurrence_filter of ON of.occurrence_id = occ.id");
    where.push(`of.filter_code IN (${filterPlaceholders})`);
    params.push(...filterCodes);
  }

  // Total count
  const totalRes = await c.env.DB.prepare(
    `SELECT COUNT(DISTINCT occ.id) as n FROM holiday_occurrence occ ${joins.join(" ")} WHERE ${where.join(" AND ")}`
  ).bind(...params).first<{ n: number }>();
  const total = totalRes?.n ?? 0;

  // Page of results
  const rows = await c.env.DB.prepare(
    `SELECT DISTINCT occ.id, occ.concept_id, c.name_en as concept_name, c.name_local as concept_name_local,
            occ.country_id, co.cca2 as country_code, co.name as country_name,
            occ.subdivision_code, occ.start_date, occ.end_date, occ.observed_date,
            occ.date_role, occ.legal_status, occ.event_domain, occ.date_status
     FROM holiday_occurrence occ ${joins.join(" ")}
     WHERE ${where.join(" AND ")}
     ORDER BY occ.start_date
     LIMIT ? OFFSET ?`
  ).bind(...params, q.limit, q.offset).all();

  // Get filters and sources for all occurrences in 2 batch queries (no N+1)
  const ids = (rows.results || []).map((r: any) => r.id);
  const attached = await attachFiltersAndSources(c.env.DB, ids);

  const holidays = (rows.results || []).map((r: any) => {
    const a = attached.get(r.id) || { filters: [], sources: [] };
    return {
      id: r.id,
      conceptId: r.concept_id,
      conceptName: r.concept_name,
      conceptNameLocal: r.concept_name_local,
      countryCode: r.country_code,
      countryName: r.country_name,
      subdivisionCode: r.subdivision_code,
      startDate: r.start_date,
      endDate: r.end_date,
      observedDate: r.observed_date,
      dateRole: r.date_role,
      legalStatus: r.legal_status,
      eventDomain: r.event_domain,
      dateStatus: r.date_status,
      filters: a.filters,
      sources: a.sources,
    };
  });

  return c.json({
    success: true,
    data: {
      countryCode: q.country ? q.country.toUpperCase() : null,
      mode: q.mode,
      year,
      from,
      to,
      total,
      count: holidays.length,
      holidays,
    },
  });
});

// -------------------------------------------------------------------------
// GET /api/v1/holidays/{id} — detail (registered at end after /today and /upcoming)
// -------------------------------------------------------------------------
function buildHolidayDetailRoute() {
  return createRoute({
    method: "get",
    path: "/api/v1/holidays/{id}",
    tags: ["Holidays"],
    summary: "Get single holiday occurrence detail",
    request: {
      params: z.object({ id: z.coerce.number().int() }),
    },
    responses: {
      200: { content: { "application/json": { schema: z.object({ success: z.boolean(), data: OccurrenceRef }) } }, description: "Holiday detail" },
      404: { content: { "application/json": { schema: z.object({ success: z.boolean(), error: z.object({ code: z.string(), message: z.string() }) }) } }, description: "Not found" },
    },
  });
}

const HolidayDetailHandler = async (c: any) => {
  const id = c.req.valid("param").id;
  const r = await c.env.DB.prepare(
    `SELECT occ.*, c.name_en as concept_name, c.name_local as concept_name_local, c.tradition,
            co.cca2 as country_code, co.name as country_name
     FROM holiday_occurrence occ
     JOIN holiday_concept c ON c.id = occ.concept_id
     JOIN countries co ON co.id = occ.country_id
     WHERE occ.id = ? LIMIT 1`
  ).bind(id).first<any>();
  if (!r) {
    return c.json({ success: false, error: { code: "HOLIDAY_NOT_FOUND", message: `Holiday ${id} not found` } }, 404);
  }
  const fRes = await c.env.DB.prepare("SELECT filter_code FROM holiday_occurrence_filter WHERE occurrence_id = ?").bind(id).all<{ filter_code: string }>();
  const sRes = await c.env.DB.prepare("SELECT source_key FROM holiday_occurrence_source WHERE occurrence_id = ?").bind(id).all<{ source_key: string }>();
  return c.json({
    success: true,
    data: {
      id: r.id,
      conceptId: r.concept_id,
      conceptName: r.concept_name,
      conceptNameLocal: r.concept_name_local,
      countryCode: r.country_code,
      countryName: r.country_name,
      subdivisionCode: r.subdivision_code,
      startDate: r.start_date,
      endDate: r.end_date,
      observedDate: r.observed_date,
      dateRole: r.date_role,
      legalStatus: r.legal_status,
      eventDomain: r.event_domain,
      dateStatus: r.date_status,
      filters: (fRes.results || []).map((f) => f.filter_code),
      sources: (sRes.results || []).map((s) => s.source_key),
    },
  });
};

// -------------------------------------------------------------------------
// GET /api/v1/countries/{cca2}/holidays — country shortcut
// -------------------------------------------------------------------------
app.openapi(createRoute({
  method: "get",
  path: "/api/v1/countries/{cca2}/holidays",
  tags: ["Holidays"],
  summary: "List holidays for a country (shortcut)",
  description: "Convenience endpoint — same as /api/v1/holidays?country=XX",
  request: {
    params: z.object({ cca2: z.string().length(2) }),
    query: z.object({
      year: z.coerce.number().int().optional(),
      from: z.string().optional(),
      to: z.string().optional(),
      filters: z.string().optional(),
      limit: z.coerce.number().int().min(1).max(500).default(100),
      offset: z.coerce.number().int().min(0).default(0),
    }),
  },
  responses: { 200: { content: { "application/json": { schema: HolidaysListResponse } }, description: "Country holidays" } },
}), async (c) => {
  // Inline the same query as /api/v1/holidays with country=p.cca2 forced.
  // (Don't recurse via self-fetch — it hits the same route and 404s.)
  const p = c.req.valid("param");
  const q = c.req.valid("query");
  const year = q.year || new Date().getFullYear();
  const from = q.from || `${year}-01-01`;
  const to = q.to || `${year}-12-31`;
  const filterCodes = q.filters ? q.filters.split(",").map((s) => s.trim()) : null;

  const country = await c.env.DB.prepare(
    "SELECT id, cca2, name FROM countries WHERE cca2 = ?"
  ).bind(p.cca2.toUpperCase()).first<{ id: number; cca2: string; name: string }>();
  if (!country) {
    return c.json({ success: false, error: { code: "COUNTRY_NOT_FOUND", message: `Country ${p.cca2} not found` } }, 404);
  }

  const where: string[] = ["occ.start_date <= ?", "COALESCE(occ.end_date, occ.start_date) >= ?", "occ.country_id = ?"];
  const params: any[] = [to, from, country.id];
  const joins: string[] = ["JOIN holiday_concept c ON c.id = occ.concept_id", "JOIN countries co ON co.id = occ.country_id"];

  if (filterCodes && filterCodes.length > 0) {
    const filterPlaceholders = filterCodes.map(() => "?").join(",");
    joins.push("JOIN holiday_occurrence_filter of ON of.occurrence_id = occ.id");
    where.push(`of.filter_code IN (${filterPlaceholders})`);
    params.push(...filterCodes);
  }

  const totalRes = await c.env.DB.prepare(
    `SELECT COUNT(DISTINCT occ.id) as n FROM holiday_occurrence occ ${joins.join(" ")} WHERE ${where.join(" AND ")}`
  ).bind(...params).first<{ n: number }>();
  const total = totalRes?.n ?? 0;

  const rows = await c.env.DB.prepare(
    `SELECT DISTINCT occ.id, occ.concept_id, c.name_en as concept_name, c.name_local as concept_name_local,
            occ.country_id, co.cca2 as country_code, co.name as country_name,
            occ.subdivision_code, occ.start_date, occ.end_date, occ.observed_date,
            occ.date_role, occ.legal_status, occ.event_domain, occ.date_status
     FROM holiday_occurrence occ ${joins.join(" ")}
     WHERE ${where.join(" AND ")}
     ORDER BY occ.start_date
     LIMIT ? OFFSET ?`
  ).bind(...params, q.limit, q.offset).all();

  const ids = (rows.results || []).map((r: any) => r.id);
  const attached = await attachFiltersAndSources(c.env.DB, ids);
  const holidays = (rows.results || []).map((r: any) => {
    const a = attached.get(r.id) || { filters: [], sources: [] };
    return {
      id: r.id,
      conceptId: r.concept_id,
      conceptName: r.concept_name,
      conceptNameLocal: r.concept_name_local,
      countryCode: r.country_code,
      countryName: r.country_name,
      subdivisionCode: r.subdivision_code,
      startDate: r.start_date,
      endDate: r.end_date,
      observedDate: r.observed_date,
      dateRole: r.date_role,
      legalStatus: r.legal_status,
      eventDomain: r.event_domain,
      dateStatus: r.date_status,
      filters: a.filters,
      sources: a.sources,
    };
  });

  return c.json({
    success: true,
    data: {
      countryCode: p.cca2.toUpperCase(),
      mode: "country",
      year,
      from,
      to,
      total,
      count: holidays.length,
      holidays,
    },
  });
});

// -------------------------------------------------------------------------
// GET /api/v1/holidays/today — today's holidays
// -------------------------------------------------------------------------
app.openapi(createRoute({
  method: "get",
  path: "/api/v1/holidays/today",
  tags: ["Holidays"],
  summary: "Today's holidays (widget-friendly)",
  description: "Returns holidays occurring today for a given country, or worldwide if no country specified.",
  request: {
    query: z.object({
      country: z.string().length(2).optional(),
    }),
  },
  responses: { 200: { content: { "application/json": { schema: HolidaysListResponse } }, description: "Today's holidays" } },
}), async (c) => {
  const q = c.req.valid("query");
  const today = new Date().toISOString().split("T")[0];
  let country_id: number | null = null;
  if (q.country) {
    const country = await c.env.DB.prepare("SELECT id FROM countries WHERE cca2 = ?").bind(q.country.toUpperCase()).first<{ id: number }>();
    if (country) country_id = country.id;
  }
  const where = ["occ.start_date = ?"];
  const params: any[] = [today];
  if (country_id !== null) {
    where.push("occ.country_id = ?");
    params.push(country_id);
  }
  const rows = await c.env.DB.prepare(
    `SELECT occ.id, occ.concept_id, c.name_en as concept_name, c.name_local as concept_name_local,
            occ.country_id, co.cca2 as country_code, co.name as country_name,
            occ.subdivision_code, occ.start_date, occ.end_date, occ.observed_date,
            occ.date_role, occ.legal_status, occ.event_domain, occ.date_status
     FROM holiday_occurrence occ
     JOIN holiday_concept c ON c.id = occ.concept_id
     JOIN countries co ON co.id = occ.country_id
     WHERE ${where.join(" AND ")}
     ORDER BY occ.start_date`
  ).bind(...params).all();
  // Get filters and sources in 2 batch queries (no N+1)
  const ids = (rows.results || []).map((r: any) => r.id);
  const attached = await attachFiltersAndSources(c.env.DB, ids);

  const holidays = (rows.results || []).map((r: any) => {
    const a = attached.get(r.id) || { filters: [], sources: [] };
    return {
      id: r.id,
      conceptId: r.concept_id,
      conceptName: r.concept_name,
      conceptNameLocal: r.concept_name_local,
      countryCode: r.country_code,
      countryName: r.country_name,
      subdivisionCode: r.subdivision_code,
      startDate: r.start_date,
      endDate: r.end_date,
      observedDate: r.observed_date,
      dateRole: r.date_role,
      legalStatus: r.legal_status,
      eventDomain: r.event_domain,
      dateStatus: r.date_status,
      filters: a.filters,
      sources: a.sources,
    };
  });
  return c.json({
    success: true,
    data: {
      countryCode: q.country ? q.country.toUpperCase() : null,
      mode: "country",
      year: new Date().getFullYear(),
      from: today,
      to: today,
      total: holidays.length,
      count: holidays.length,
      holidays,
    },
  });
});

// -------------------------------------------------------------------------
// GET /api/v1/holidays/upcoming — next N days
// -------------------------------------------------------------------------
app.openapi(createRoute({
  method: "get",
  path: "/api/v1/holidays/upcoming",
  tags: ["Holidays"],
  summary: "Upcoming holidays (widget-friendly)",
  request: {
    query: z.object({
      country: z.string().length(2).optional(),
      days: z.coerce.number().int().min(1).max(365).default(30),
    }),
  },
  responses: { 200: { content: { "application/json": { schema: HolidaysListResponse } }, description: "Upcoming holidays" } },
}), async (c) => {
  const q = c.req.valid("query");
  const today = new Date();
  const to = new Date(today.getTime() + q.days * 24 * 60 * 60 * 1000);
  const fromStr = today.toISOString().split("T")[0];
  const toStr = to.toISOString().split("T")[0];
  let country_id: number | null = null;
  if (q.country) {
    const country = await c.env.DB.prepare("SELECT id FROM countries WHERE cca2 = ?").bind(q.country.toUpperCase()).first<{ id: number }>();
    if (country) country_id = country.id;
  }
  const where = ["occ.start_date >= ?", "occ.start_date <= ?"];
  const params: any[] = [fromStr, toStr];
  if (country_id !== null) {
    where.push("occ.country_id = ?");
    params.push(country_id);
  }
  const rows = await c.env.DB.prepare(
    `SELECT occ.id, occ.concept_id, c.name_en as concept_name, c.name_local as concept_name_local,
            occ.country_id, co.cca2 as country_code, co.name as country_name,
            occ.subdivision_code, occ.start_date, occ.end_date, occ.observed_date,
            occ.date_role, occ.legal_status, occ.event_domain, occ.date_status
     FROM holiday_occurrence occ
     JOIN holiday_concept c ON c.id = occ.concept_id
     JOIN countries co ON co.id = occ.country_id
     WHERE ${where.join(" AND ")}
     ORDER BY occ.start_date`
  ).bind(...params).all();
  // Get filters and sources in 2 batch queries (no N+1)
  const ids = (rows.results || []).map((r: any) => r.id);
  const attached = await attachFiltersAndSources(c.env.DB, ids);

  const holidays = (rows.results || []).map((r: any) => {
    const a = attached.get(r.id) || { filters: [], sources: [] };
    return {
      id: r.id,
      conceptId: r.concept_id,
      conceptName: r.concept_name,
      conceptNameLocal: r.concept_name_local,
      countryCode: r.country_code,
      countryName: r.country_name,
      subdivisionCode: r.subdivision_code,
      startDate: r.start_date,
      endDate: r.end_date,
      observedDate: r.observed_date,
      dateRole: r.date_role,
      legalStatus: r.legal_status,
      eventDomain: r.event_domain,
      dateStatus: r.date_status,
      filters: a.filters,
      sources: a.sources,
    };
  });
  return c.json({
    success: true,
    data: {
      countryCode: q.country ? q.country.toUpperCase() : null,
      mode: "country",
      year: today.getFullYear(),
      from: fromStr,
      to: toStr,
      total: holidays.length,
      count: holidays.length,
      holidays,
    },
  });
});

// -------------------------------------------------------------------------
// GET /api/v1/holidays/{id} — detail (registered AFTER /today and /upcoming)
// -------------------------------------------------------------------------
app.openapi(buildHolidayDetailRoute(), HolidayDetailHandler);

// -------------------------------------------------------------------------
// GET /api/v1/long-weekends — long-weekend finder (SEO gold)
// -------------------------------------------------------------------------
app.openapi(createRoute({
  method: "get",
  path: "/api/v1/long-weekends",
  tags: ["Holidays"],
  summary: "Long weekends in a country for a year (SEO-friendly)",
  description: "Returns 3-day, 4-day, 5-day long weekends created by public holidays. Each entry has start, end, days, and reason.",
  request: {
    query: z.object({
      country: z.string().length(2).describe("ISO 3166-1 alpha-2 country code"),
      year: z.coerce.number().int().optional(),
    }),
  },
  responses: { 200: { content: { "application/json": { schema: z.object({
    success: z.boolean(),
    data: z.object({
      countryCode: z.string(),
      year: z.number().int(),
      count: z.number().int(),
      longWeekends: z.array(z.object({
        start: z.string(),
        end: z.string(),
        days: z.number().int(),
        type: z.string().describe("3-day | 4-day | 5-day"),
        reason: z.string().describe("Why this is a long weekend (which holiday creates the bridge)"),
        holidayName: z.string(),
      })),
    }),
  })}}, description: "Long weekends" } },
}), async (c) => {
  const q = c.req.valid("query");
  const year = q.year || new Date().getFullYear();
  const country = await c.env.DB.prepare("SELECT id FROM countries WHERE cca2 = ?").bind(q.country.toUpperCase()).first<{ id: number }>();
  if (!country) {
    return c.json({ success: false, error: { code: "COUNTRY_NOT_FOUND", message: `Country ${q.country} not found` } }, 404);
  }
  // Get public holidays for the year
  // Dedup by (start_date, name) — multiple sources may contribute the same holiday
  // (e.g. Nager.Date and computed_federal_us both list Independence Day)
  const rows = await c.env.DB.prepare(
    `SELECT occ.start_date, c.name_en as name
     FROM holiday_occurrence occ
     JOIN holiday_occurrence_filter f ON f.occurrence_id = occ.id
     JOIN holiday_concept c ON c.id = occ.concept_id
     WHERE occ.country_id = ? AND f.filter_code IN ('PUBLIC_NATIONAL', 'PUBLIC_LOCAL')
       AND substr(occ.start_date, 1, 4) = ?
     GROUP BY occ.start_date, c.name_en
     ORDER BY occ.start_date`
  ).bind(country.id, String(year)).all<{ start_date: string; name: string }>();

  // Collect set of holiday dates for bridge detection (Tue/Thu)
  const holidayDates = new Set((rows.results || []).map((r) => r.start_date));

  // Find long weekends (deduped by start date)
  const longWeekendMap = new Map<string, { start: string; end: string; days: number; type: string; reason: string; holidayName: string }>();

  for (const h of (rows.results || [])) {
    const d = new Date(h.start_date + "T12:00:00Z");
    const dow = d.getUTCDay(); // 0=Sun, 6=Sat
    let start: Date, end: Date, days: number, type: string, reason: string;

    if (dow === 1) {
      // Monday holiday: Sun-Mon-Tue = 3-day weekend
      start = new Date(d.getTime() - 24 * 60 * 60 * 1000);
      end = new Date(d.getTime() + 24 * 60 * 60 * 1000);
      days = 3;
      type = "3-day";
      reason = `${h.name} (Mon) + weekend`;
    } else if (dow === 5) {
      // Friday holiday: Fri-Sat-Sun = 3-day weekend
      start = new Date(d.getTime());
      end = new Date(d.getTime() + 2 * 24 * 60 * 60 * 1000);
      days = 3;
      type = "3-day";
      reason = `${h.name} (Fri) + weekend`;
    } else if (dow === 6) {
      // Saturday holiday (rare): Fri-Sat-Sun = 3-day if Fri also off
      const fri = new Date(d.getTime() - 24 * 60 * 60 * 1000).toISOString().split("T")[0];
      if (holidayDates.has(fri)) {
        // 4-day weekend: Fri-Sat-Sun-Mon
        start = new Date(d.getTime() - 24 * 60 * 60 * 1000);
        end = new Date(d.getTime() + 2 * 24 * 60 * 60 * 1000);
        days = 4;
        type = "4-day";
        reason = `${h.name} (Sat) + adjacent holiday Fri`;
      } else {
        continue; // Sat alone, no long weekend
      }
    } else if (dow === 2) {
      // Tuesday: only a long weekend if Monday is also a holiday
      const mon = new Date(d.getTime() - 24 * 60 * 60 * 1000).toISOString().split("T")[0];
      if (holidayDates.has(mon)) {
        // 4-day: Sat-Sun-Mon-Tue
        start = new Date(d.getTime() - 3 * 24 * 60 * 60 * 1000);
        end = new Date(d.getTime());
        days = 4;
        type = "4-day";
        reason = `${h.name} (Tue) + bridge from Mon`;
      } else {
        continue;
      }
    } else if (dow === 4) {
      // Thursday: only a long weekend if Friday is also a holiday
      const fri = new Date(d.getTime() + 24 * 60 * 60 * 1000).toISOString().split("T")[0];
      if (holidayDates.has(fri)) {
        // 4-day: Thu-Fri-Sat-Sun
        start = new Date(d.getTime());
        end = new Date(d.getTime() + 3 * 24 * 60 * 60 * 1000);
        days = 4;
        type = "4-day";
        reason = `${h.name} (Thu) + bridge to Fri`;
      } else {
        continue;
      }
    } else {
      // Wed, Sun — no long weekend
      continue;
    }

    const startStr = start.toISOString().split("T")[0];
    const endStr = end.toISOString().split("T")[0];

    // Dedup by start date — if multiple holidays create the same long-weekend
    // (e.g. Mon+Wed both off, both create 3-day with Sun-Mon-Tue), keep the first
    const existing = longWeekendMap.get(startStr);
    if (!existing || days > existing.days) {
      longWeekendMap.set(startStr, { start: startStr, end: endStr, days, type, reason, holidayName: h.name });
    }
  }

  // Sort by start date
  const longWeekends = Array.from(longWeekendMap.values()).sort((a, b) => a.start.localeCompare(b.start));
  return c.json({
    success: true,
    data: {
      countryCode: q.country.toUpperCase(),
      year,
      count: longWeekends.length,
      longWeekends,
    },
  });
});

// -------------------------------------------------------------------------
// GET /api/v1/calendars/holidays.ics — ICS export
// -------------------------------------------------------------------------
app.openapi(createRoute({
  method: "get",
  path: "/api/v1/calendars/holidays.ics",
  tags: ["Holidays"],
  summary: "ICS calendar export",
  description: "Returns an RFC 5545-compliant ICS calendar file. Subscribe in Apple Calendar, Google Calendar, Outlook.",
  request: {
    query: z.object({
      country: z.string().length(2),
      year: z.coerce.number().int().optional(),
    }),
  },
  responses: { 200: { content: { "text/calendar": { schema: z.string() } }, description: "ICS calendar" } },
}), async (c) => {
  const q = c.req.valid("query");
  const year = q.year || new Date().getFullYear();
  const country = await c.env.DB.prepare("SELECT id, cca2, name FROM countries WHERE cca2 = ?").bind(q.country.toUpperCase()).first<{ id: number; cca2: string; name: string }>();
  if (!country) {
    return c.json({ success: false, error: { code: "COUNTRY_NOT_FOUND", message: `Country ${q.country} not found` } }, 404);
  }
  const rows = await c.env.DB.prepare(
    `SELECT DISTINCT occ.id, occ.start_date, occ.end_date, c.name_en as name
     FROM holiday_occurrence occ
     JOIN holiday_occurrence_filter f ON f.occurrence_id = occ.id
     JOIN holiday_concept c ON c.id = occ.concept_id
     WHERE occ.country_id = ? AND f.filter_code = 'PUBLIC_NATIONAL'
       AND substr(occ.start_date, 1, 4) = ?
     ORDER BY occ.start_date`
  ).bind(country.id, String(year)).all<{ id: number; start_date: string; end_date: string | null; name: string }>();
  // Build ICS
  const lines: string[] = [
    "BEGIN:VCALENDAR",
    "VERSION:2.0",
    "PRODID:-//dateandtime-api-v2//holidays//EN",
    `X-WR-CALNAME:${country.name} Public Holidays ${year}`,
    "CALSCALE:GREGORIAN",
  ];
  for (const h of (rows.results || [])) {
    const dt = h.start_date.replace(/-/g, "");
    // DTEND is exclusive in ICS for all-day events, so add 1 day
    const endDate = h.end_date || h.start_date;
    const endDt = new Date(new Date(endDate + "T12:00:00Z").getTime() + 24 * 60 * 60 * 1000).toISOString().split("T")[0].replace(/-/g, "");
    lines.push("BEGIN:VEVENT");
    lines.push(`UID:holiday-${country.cca2}-${h.id}@dateandtime.live`);
    lines.push(`DTSTART;VALUE=DATE:${dt}`);
    lines.push(`DTEND;VALUE=DATE:${endDt}`);
    lines.push(`SUMMARY:${h.name}`);
    lines.push("END:VEVENT");
  }
  lines.push("END:VCALENDAR");
  const ics = lines.join("\r\n");
  return c.body(ics, 200, {
    "Content-Type": "text/calendar; charset=utf-8",
    "Content-Disposition": `attachment; filename="${country.cca2}-holidays-${year}.ics"`,
  });
});

// -------------------------------------------------------------------------
// POST /api/v1/feedback — submit correction
// -------------------------------------------------------------------------
app.openapi(createRoute({
  method: "post",
  path: "/api/v1/feedback",
  tags: ["Holidays"],
  summary: "Submit a correction or report about a holiday",
  description: "Allows users to report wrong dates, missing holidays, scope issues, etc. SLA: P0 4h, P1 1 business day, P2 3 days, P3 10 days.",
  request: {
    body: {
      content: { "application/json": { schema: z.object({
        occurrenceId: z.number().int().optional(),
        reportType: z.enum(["wrong_date", "wrong_name", "missing_holiday", "wrong_scope", "other"]),
        severity: z.enum(["P0", "P1", "P2", "P3"]).default("P2"),
        description: z.string().min(1).max(2000),
        reporterEmail: z.string().email().optional(),
        evidenceUrl: z.string().url().optional(),
      })}},
    },
  },
  responses: {
    201: { content: { "application/json": { schema: z.object({
      success: z.boolean(),
      data: z.object({
        id: z.number().int(),
        status: z.string(),
        createdAt: z.number().int(),
      }),
    })}}, description: "Feedback submitted" },
    400: { content: { "application/json": { schema: z.object({ success: z.boolean(), error: z.object({ code: z.string(), message: z.string() }) })}}, description: "Invalid input" },
  },
}), async (c) => {
  const body = c.req.valid("json");
  if (!body.description || body.description.trim().length === 0) {
    return c.json({ success: false, error: { code: "INVALID_INPUT", message: "description is required" } }, 400);
  }
  const now_ms = Date.now();
  // Simple hash for rate limiting
  const reporterHash = body.reporterEmail ? body.reporterEmail.split("@")[0].slice(0, 20) : "anon";
  const r = await c.env.DB.prepare(
    `INSERT INTO holiday_feedback
     (occurrence_id, report_type, severity, status, description, reporter_email, reporter_hash, evidence_url, created_at, updated_at)
     VALUES (?, ?, ?, 'open', ?, ?, ?, ?, ?, ?) RETURNING id`
  ).bind(
    body.occurrenceId || null,
    body.reportType,
    body.severity,
    body.description,
    body.reporterEmail || null,
    reporterHash,
    body.evidenceUrl || null,
    now_ms,
    now_ms
  ).first<{ id: number }>();
  return c.json({
    success: true,
    data: { id: r.id, status: "open", createdAt: now_ms },
  }, 201);
});

export default app;
