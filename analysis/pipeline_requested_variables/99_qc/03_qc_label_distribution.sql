SELECT
  clinical_improvement_72h,
  COUNT(*) AS n_rows,
  SAFE_DIVIDE(COUNT(*), SUM(COUNT(*)) OVER ()) AS row_fraction
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_model_dataset_requested_variables`
GROUP BY clinical_improvement_72h
ORDER BY clinical_improvement_72h;
