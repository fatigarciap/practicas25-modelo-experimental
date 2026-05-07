# RUN_ORDER_REQUESTED

## Principio revisado

`analysis/pipeline_final/` queda como legado intacto. Este run order aplica a la futura carpeta paralela `analysis/pipeline_requested_variables/`. No implica crear scripts todavia ni modificar scripts existentes.

## Orden recomendado

1. `analysis/pipeline_requested_variables/00_cohort/00_01_episode_candidates_clean.sql`
2. `analysis/pipeline_requested_variables/00_cohort/00_02_antibiogram_detail_clean.sql`
3. `analysis/pipeline_requested_variables/00_cohort/00_03_index_stay_clean.sql`
4. `analysis/pipeline_requested_variables/00_cohort/00_04_microbiology_infection_features_requested.sql`
5. `analysis/pipeline_requested_variables/00_cohort/00_05_resistance_phenotype_requested.sql`

Los pasos 1-3 replican la cohorte indice sin modificar criterios. Los pasos 4-5 son predictores/proxies o pendientes, no cambios de cohorte.

6. `analysis/pipeline_requested_variables/01_antibiotics_t0/01_01_abx_spectrum_map_clean.sql`
7. `analysis/pipeline_requested_variables/01_antibiotics_t0/01_02_t0_true.sql`
8. `analysis/pipeline_requested_variables/01_antibiotics_t0/01_03_baseline_regimen_detail_clean.sql`
9. `analysis/pipeline_requested_variables/01_antibiotics_t0/01_04_baseline_regimen_summary_clean.sql`
10. `analysis/pipeline_requested_variables/01_antibiotics_t0/01_05_antibiotic_requested_features.sql`

Estos scripts mantienen T0 como primer inicio de antibiotico sistemico mapeado desde ingreso hospitalario hasta `LEAST(index_charttime + INTERVAL 48 HOUR, icu_outtime)`.

11. `analysis/pipeline_requested_variables/02_windows/02_01_base_windows_clean.sql`

Construye ventanas diarias desde T0 antibiotico con granularidad `stay_id + day_idx`.

12. `analysis/pipeline_requested_variables/03_events_outcome_only/03_01_radiology_worsening_events_clean.sql`
13. `analysis/pipeline_requested_variables/03_events_outcome_only/03_02_radiology_flag_clean.sql`
14. `analysis/pipeline_requested_variables/03_events_outcome_only/03_03_new_foci_events_clean.sql`
15. `analysis/pipeline_requested_variables/03_events_outcome_only/03_04_new_foci_flag_clean.sql`

Estos scripts son solo soporte del outcome. Sus variables internas no entran en la tabla final.

16. `analysis/pipeline_requested_variables/04_daily_features/04_01_daily_features_clean.sql`
17. `analysis/pipeline_requested_variables/04_daily_features/04_02_daily_severity_support_requested.sql`

`04_01` implementa la opcion A recomendada: medianas diarias post-T0 por `stay_id + day_idx`.

18. `analysis/pipeline_requested_variables/05_baseline_predictors/05_01_demographics_comorbidity_requested.sql`
19. `analysis/pipeline_requested_variables/05_baseline_predictors/05_02_microbiology_infection_requested.sql`
20. `analysis/pipeline_requested_variables/05_baseline_predictors/05_03_antibiotics_baseline_requested.sql`
21. `analysis/pipeline_requested_variables/05_baseline_predictors/05_04_infection_acquisition_requested.sql`
22. `analysis/pipeline_requested_variables/05_baseline_predictors/05_05_source_control_requested.sql`
23. `analysis/pipeline_requested_variables/05_baseline_predictors/05_06_severity_support_baseline_requested.sql`
24. `analysis/pipeline_requested_variables/05_baseline_predictors/05_07_respiratory_t0_requested.sql`
25. Opcional: `analysis/pipeline_requested_variables/05_baseline_predictors/05_08_first_value_post_t0_optional.sql`

Los scripts de `05_baseline_predictors/` son por `stay_id`. Las variables `pending_clinical_codelist` o `pending_source_mapping` no deben entrar como model-ready hasta validacion.

26. `analysis/pipeline_requested_variables/06_outcome/06_01_clinical_domains_sci_clean.sql`
27. `analysis/pipeline_requested_variables/06_outcome/06_02_improvement_flags_clean.sql`
28. `analysis/pipeline_requested_variables/06_outcome/06_03_clinical_improvement_72h_labels_clean.sql`

Replican la definicion actual de mejoria clinica y outcome sin cambios.

29. `analysis/pipeline_requested_variables/07_final_table/07_01_longitudinal_model_dataset_requested_variables.sql`

Crea `longitudinal_model_dataset_requested_variables`, granularidad `stay_id + day_idx`, con seleccion explicita, `clinical_improvement_72h`, `has_full_72h_label_window`, y sin variables internas del outcome.

30. `analysis/pipeline_requested_variables/99_qc/99_01_qc_t0_definition.sql`
31. `analysis/pipeline_requested_variables/99_qc/99_02_qc_label_distribution.sql`
32. `analysis/pipeline_requested_variables/99_qc/99_03_qc_final_counts.sql`
33. `analysis/pipeline_requested_variables/99_qc/99_04_qc_duplicates_stay_day.sql`
34. `analysis/pipeline_requested_variables/99_qc/99_05_qc_missingness_requested_variables.sql`
35. `analysis/pipeline_requested_variables/99_qc/99_06_qc_allowed_columns.sql`
36. `analysis/pipeline_requested_variables/99_qc/99_07_qc_variable_readiness_status.sql`

## Fuera del flujo nuevo

Permanecen como legado en `analysis/pipeline_final/` y no se tocan:

- `01_antibiotics_t0/01_05_baseline_regimen_multihot_clean.sql`
- `06_final_table/06_01_longitudinal_cohort_model_ready.sql`
- `06_final_table/06_02_longitudinal_model_ready_predictive_72h.sql`
- `06_final_table/06_03_longitudinal_model_ready_predictive_72h_clean.sql`

## Decision post-T0

Recomendada: opcion A, medianas diarias longitudinales desde `daily_features_clean` por `stay_id + day_idx`.

Alternativa no principal: opcion B, primer valor tras T0 por `stay_id`, con script opcional y documentacion separada.
