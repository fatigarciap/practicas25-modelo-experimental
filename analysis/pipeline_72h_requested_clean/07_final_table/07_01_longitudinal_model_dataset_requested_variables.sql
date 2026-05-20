-- OBSOLETE for the publication-oriented 72h longitudinal dataset.
-- Kept for traceability only. Use
-- 07_final_table/07_01_longitudinal_72h_model_dataset_requested.sql instead.

CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.longitudinal_model_dataset_requested_variables` AS
WITH base AS (
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    day_idx,
    t0,
    index_charttime
  FROM `strange-math-456415-c3.mimic_analysis.base_windows_requested`
),
labels AS (
  SELECT
    stay_id,
    day_idx,
    clinical_improvement_72h,
    has_full_72h_label_window
  FROM `strange-math-456415-c3.mimic_analysis.clinical_improvement_72h_labels_requested`
),
daily AS (
  SELECT
    stay_id,
    day_idx,
    HR_median,
    MAP_median,
    RR_median,
    SpO2_median,
    Temp_median,
    WBC_median,
    Lactate_median,
    Creatinine_median,
    Bilirubin_median
  FROM `strange-math-456415-c3.mimic_analysis.daily_features_requested`
)
SELECT
  b.subject_id,
  b.hadm_id,
  b.stay_id,
  b.day_idx,
  b.t0,
  b.index_charttime,

  y.clinical_improvement_72h,
  y.has_full_72h_label_window,

  demo.age,
  demo.sex,
  demo.race,
  demo.insurance,

  demo.comorb_myocardial_infarct_bin,
  demo.comorb_congestive_heart_failure_bin,
  demo.comorb_peripheral_vascular_disease_bin,
  demo.comorb_cerebrovascular_disease_bin,
  demo.comorb_dementia_bin,
  demo.comorb_chronic_pulmonary_disease_bin,
  demo.comorb_rheumatic_disease_bin,
  demo.comorb_peptic_ulcer_disease_bin,
  demo.comorb_mild_liver_disease_bin,
  demo.comorb_diabetes_without_cc_bin,
  demo.comorb_diabetes_with_cc_bin,
  demo.comorb_paraplegia_bin,
  demo.comorb_renal_disease_bin,
  demo.comorb_malignant_cancer_bin,
  demo.comorb_severe_liver_disease_bin,
  demo.comorb_metastatic_solid_tumor_bin,
  demo.comorb_aids_bin,
  demo.charlson_index,

  micro.microorganism,
  micro.infection_site,
  micro.bacteremia,
  micro.polymicrobial_infection,

  abx.n_abx_at_start,
  abx.spectrum_level_at_start,
  abx.has_broad_at_start,
  abx.has_gp_resistant_at_start,
  abx.has_gn_mdr_at_start,
  abx.prior_antibiotics_before_start,

  acq.infection_acquisition_type,

  d.HR_median AS HR_post_t0,
  d.MAP_median AS MAP_post_t0,
  d.RR_median AS RR_post_t0,
  d.SpO2_median AS SpO2_post_t0,
  d.Temp_median AS Temp_post_t0,
  d.WBC_median AS WBC_post_t0,
  d.Lactate_median AS Lactate_post_t0,
  d.Creatinine_median AS Creatinine_post_t0,
  d.Bilirubin_median AS Bilirubin_post_t0,

  sev_base.SAPS,
  sev_daily.SOFA_post_t0,
  sev_daily.mechanical_ventilation,
  sev_daily.vasopressors,

  resp.FiO2_t0,
  resp.PaO2_FiO2_t0
FROM base b
LEFT JOIN labels y
  ON b.stay_id = y.stay_id
 AND b.day_idx = y.day_idx
LEFT JOIN `strange-math-456415-c3.mimic_analysis.demographics_comorbidity_requested` demo
  ON b.stay_id = demo.stay_id
LEFT JOIN `strange-math-456415-c3.mimic_analysis.microbiology_infection_requested` micro
  ON b.stay_id = micro.stay_id
LEFT JOIN `strange-math-456415-c3.mimic_analysis.antibiotics_baseline_requested` abx
  ON b.stay_id = abx.stay_id
LEFT JOIN `strange-math-456415-c3.mimic_analysis.infection_acquisition_requested` acq
  ON b.stay_id = acq.stay_id
LEFT JOIN daily d
  ON b.stay_id = d.stay_id
 AND b.day_idx = d.day_idx
LEFT JOIN `strange-math-456415-c3.mimic_analysis.severity_support_baseline_requested` sev_base
  ON b.stay_id = sev_base.stay_id
LEFT JOIN `strange-math-456415-c3.mimic_analysis.daily_severity_support_requested` sev_daily
  ON b.stay_id = sev_daily.stay_id
 AND b.day_idx = sev_daily.day_idx
LEFT JOIN `strange-math-456415-c3.mimic_analysis.respiratory_t0_requested` resp
  ON b.stay_id = resp.stay_id
WHERE y.has_full_72h_label_window = 1;
