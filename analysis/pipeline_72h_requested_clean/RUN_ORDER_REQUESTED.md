# RUN_ORDER_REQUESTED

Ejecutar solo scripts dentro de `analysis/pipeline_72h_requested_clean/`.

La unidad final del pipeline es `stay_id + window_idx`, con ventanas no solapadas de 72 horas desde T0:

- `window_idx = 0`: T0 a T0 + 72h
- `window_idx = 1`: T0 + 72h a T0 + 144h
- `window_idx = 2`: T0 + 144h a T0 + 216h

## Orden Principal

1. `00_cohort/00_01_episode_candidates_requested.sql`
2. `00_cohort/00_02_antibiogram_detail_requested.sql`
3. `00_cohort/00_03_index_stay_requested.sql`
4. `01_antibiotics_t0/01_01_abx_spectrum_map_requested.sql`
5. `01_antibiotics_t0/01_02_t0_true_requested.sql`
6. `01_antibiotics_t0/01_03_baseline_regimen_detail_requested.sql`
7. `01_antibiotics_t0/01_04_baseline_regimen_summary_requested.sql`
8. `02_windows/02_01_base_windows_requested.sql`
9. `02_windows/02_01_base_windows_72h_requested.sql`
10. `03_events_outcome_only/03_01_radiology_worsening_events_requested.sql`
11. `03_events_outcome_only/03_02_radiology_flag_requested.sql`
12. `03_events_outcome_only/03_03_new_foci_events_requested.sql`
13. `03_events_outcome_only/03_04_new_foci_flag_requested.sql`
14. `04_daily_features/04_01_daily_features_requested.sql`
15. `04_daily_features/04_02_daily_severity_support_requested.sql`
16. `04_daily_features/04_01_window_features_72h_requested.sql`
17. `04_daily_features/04_02_window_severity_support_72h_requested.sql`
18. `05_baseline_predictors/05_01_demographics_comorbidity_requested.sql`
19. `05_baseline_predictors/05_02_microbiology_infection_requested.sql`
20. `05_baseline_predictors/05_03_antibiotics_baseline_requested.sql`
21. `05_baseline_predictors/05_04_infection_acquisition_requested.sql`
22. `05_baseline_predictors/05_06_severity_support_baseline_requested.sql`
23. `05_baseline_predictors/05_07_respiratory_t0_requested.sql`
24. `06_outcome/06_01_clinical_domains_sci_requested.sql`
25. `06_outcome/06_02_improvement_flags_requested.sql`
26. `06_outcome/06_03_clinical_improvement_72h_window_labels_requested.sql`
27. `07_final_table/07_01_longitudinal_72h_model_dataset_requested.sql`

## Tablas Finales

El script final genera:

- `longitudinal_72h_dataset_requested`: tabla analitica longitudinal principal.
- `analytical_dataset_72h_requested`: alias publicacion/analisis.
- `longitudinal_72h_model_dataset_requested`: alias compatible con notebooks antiguos.

La variable de outcome de la ventana actual es `clinical_status_72h`.

La variable desplazada para analisis es `clinical_status_72h_next`, creada como:

```sql
LEAD(clinical_status_72h) OVER (PARTITION BY stay_id ORDER BY window_idx)
```

## Scripts Obsoletos O Legacy

- `06_outcome/06_03_clinical_improvement_72h_labels_requested.sql`: conserva la version diaria/legacy; no usar para la tabla longitudinal 72h final.
- `07_final_table/07_01_longitudinal_model_dataset_requested_variables.sql`: conserva la tabla diaria/legacy; no usar para la tabla longitudinal 72h final.
- `99_qc/01_qc_duplicates_stay_day.sql`: mantiene el nombre historico, pero ahora comprueba duplicados por `stay_id + window_idx`.

## QC Despues De Crear La Tabla Final

1. `99_qc/01_qc_duplicates_stay_day.sql`
2. `99_qc/02_qc_counts.sql`
3. `99_qc/03_qc_label_distribution.sql`
4. `99_qc/04_qc_missingness.sql`
5. `99_qc/05_qc_allowed_columns.sql`
6. `99_qc/06_qc_readiness_status.sql`
7. `99_qc/07_qc_prior_antibiotics_before_start.sql`

`99_qc/00_schema_inventory_requested.sql` es un inventario previo y puede ejecutarse cuando cambien fuentes/esquemas.

## Notas Metodologicas

- No se cambia la logica de cohorte, microorganismos ni T0.
- Las variables dinamicas se calculan dentro de la ventana actual `t`.
- `clinical_status_72h_next` asocia las variables de ventana `t` con el outcome de la ventana `t+1`.
- Los componentes internos del outcome (`improved_today`, `sustained_improvement`, `n_domains_ok`, `no_new_foci_flag`, `radiology_stable_flag`) no se incluyen como variables analiticas principales en la tabla final.
- `PaO2_FiO2_median_window` usa el proxy diario disponible `spo2fio2_ratio`; queda marcado para validacion metodologica.
