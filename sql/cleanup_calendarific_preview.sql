-- ============================================================================
-- Holiday Data Cleanup — Calendarific-Only (PREVIEW, NOT YET APPLIED)
-- ============================================================================
-- Run this AFTER quality gate review of preview/clean_calendarific.html
--
-- What this does:
-- 1. Removes 4 non-Calendarific sources (nager_date, un_official, hebcal, computed)
-- 2. Deletes orphan holidays (no sources left)
-- 3. Re-derives M14 filter assignments from Calendarific's "type" field
--
-- Net effect:
--   US: 500 → 369 holidays
--   CA: 184 → 184 (no change)
--   IN: 364 → 71 holidays (huge loss, but only UN/religious depth)
--   GB: 389 → 97 holidays
--   AU/DE/FR: unchanged
-- ============================================================================

-- SAFETY: wrap in transaction (uncomment to enable)
-- BEGIN TRANSACTION;

-- Step 1: Remove non-Calendarific sources from registry
DELETE FROM holiday_source
WHERE code IN (
  'nager_date',
  'un_official',
  'hebcal',
  'computed_federal_us'
);

-- Step 2: Remove links to those sources
DELETE FROM holiday_occurrence_source
WHERE source_key IN (
  'nager_date',
  'un_official',
  'hebcal',
  'computed_federal_us'
);

-- Step 3: Delete orphan occurrences (no source links)
DELETE FROM holiday_occurrence
WHERE id NOT IN (SELECT DISTINCT occurrence_id FROM holiday_occurrence_source);

-- Step 4: Delete orphan concepts (no occurrences)
DELETE FROM holiday_concept
WHERE id NOT IN (SELECT DISTINCT concept_id FROM holiday_occurrence);

-- Step 5: Clear all filter assignments (will re-derive)
DELETE FROM holiday_occurrence_filter;

-- Step 6: Re-derive filter assignments from Calendarific data
-- This is done by lib/calendarific_to_m14.py — see apply_to_db() function
-- For each remaining occurrence, derive filter codes from Calendarific's "type"
-- and insert into holiday_occurrence_filter

-- COMMIT;

-- ============================================================================
-- After running, verify with:
-- ============================================================================
-- SELECT source_key, COUNT(*) FROM holiday_occurrence_source GROUP BY source_key;
-- SELECT country_code, COUNT(DISTINCT ho.id) AS holidays
--   FROM holiday_occurrence ho
--   JOIN holiday_occurrence_source hos ON hos.occurrence_id = ho.id
--   JOIN holiday_source hs ON hs.id = hos.source_id
--   GROUP BY country_code;
-- SELECT filter_code, COUNT(*) FROM holiday_occurrence_filter GROUP BY filter_code;
-- ============================================================================
