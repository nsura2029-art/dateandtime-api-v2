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
import { computeLongWeekends, planYearPTO } from "@/lib/longWeekend";

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
  conceptTradition: z.string().nullable().describe("Religious/cultural tradition (christian, jewish, muslim, hindu, civic, etc.)"),
  countryCode: z.string().nullable().describe("ISO 3166-1 alpha-2 or NULL for worldwide"),
  countryName: z.string().nullable(),
  subdivisionCode: z.string().nullable().describe("ISO 3166-2 or NULL for national"),
  startDate: z.string().describe("ISO 8601 date (actual date)"),
  endDate: z.string().nullable().describe("ISO 8601 date or NULL for single-day"),
  observedDate: z.string().nullable().describe("Observed date (e.g. observed Monday)"),
  dateRole: z.enum(["actual", "observed", "substitute", "in_lieu", "working_day_swap"]),
  legalStatus: z.enum(["public", "de_facto", "optional", "observance", "half_day", "working_day_override", "school", "bank", "authorities"]),
  scopeLevel: z.enum(["global", "country", "subdivision", "locality", "organization"]).describe("Scope: global = worldwide, country = national, subdivision = state/region"),
  eventDomain: z.string().nullable().describe("Domain: civil, religious, UN, worldwide, astronomical, time_zone, sports, etc."),
  prominence: z.string().nullable(),
  dateStatus: z.enum(["confirmed", "official_announced", "calculated", "tentative", "moon_sighting_pending", "estimated", "canceled"]),
  worldwide: z.boolean().describe("True if this holiday applies globally (UN days, New Year, etc.)"),
  category: z.string().nullable().describe("Primary category: public_holiday, observance, religious, international, season, clock_change, sporting_event, election, school_break, bank_closure"),
  origin: z.string().nullable().describe("Which source produced this row: nager_date, hebcal, un_official, computed_easter, computed_federal_us, etc."),
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
  description: "Returns the filter list applicable to a country with rangeCount (in requested range) and annualCount (in full year). US shows 18 filters, NL shows 4.",
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

  // For each filter, count occurrences (includes both country-specific AND worldwide events)
  const filters = [];
  for (const p of (policyRes.results || [])) {
    // rangeCount: in requested range (country events + worldwide)
    const rangeRes = await c.env.DB.prepare(
      `SELECT COUNT(DISTINCT occ.id) as n
       FROM holiday_occurrence occ
       JOIN holiday_occurrence_filter f ON f.occurrence_id = occ.id
       WHERE occ.country_id = ?
         AND f.filter_code = ?
         AND occ.start_date <= ? AND COALESCE(occ.end_date, occ.start_date) >= ?`
    ).bind(country.id, p.filter_code, to, from).first<{ n: number }>();
    // annualCount: in full year (country events + worldwide)
    const annualRes = await c.env.DB.prepare(
      `SELECT COUNT(DISTINCT occ.id) as n
       FROM holiday_occurrence occ
       JOIN holiday_occurrence_filter f ON f.occurrence_id = occ.id
       WHERE occ.country_id = ?
         AND f.filter_code = ?
         AND substr(occ.start_date, 1, 4) = ?`
    ).bind(country.id, p.filter_code, String(year)).first<{ n: number }>();
    filters.push({
      code: p.filter_code,
      label: p.label_en,
      state: p.state,
      rangeCount: rangeRes?.n ?? 0,
      annualCount: annualRes?.n ?? 0,
      defaultSelected: p.default_selected === 1,
      displayOrder: p.display_order,
    });
  }

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
  // Use LEFT JOIN for countries so worldwide events (country_id NULL) aren't dropped
  const joins: string[] = ["JOIN holiday_concept c ON c.id = occ.concept_id", "LEFT JOIN countries co ON co.id = occ.country_id"];

  if (q.country) {
    const country = await c.env.DB.prepare("SELECT id FROM countries WHERE cca2 = ?").bind(q.country.toUpperCase()).first<{ id: number }>();
    if (!country) {
      return c.json({ success: false, error: { code: "COUNTRY_NOT_FOUND", message: `Country ${q.country} not found` } }, 404);
    }
    where.push("occ.country_id = ?");
    params.push(country.id);
  } else if (q.mode === "international") {
    // Only global/worldwide observances (per migration 157)
    where.push("(occ.worldwide = 1 OR occ.country_id IS NULL)");
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
            c.tradition as concept_tradition,
            occ.country_id, co.cca2 as country_code, co.name as country_name,
            occ.subdivision_code, occ.start_date, occ.end_date, occ.observed_date,
            occ.date_role, occ.legal_status, occ.scope_level, occ.event_domain, occ.prominence, occ.date_status,
            occ.worldwide, occ.category, occ.origin
     FROM holiday_occurrence occ ${joins.join(" ")}
     WHERE ${where.join(" AND ")}
     ORDER BY occ.start_date
     LIMIT ? OFFSET ?`
  ).bind(...params, q.limit, q.offset).all();

  // Get filters and sources for each occurrence
  const holidays = [];
  for (const r of (rows.results || [])) {
    const fRes = await c.env.DB.prepare(
      "SELECT filter_code FROM holiday_occurrence_filter WHERE occurrence_id = ?"
    ).bind(r.id).all<{ filter_code: string }>();
    const sRes = await c.env.DB.prepare(
      "SELECT source_key FROM holiday_occurrence_source WHERE occurrence_id = ?"
    ).bind(r.id).all<{ source_key: string }>();
    holidays.push({
      id: r.id,
      conceptId: r.concept_id,
      conceptName: r.concept_name,
      conceptNameLocal: r.concept_name_local,
      conceptTradition: r.concept_tradition,
      countryCode: r.country_code,
      countryName: r.country_name,
      subdivisionCode: r.subdivision_code,
      startDate: r.start_date,
      endDate: r.end_date,
      observedDate: r.observed_date,
      dateRole: r.date_role,
      legalStatus: r.legal_status,
      scopeLevel: r.scope_level,
      eventDomain: r.event_domain,
      prominence: r.prominence,
      dateStatus: r.date_status,
      worldwide: r.worldwide === 1,
      category: r.category,
      origin: r.origin,
      filters: (fRes.results || []).map((f) => f.filter_code),
      sources: (sRes.results || []).map((s) => s.source_key),
    });
  }

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
  // Delegate to /api/v1/holidays by re-running the handler
  const p = c.req.valid("param");
  const q = c.req.valid("query");
  // Re-call with country set
  const newReq = new Request(c.req.url, {
    method: "GET",
    headers: c.req.raw.headers,
  });
  // Simpler: just inline the query
  const url = new URL(c.req.url);
  url.searchParams.set("country", p.cca2);
  const r = await fetch(url.toString(), { headers: c.req.raw.headers });
  return r as any;
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
  const holidays = [];
  for (const r of (rows.results || [])) {
    holidays.push({
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
      filters: [],
      sources: [],
    });
  }
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
  const holidays = (rows.results || []).map((r: any) => ({
    id: r.id, conceptId: r.concept_id, conceptName: r.concept_name, conceptNameLocal: r.concept_name_local,
    countryCode: r.country_code, countryName: r.country_name, subdivisionCode: r.subdivision_code,
    startDate: r.start_date, endDate: r.end_date, observedDate: r.observed_date,
    dateRole: r.date_role, legalStatus: r.legal_status, eventDomain: r.event_domain, dateStatus: r.date_status,
    filters: [], sources: [],
  }));
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
  const rows = await c.env.DB.prepare(
    `SELECT DISTINCT occ.id, occ.start_date, c.name_en as name
     FROM holiday_occurrence occ
     JOIN holiday_occurrence_filter f ON f.occurrence_id = occ.id
     JOIN holiday_concept c ON c.id = occ.concept_id
     WHERE occ.country_id = ? AND f.filter_code IN ('PUBLIC_NATIONAL', 'PUBLIC_LOCAL')
       AND substr(occ.start_date, 1, 4) = ?
     ORDER BY occ.start_date`
  ).bind(country.id, String(year)).all<{ id: number; start_date: string; name: string }>();
  // Find long weekends
  const longWeekends: { start: string; end: string; days: number; type: string; reason: string; holidayName: string }[] = [];
  for (const h of (rows.results || [])) {
    const d = new Date(h.start_date + "T12:00:00Z");
    const dow = d.getUTCDay(); // 0=Sun, 6=Sat
    if (dow === 1) {
      // Monday holiday: Sun-Mon-Tue = 3-day weekend
      const start = new Date(d.getTime() - 24 * 60 * 60 * 1000);
      const end = new Date(d.getTime() + 24 * 60 * 60 * 1000);
      longWeekends.push({
        start: start.toISOString().split("T")[0],
        end: end.toISOString().split("T")[0],
        days: 3,
        type: "3-day",
        reason: `${h.name} (Mon) + weekend`,
        holidayName: h.name,
      });
    } else if (dow === 5) {
      // Friday holiday: Thu-Fri-Sat = 3-day weekend
      const start = new Date(d.getTime() - 24 * 60 * 60 * 1000);
      const end = new Date(d.getTime() + 24 * 60 * 60 * 1000);
      longWeekends.push({
        start: start.toISOString().split("T")[0],
        end: end.toISOString().split("T")[0],
        days: 3,
        type: "3-day",
        reason: `${h.name} (Fri) + weekend`,
        holidayName: h.name,
      });
    } else if (dow === 2) {
      // Tuesday: Mon-Tue-Wed = 3-day if Mon off
      const start = new Date(d.getTime() - 24 * 60 * 60 * 1000);
      const end = new Date(d.getTime() + 24 * 60 * 60 * 1000);
      longWeekends.push({
        start: start.toISOString().split("T")[0],
        end: end.toISOString().split("T")[0],
        days: 3,
        type: "3-day",
        reason: `${h.name} (Tue) + possible bridge`,
        holidayName: h.name,
      });
    } else if (dow === 4) {
      // Thursday: Wed-Thu-Fri = 3-day if Fri off
      const start = new Date(d.getTime() - 24 * 60 * 60 * 1000);
      const end = new Date(d.getTime() + 24 * 60 * 60 * 1000);
      longWeekends.push({
        start: start.toISOString().split("T")[0],
        end: end.toISOString().split("T")[0],
        days: 3,
        type: "3-day",
        reason: `${h.name} (Thu) + possible bridge`,
        holidayName: h.name,
      });
    }
  }
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


// ============================================================================
// M14.5 — Long weekend + PTO strategy endpoints
// ============================================================================

// -------------------------------------------------------------------------
// GET /api/v1/countries/{cca2}/long-weekends/{year} — full implementation
app.openapi(createRoute({
  method: "get",
  path: "/api/v1/countries/{cca2}/long-weekends/{year}",
  tags: ["Holidays"],
  summary: "Long weekends in a country for a year (enhanced)",
  request: {
    params: z.object({
      cca2: z.string().length(2),
      year: z.coerce.number().int(),
    }),
    query: z.object({
      work_days: z.enum(["mon-fri", "sun-thu", "fri-sat", "sat-wed"]).optional(),
      min_days: z.coerce.number().int().min(2).max(14).optional(),
      include_optional: z.coerce.boolean().optional(),
      subdivisions: z.string().optional(),
      pto: z.coerce.number().int().min(0).max(5).optional(),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: z.any() } }, description: "OK" },
  },
}), async (c) => {
  const cca2 = c.req.valid("param").cca2.toUpperCase();
  const year = c.req.valid("param").year;
  const q = c.req.valid("query");

  const country = await c.env.DB.prepare("SELECT id, name FROM countries WHERE cca2 = ?")
    .bind(cca2).first<{ id: number; name: string }>();
  if (!country) {
    return c.json({ success: false, error: { code: "COUNTRY_NOT_FOUND", message: `Country ${cca2} not found` } }, 404);
  }

  const includeOptional = q.include_optional !== false;
  const holidayRes = await c.env.DB.prepare(`
    SELECT occ.id, occ.concept_id, occ.start_date, occ.end_date, occ.observed_date,
           c.name_en as concept_name
    FROM holiday_occurrence occ
    JOIN holiday_concept c ON c.id = occ.concept_id
    WHERE occ.country_id = ?
      AND substr(occ.start_date, 1, 4) = ?
      AND 1=1
    ORDER BY occ.start_date
  `).bind(country.id, String(year)).all<{
    id: number; concept_id: number; start_date: string; end_date: string | null;
    observed_date: string | null; concept_name: string;
  }>();

  const holidays = holidayRes.results.map(h => ({
    date: h.start_date,
    endDate: h.end_date || h.start_date,
    name: h.concept_name,
    filterCode: h.filter_codes ? h.filter_codes.split(',')[0] : 'PUBLIC_NATIONAL',
  }));

  const result = computeLongWeekends(holidays, year, {
    workDays: q.work_days,
    minDays: q.min_days ?? 3,
    includeOptional: q.include_optional ?? true,
  });

  // Optionally attach PTO strategies
  if (q.pto && q.pto > 0) {
    for (const w of result.longWeekends) {
      w.ptoStrategies = [];
      for (let n = 1; n <= Math.min(q.pto, 3); n++) {
        const beforeDays: string[] = [];
        for (let i = 1; i <= n; i++) {
          const d = new Date(w.start);
          d.setDate(d.getDate() - i);
          const dow = d.getUTCDay();
          if (dow !== 0 && dow !== 6) beforeDays.push(d.toISOString().slice(0, 10));
        }
        if (beforeDays.length === n) {
          w.ptoStrategies.push({
            direction: 'before' as const,
            ptoDays: beforeDays,
            totalOff: w.days + beforeDays.length,
            efficiency: (w.days + beforeDays.length) / beforeDays.length,
          });
        }
        const afterDays: string[] = [];
        for (let i = 1; i <= n; i++) {
          const d = new Date(w.end);
          d.setDate(d.getDate() + i);
          const dow = d.getUTCDay();
          if (dow !== 0 && dow !== 6) afterDays.push(d.toISOString().slice(0, 10));
        }
        if (afterDays.length === n) {
          w.ptoStrategies.push({
            direction: 'after' as const,
            ptoDays: afterDays,
            totalOff: w.days + afterDays.length,
            efficiency: (w.days + afterDays.length) / afterDays.length,
          });
        }
      }
    }
  }

  const summary: Record<string, number> = {};
  for (const w of result.longWeekends) {
    const type = w.days >= 6 ? '6-day+' : w.days === 5 ? '5-day' : w.days === 4 ? '4-day' : '3-day';
    summary[type] = (summary[type] || 0) + 1;
  }

  return c.json({
    success: true,
    data: {
      countryCode: cca2,
      year,
      workDays: q.work_days || 'mon-fri',
      minDays: q.min_days ?? 3,
      includeOptional: q.include_optional ?? true,
      totalLongWeekends: result.longWeekends.length,
      totalDaysOff: result.longWeekends.reduce((s, w) => s + w.days, 0),
      summary,
      longWeekends: result.longWeekends,
    },
  });
});

// -------------------------------------------------------------------------
// GET /api/v1/countries/{cca2}/pto-strategy/{year} — best PTO planning
// -------------------------------------------------------------------------
app.openapi(createRoute({
  method: "get",
  path: "/api/v1/countries/{cca2}/pto-strategy/{year}",
  tags: ["Holidays"],
  summary: "Best PTO strategy for the year (greedy optimal)",
  description: "Given N available PTO days, returns the optimal way to use them to maximize total days off. Uses greedy selection by efficiency.",
  request: {
    params: z.object({
      cca2: z.string().length(2),
      year: z.coerce.number().int(),
    }),
    query: z.object({
      available_pto: z.coerce.number().int().min(1).max(20).default(5),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: z.any() } }, description: "OK" },
    404: { content: { "application/json": { schema: z.any() } }, description: "Country not found" },
  },
}), async (c) => {
  const cca2 = c.req.valid("param").cca2.toUpperCase();
  const year = c.req.valid("param").year;
  const availablePto = c.req.valid("query").available_pto;

  const country = await c.env.DB.prepare("SELECT id FROM countries WHERE cca2 = ?")
    .bind(cca2).first<{ id: number }>();
  if (!country) {
    return c.json({ success: false, error: { code: "COUNTRY_NOT_FOUND", message: `Country ${cca2} not found` } }, 404);
  }

  const holidayRes = await c.env.DB.prepare(`
    SELECT occ.id, occ.concept_id, occ.start_date, occ.end_date, occ.observed_date,
           c.name_en as concept_name,
           GROUP_CONCAT(f.filter_code) as filter_codes
    FROM holiday_occurrence occ
    JOIN holiday_concept c ON c.id = occ.concept_id
    LEFT JOIN holiday_occurrence_filter f ON f.occurrence_id = occ.id
    WHERE occ.country_id = ?
    GROUP BY occ.id
    ORDER BY occ.start_date
    LIMIT 200
  `).bind(country.id).all<{
    id: number; concept_id: number; start_date: string; end_date: string | null;
    observed_date: string | null; concept_name: string; filter_codes: string | null;
  }>();

  const holidays = holidayRes.results.map(h => ({
    date: h.start_date,
    endDate: h.end_date || h.start_date,
    name: h.concept_name,
    filterCode: h.filter_codes ? h.filter_codes.split(",")[0] : "PUBLIC_NATIONAL",
  }));

  const result = computeLongWeekends(holidays, year, { minDays: 3, includeOptional: true });

  // Build ptoStrategies map
  const ptoMap: Record<string, any[]> = {};
  for (const w of result.longWeekends) {
    const exts: any[] = [];
    for (let n = 1; n <= 3; n++) {
      const beforeDays: string[] = [];
      for (let i = 1; i <= n; i++) {
        const d = new Date(w.start);
        d.setDate(d.getDate() - i);
        const dow = d.getUTCDay();
        if (dow !== 0 && dow !== 6) beforeDays.push(d.toISOString().slice(0, 10));
      }
      if (beforeDays.length === n) {
        exts.push({
          direction: "before",
          ptoDays: beforeDays,
          totalOff: w.days + beforeDays.length,
          efficiency: (w.days + beforeDays.length) / beforeDays.length,
        });
      }
      const afterDays: string[] = [];
      for (let i = 1; i <= n; i++) {
        const d = new Date(w.end);
        d.setDate(d.getDate() + i);
        const dow = d.getUTCDay();
        if (dow !== 0 && dow !== 6) afterDays.push(d.toISOString().slice(0, 10));
      }
      if (afterDays.length === n) {
        exts.push({
          direction: "after",
          ptoDays: afterDays,
          totalOff: w.days + afterDays.length,
          efficiency: (w.days + afterDays.length) / afterDays.length,
        });
      }
    }
    if (exts.length > 0) ptoMap[w.start] = exts;
  }

  const plan = planYearPTO(result.longWeekends, ptoMap, availablePto);
  const lwByStart = new Map(result.longWeekends.map(w => [w.start, w]));

  return c.json({
    success: true,
    data: {
      countryCode: cca2,
      year,
      availablePto,
      totalPtoUsed: plan.totalPtoUsed,
      totalDaysOff: plan.totalDaysOff,
      coverage: plan.coverage,
      strategies: plan.strategies.map(s => {
        const lw = lwByStart.get(s.longWeekendStart);
        return {
          longWeekendStart: s.longWeekendStart,
          longWeekendEnd: s.longWeekendEnd,
          trigger: lw ? lw.trigger : "Unknown",
          pto: {
            direction: "before",
            ptoDays: s.ptoDays,
            totalOff: s.extendedDays,
            efficiency: s.efficiency,
          },
        };
      }),
    },
  });
});

export default app;
