CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.table1_binary_72h` AS
WITH long_format AS (
  SELECT
    'male_sex' AS variable,
    clinical_status_72h_next,
    CASE
      WHEN sex IS NULL THEN NULL
      WHEN LOWER(CAST(sex AS STRING)) IN ('m', 'male') THEN 1
      ELSE 0
    END AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'bacteremia' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(bacteremia AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'polymicrobial_infection' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(polymicrobial_infection AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'has_broad_at_start' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(has_broad_at_start AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'has_gp_resistant_at_start' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(has_gp_resistant_at_start AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'has_gn_mdr_at_start' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(has_gn_mdr_at_start AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'prior_antibiotics_before_start' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(prior_antibiotics_before_start AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'has_abx_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(has_abx_window AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'mechanical_ventilation_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(mechanical_ventilation_window AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'vasopressors_window' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(vasopressors_window AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_myocardial_infarct_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_myocardial_infarct_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_congestive_heart_failure_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_congestive_heart_failure_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_peripheral_vascular_disease_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_peripheral_vascular_disease_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_cerebrovascular_disease_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_cerebrovascular_disease_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_dementia_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_dementia_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_chronic_pulmonary_disease_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_chronic_pulmonary_disease_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_rheumatic_disease_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_rheumatic_disease_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_peptic_ulcer_disease_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_peptic_ulcer_disease_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_mild_liver_disease_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_mild_liver_disease_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_diabetes_without_cc_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_diabetes_without_cc_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_diabetes_with_cc_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_diabetes_with_cc_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_paraplegia_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_paraplegia_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_renal_disease_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_renal_disease_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_malignant_cancer_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_malignant_cancer_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_severe_liver_disease_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_severe_liver_disease_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_metastatic_solid_tumor_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_metastatic_solid_tumor_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'comorb_aids_bin' AS variable,
    clinical_status_72h_next,
    SAFE_CAST(comorb_aids_bin AS INT64) AS value
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`
),
summary AS (
  SELECT
    variable,
    clinical_status_72h_next,
    COUNT(value) AS n_total,
    SUM(value) AS n_positive,
    SAFE_DIVIDE(SUM(value), COUNT(value)) * 100 AS pct_positive
  FROM long_format
  WHERE value IS NOT NULL
  GROUP BY
    variable,
    clinical_status_72h_next
)
SELECT
  variable,
  clinical_status_72h_next,
  n_total,
  n_positive,
  pct_positive,
  FORMAT('%d (%.1f%%)', n_positive, pct_positive) AS summary_text
FROM summary
ORDER BY
  variable,
  clinical_status_72h_next;
