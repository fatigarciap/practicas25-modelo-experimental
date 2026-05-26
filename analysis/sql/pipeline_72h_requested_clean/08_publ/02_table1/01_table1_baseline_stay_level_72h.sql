CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h` AS
SELECT
  subject_id,
  hadm_id,
  stay_id,
  window_idx,
  t0,
  index_charttime,

  clinical_status_72h_next,

  age,
  sex,
  race,
  insurance,

  charlson_index,
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

  microorganism,
  infection_site,
  bacteremia,
  polymicrobial_infection,
  infection_acquisition_type,

  n_abx_at_start,
  spectrum_level_at_start,
  has_broad_at_start,
  has_gp_resistant_at_start,
  has_gn_mdr_at_start,
  prior_antibiotics_before_start,

  n_abx_window,
  has_abx_window,
  spectrum_level_window,
  spectrum_level_window_filled,
  HR_median_window,
  MAP_median_window,
  RR_median_window,
  SpO2_median_window,
  Temp_median_window,
  WBC_median_window,
  Lactate_median_window,
  Creatinine_median_window,
  Bilirubin_median_window,
  SAPS,
  mechanical_ventilation_window,
  vasopressors_window,
  FiO2_median_window,
  PaO2_FiO2_median_window
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`
WHERE window_idx = 0
  AND clinical_status_72h_next IS NOT NULL;

-- Pending review:
-- SOFA_max_72h and SOFA_mean_72h are requested for Table 1, but the source
-- longitudinal_72h_dataset_requested currently exposes them as internal QC
-- fields: qc_SOFA_max_72h and qc_SOFA_mean_72h.
