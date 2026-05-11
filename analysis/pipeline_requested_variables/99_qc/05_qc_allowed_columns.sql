WITH allowed_columns AS (
  SELECT column_name
  FROM UNNEST([
    'subject_id','hadm_id','stay_id','day_idx','t0','index_charttime',
    'clinical_improvement_72h','has_full_72h_label_window',
    'age','sex','race','insurance',
    'comorb_myocardial_infarct_bin','comorb_congestive_heart_failure_bin',
    'comorb_peripheral_vascular_disease_bin','comorb_cerebrovascular_disease_bin',
    'comorb_dementia_bin','comorb_chronic_pulmonary_disease_bin','comorb_rheumatic_disease_bin','comorb_peptic_ulcer_disease_bin',
    'comorb_mild_liver_disease_bin','comorb_diabetes_without_cc_bin','comorb_diabetes_with_cc_bin','comorb_paraplegia_bin',
    'comorb_renal_disease_bin','comorb_malignant_cancer_bin','comorb_severe_liver_disease_bin','comorb_metastatic_solid_tumor_bin',
    'comorb_aids_bin','charlson_index',
    'microorganism','infection_site','bacteremia','polymicrobial_infection',
    'n_abx_at_start','spectrum_level_at_start','has_broad_at_start','has_gp_resistant_at_start','has_gn_mdr_at_start',
    'prior_antibiotics_before_start','infection_acquisition_type',
    'HR_post_t0','MAP_post_t0','RR_post_t0','SpO2_post_t0','Temp_post_t0','WBC_post_t0','Lactate_post_t0','Creatinine_post_t0','Bilirubin_post_t0',
    'SAPS','SOFA_post_t0','mechanical_ventilation','vasopressors','FiO2_t0','PaO2_FiO2_t0'
  ]) AS column_name
),
actual_columns AS (
  SELECT column_name
  FROM `strange-math-456415-c3.mimic_analysis.INFORMATION_SCHEMA.COLUMNS`
  WHERE table_name = 'longitudinal_model_dataset_requested_variables'
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
