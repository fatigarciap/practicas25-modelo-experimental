-- Schema inventory for requested variables pipeline.
-- Purpose: inspect real column availability before generating definitive modeling SQL.
-- Do not modify legacy scripts in analysis/pipeline_final/.

WITH schema_inventory AS (
  SELECT
    'strange-math-456415-c3.mimic_analysis' AS source_dataset,
    table_name,
    column_name,
    data_type,
    ordinal_position
  FROM `strange-math-456415-c3.mimic_analysis.INFORMATION_SCHEMA.COLUMNS`
  WHERE table_name IN (
    'bloque_0_episode_candidates_clean',
    'bloque_0_antibiogram_detail_clean',
    'bloque_0b_index_stay_clean',
    'abx_spectrum_map_clean',
    'bloque_t0_true',
    'baseline_regimen_detail_clean',
    'baseline_regimen_summary_clean',
    'bloque_1_base_windows_clean',
    'daily_features_clean',
    'clinical_domains_sci_clean',
    'improvement_flags_clean',
    'clinical_improvement_72h_labels_clean'
  )

  UNION ALL

  SELECT
    'physionet-data.mimiciv_3_1_hosp' AS source_dataset,
    table_name,
    column_name,
    data_type,
    ordinal_position
  FROM `physionet-data.mimiciv_3_1_hosp.INFORMATION_SCHEMA.COLUMNS`
  WHERE table_name IN (
    'patients',
    'admissions',
    'microbiologyevents',
    'prescriptions',
    'procedures_icd',
    'd_icd_procedures',
    'labevents',
    'd_labitems'
  )

  UNION ALL

  SELECT
    'physionet-data.mimiciv_3_1_icu' AS source_dataset,
    table_name,
    column_name,
    data_type,
    ordinal_position
  FROM `physionet-data.mimiciv_3_1_icu.INFORMATION_SCHEMA.COLUMNS`
  WHERE table_name IN (
    'icustays',
    'chartevents',
    'd_items',
    'inputevents',
    'procedureevents'
  )

  UNION ALL

  SELECT
    'physionet-data.mimiciv_3_1_derived' AS source_dataset,
    table_name,
    column_name,
    data_type,
    ordinal_position
  FROM `physionet-data.mimiciv_3_1_derived.INFORMATION_SCHEMA.COLUMNS`
  WHERE table_name IN (
    'charlson',
    'sapsii',
    'sofa',
    'ventilation',
    'ventilation_status',
    'vasoactive_agent'
  )
)

SELECT
  source_dataset,
  table_name,
  column_name,
  data_type,
  ordinal_position
FROM schema_inventory
ORDER BY
  source_dataset,
  table_name,
  ordinal_position;
