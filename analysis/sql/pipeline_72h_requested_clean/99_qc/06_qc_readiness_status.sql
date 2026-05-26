-- QC/readiness inventory for the publication-oriented 72h longitudinal dataset.

WITH readiness AS (
  SELECT 'implemented' AS status, 'identifiers_and_time' AS variable UNION ALL
  SELECT 'implemented', 'window_idx_zero_based_72h' UNION ALL
  SELECT 'implemented', 'clinical_status_72h' UNION ALL
  SELECT 'implemented', 'clinical_status_72h_next' UNION ALL
  SELECT 'implemented', 'next_window_availability_flags' UNION ALL
  SELECT 'implemented', 'baseline_demographics_comorbidity' UNION ALL
  SELECT 'implemented', 'baseline_antibiotic_summary' UNION ALL
  SELECT 'implemented', 'prior_antibiotics_before_start' UNION ALL
  SELECT 'implemented_proxy', 'infection_site' UNION ALL
  SELECT 'implemented_proxy', 'bacteremia' UNION ALL
  SELECT 'implemented_proxy', 'polymicrobial_infection' UNION ALL
  SELECT 'implemented_proxy', 'infection_acquisition_type' UNION ALL
  SELECT 'implemented', 'dynamic_vitals_labs_window' UNION ALL
  SELECT 'implemented', 'mechanical_ventilation_window' UNION ALL
  SELECT 'implemented', 'vasopressors_window' UNION ALL
  SELECT 'implemented_proxy', 'PaO2_FiO2_median_window_from_daily_spo2fio2_ratio' UNION ALL
  SELECT 'qc_only', 'improved_today' UNION ALL
  SELECT 'qc_only', 'sustained_improvement' UNION ALL
  SELECT 'qc_only', 'n_domains_ok' UNION ALL
  SELECT 'qc_only', 'no_new_foci_flag' UNION ALL
  SELECT 'qc_only', 'radiology_stable_flag' UNION ALL
  SELECT 'pending_clinical_codelist', 'resistance_phenotype_or_MDR' UNION ALL
  SELECT 'pending_clinical_codelist', 'true_clinical_infection_source' UNION ALL
  SELECT 'pending_clinical_codelist', 'source_control_done' UNION ALL
  SELECT 'pending_clinical_codelist', 'source_control_needed' UNION ALL
  SELECT 'pending_clinical_codelist', 'time_to_source_control_hours' UNION ALL
  SELECT 'pending_source_mapping', 'empiric_adequate_at_start' UNION ALL
  SELECT 'pending_source_mapping', 'vasopressor_dose_norepi_equiv_at_t0' UNION ALL
  SELECT 'pending_source_mapping', 'renal_replacement_therapy_t0'
)
SELECT
  status,
  variable
FROM readiness
ORDER BY status, variable;
