/**
 * Typed D1 query helpers — one place for SELECT/INSERT/UPDATE patterns.
 *
 * Each helper takes a D1 binding and returns typed data.
 * For complex queries, use `c.env.DB.prepare(sql).bind(...).all<T>()` directly.
 */
import type { City, Country, Timezone, Holiday, OnThisDay, CityAlias, PlaceRedirect } from "./types";

/** Cities table — typed SELECT helpers. */
export const Cities = {
  /** Get a city by numeric ID (geoname_id). */
  async byId(db: D1Database, id: number): Promise<City | null> {
    return await db
      .prepare("SELECT * FROM cities WHERE geoname_id = ?")
      .bind(id)
      .first<City>();
  },

  /** List cities, paginated, optionally filtered by country. */
  async list(
    db: D1Database,
    opts: { country?: string; tz?: string; limit: number; offset: number; sort?: "name" | "population" }
  ): Promise<City[]> {
    const where: string[] = [];
    const params: (string | number)[] = [];

    if (opts.country) {
      where.push("country_code = ?");
      params.push(opts.country.toUpperCase());
    }
    if (opts.tz) {
      where.push("timezone = ?");
      params.push(opts.tz);
    }

    const whereClause = where.length > 0 ? `WHERE ${where.join(" AND ")}` : "";
    const orderBy = opts.sort === "population" ? "ORDER BY population DESC NULLS LAST" : "ORDER BY name ASC";
    const sql = `SELECT * FROM cities ${whereClause} ${orderBy} LIMIT ? OFFSET ?`;
    params.push(opts.limit, opts.offset);

    const result = await db.prepare(sql).bind(...params).all<City>();
    return result.results ?? [];
  },

  /** Count cities, optionally filtered by country. */
  async count(db: D1Database, opts: { country?: string; tz?: string } = {}): Promise<number> {
    const where: string[] = [];
    const params: (string | number)[] = [];

    if (opts.country) {
      where.push("country_code = ?");
      params.push(opts.country.toUpperCase());
    }
    if (opts.tz) {
      where.push("timezone = ?");
      params.push(opts.tz);
    }
    const whereClause = where.length > 0 ? `WHERE ${where.join(" AND ")}` : "";

    const result = await db
      .prepare(`SELECT COUNT(*) as c FROM cities ${whereClause}`)
      .bind(...params)
      .first<{ c: number }>();
    return result?.c ?? 0;
  },

  /** Search cities by LIKE on name + asciiName. */
  async search(db: D1Database, q: string, limit: number, offset: number): Promise<City[]> {
    const like = `%${q}%`;
    const result = await db
      .prepare(
        `SELECT * FROM cities WHERE name LIKE ? OR ascii_name LIKE ? ORDER BY population DESC NULLS LAST LIMIT ? OFFSET ?`
      )
      .bind(like, like, limit, offset)
      .all<City>();
    return result.results ?? [];
  },

  /** Haversine proximity search. */
  async near(
    db: D1Database,
    lat: number,
    lon: number,
    radiusKm: number,
    limit: number
  ): Promise<City[]> {
    // Bounding box pre-filter (much faster than full haversine on all cities)
    const latDelta = radiusKm / 111.0;
    const lonDelta = radiusKm / (111.0 * Math.max(0.01, Math.cos((lat * Math.PI) / 180)));
    const result = await db
      .prepare(
        `SELECT *, (
           6371 * acos(
             cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?))
             + sin(radians(?)) * sin(radians(latitude))
           )
         ) AS distance_km
         FROM cities
         WHERE latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?
         HAVING distance_km <= ?
         ORDER BY distance_km ASC
         LIMIT ?`
      )
      .bind(lat, lon, lat, lat - latDelta, lat + latDelta, lon - lonDelta, lon + lonDelta, radiusKm, limit)
      .all<City & { distance_km: number }>();
    return result.results ?? [];
  },
};

/** Countries table — typed SELECT helpers. */
export const Countries = {
  async byCca2(db: D1Database, cca2: string): Promise<Country | null> {
    return await db
      .prepare("SELECT * FROM countries WHERE cca2 = ?")
      .bind(cca2.toUpperCase())
      .first<Country>();
  },

  async list(db: D1Database, limit: number, offset: number, region?: string): Promise<Country[]> {
    const where = region ? "WHERE un_region = ?" : "";
    const params: (string | number)[] = region ? [region, limit, offset] : [limit, offset];
    const result = await db
      .prepare(`SELECT * FROM countries ${where} ORDER BY name ASC LIMIT ? OFFSET ?`)
      .bind(...params)
      .all<Country>();
    return result.results ?? [];
  },

  async count(db: D1Database): Promise<number> {
    const result = await db.prepare("SELECT COUNT(*) as c FROM countries").first<{ c: number }>();
    return result?.c ?? 0;
  },

  async workingHours(db: D1Database, cca2: string): Promise<unknown | null> {
    return await db
      .prepare(
        "SELECT * FROM business_calendars WHERE country_code = ? ORDER BY is_default DESC LIMIT 1"
      )
      .bind(cca2.toUpperCase())
      .first();
  },
};

/** Timezones table — typed SELECT helpers. */
export const Timezones = {
  async byId(db: D1Database, id: string): Promise<Timezone | null> {
    return await db
      .prepare("SELECT * FROM timezones WHERE id = ?")
      .bind(id)
      .first<Timezone>();
  },

  async list(db: D1Database, limit: number, offset: number): Promise<Timezone[]> {
    const result = await db
      .prepare("SELECT * FROM timezones ORDER BY id ASC LIMIT ? OFFSET ?")
      .bind(limit, offset)
      .all<Timezone>();
    return result.results ?? [];
  },

  async count(db: D1Database): Promise<number> {
    const result = await db.prepare("SELECT COUNT(*) as c FROM timezones").first<{ c: number }>();
    return result?.c ?? 0;
  },
};

/** Holidays table. */
export const Holidays = {
  async listForYear(db: D1Database, country: string, year: number): Promise<Holiday[]> {
    const result = await db
      .prepare(
        "SELECT * FROM holidays WHERE country_code = ? AND year = ? ORDER BY date ASC"
      )
      .bind(country.toUpperCase(), year)
      .all<Holiday>();
    return result.results ?? [];
  },

  async today(db: D1Database, country: string, date: string): Promise<Holiday[]> {
    const result = await db
      .prepare("SELECT * FROM holidays WHERE country_code = ? AND date = ?")
      .bind(country.toUpperCase(), date)
      .all<Holiday>();
    return result.results ?? [];
  },

  async upcoming(
    db: D1Database,
    country: string,
    fromDate: string,
    days: number
  ): Promise<Holiday[]> {
    const result = await db
      .prepare(
        "SELECT * FROM holidays WHERE country_code = ? AND date >= ? AND date <= date(?, '+' || ? || ' days') ORDER BY date ASC"
      )
      .bind(country.toUpperCase(), fromDate, fromDate, days)
      .all<Holiday>();
    return result.results ?? [];
  },
};

/** Onthisday table — exported as `Otd` to avoid name collision with the `OnThisDay` row type. */
export const Otd = {
  async byDate(db: D1Database, month: number, day: number): Promise<OnThisDay[]> {
    const result = await db
      .prepare("SELECT * FROM onthisday WHERE month = ? AND day = ? ORDER BY year ASC NULLS LAST")
      .bind(month, day)
      .all<OnThisDay>();
    return result.results ?? [];
  },

  async count(db: D1Database): Promise<number> {
    const result = await db.prepare("SELECT COUNT(*) as c FROM onthisday").first<{ c: number }>();
    return result?.c ?? 0;
  },
};

/** City aliases. */
export const CityAliases = {
  async forCity(db: D1Database, cityId: number): Promise<CityAlias[]> {
    const result = await db
      .prepare("SELECT * FROM city_aliases WHERE city_id = ?")
      .bind(cityId)
      .all<CityAlias>();
    return result.results ?? [];
  },

  async count(db: D1Database): Promise<number> {
    const result = await db.prepare("SELECT COUNT(*) as c FROM city_aliases").first<{ c: number }>();
    return result?.c ?? 0;
  },
};

/** Place redirects (historical city renamings). */
export const PlaceRedirects = {
  async forCity(db: D1Database, cityId: number): Promise<PlaceRedirect[]> {
    const result = await db
      .prepare("SELECT * FROM place_redirects WHERE city_id = ? ORDER BY year_from ASC")
      .bind(cityId)
      .all<PlaceRedirect>();
    return result.results ?? [];
  },
};
