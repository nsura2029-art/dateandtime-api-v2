-- canada_filter_policy.sql
-- Add Canada (CA) to the M14 country_filter_policy
-- Based on Calendarific 2026 data: 184 holidays, 107 concepts, 13 provinces/territories
-- Filter codes: Federal statutory, provincial, observance, religious (Christian, Jewish, Muslim, Orthodox), seasons, clock changes

DELETE FROM country_filter_policy WHERE country_code = 'CA';

-- 6 cols × 16 rows = 96 vars (under the 100-var D1 limit)
-- Use 2 batches

-- Batch 1: 16 rows = 96 vars
INSERT OR REPLACE INTO country_filter_policy
  (country_code, filter_code, state, default_selected, display_order, updated_at)
VALUES
  -- Federal statutory
  ('CA', 'PUBLIC_NATIONAL',     'available',        1,  10, strftime('%s','now')*1000),
  -- Provincial (Family Day, Civic Holiday, etc.)
  ('CA', 'PUBLIC_LOCAL',        'available',        1,  20, strftime('%s','now')*1000),
  ('CA', 'PUBLIC_COMMON_LOCAL', 'available',        1,  30, strftime('%s','now')*1000),
  -- Optional (Boxing Day in some provinces)
  ('CA', 'OPTIONAL_HOLIDAY',    'available',        0,  50, strftime('%s','now')*1000),
  -- Observances
  ('CA', 'OBS_IMPORTANT',       'available',        1, 200, strftime('%s','now')*1000),
  ('CA', 'OBS_COMMON',          'available',        1, 210, strftime('%s','now')*1000),
  ('CA', 'OBS_OTHER',           'available',        0, 220, strftime('%s','now')*1000),
  ('CA', 'OBS_LOCAL',           'available',        0, 230, strftime('%s','now')*1000),
  -- Astronomical
  ('CA', 'SEASON',              'available',        1, 320, strftime('%s','now')*1000),
  ('CA', 'CLOCK_CHANGE',        'available',        1, 330, strftime('%s','now')*1000),
  -- Christian
  ('CA', 'CHRISTIAN_MAJOR',     'available',        1, 400, strftime('%s','now')*1000),
  ('CA', 'CHRISTIAN_MORE',      'available',        0, 410, strftime('%s','now')*1000),
  -- Jewish (Calendarific has all major + minor)
  ('CA', 'JEWISH_MAJOR',        'available',        1, 420, strftime('%s','now')*1000),
  ('CA', 'JEWISH_MORE',         'available',        0, 430, strftime('%s','now')*1000),
  -- Muslim
  ('CA', 'MUSLIM_MAJOR',        'available',        0, 440, strftime('%s','now')*1000),
  ('CA', 'MUSLIM_MORE',         'available',        0, 450, strftime('%s','now')*1000);

-- Batch 2: 5 rows = 30 vars
INSERT OR REPLACE INTO country_filter_policy
  (country_code, filter_code, state, default_selected, display_order, updated_at)
VALUES
  -- Hindu (small community in CA)
  ('CA', 'HINDU_MAJOR',         'supported_empty',  0, 460, strftime('%s','now')*1000),
  ('CA', 'HINDU_MORE',          'supported_empty',  0, 470, strftime('%s','now')*1000),
  -- Orthodox (Greek, Russian, Ukrainian, Serbian communities)
  ('CA', 'ORTHODOX_MAJOR',      'available',        0, 480, strftime('%s','now')*1000),
  ('CA', 'ORTHODOX_MORE',       'available',        0, 490, strftime('%s','now')*1000),
  -- Worldwide
  ('CA', 'WORLD_OBSERVANCE',    'available',        0, 310, strftime('%s','now')*1000),
  ('CA', 'UN_OBSERVANCE',       'available',        0, 300, strftime('%s','now')*1000);
