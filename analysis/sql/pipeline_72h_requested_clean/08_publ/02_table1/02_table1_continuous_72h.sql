CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.table1_continuous_72h` AS
WITH long_format AS (
  SELECT
    'age' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(age AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'SAPS' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(SAPS AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'charlson_index' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(charlson_index AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'MAP_median_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(MAP_median_window AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'Lactate_median_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(Lactate_median_window AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'Creatinine_median_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(Creatinine_median_window AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'PaO2_FiO2_median_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(PaO2_FiO2_median_window AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'HR_median_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(HR_median_window AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'RR_median_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(RR_median_window AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'SpO2_median_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(SpO2_median_window AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'Temp_median_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(Temp_median_window AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'WBC_median_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(WBC_median_window AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'Bilirubin_median_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(Bilirubin_median_window AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'FiO2_median_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(FiO2_median_window AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'n_abx_at_start' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(n_abx_at_start AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'n_abx_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(n_abx_window AS FLOAT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`
),
summary AS (
  SELECT
    variable,
    clinical_status_72h_next,
    COUNT(value) AS n_non_missing,
    APPROX_QUANTILES(value, 100 IGNORE NULLS)[OFFSET(50)] AS median,
    APPROX_QUANTILES(value, 100 IGNORE NULLS)[OFFSET(25)] AS q1,
    APPROX_QUANTILES(value, 100 IGNORE NULLS)[OFFSET(75)] AS q3
  FROM long_format
  WHERE value IS NOT NULL
  GROUP BY
    variable,
    clinical_status_72h_next
)
SELECT
  variable,
  clinical_status_72h_next,
  n_non_missing,
  median,
  q1,
  q3,
  FORMAT('%.1f [%.1f-%.1f]', median, q1, q3) AS summary_text
FROM summary
ORDER BY
  variable,
  clinical_status_72h_next;

-- Pending review:
-- qc_SOFA_max_72h and qc_SOFA_mean_72h are intentionally not included here.
-- Decide later whether to expose them as non-QC Table 1 variables.
