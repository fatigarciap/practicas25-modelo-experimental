-- ============================================================
-- QC TABLE 1 72H
-- Project: AMR days / TFM
-- No CREATE TABLE statements; SELECT-only QC script.
-- ============================================================

-- 1. Baseline count
SELECT
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays,
  COUNT(DISTINCT subject_id) AS n_patients,
  MIN(window_idx) AS min_window_idx,
  MAX(window_idx) AS max_window_idx
FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`;


-- 2. clinical_status_72h_next distribution in baseline table
WITH totals AS (
  SELECT COUNT(DISTINCT stay_id) AS total_stays
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`
)
SELECT
  b.clinical_status_72h_next,
  COUNT(DISTINCT b.stay_id) AS n_stays,
  COUNT(DISTINCT b.subject_id) AS n_patients,
  SAFE_DIVIDE(COUNT(DISTINCT b.stay_id), t.total_stays) * 100 AS pct_stays
FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h` b
CROSS JOIN totals t
GROUP BY
  b.clinical_status_72h_next,
  t.total_stays
ORDER BY b.clinical_status_72h_next;


-- 3. Duplicate stay_id check
SELECT
  stay_id,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`
GROUP BY stay_id
HAVING COUNT(*) > 1
ORDER BY n_rows DESC, stay_id;


-- 4. Check that only window_idx = 0 is present
SELECT
  window_idx,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`
GROUP BY window_idx
ORDER BY window_idx;


-- 5. Row counts by Table 1 partial/final table
SELECT
  'table1_continuous_72h' AS table_name,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.table1_continuous_72h`

UNION ALL

SELECT
  'table1_binary_72h' AS table_name,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.table1_binary_72h`

UNION ALL

SELECT
  'table1_multicategory_72h' AS table_name,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.table1_multicategory_72h`

UNION ALL

SELECT
  'table1_stratified_72h_summary' AS table_name,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.table1_stratified_72h_summary`;


-- 6. Strata present in continuous table
SELECT
  clinical_status_72h_next,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.table1_continuous_72h`
GROUP BY clinical_status_72h_next
ORDER BY clinical_status_72h_next;


-- 7. Strata present in binary table
SELECT
  clinical_status_72h_next,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.table1_binary_72h`
GROUP BY clinical_status_72h_next
ORDER BY clinical_status_72h_next;


-- 8. Strata present in multicategory table
SELECT
  clinical_status_72h_next,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.table1_multicategory_72h`
GROUP BY clinical_status_72h_next
ORDER BY clinical_status_72h_next;


-- 9. Sections present in final pivot
SELECT
  section,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.table1_stratified_72h_summary`
GROUP BY section
ORDER BY
  CASE section
    WHEN 'Continuous' THEN 1
    WHEN 'Binary' THEN 2
    WHEN 'Multicategory' THEN 3
    ELSE 4
  END,
  section;


-- 10. Final pivot rows with all outcome columns empty
SELECT
  section,
  variable,
  category,
  death,
  no_improvement,
  improvement
FROM `strange-math-456415-c3.mimic_analysis.table1_stratified_72h_summary`
WHERE death IS NULL
  AND no_improvement IS NULL
  AND improvement IS NULL
ORDER BY
  section,
  variable,
  category;
