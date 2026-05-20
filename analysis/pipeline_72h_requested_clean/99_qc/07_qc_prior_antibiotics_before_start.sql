-- QC for prior_antibiotics_before_start in the current 72h analytical dataset.
-- Under the T0 definition this should usually be 0 or close to 0.

SELECT
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays,
  COUNTIF(prior_antibiotics_before_start = 1) AS n_rows_prior_antibiotics_before_start,
  COUNT(DISTINCT IF(prior_antibiotics_before_start = 1, stay_id, NULL)) AS n_stays_prior_antibiotics_before_start,
  SAFE_DIVIDE(
    COUNTIF(prior_antibiotics_before_start = 1),
    COUNT(*)
  ) AS row_fraction_prior_antibiotics_before_start
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`;
