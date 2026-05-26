-- QC allowed columns for the final longitudinal 72h analytical dataset.

WITH allowed_columns AS (
  SELECT column_name
  FROM UNNEST([
    'subject_id','hadm_id','stay_id','microevent_id','t0','index_charttime','icu_intime','icu_outtime','deathtime','followup_end',
    'window_idx','window_start','window_end','window_hours_observed','window_minutes_observed','window_seconds_observed','has_full_72h_window',
    'next_window_idx','next_window_start','next_window_end','has_next_window','next_has_full_72h_window','has_valid_next_status',
    'age','sex','race','insurance','charlson_index','SAPS',
    'comorb_myocardial_infarct_bin','comorb_congestive_heart_failure_bin','comorb_peripheral_vascular_disease_bin','comorb_cerebrovascular_disease_bin',
    'comorb_dementia_bin','comorb_chronic_pulmonary_disease_bin','comorb_rheumatic_disease_bin','comorb_peptic_ulcer_disease_bin',
    'comorb_mild_liver_disease_bin','comorb_diabetes_without_cc_bin','comorb_diabetes_with_cc_bin','comorb_paraplegia_bin',
    'comorb_renal_disease_bin','comorb_malignant_cancer_bin','comorb_severe_liver_disease_bin','comorb_metastatic_solid_tumor_bin','comorb_aids_bin',
    'microorganism','infection_site','bacteremia','polymicrobial_infection','infection_acquisition_type',
    'n_abx_at_start','spectrum_level_at_start','has_broad_at_start','has_gp_resistant_at_start','has_gn_mdr_at_start','prior_antibiotics_before_start',
    'n_abx_window','spectrum_level_window','HR_median_window','MAP_median_window','RR_median_window','SpO2_median_window','Temp_median_window',
    'WBC_median_window','Lactate_median_window','Creatinine_median_window','Bilirubin_median_window','FiO2_median_window','PaO2_FiO2_median_window',
    'mechanical_ventilation_window','vasopressors_window',
    'clinical_status_72h','clinical_status_72h_next',
    'qc_n_daily_rows_in_window','qc_n_days_with_HR','qc_n_days_with_MAP','qc_n_days_with_Lactate','qc_n_days_with_Creatinine','qc_n_days_with_spo2fio2',
    'qc_SOFA_max_72h','qc_SOFA_mean_72h'
  ]) AS column_name
),
actual_columns AS (
  SELECT column_name
  FROM `strange-math-456415-c3.mimic_analysis.INFORMATION_SCHEMA.COLUMNS`
  WHERE table_name = 'longitudinal_72h_dataset_requested'
)
SELECT
  'not_allowed_in_final' AS issue_type,
  a.column_name
FROM actual_columns a
LEFT JOIN allowed_columns ok
  ON a.column_name = ok.column_name
WHERE ok.column_name IS NULL

UNION ALL

SELECT
  'missing_required_column' AS issue_type,
  ok.column_name
FROM allowed_columns ok
LEFT JOIN actual_columns a
  ON ok.column_name = a.column_name
WHERE a.column_name IS NULL;
