/**
 * dateandtime-api-v2 — translations routes.
 *
 * GET /api/v1/cities/{id}/translations — All translations for a city
 * GET /api/v1/cities/{id}/translations/{lang} — Single language translation
 * GET /api/v1/translations/search — Search by translated name (e.g. "東京")
 *
 * Source: dr5hn translations.csv (2,965,565 rows, 19 langs)
 */
import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import type { Env, Variables } from "@/types/env";

const translations = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// ============================================================================
// Schemas
// ============================================================================
const CityTranslation = z.object({
  language: z.string().describe("ISO 639-1 code (e.g. 'ja', 'es', 'ar')"),
  translation: z.string(),
});

const CityTranslationsResponse = z.object({
  success: z.literal(true),
  data: z.object({
    cityId: z.number(),
    placeType: z.literal("city"),
    count: z.number(),
    translations: z.array(CityTranslation),
  }),
});

const ErrorResponse = z.object({
  success: z.literal(false),
  error: z.object({ code: z.string(), message: z.string() }),
});

const SearchResult = z.object({
  cityId: z.number(),
  cityName: z.string(),
  language: z.string(),
  translation: z.string(),
  country: z.object({
    cca2: z.string(),
    name: z.string(),
  }).nullable(),
});

const SearchResponse = z.object({
  success: z.literal(true),
  data: z.object({
    query: z.string(),
    language: z.string(),
    count: z.number(),
    results: z.array(SearchResult),
  }),
});

// ============================================================================
// GET /api/v1/cities/{id}/translations
// ============================================================================
const cityTranslationsRoute = createRoute({
  method: "get",
  path: "/api/v1/cities/{id}/translations",
  summary: "Get all translations for a city",
  description:
    "Returns city name translated into all 19 supported languages " +
    "(ar, br, de, es, fa, fr, hi, hr, it, ja, ko, nl, pl, pt, pt-BR, ru, tr, uk, zh-CN).",
  tags: ["Translations"],
  request: {
    params: z.object({ id: z.coerce.number().int().positive() }),
  },
  responses: {
    200: { content: { "application/json": { schema: CityTranslationsResponse } }, description: "All city translations" },
    404: { content: { "application/json": { schema: ErrorResponse } }, description: "City not found" },
  },
});

translations.openapi(cityTranslationsRoute, async (c) => {
  const { id } = c.req.valid("param");

  // --------------------------------------------------------------------------
  // STEP 1: Verify city exists (404 if not)
  // --------------------------------------------------------------------------
  // Single SELECT for existence + name (we only need id but name is nice for
  // debugging if the FK ever breaks). Lightweight query.
  // --------------------------------------------------------------------------
  const city = await c.env.DB.prepare(
    `SELECT id, name FROM cities WHERE id = ?`
  ).bind(id).first<{ id: number; name: string }>();
  if (!city) {
    return c.json(
      { success: false as const, error: { code: "NOT_FOUND", message: `City ${id} not found` } },
      404
    );
  }

  // --------------------------------------------------------------------------
  // STEP 2: Fetch all translations for the city
  // --------------------------------------------------------------------------
  // translations table has composite PK (place_id, place_type, language),
  // so WHERE place_id=? AND place_type='city' is a single index seek.
  //
  // Most cities have 19 translations (one per supported language).
  // Some cities (small towns) may have fewer — dr5hn coverage varies.
  //
  // ORDER BY language for stable client display.
  // --------------------------------------------------------------------------
  const result = await c.env.DB.prepare(
    `SELECT language, translation FROM translations
     WHERE place_id = ? AND place_type = 'city'
     ORDER BY language`
  ).bind(id).all<{ language: string; translation: string }>();

  // --------------------------------------------------------------------------
  // STEP 3: Build response
  // --------------------------------------------------------------------------
  // Returns:
  //   - cityId: input
  //   - placeType: 'city' (constant for now; future: 'state', 'country')
  //   - count: number of translations (typically 19)
  //   - translations: array of { language, translation }
  // --------------------------------------------------------------------------
  return c.json(
    {
      success: true as const,
      data: {
        cityId: id,
        placeType: "city" as const,
        count: result.results?.length || 0,
        translations: (result.results || []).map((r) => ({
          language: r.language,
          translation: r.translation,
        })),
      },
    },
    200
  );
});

// ============================================================================
// GET /api/v1/cities/{id}/translations/{lang}
// ============================================================================
const cityTranslationLangRoute = createRoute({
  method: "get",
  path: "/api/v1/cities/{id}/translations/{lang}",
  summary: "Get city name in a specific language",
  description:
    "Returns the city name translated into a single language " +
    "(e.g. ja=Japanese, es=Spanish, ar=Arabic).",
  tags: ["Translations"],
  request: {
    params: z.object({
      id: z.coerce.number().int().positive(),
      lang: z.string().min(2).max(10),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: z.object({
      success: z.literal(true),
      data: z.object({
        cityId: z.number(),
        language: z.string(),
        translation: z.string().nullable(),
      }),
    }) } }, description: "City translation" },
    404: { content: { "application/json": { schema: ErrorResponse } }, description: "City or language not found" },
  },
});

translations.openapi(cityTranslationLangRoute, async (c) => {
  const { id, lang } = c.req.valid("param");
  const langLower = lang.toLowerCase();

  const result = await c.env.DB.prepare(
    `SELECT translation, language FROM translations
     WHERE place_id = ? AND place_type = 'city' AND LOWER(language) = ?`
  ).bind(id, langLower).first<{ translation: string; language: string }>();

  if (!result) {
    return c.json(
      { success: false as const, error: { code: "NOT_FOUND", message: `No ${lang} translation for city ${id}` } },
      404
    );
  }

  return c.json(
    {
      success: true as const,
      data: { cityId: id, language: result.language, translation: result.translation },
    },
    200
  );
});

// ============================================================================
// GET /api/v1/translations/search?q=&lang=
// ============================================================================
const searchTranslationsRoute = createRoute({
  method: "get",
  path: "/api/v1/translations/search",
  summary: "Search cities by translated name",
  description:
    "Find cities by their name in a non-English language. " +
    "Example: ?q=東京&lang=ja finds all cities whose Japanese name matches. " +
    "Returns up to 20 results.",
  tags: ["Translations"],
  request: {
    query: z.object({
      q: z.string().min(1).max(100),
      lang: z.string().min(2).max(10),
      limit: z.coerce.number().int().min(1).max(50).default(20),
    }),
  },
  responses: {
    200: { content: { "application/json": { schema: SearchResponse } }, description: "Matching cities" },
  },
});

translations.openapi(searchTranslationsRoute, async (c) => {
  const { q, lang, limit } = c.req.valid("query");
  // dr5hn uses mixed case ('zh-CN', 'pt-BR'). Normalize to lowercase for matching,
  // but return the original case in the response.
  const langLower = lang.toLowerCase();

  // Use indexed (language, translation) search with prefix matching
  // SQLite is case-insensitive for ASCII LIKE by default
  const result = await c.env.DB.prepare(
    `SELECT t.place_id as cityId, t.translation, t.language, ci.name as cityName,
            co.cca2, co.name as countryName
     FROM translations t
     JOIN cities ci ON ci.id = t.place_id
     JOIN countries co ON co.id = ci.country_id
     WHERE LOWER(t.language) = ? AND t.translation LIKE ?
     ORDER BY LENGTH(t.translation), t.translation
     LIMIT ?`
  ).bind(langLower, `${q}%`, limit).all<{
    cityId: number;
    translation: string;
    language: string;
    cityName: string;
    cca2: string;
    countryName: string;
  }>();

  return c.json(
    {
      success: true as const,
      data: {
        query: q,
        language: lang,
        count: result.results?.length || 0,
        results: (result.results || []).map((r) => ({
          cityId: r.cityId,
          cityName: r.cityName,
          language: r.language,
          translation: r.translation,
          country: { cca2: r.cca2, name: r.countryName },
        })),
      },
    },
    200
  );
});

export default translations;
