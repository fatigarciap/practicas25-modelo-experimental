SELECT
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays,
  COUNT(DISTINCT subject_id) AS n_subjects,

  COUNT(*) - COUNT(DISTINCT CONCAT(CAST(stay_id AS STRING), '-', CAST(day_idx AS STRING))) AS n_duplicate_stay_day,

  MIN(day_idx) AS min_day_idx,
  MAX(day_idx) AS max_day_idx,

  COUNTIF(clinical_improvement_72h IS NULL) AS n_missing_label,
  COUNTIF(has_full_72h_label_window = 1) AS n_full_window,
  COUNTIF(has_full_72h_label_window = 0) AS n_incomplete_window,

  COUNTIF(clinical_improvement_72h = 1) AS n_positive_label,
  COUNTIF(clinical_improvement_72h = 0) AS n_negative_label

FROM `strange-math-456415-c3.mimic_analysis.longitudinal_model_ready_predictive_72h`;