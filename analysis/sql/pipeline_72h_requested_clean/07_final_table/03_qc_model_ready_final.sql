-- ============================================================
-- QC MODEL-READY FINAL DATASET
-- ============================================================

-- 1. Basic size
SELECT
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays,
  MIN(window_idx) AS min_window_idx,
  MAX(window_idx) AS max_window_idx
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_model_ready_final`;


-- 2. Check duplicates by stay_id + window_idx
SELECT
  stay_id,
  window_idx,
  COUNT(*) AS n
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_model_ready_final`
GROUP BY stay_id, window_idx
HAVING COUNT(*) > 1;


-- 3. Outcome distribution
SELECT
  clinical_improvement_72h_next,
  clinical_status_72h_next,
  clinical_status_72h_next_ord,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_model_ready_final`
GROUP BY
  clinical_improvement_72h_next,
  clinical_status_72h_next,
  clinical_status_72h_next_ord
ORDER BY clinical_status_72h_next_ord;


-- 4. Check missing outcome
SELECT
  COUNT(*) AS n_rows,
  COUNTIF(clinical_improvement_72h_next IS NULL) AS missing_binary_outcome,
  COUNTIF(clinical_status_72h_next IS NULL) AS missing_categorical_outcome,
  COUNTIF(clinical_status_72h_next_ord IS NULL) AS missing_ordinal_outcome
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_model_ready_final`;


-- 5. Window distribution
SELECT
  window_idx,
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_model_ready_final`
GROUP BY window_idx
ORDER BY window_idx;


-- 6. Quick preview for export/check
SELECT *
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_model_ready_final`
ORDER BY stay_id, window_idx;