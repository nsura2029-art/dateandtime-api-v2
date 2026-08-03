-- Migration 155: Global admin-2 (counties, districts, communes) — M12
-- Adds admin-2 region data from GeoNames + city → admin-2 mapping

-- 1. Add geoname_id to administrative_regions (used to look up admin-2 from GeoNames codes)
ALTER TABLE administrative_regions ADD COLUMN geoname_id INTEGER;
CREATE UNIQUE INDEX IF NOT EXISTS idx_admin_regions_geoname ON administrative_regions (geoname_id) WHERE geoname_id IS NOT NULL;

-- 2. Add admin2_id to cities (FK to administrative_regions level 2)
ALTER TABLE cities ADD COLUMN admin2_id INTEGER REFERENCES administrative_regions(id);

-- 3. Index for fast city → admin-2 lookup
CREATE INDEX IF NOT EXISTS idx_cities_admin2 ON cities (admin2_id);

-- 4. Index for fast admin-2 region queries
CREATE INDEX IF NOT EXISTS idx_admin_regions_parent_level ON administrative_regions (parent_id, level);
CREATE INDEX IF NOT EXISTS idx_admin_regions_country_level ON administrative_regions (country_id, level);
