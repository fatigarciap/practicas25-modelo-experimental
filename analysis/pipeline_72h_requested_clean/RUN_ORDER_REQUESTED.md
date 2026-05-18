# RUN_ORDER_REQUESTED

No modificar `analysis/pipeline_final/`. Ejecutar solo scripts en `analysis/pipeline_requested_variables/`.

## Orden

1. `00_cohort/00_01_episode_candidates_requested.sql`
2. `00_cohort/00_02_antibiogram_detail_requested.sql`
3. `00_cohort/00_03_index_stay_requested.sql`
4. `01_antibiotics_t0/01_01_abx_spectrum_map_requested.sql`
5. `01_antibiotics_t0/01_02_t0_true_requested.sql`
6. `01_antibiotics_t0/01_03_baseline_regimen_detail_requested.sql`
7. `01_antibiotics_t0/01_04_baseline_regimen_summary_requested.sql`
8. `02_windows/02_01_base_windows_requested.sql`
9. `03_events_outcome_only/03_01_radiology_worsening_events_requested.sql`
10. `03_events_outcome_only/03_02_radiology_flag_requested.sql`
11. `03_events_outcome_only/03_03_new_foci_events_requested.sql`
12. `03_events_outcome_only/03_04_new_foci_flag_requested.sql`
13. `04_daily_features/04_01_daily_features_requested.sql`
14. `04_daily_features/04_02_daily_severity_support_requested.sql`
15. `05_baseline_predictors/05_01_demographics_comorbidity_requested.sql`
16. `05_baseline_predictors/05_02_microbiology_infection_requested.sql`
17. `05_baseline_predictors/05_03_antibiotics_baseline_requested.sql`
18. `05_baseline_predictors/05_04_infection_acquisition_requested.sql`
19. `05_baseline_predictors/05_06_severity_support_baseline_requested.sql`
20. `05_baseline_predictors/05_07_respiratory_t0_requested.sql`
21. `06_outcome/06_01_clinical_domains_sci_requested.sql`
22. `06_outcome/06_02_improvement_flags_requested.sql`
23. `06_outcome/06_03_clinical_improvement_72h_labels_requested.sql`
24. `07_final_table/07_01_longitudinal_model_dataset_requested_variables.sql`

## QC Despues De Crear La Tabla Final

1. `99_qc/01_qc_duplicates_stay_day.sql`
2. `99_qc/02_qc_counts.sql`
3. `99_qc/03_qc_label_distribution.sql`
4. `99_qc/04_qc_missingness.sql`
5. `99_qc/05_qc_allowed_columns.sql`
6. `99_qc/06_qc_readiness_status.sql`
7. `99_qc/07_qc_prior_antibiotics_before_start.sql`

`99_qc/00_schema_inventory_requested.sql` ya es un inventario previo y puede ejecutarse cuando cambien fuentes/esquemas.

## Notas

- Los scripts de cohorte/T0 crean tablas `_requested` a partir de tablas legacy verificadas, sin cambiar criterios.
- T0 se conserva como primer inicio de antibiotico sistemico mapeado desde ingreso hospitalario hasta `LEAST(index_charttime + INTERVAL 48 HOUR, icu_outtime)`.
- Outcome y mejoria clinica se conservan sin cambios.
- La tabla final incluye solo variables model-ready o proxies aceptados en la primera version productiva.
- `prior_antibiotics_before_start` requiere QC especifico porque conceptualmente deberia ser 0 o casi 0 bajo la definicion actual de T0.
- `05_baseline_predictors/05_05_source_control_requested.md` es documentacion, no SQL ejecutable.
