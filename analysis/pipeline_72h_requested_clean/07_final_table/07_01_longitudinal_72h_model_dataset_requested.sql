-- Final MVP 72h longitudinal model dataset.
-- Unit: one row per stay_id + window_idx.
-- Dynamic predictors are measured in current window X.
-- Outcomes are taken from the next window X+1 via the precomputed labels table.
-- This temporal alignment avoids the main same-window leakage risk.

CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.longitudinal_72h_model_dataset_requested` AS
WITH base AS (
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    microevent_id,
    t0,
    index_charttime,
    icu_intime,
    icu_outtime,
    deathtime,
    followup_end,
    specimen_type,
    organism_name,
    is_monomicrobial_event,
    n_abx_t0,
    spectrum_level_t0,
    has_broad_t0,
    has_gp_resistant_t0,
    has_gn_mdr_t0,
    window_idx,
    window_start,
    window_end,
    window_hours_observed,
    window_minutes_observed,
    window_seconds_observed,
    has_full_72h_window
  FROM `strange-math-456415-c3.mimic_analysis.base_windows_72h_requested`
),
features AS (
  SELECT
    stay_id,
    window_idx,
    HR_mean_72h,
    MAP_mean_72h,
    SysBP_mean_72h,
    DiasBP_mean_72h,
    Temp_mean_72h,
    RR_mean_72h,
    SpO2_mean_72h,
    FiO2_mean_72h,
    WBC_mean_72h,
    Lactate_mean_72h,
    Creatinine_mean_72h,
    Bilirubin_mean_72h,
    Platelets_mean_72h,
    Hgb_mean_72h,
    spo2fio2_ratio_mean_72h,
    n_daily_rows_in_window,
    n_days_with_HR,
    n_days_with_MAP,
    n_days_with_Lactate,
    n_days_with_Creatinine,
    n_days_with_spo2fio2
  FROM `strange-math-456415-c3.mimic_analysis.window_features_72h_requested`
),
severity AS (
  SELECT
    stay_id,
    window_idx,
    SOFA_max_72h,
    SOFA_mean_72h,
    mechanical_ventilation_72h,
    vasopressors_72h
  FROM `strange-math-456415-c3.mimic_analysis.window_severity_support_72h_requested`
),
labels AS (
  SELECT
    stay_id,
    window_idx,
    outcome_window_idx,
    outcome_window_start,
    outcome_window_end,
    has_future_window,
    clinical_improvement_72h,
    clinical_status_72h,
    n_daily_outcome_rows_in_outcome_window,
    n_sustained_improvement_days_in_outcome_window,
    outcome_from_next_window
  FROM `strange-math-456415-c3.mimic_analysis.clinical_improvement_72h_window_labels_requested`
)
SELECT
  b.subject_id,
  b.hadm_id,
  b.stay_id,
  b.microevent_id,
  b.t0,
  b.index_charttime,
  b.icu_intime,
  b.icu_outtime,
  b.deathtime,
  b.followup_end,
  b.window_idx,
  b.window_start,
  b.window_end,
  b.window_hours_observed,
  b.window_minutes_observed,
  b.window_seconds_observed,
  b.has_full_72h_window,
  b.specimen_type,
  b.organism_name,
  b.is_monomicrobial_event,

  b.n_abx_t0,
  b.spectrum_level_t0,
  b.has_broad_t0,
  b.has_gp_resistant_t0,
  b.has_gn_mdr_t0,
  abx.n_abx_at_start,
  abx.spectrum_level_at_start,
  abx.has_broad_at_start,
  abx.has_gp_resistant_at_start,
  abx.has_gn_mdr_at_start,
  abx.prior_antibiotics_before_start,

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
  acq.infection_acquisition_type,
  sev_base.SAPS,

  f.HR_mean_72h,
  f.MAP_mean_72h,
  f.SysBP_mean_72h,
  f.DiasBP_mean_72h,
  f.Temp_mean_72h,
  f.RR_mean_72h,
  f.SpO2_mean_72h,
  f.FiO2_mean_72h,
  f.WBC_mean_72h,
  f.Lactate_mean_72h,
  f.Creatinine_mean_72h,
  f.Bilirubin_mean_72h,
  f.Platelets_mean_72h,
  f.Hgb_mean_72h,
  f.spo2fio2_ratio_mean_72h,
  f.n_daily_rows_in_window,
  f.n_days_with_HR,
  f.n_days_with_MAP,
  f.n_days_with_Lactate,
  f.n_days_with_Creatinine,
  f.n_days_with_spo2fio2,

  sev.SOFA_max_72h,
  sev.SOFA_mean_72h,
  sev.mechanical_ventilation_72h,
  sev.vasopressors_72h,

  l.outcome_window_idx,
  l.outcome_window_start,
  l.outcome_window_end,
  l.has_future_window,
  l.clinical_improvement_72h,
  l.clinical_status_72h,
  l.n_daily_outcome_rows_in_outcome_window,
  l.n_sustained_improvement_days_in_outcome_window,

  1 AS predictors_from_current_window,
  COALESCE(l.outcome_from_next_window, 0) AS outcome_from_next_window
FROM base b
LEFT JOIN features f
  ON b.stay_id = f.stay_id
 AND b.window_idx = f.window_idx
LEFT JOIN severity sev
  ON b.stay_id = sev.stay_id
 AND b.window_idx = sev.window_idx
LEFT JOIN labels l
  ON b.stay_id = l.stay_id
 AND b.window_idx = l.window_idx
LEFT JOIN `strange-math-456415-c3.mimic_analysis.antibiotics_baseline_requested` abx
  ON b.stay_id = abx.stay_id
LEFT JOIN `strange-math-456415-c3.mimic_analysis.demographics_comorbidity_requested` demo
  ON b.stay_id = demo.stay_id
LEFT JOIN `strange-math-456415-c3.mimic_analysis.microbiology_infection_requested` micro
  ON b.stay_id = micro.stay_id
LEFT JOIN `strange-math-456415-c3.mimic_analysis.infection_acquisition_requested` acq
  ON b.stay_id = acq.stay_id
LEFT JOIN `strange-math-456415-c3.mimic_analysis.severity_support_baseline_requested` sev_base
  ON b.stay_id = sev_base.stay_id;
