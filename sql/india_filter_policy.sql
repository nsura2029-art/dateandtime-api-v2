-- india_filter_policy.sql
-- Add India (IN) to the M14 country_filter_policy
-- 13 filters visible in timeanddate.com India UI, plus WORLD/UN observances
-- Per the common pattern: each country has a subset of the 36 global filters

DELETE FROM country_filter_policy WHERE country_code = 'IN';

-- 6 cols × 16 rows = 96 vars (under the 100-var D1 limit)
INSERT OR REPLACE INTO country_filter_policy
  (country_code, filter_code, state, default_selected, display_order, updated_at)
VALUES
  -- Primary type axis (Gazetted/Optional)
  ('IN', 'PUBLIC_NATIONAL',     'available',        1, 10,  strftime('%s','now')*1000),
  ('IN', 'PUBLIC_LOCAL',        'available',        0, 20,  strftime('%s','now')*1000),
  ('IN', 'OPTIONAL_HOLIDAY',    'available',        1, 30,  strftime('%s','now')*1000),
  -- Observance axis
  ('IN', 'OBS_IMPORTANT',       'supported_empty',  1, 200, strftime('%s','now')*1000),
  ('IN', 'OBS_COMMON',          'supported_empty',  1, 210, strftime('%s','now')*1000),
  ('IN', 'OBS_LOCAL',           'available',        0, 220, strftime('%s','now')*1000),
  -- Astronomical
  ('IN', 'SEASON',              'supported_empty',  1, 320, strftime('%s','now')*1000),
  -- Tradition axis (Major Christian / Muslim / Hindu)
  ('IN', 'CHRISTIAN_MAJOR',     'available',        0, 400, strftime('%s','now')*1000),
  ('IN', 'CHRISTIAN_MORE',      'available',        0, 410, strftime('%s','now')*1000),
  ('IN', 'MUSLIM_MAJOR',        'available',        0, 440, strftime('%s','now')*1000),
  ('IN', 'MUSLIM_MORE',         'available',        0, 450, strftime('%s','now')*1000),
  ('IN', 'HINDU_MAJOR',         'available',        1, 460, strftime('%s','now')*1000),
  ('IN', 'HINDU_MORE',          'available',        1, 470, strftime('%s','now')*1000),
  -- Religious fallback for Sikh/Jain (no SIKH/JAIN codes in M14; use OTHER_RELIGION)
  ('IN', 'OTHER_RELIGION',      'available',        0, 510, strftime('%s','now')*1000),
  ('IN', 'BUDDHIST',            'available',        0, 500, strftime('%s','now')*1000),
  -- Worldwide / UN
  ('IN', 'WORLD_OBSERVANCE',    'supported_empty',  0, 310, strftime('%s','now')*1000),
  ('IN', 'UN_OBSERVANCE',       'supported_empty',  0, 300, strftime('%s','now')*1000);
