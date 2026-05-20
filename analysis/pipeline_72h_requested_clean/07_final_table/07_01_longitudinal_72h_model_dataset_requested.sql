-- Final longitudinal 72h analytical dataset.
-- Unit: one row per stay_id + window_idx.
-- Dynamic variables are measured in the current window t.
-- The analytical outcome is clinical_status_72h_next, observed in window t+1.

CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested` AS
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
    window_idx,
    window_start,
    window_end,
    window_hours_observed,
    window_minutes_observed,
    window_seconds_observed,
    has_full_72h_window
  FROM `strange-math-456415-c3.mimic_analysis.base_windows_72h_requested`
),
window_variables AS (
  SELECT
    stay_id,
    window_idx,
    n_abx_window,
    spectrum_level_window,
    HR_median_window,
    MAP_median_window,
    RR_median_window,
    SpO2_median_window,
    Temp_median_window,
    WBC_median_window,
    Lactate_median_window,
    Creatinine_median_window,
    Bilirubin_median_window,
    FiO2_median_window,
    PaO2_FiO2_median_window,
    n_daily_rows_in_window,
    n_days_with_HR,
    n_days_with_MAP,
    n_days_with_Lactate,
    n_days_with_Creatinine,
    n_days_with_spo2fio2
  FROM `strange-math-456415-c3.mimic_analysis.window_features_72h_requested`
),
severity_support_window AS (
  SELECT
    stay_id,
    window_idx,
    SOFA_max_72h,
    SOFA_mean_72h,
    mechanical_ventilation_window,
    vasopressors_window
  FROM `strange-math-456415-c3.mimic_analysis.window_severity_support_72h_requested`
),
labels AS (
  SELECT
    stay_id,
    window_idx,
    clinical_status_72h,
    clinical_status_72h_next,
    next_window_idx,
    next_window_start,
    next_window_end,
    has_next_window,
    next_has_full_72h_window,
    has_valid_next_status
  FROM `strange-math-456415-c3.mimic_analysis.clinical_status_72h_window_labels_requested`
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
  l.next_window_idx,
  l.next_window_start,
  l.next_window_end,
  COALESCE(l.has_next_window, 0) AS has_next_window,
  COALESCE(l.next_has_full_72h_window, 0) AS next_has_full_72h_window,
  COALESCE(l.has_valid_next_status, 0) AS has_valid_next_status,

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
  sev_base.SAPS,
  micro.microorganism,
  micro.infection_site,
  micro.bacteremia,
  micro.polymicrobial_infection,
  acq.infection_acquisition_type,
  abx.n_abx_at_start,
  abx.spectrum_level_at_start,
  abx.has_broad_at_start,
  abx.has_gp_resistant_at_start,
  abx.has_gn_mdr_at_start,
  abx.prior_antibiotics_before_start,

  wv.n_abx_window,
  wv.spectrum_level_window,
  CASE
    WHEN wv.n_abx_window > 0 THEN 1
    ELSE 0
  END AS has_abx_window,
  CASE
    WHEN wv.n_abx_window = 0 THEN 0
    ELSE wv.spectrum_level_window
  END AS spectrum_level_window_filled,
  wv.HR_median_window,
  wv.MAP_median_window,
  wv.RR_median_window,
  wv.SpO2_median_window,
  wv.Temp_median_window,
  wv.WBC_median_window,
  wv.Lactate_median_window,
  wv.Creatinine_median_window,
  wv.Bilirubin_median_window,
  wv.FiO2_median_window,
  wv.PaO2_FiO2_median_window,
  ss.mechanical_ventilation_window,
  ss.vasopressors_window,

  l.clinical_status_72h,
  l.clinical_status_72h_next,

  wv.n_daily_rows_in_window AS qc_n_daily_rows_in_window,
  wv.n_days_with_HR AS qc_n_days_with_HR,
  wv.n_days_with_MAP AS qc_n_days_with_MAP,
  wv.n_days_with_Lactate AS qc_n_days_with_Lactate,
  wv.n_days_with_Creatinine AS qc_n_days_with_Creatinine,
  wv.n_days_with_spo2fio2 AS qc_n_days_with_spo2fio2,
  ss.SOFA_max_72h AS qc_SOFA_max_72h,
  ss.SOFA_mean_72h AS qc_SOFA_mean_72h
FROM base b
LEFT JOIN window_variables wv
  ON b.stay_id = wv.stay_id
 AND b.window_idx = wv.window_idx
LEFT JOIN severity_support_window ss
  ON b.stay_id = ss.stay_id
 AND b.window_idx = ss.window_idx
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

CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.analytical_dataset_72h_requested` AS
SELECT *
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`;

-- Backward-compatible table name for older notebooks/runbooks.
CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.longitudinal_72h_model_dataset_requested` AS
SELECT *
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`;
