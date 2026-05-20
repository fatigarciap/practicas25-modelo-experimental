-- QC counts, window distribution, availability of next window, and temporal coherence.

SELECT
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays,
  COUNT(DISTINCT subject_id) AS n_subjects,
  MIN(window_idx) AS min_window_idx,
  MAX(window_idx) AS max_window_idx,
  COUNTIF(clinical_status_72h_next IS NULL) AS n_rows_without_next_window_status,
  COUNTIF(clinical_status_72h_next IS NOT NULL) AS n_rows_valid_for_analysis,
  COUNTIF(window_start >= window_end) AS n_temporal_incoherent_windows,
  COUNTIF(next_window_idx IS NOT NULL AND next_window_idx != window_idx + 1) AS n_bad_next_window_idx
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`;

SELECT
  window_idx,
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`
GROUP BY window_idx
ORDER BY window_idx;

SELECT
  has_next_window,
  next_has_full_72h_window,
  has_valid_next_status,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`
GROUP BY
  has_next_window,
  next_has_full_72h_window,
  has_valid_next_status
ORDER BY
  has_next_window,
  next_has_full_72h_window,
  has_valid_next_status;
