-- ============================================================
-- FINAL MODEL-READY LONGITUDINAL 72H DATASET
-- Project: AMR days / MIMIC-IV v3.1
-- Unit of analysis: stay_id + window_idx
--
-- Predictors are measured in the current 72h window t.
-- Outcomes are measured in the next 72h window t+1.
--
-- Primary outcome:
--   clinical_improvement_72h_next
--   improvement = 1
--   death / no_improvement = 0
--
-- Secondary outcomes:
--   clinical_status_72h_next
--   clinical_status_72h_next_ord
--
-- Ordinal coding:
--   death = 0
--   no_improvement = 1
--   improvement = 2
-- ============================================================

CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.longitudinal_72h_model_ready_final` AS

SELECT
  -- ============================================================
  -- 1. IDENTIFIERS / TEMPORAL STRUCTURE
  -- ============================================================
  stay_id,
  window_idx,
  t0,
  index_charttime,

  -- ============================================================
  -- 2. DEMOGRAPHICS
  -- ============================================================
  age,
  sex,
  race,
  insurance,

  -- ============================================================
  -- 3. COMORBIDITY
  -- ============================================================
  comorb_myocardial_infarct_bin,
  comorb_congestive_heart_failure_bin,
  comorb_peripheral_vascular_disease_bin,
  comorb_cerebrovascular_disease_bin,
  comorb_dementia_bin,
  comorb_chronic_pulmonary_disease_bin,
  comorb_rheumatic_disease_bin,
  comorb_peptic_ulcer_disease_bin,
  comorb_mild_liver_disease_bin,
  comorb_diabetes_without_cc_bin,
  comorb_diabetes_with_cc_bin,
  comorb_paraplegia_bin,
  comorb_renal_disease_bin,
  comorb_malignant_cancer_bin,
  comorb_severe_liver_disease_bin,
  comorb_metastatic_solid_tumor_bin,
  comorb_aids_bin,
  charlson_index,

  -- ============================================================
  -- 4. MICROBIOLOGY / INFECTION
  -- ============================================================
  microorganism,
  infection_site,
  bacteremia,
  polymicrobial_infection,
  infection_acquisition_type,

  -- ============================================================
  -- 5. ANTIBIOTICS
  -- ============================================================
  n_abx_at_start,
  spectrum_level_at_start,
  has_broad_at_start,
  has_gp_resistant_at_start,
  has_gn_mdr_at_start,
  prior_antibiotics_before_start,
  n_abx_window,
  spectrum_level_window,
  has_abx_window,
  spectrum_level_window_filled,

  -- ============================================================
  -- 6. VITAL SIGNS - CURRENT 72H WINDOW
  -- ============================================================
  HR_median_window,
  MAP_median_window,
  RR_median_window,
  SpO2_median_window,
  Temp_median_window,

  -- ============================================================
  -- 7. LABORATORY - CURRENT 72H WINDOW
  -- ============================================================
  WBC_median_window,
  Lactate_median_window,
  Creatinine_median_window,
  Bilirubin_median_window,

  -- ============================================================
  -- 8. BASELINE AND LONGITUDINAL SEVERITY
  -- ============================================================
  SAPS,
  qc_SOFA_max_72h AS SOFA_max_72h,
  qc_SOFA_mean_72h AS SOFA_mean_72h,

  -- ============================================================
  -- 9. ORGAN SUPPORT / RESPIRATORY STATUS
  -- ============================================================
  mechanical_ventilation_window,
  vasopressors_window,
  FiO2_median_window,
  PaO2_FiO2_median_window,

  -- ============================================================
  -- 10. PRIMARY BINARY OUTCOME
  -- improvement = 1
  -- death or no_improvement = 0
  -- ============================================================
  CASE
    WHEN clinical_status_72h_next = 'improvement' THEN 1
    WHEN clinical_status_72h_next IN ('death', 'no_improvement') THEN 0
    ELSE NULL
  END AS clinical_improvement_72h_next,

  -- ============================================================
  -- 11. SECONDARY CATEGORICAL OUTCOME
  -- ============================================================
  clinical_status_72h_next,

  -- ============================================================
  -- 12. SECONDARY ORDINAL OUTCOME
  -- 0 = death
  -- 1 = no_improvement
  -- 2 = improvement
  -- ============================================================
  CASE
    WHEN clinical_status_72h_next = 'death' THEN 0
    WHEN clinical_status_72h_next = 'no_improvement' THEN 1
    WHEN clinical_status_72h_next = 'improvement' THEN 2
    ELSE NULL
  END AS clinical_status_72h_next_ord

FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`

WHERE clinical_status_72h_next IS NOT NULL

ORDER BY stay_id, window_idx;
