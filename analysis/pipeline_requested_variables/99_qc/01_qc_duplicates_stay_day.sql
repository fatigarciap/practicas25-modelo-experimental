SELECT
  stay_id,
  day_idx,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_model_dataset_requested_variables`
GROUP BY stay_id, day_idx
HAVING COUNT(*) > 1;
