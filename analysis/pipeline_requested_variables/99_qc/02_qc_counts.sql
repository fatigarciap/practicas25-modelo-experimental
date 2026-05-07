SELECT
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays,
  COUNT(DISTINCT subject_id) AS n_subjects,
  MIN(day_idx) AS min_day_idx,
  MAX(day_idx) AS max_day_idx,
  COUNTIF(has_full_72h_label_window = 1) AS n_full_72h_label_window,
  COUNTIF(has_full_72h_label_window = 0) AS n_incomplete_72h_label_window
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_model_dataset_requested_variables`;
