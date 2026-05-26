-- QC distribution of current and next-window ordinal clinical status.

SELECT
  clinical_status_72h,
  COUNT(*) AS n_rows,
  SAFE_DIVIDE(COUNT(*), SUM(COUNT(*)) OVER ()) AS row_fraction
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`
GROUP BY clinical_status_72h
ORDER BY clinical_status_72h;

SELECT
  clinical_status_72h_next,
  COUNT(*) AS n_rows,
  SAFE_DIVIDE(COUNT(*), SUM(COUNT(*)) OVER ()) AS row_fraction
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`
GROUP BY clinical_status_72h_next
ORDER BY clinical_status_72h_next;

SELECT
  window_idx,
  clinical_status_72h_next,
  COUNT(*) AS n_rows
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`
GROUP BY
  window_idx,
  clinical_status_72h_next
ORDER BY
  window_idx,
  clinical_status_72h_next;
