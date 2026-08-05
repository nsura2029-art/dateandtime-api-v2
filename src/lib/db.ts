/**
 * Typed D1 query helpers — one place for SELECT/INSERT/UPDATE patterns.
 *
 * Each helper takes a D1 binding and returns typed data.
 * For complex queries, use `c.env.DB.prepare(sql).bind(...).all<T>()` directly.
 *
 * Schema: matches migrations/101_create_schema.sql (Phase 1 of
 * docs/PLAN-phased-implementation.md).
 */
import type {
  Region,
  Subregion,
  Country,
  AdminRegion,
  City,
  Timezone,
  CityTimezone,
  CountryTimezone,
  PlaceName,
  DataSource,
  ImportHistory,
  PlaceRedirect,
} from "./types";

// ============================================================================
// regions (6 rows)
// ============================================================================

export const Regions = {
  async list(db: D1Database): Promise<Region[]> {
    const result = await db
      .prepare("SELECT * FROM regions ORDER BY id ASC")
      .all<Region>();
    return result.results ?? [];
  },

  async byId(db: D1Database, id: number): Promise<Region | null> {
    return await db.prepare("SELECT * FROM regions WHERE id = ?").bind(id).first<Region>();
  },

  async byCode(db: D1Database, code: string): Promise<Region | null> {
    return await db
      .prepare("SELECT * FROM regions WHERE code = ? OR un_m49_code = ?")
      .bind(code.toUpperCase(), code)
      .first<Region>();
  },

  async count(db: D1Database): Promise<number> {
    const result = await db.prepare("SELECT COUNT(*) as c FROM regions").first<{ c: number }>();
    return result?.c ?? 0;
  },
};

// ============================================================================
// subregions (22 rows)
// ============================================================================

export const Subregions = {
  async list(db: D1Database, regionId?: number): Promise<Subregion[]> {
    const where = regionId ? "WHERE region_id = ?" : "";
    const result = await db
      .prepare(`SELECT * FROM subregions ${where} ORDER BY id ASC`)
      .bind(...(regionId ? [regionId] : []))
      .all<Subregion>();
    return result.results ?? [];
  },

  async byId(db: D1Database, id: number): Promise<Subregion | null> {
    return await db.prepare("SELECT * FROM subregions WHERE id = ?").bind(id).first<Subregion>();
  },

  async byCode(db: D1Database, code: string): Promise<Subregion | null> {
    return await db.prepare("SELECT * FROM subregions WHERE code = ?").bind(code).first<Subregion>();
  },

  async count(db: D1Database): Promise<number> {
    const result = await db.prepare("SELECT COUNT(*) as c FROM subregions").first<{ c: number }>();
    return result?.c ?? 0;
  },
};

// ============================================================================
// countries (250 rows)
// ============================================================================

export const Countries = {
  async byCca2(db: D1Database, cca2: string): Promise<Country | null> {
    return await db
      .prepare("SELECT * FROM countries WHERE cca2 = ?")
      .bind(cca2.toUpperCase())
      .first<Country>();
  },

  async byId(db: D1Database, id: number): Promise<Country | null> {
    return await db.prepare("SELECT * FROM countries WHERE id = ?").bind(id).first<Country>();
  },

  async list(
    db: D1Database,
    opts: { regionId?: number; subregionId?: number; limit: number; offset: number }
  ): Promise<Country[]> {
    const where: string[] = [];
    const params: (string | number)[] = [];
    if (opts.regionId !== undefined) {
      where.push("region_id = ?");
      params.push(opts.regionId);
    }
    if (opts.subregionId !== undefined) {
      where.push("subregion_id = ?");
      params.push(opts.subregionId);
    }
    const whereClause = where.length > 0 ? `WHERE ${where.join(" AND ")}` : "";
    const sql = `SELECT * FROM countries ${whereClause} ORDER BY name ASC LIMIT ? OFFSET ?`;
    params.push(opts.limit, opts.offset);
    const result = await db.prepare(sql).bind(...params).all<Country>();
    return result.results ?? [];
  },

  async count(db: D1Database): Promise<number> {
    const result = await db.prepare("SELECT COUNT(*) as c FROM countries").first<{ c: number }>();
    return result?.c ?? 0;
  },
};

// ============================================================================
// administrative_regions (5,308 rows: states / provinces / counties)
// ============================================================================

export const AdminRegions = {
  async byId(db: D1Database, id: number): Promise<AdminRegion | null> {
    return await db
      .prepare("SELECT * FROM administrative_regions WHERE id = ?")
      .bind(id)
      .first<AdminRegion>();
  },

  async listByCountry(db: D1Database, countryId: number, limit = 100, offset = 0): Promise<AdminRegion[]> {
    const result = await db
      .prepare(
        "SELECT * FROM administrative_regions WHERE country_id = ? ORDER BY level ASC, name ASC LIMIT ? OFFSET ?"
      )
      .bind(countryId, limit, offset)
      .all<AdminRegion>();
    return result.results ?? [];
  },

  async count(db: D1Database, countryId?: number): Promise<number> {
    const sql = countryId
      ? "SELECT COUNT(*) as c FROM administrative_regions WHERE country_id = ?"
      : "SELECT COUNT(*) as c FROM administrative_regions";
    const result = await db
      .prepare(sql)
      .bind(...(countryId ? [countryId] : []))
      .first<{ c: number }>();
    return result?.c ?? 0;
  },
};

// ============================================================================
// cities (152,970 rows)
// ============================================================================

export const Cities = {
  async byId(db: D1Database, id: number): Promise<City | null> {
    return await db.prepare("SELECT * FROM cities WHERE id = ?").bind(id).first<City>();
  },

  async list(
    db: D1Database,
    opts: {
      countryId?: number;
      stateId?: number;
      timezone?: string;
      limit: number;
      offset: number;
      sort?: "name" | "population";
    }
  ): Promise<City[]> {
    const where: string[] = [];
    const params: (string | number)[] = [];

    if (opts.countryId !== undefined) {
      where.push("country_id = ?");
      params.push(opts.countryId);
    }
    if (opts.stateId !== undefined) {
      where.push("state_id = ?");
      params.push(opts.stateId);
    }
    if (opts.timezone) {
      where.push("timezone = ?");
      params.push(opts.timezone);
    }

    const whereClause = where.length > 0 ? `WHERE ${where.join(" AND ")}` : "";
    const orderBy =
      opts.sort === "population" ? "ORDER BY population DESC" : "ORDER BY name ASC";
    const sql = `SELECT * FROM cities ${whereClause} ${orderBy} LIMIT ? OFFSET ?`;
    params.push(opts.limit, opts.offset);

    const result = await db.prepare(sql).bind(...params).all<City>();
    return result.results ?? [];
  },

  async count(
    db: D1Database,
    opts: { countryId?: number; stateId?: number; timezone?: string } = {}
  ): Promise<number> {
    const where: string[] = [];
    const params: (string | number)[] = [];

    if (opts.countryId !== undefined) {
      where.push("country_id = ?");
      params.push(opts.countryId);
    }
    if (opts.stateId !== undefined) {
      where.push("state_id = ?");
      params.push(opts.stateId);
    }
    if (opts.timezone) {
      where.push("timezone = ?");
      params.push(opts.timezone);
    }

    const whereClause = where.length > 0 ? `WHERE ${where.join(" AND ")}` : "";
    const result = await db
      .prepare(`SELECT COUNT(*) as c FROM cities ${whereClause}`)
      .bind(...params)
      .first<{ c: number }>();
    return result?.c ?? 0;
  },

  /** Haversine proximity search — find cities within radiusKm of (lat, lon). */
  async near(
    db: D1Database,
    lat: number,
    lon: number,
    radiusKm: number,
    limit: number
  ): Promise<(City & { distance_km: number })[]> {
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

  /** LIKE search on name and ascii_name. */
  async search(
    db: D1Database,
    q: string,
    limit: number,
    offset: number
  ): Promise<City[]> {
    const like = `%${q}%`;
    const result = await db
      .prepare(
        `SELECT * FROM cities WHERE name LIKE ? OR ascii_name LIKE ?
         ORDER BY population DESC LIMIT ? OFFSET ?`
      )
      .bind(like, like, limit, offset)
      .all<City>();
    return result.results ?? [];
  },
};

// ============================================================================
// time_zones (~450 rows)
// ============================================================================

export const Timezones = {
  async byId(db: D1Database, id: string): Promise<Timezone | null> {
    return await db
      .prepare("SELECT * FROM time_zones WHERE id = ?")
      .bind(id)
      .first<Timezone>();
  },

  async list(db: D1Database, limit = 100, offset = 0): Promise<Timezone[]> {
    const result = await db
      .prepare("SELECT * FROM time_zones ORDER BY id ASC LIMIT ? OFFSET ?")
      .bind(limit, offset)
      .all<Timezone>();
    return result.results ?? [];
  },

  async count(db: D1Database): Promise<number> {
    const result = await db.prepare("SELECT COUNT(*) as c FROM time_zones").first<{ c: number }>();
    return result?.c ?? 0;
  },
};

// ============================================================================
// place_names (Phase 2 — empty for now)
// ============================================================================

export const PlaceNames = {
  async forCity(db: D1Database, cityId: number): Promise<PlaceName[]> {
    const result = await db
      .prepare("SELECT * FROM place_names WHERE canonical_place_id = ?")
      .bind(cityId)
      .all<PlaceName>();
    return result.results ?? [];
  },

  async count(db: D1Database): Promise<number> {
    const result = await db.prepare("SELECT COUNT(*) as c FROM place_names").first<{ c: number }>();
    return result?.c ?? 0;
  },
};

// ============================================================================
// M2M tables
// ============================================================================

export const CityTimezones = {
  async forCity(db: D1Database, cityId: number): Promise<CityTimezone[]> {
    const result = await db
      .prepare("SELECT * FROM city_time_zones WHERE city_id = ?")
      .bind(cityId)
      .all<CityTimezone>();
    return result.results ?? [];
  },
};

export const CountryTimezones = {
  async forCountry(db: D1Database, countryId: number): Promise<CountryTimezone[]> {
    const result = await db
      .prepare("SELECT * FROM country_time_zones WHERE country_id = ?")
      .bind(countryId)
      .all<CountryTimezone>();
    return result.results ?? [];
  },
};

// ============================================================================
// Data lineage
// ============================================================================

export const DataSources = {
  async list(db: D1Database): Promise<DataSource[]> {
    const result = await db.prepare("SELECT * FROM data_sources ORDER BY name ASC").all<DataSource>();
    return result.results ?? [];
  },
  async count(db: D1Database): Promise<number> {
    const result = await db.prepare("SELECT COUNT(*) as c FROM data_sources").first<{ c: number }>();
    return result?.c ?? 0;
  },
};

export const ImportHistories = {
  async recent(db: D1Database, limit = 20): Promise<ImportHistory[]> {
    const result = await db
      .prepare("SELECT * FROM import_history ORDER BY started_at DESC LIMIT ?")
      .bind(limit)
      .all<ImportHistory>();
    return result.results ?? [];
  },
};

export const PlaceRedirects = {
  async forCity(db: D1Database, cityId: number): Promise<PlaceRedirect[]> {
    const result = await db
      .prepare("SELECT * FROM place_redirects WHERE from_id = ? OR to_id = ?")
      .bind(cityId, cityId)
      .all<PlaceRedirect>();
    return result.results ?? [];
  },
  async count(db: D1Database): Promise<number> {
    const result = await db.prepare("SELECT COUNT(*) as c FROM place_redirects").first<{ c: number }>();
    return result?.c ?? 0;
  },
};
