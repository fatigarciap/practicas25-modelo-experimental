-- QC duplicates for the final longitudinal 72h analytical dataset.
-- Historical filename retained; the checked unit is now stay_id + window_idx.

SELECT
  stay_id,
  window_idx,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`
GROUP BY
  stay_id,
  window_idx
HAVING COUNT(*) > 1;
