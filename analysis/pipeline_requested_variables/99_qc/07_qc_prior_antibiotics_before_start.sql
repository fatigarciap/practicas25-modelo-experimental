SELECT
  COUNT(*) AS n_rows,
  COUNTIF(prior_antibiotics_before_start = 1) AS n_prior_antibiotics_before_start,
  SAFE_DIVIDE(
    COUNTIF(prior_antibiotics_before_start = 1),
    COUNT(*)
  ) AS prior_antibiotics_before_start_fraction
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_model_dataset_requested_variables`;

