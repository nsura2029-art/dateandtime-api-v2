/**
 * Country endpoints (M11.3)
 *
 *   GET /api/v1/countries          — list all countries (with optional ?lang=xx)
 *   GET /api/v1/countries/{cca2}   — single country detail (with ?lang=xx)
 *
 * Source: dr5hn `countries` table (base data) + CLDR `country_names` (localized
 * names for 20 languages: en, es, fr, de, zh, ja, ko, ru, ar, hi, pt, it, tr,
 * nl, pl, sv, uk, he, fa, th).
 *
 * When ?lang=xx is provided, the response includes the localized name and
 * short name (if any) for that language. The base English name remains
 * `name` and `official_name` for backward compatibility.
 *
 * If a country has no translation for the requested language, the English
 * name is returned (graceful fallback) and a `languageFallback: true` flag
 * is set so the client can tell.
 */
import { Hono } from "hono";
import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import type { Env, Variables } from "@/types/env";

const countries = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// ============================================================================
// Schemas
// ============================================================================
const LocalizedName = z.object({
  language: z.string().describe("ISO 639-1 code (e.g. 'en', 'ja', 'zh')"),
  name: z.string().describe("Localized name (or English fallback if no translation)"),
  shortName: z.string().nullable().describe("Short form (e.g. 'US', 'UK') — null if no short variant"),
  languageFallback: z.boolean().describe("True if we used the English name because the requested language had no entry"),
});

const CountryBase = z.object({
  id: z.number().int().describe("Country ID (internal)"),
  cca2: z.string().length(2).describe("ISO 3166-1 alpha-2 (e.g. 'US', 'FR')"),
  cca3: z.string().nullable().describe("ISO 3166-1 alpha-3 (e.g. 'USA')"),
  ccn3: z.string().nullable().describe("ISO 3166-1 numeric (e.g. '840')"),
  name: z.string().describe("English name (canonical, dr5hn)"),
  officialName: z.string().nullable().describe("Local official name (dr5hn, e.g. 'Brasil' for Brazil)"),
  capital: z.string().nullable().describe("Capital city name (English)"),
  region: z.string().nullable().describe("Region name (e.g. 'Europe', 'Asia')"),
  subregion: z.string().nullable().describe("Subregion name (e.g. 'Western Europe')"),
  currency: z.object({
    code: z.string().nullable(),
    name: z.string().nullable(),
    symbol: z.string().nullable(),
  }).nullable(),
  phoneCode: z.string().nullable(),
  languages: z.array(z.string()).nullable().describe("ISO 639-1 codes spoken in this country (dr5hn, sparse)"),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
  areaKm2: z.number().nullable(),
  population: z.number().nullable().describe("Country population (dr5hn, may be stale)"),
  flagEmoji: z.string().nullable(),
  tld: z.string().nullable(),
  nationality: z.string().nullable().describe("Demonym (e.g. 'American', 'Brazilian')"),
  unMember: z.boolean().nullable(),
  landlocked: z.boolean().nullable(),
  independent: z.boolean().nullable(),
  startOfWeek: z.string().nullable(),
  borders: z.array(z.string()).nullable().describe("Adjacent country CCA2 codes"),
  populationSources: z.object({
    dr5hn: z.number().nullable().describe("Population from dr5hn (may be stale, ~2020 estimates)"),
    worldBank2024: z.number().nullable().describe("Population from World Bank SP.POP.TOTL year=2024"),
    primary: z.enum(["dr5hn", "worldBank2024"]).describe("Which source is preferred for this country"),
  }).nullable().describe("Population data from multiple sources. worldBank2024 is generally fresher (2024 estimate). dr5hn may be NULL for territories WB doesn't track."),
});

const CountryWithLocale = CountryBase.extend({
  localized: LocalizedName.nullable().describe("Localized name for the requested language, or null if no ?lang given"),
});

const CountryListResponse = z.object({
  success: z.literal(true),
  data: z.object({
    language: z.string().nullable().describe("Requested language (or null if no ?lang)"),
    count: z.number().int(),
    countries: z.array(CountryWithLocale),
    tookMs: z.number().int(),
  }),
});

const CountryDetailResponse = z.object({
  success: z.literal(true),
  data: CountryWithLocale,
});

const ErrorResponse = z.object({
  success: z.literal(false),
  error: z.object({ code: z.string(), message: z.string() }),
});

// ============================================================================
// GET /api/v1/countries
// ============================================================================
const listRoute = createRoute({
  method: "get",
  path: "/api/v1/countries",
  summary: "List all countries",
  description:
    "Returns all 250 countries with English base data. If `?lang=xx` is provided, " +
    "each country includes a `localized` block with the localized name and short " +
    "name (where available) for that language. Languages available: en, es, fr, de, " +
    "zh, ja, ko, ru, ar, hi, pt, it, tr, nl, pl, sv, uk, he, fa, th.",
  tags: ["Countries"],
  request: {
    query: z.object({
      lang: z.string().min(2).max(10).optional()
        .describe("ISO 639-1 code (e.g. 'ja', 'es') for localized names"),
      region: z.string().min(2).max(30).optional()
        .describe("Filter by region name (e.g. 'Europe', 'Asia')"),
      limit: z.coerce.number().int().min(1).max(500).default(250)
        .describe("Max countries to return (default 250)"),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: CountryListResponse } }, description: "Country list" },
  },
});

countries.openapi(listRoute, async (c) => {
  const { lang, region, limit } = c.req.valid("query");
  const start = Date.now();

  let sql = `SELECT
      co.id, co.cca2, co.cca3, co.ccn3, co.name, co.official_name, co.capital,
      co.region_id, co.subregion_id, co.currency_code, co.currency_name, co.currency_symbol,
      co.phone_code, co.languages, co.latitude, co.longitude, co.area_km2, co.population,
      co.flag_emoji, co.tld, co.nationality, co.un_member, co.landlocked, co.independent,
      co.start_of_week, co.borders,
      r.name as region_name, sr.name as subregion_name
    FROM countries co
    LEFT JOIN regions r ON r.id = co.region_id
    LEFT JOIN subregions sr ON sr.id = co.subregion_id`;

  const params: any[] = [];
  if (region) {
    sql += " WHERE r.name = ?";
    params.push(region);
  }
  sql += " ORDER BY co.name ASC LIMIT ?";
  params.push(limit);

  const result = await c.env.DB.prepare(sql).bind(...params).all();
  const rows = result.results || [];

  // Build World Bank population lookup (M11.4)
  // Fetch all WB populations for the loaded countries; one query.
  const wbMap = new Map<number, number>();
  if (rows.length > 0) {
    const wbRes = await c.env.DB.prepare(
      `SELECT country_id, population FROM country_populations
       WHERE year = 2024 AND source = 'world_bank'`
    ).all();
    for (const r of (wbRes.results || [])) {
      wbMap.set(Number((r as any).country_id), Number((r as any).population));
    }
  }

  // Build localized lookup if lang given
  let localizedMap = new Map<number, any>();
  if (lang && rows.length > 0) {
    // D1 SQL bind limit is ~100 vars per prepared statement. With cca2 IN (...)
    // using N placeholders + 1 for language, we can do at most 99 cca2 values.
    // For larger lists, fetch translations in chunks.
    const cca2List = rows.map((r: any) => r.cca2);
    const CHUNK = 95;
    for (let i = 0; i < cca2List.length; i += CHUNK) {
      const chunk = cca2List.slice(i, i + CHUNK);
      const placeholders = chunk.map(() => "?").join(",");
      const cn = await c.env.DB.prepare(
        `SELECT cn.country_id, cn.name, cn.short_name
         FROM country_names cn
         WHERE cn.language = ? AND cn.country_id IN (
           SELECT id FROM countries WHERE cca2 IN (${placeholders})
         )`
      ).bind(lang, ...chunk).all();
      for (const r of (cn.results || [])) {
        localizedMap.set(Number((r as any).country_id), { name: (r as any).name, shortName: (r as any).short_name });
      }
    }
  }

  const data = rows.map((r: any) => {
    const base: any = {
      id: r.id,
      cca2: r.cca2,
      cca3: r.cca3,
      ccn3: r.ccn3,
      name: r.name,
      officialName: r.official_name,
      capital: r.capital,
      region: r.region_name,
      subregion: r.subregion_name,
      currency: r.currency_code || r.currency_name || r.currency_symbol
        ? { code: r.currency_code, name: r.currency_name, symbol: r.currency_symbol }
        : null,
      phoneCode: r.phone_code,
      languages: r.languages ? JSON.parse(r.languages) : null,
      latitude: r.latitude,
      longitude: r.longitude,
      areaKm2: r.area_km2,
      population: r.population,
      flagEmoji: r.flag_emoji,
      tld: r.tld,
      nationality: r.nationality,
      unMember: r.un_member === 1,
      landlocked: r.landlocked === 1,
      independent: r.independent === 1,
      startOfWeek: r.start_of_week,
      borders: r.borders ? JSON.parse(r.borders) : null,
    };
    // M11.4: Add World Bank population alongside dr5hn
    const dr5hnPop = r.population;
    const wbPop = wbMap.get(r.id) || null;
    base.populationSources = {
      dr5hn: dr5hnPop,
      worldBank2024: wbPop,
      // World Bank 2024 is fresher, prefer it when available
      primary: wbPop !== null ? "worldBank2024" : "dr5hn",
    };

    if (lang) {
      const localized = localizedMap.get(r.id);
      if (localized) {
        base.localized = {
          language: lang,
          name: localized.name,
          shortName: localized.shortName,
          languageFallback: false,
        };
      } else {
        // No translation for this language — fallback to English
        base.localized = {
          language: lang,
          name: r.name,
          shortName: null,
          languageFallback: true,
        };
      }
    } else {
      base.localized = null;
    }
    return base;
  });

  return c.json({
    success: true,
    data: {
      language: lang || null,
      count: data.length,
      countries: data,
      tookMs: Date.now() - start,
    },
  });
});

// ============================================================================
// GET /api/v1/countries/{cca2}
// ============================================================================
const detailRoute = createRoute({
  method: "get",
  path: "/api/v1/countries/{cca2}",
  summary: "Get a single country by cca2",
  description:
    "Returns one country (by ISO 3166-1 alpha-2 code) with English base data. " +
    "If `?lang=xx` is provided, the response includes a `localized` block.",
  tags: ["Countries"],
  request: {
    params: z.object({ cca2: z.string().length(2).describe("ISO 3166-1 alpha-2 (e.g. 'US', 'FR')") }),
    query: z.object({
      lang: z.string().min(2).max(10).optional()
        .describe("ISO 639-1 code for localized name"),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: CountryDetailResponse } }, description: "Country detail" },
    404: { content: { "application/json": { schema: ErrorResponse } }, description: "Country not found" },
  },
});

countries.openapi(detailRoute, async (c) => {
  const { cca2 } = c.req.valid("param");
  const { lang } = c.req.valid("query");
  const cca2Upper = cca2.toUpperCase();

  const row = await c.env.DB.prepare(
    `SELECT
      co.id, co.cca2, co.cca3, co.ccn3, co.name, co.official_name, co.capital,
      co.region_id, co.subregion_id, co.currency_code, co.currency_name, co.currency_symbol,
      co.phone_code, co.languages, co.latitude, co.longitude, co.area_km2, co.population,
      co.flag_emoji, co.tld, co.nationality, co.un_member, co.landlocked, co.independent,
      co.start_of_week, co.borders,
      r.name as region_name, sr.name as subregion_name
    FROM countries co
    LEFT JOIN regions r ON r.id = co.region_id
    LEFT JOIN subregions sr ON sr.id = co.subregion_id
    WHERE co.cca2 = ?`
  ).bind(cca2Upper).first();

  if (!row) {
    return c.json(
      { success: false as const, error: { code: "NOT_FOUND", message: `Country ${cca2Upper} not found` } },
      404
    );
  }

  const r: any = row;
  const base: any = {
    id: r.id,
    cca2: r.cca2,
    cca3: r.cca3,
    ccn3: r.ccn3,
    name: r.name,
    officialName: r.official_name,
    capital: r.capital,
    region: r.region_name,
    subregion: r.subregion_name,
    currency: r.currency_code || r.currency_name || r.currency_symbol
      ? { code: r.currency_code, name: r.currency_name, symbol: r.currency_symbol }
      : null,
    phoneCode: r.phone_code,
    languages: r.languages ? JSON.parse(r.languages) : null,
    latitude: r.latitude,
    longitude: r.longitude,
    areaKm2: r.area_km2,
    population: r.population,
    flagEmoji: r.flag_emoji,
    tld: r.tld,
    nationality: r.nationality,
    unMember: r.un_member === 1,
    landlocked: r.landlocked === 1,
    independent: r.independent === 1,
    startOfWeek: r.start_of_week,
    borders: r.borders ? JSON.parse(r.borders) : null,
    populationSources: null,  // filled below
  };

  // M11.4: World Bank population
  const wbRow = await c.env.DB.prepare(
    `SELECT population FROM country_populations
     WHERE country_id = ? AND year = 2024 AND source = 'world_bank'`
  ).bind(r.id).first();
  const dr5hnPop = r.population;
  const wbPop = wbRow ? Number((wbRow as any).population) : null;
  base.populationSources = {
    dr5hn: dr5hnPop,
    worldBank2024: wbPop,
    primary: wbPop !== null ? "worldBank2024" : "dr5hn",
  };

  if (lang) {
    const localized = await c.env.DB.prepare(
      `SELECT name, short_name FROM country_names WHERE country_id = ? AND language = ?`
    ).bind(r.id, lang).first();
    if (localized) {
      base.localized = {
        language: lang,
        name: (localized as any).name,
        shortName: (localized as any).short_name,
        languageFallback: false,
      };
    } else {
      base.localized = {
        language: lang,
        name: r.name,
        shortName: null,
        languageFallback: true,
      };
    }
  } else {
    base.localized = null;
  }

  return c.json({ success: true, data: base });
});

export default countries;
