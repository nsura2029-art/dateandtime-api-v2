-- usa_filter_policy.sql
-- Add USA (US) to the M14 country_filter_policy
-- 18 filters visible in timeanddate.com USA UI, matching the M14 catalog

DELETE FROM country_filter_policy WHERE country_code = 'US';

-- 6 cols × 18 rows = 108 vars (over the 100-var D1 limit)
-- Use 2 batches: 16 + 2

-- Batch 1: 16 rows = 96 vars
INSERT OR REPLACE INTO country_filter_policy
  (country_code, filter_code, state, default_selected, display_order, updated_at)
VALUES
  ('US', 'PUBLIC_NATIONAL',     'available',        1,  10, strftime('%s','now')*1000),
  ('US', 'PUBLIC_LOCAL',        'available',        1,  20, strftime('%s','now')*1000),
  ('US', 'OPTIONAL_HOLIDAY',    'supported_empty',  0,  50, strftime('%s','now')*1000),
  ('US', 'OBS_IMPORTANT',       'available',        1, 200, strftime('%s','now')*1000),
  ('US', 'OBS_COMMON',          'available',        1, 210, strftime('%s','now')*1000),
  ('US', 'OBS_OTHER',           'available',        0, 220, strftime('%s','now')*1000),
  ('US', 'OBS_LOCAL',           'available',        0, 230, strftime('%s','now')*1000),
  ('US', 'SEASON',              'available',        1, 320, strftime('%s','now')*1000),
  ('US', 'CLOCK_CHANGE',        'available',        1, 330, strftime('%s','now')*1000),
  ('US', 'WORLD_OBSERVANCE',    'available',        0, 310, strftime('%s','now')*1000),
  ('US', 'UN_OBSERVANCE',       'available',        0, 300, strftime('%s','now')*1000),
  ('US', 'CHRISTIAN_MAJOR',     'available',        1, 400, strftime('%s','now')*1000),
  ('US', 'CHRISTIAN_MORE',      'available',        0, 410, strftime('%s','now')*1000),
  ('US', 'JEWISH_MAJOR',        'supported_empty',  0, 420, strftime('%s','now')*1000),
  ('US', 'JEWISH_MORE',         'supported_empty',  0, 430, strftime('%s','now')*1000),
  ('US', 'MUSLIM_MAJOR',        'available',        0, 440, strftime('%s','now')*1000);

-- Batch 2: 3 rows = 18 vars
INSERT OR REPLACE INTO country_filter_policy
  (country_code, filter_code, state, default_selected, display_order, updated_at)
VALUES
  ('US', 'HINDU_MAJOR',         'available',        0, 460, strftime('%s','now')*1000),
  ('US', 'ORTHODOX_MAJOR',      'supported_empty',  0, 480, strftime('%s','now')*1000),
  ('US', 'SPORTING_EVENT',      'supported_empty',  0, 340, strftime('%s','now')*1000);
