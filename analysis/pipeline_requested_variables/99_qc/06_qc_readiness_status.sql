WITH readiness AS (
  SELECT 'implemented' AS status, 'subject_id' AS variable UNION ALL
  SELECT 'implemented', 'hadm_id' UNION ALL
  SELECT 'implemented', 'stay_id' UNION ALL
  SELECT 'implemented', 'day_idx' UNION ALL
  SELECT 'implemented', 't0' UNION ALL
  SELECT 'implemented', 'index_charttime' UNION ALL
  SELECT 'implemented', 'clinical_improvement_72h' UNION ALL
  SELECT 'implemented', 'has_full_72h_label_window' UNION ALL
  SELECT 'implemented', 'age' UNION ALL
  SELECT 'implemented', 'sex' UNION ALL
  SELECT 'implemented', 'race' UNION ALL
  SELECT 'implemented', 'insurance' UNION ALL
  SELECT 'implemented', 'charlson_components_and_index' UNION ALL
  SELECT 'implemented', 'microorganism' UNION ALL
  SELECT 'implemented_proxy', 'infection_site' UNION ALL
  SELECT 'implemented_proxy', 'bacteremia' UNION ALL
  SELECT 'implemented_proxy', 'polymicrobial_infection' UNION ALL
  SELECT 'implemented', 't0_antibiotic_summary' UNION ALL
  SELECT 'implemented', 'prior_antibiotics_before_start' UNION ALL
  SELECT 'implemented_proxy', 'infection_acquisition_type' UNION ALL
  SELECT 'implemented', 'daily_clinical_labs_post_t0' UNION ALL
  SELECT 'implemented', 'SAPS' UNION ALL
  SELECT 'implemented', 'SOFA_post_t0' UNION ALL
  SELECT 'implemented', 'mechanical_ventilation' UNION ALL
  SELECT 'implemented', 'vasopressors' UNION ALL
  SELECT 'implemented_proxy', 'FiO2_t0' UNION ALL
  SELECT 'pending_clinical_codelist', 'resistance_phenotype_or_MDR' UNION ALL
  SELECT 'pending_clinical_codelist', 'true_clinical_infection_source' UNION ALL
  SELECT 'pending_clinical_codelist', 'source_control_done' UNION ALL
  SELECT 'pending_clinical_codelist', 'source_control_needed' UNION ALL
  SELECT 'pending_clinical_codelist', 'time_to_source_control_hours' UNION ALL
  SELECT 'pending_source_mapping', 'empiric_adequate_at_start' UNION ALL
  SELECT 'pending_source_mapping', 'vasopressor_dose_norepi_equiv_at_t0' UNION ALL
  SELECT 'pending_source_mapping', 'renal_replacement_therapy_t0' UNION ALL
  SELECT 'pending_source_mapping', 'PaO2_FiO2_t0'
)
SELECT
  status,
  variable
FROM readiness
ORDER BY status, variable;
