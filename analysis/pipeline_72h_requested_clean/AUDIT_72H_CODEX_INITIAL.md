# AUDIT_72H_CODEX_INITIAL

## A) Resumen ejecutivo

La carpeta `analysis/pipeline_72h_requested_clean` es una copia diaria, no una version 72h real todavia.
La granularidad actual sigue siendo `stay_id + day_idx`; no aparece `window_idx`.
`T0` esta documentado como primer inicio de antibiotico sistemico mapeado, y se conserva desde tablas legacy.
`02_windows` copia `bloque_1_base_windows_clean`, por tanto hereda ventanas diarias.
`04_daily_features` y `04_02_daily_severity_support` agregan predictores en la misma ventana diaria.
`06_outcome` copia outcomes diarios/72h ya existentes por `day_idx`.
`07_final_table` une predictores dinamicos y outcome por el mismo `stay_id + day_idx`, lo cual no cumple la regla anti-leakage X -> X+1.
Para MVP 72h hay que reconstruir ventanas no solapadas `window_idx`, agregar predictores por ventana X, y etiquetar outcome en ventana X+1.
Conviene dejar fuera hoy radiologia/focos/source control/MDR/adecuacion empirica/RRT/dosis norepi-equivalente.
El MVP puede hacerse con cohorte/T0/basales + features 72h + outcome desplazado + QC adaptado.

## B) Tabla de scripts

| script | tabla generada | input principal | nivel actual | decision recomendada | motivo breve |
|---|---|---|---|---|---|
| `00_01_episode_candidates_requested.sql` | `episode_candidates_requested` | `bloque_0_episode_candidates_clean` | evento | conservar | Copia cohorte candidata legacy. |
| `00_02_antibiogram_detail_requested.sql` | `antibiogram_detail_requested` | `bloque_0_antibiogram_detail_clean` | evento | revisar | Util solo si se usa antibiograma/MDR/adecuacion; no MVP. |
| `00_03_index_stay_requested.sql` | `index_stay_requested` | `bloque_0b_index_stay_clean` | evento | conservar | Define episodio indice por stay. |
| `01_01_abx_spectrum_map_requested.sql` | `abx_spectrum_map_requested` | `abx_spectrum_map_clean` | basal | conservar | Necesario para antibioticos T0/prior. |
| `01_02_t0_true_requested.sql` | `t0_true_requested` | `bloque_t0_true` | basal | conservar | T0 central del pipeline. |
| `01_03_baseline_regimen_detail_requested.sql` | `baseline_regimen_detail_requested` | `baseline_regimen_detail_clean` | basal | revisar | Detalle util, pero MVP usa summary. |
| `01_04_baseline_regimen_summary_requested.sql` | `baseline_regimen_summary_requested` | `baseline_regimen_summary_clean` | basal | conservar | Predictores antibiotico inicial. |
| `02_01_base_windows_requested.sql` | `base_windows_requested` | `bloque_1_base_windows_clean` | diario | adaptar | Copia `day_idx`; debe crear `window_idx` 72h. |
| `03_01_radiology_worsening_events_requested.sql` | `radiology_worsening_events_requested` | `radiology_worsening_events_clean` | evento | dejar fuera | Outcome auxiliar/metodologia dudosa para MVP. |
| `03_02_radiology_flag_requested.sql` | `radiology_flag_requested` | `radiology_flag_clean` | diario | dejar fuera | Flag diario interno del outcome. |
| `03_03_new_foci_events_requested.sql` | `new_foci_events_requested` | `new_foci_events_clean` | evento | dejar fuera | Evento outcome/foco nuevo; no predictor MVP. |
| `03_04_new_foci_flag_requested.sql` | `new_foci_flag_requested` | `new_foci_flag_clean` | diario | dejar fuera | Flag interno del outcome. |
| `04_01_daily_features_requested.sql` | `daily_features_requested` | `daily_features_clean` | diario | adaptar | Debe agregarse a ventanas 72h. |
| `04_02_daily_severity_support_requested.sql` | `daily_severity_support_requested` | `base_windows_requested`, SOFA, ventilation, vasoactive | diario | adaptar | Debe usar `window_idx` y agregacion 72h. |
| `05_01_demographics_comorbidity_requested.sql` | `demographics_comorbidity_requested` | `t0_true_requested`, patients/admissions/charlson | basal | conservar | Basal estable por stay. |
| `05_02_microbiology_infection_requested.sql` | `microbiology_infection_requested` | `index_stay_requested` | basal/evento | conservar | Microorganismo y proxies simples. |
| `05_03_antibiotics_baseline_requested.sql` | `antibiotics_baseline_requested` | `t0_true_requested`, prescriptions, abx map, regimen summary | basal | conservar | Basal; QC importante para prior abx. |
| `05_04_infection_acquisition_requested.sql` | `infection_acquisition_requested` | `t0_true_requested`, admissions | basal | conservar | Proxy basal por tiempos. |
| `05_06_severity_support_baseline_requested.sql` | `severity_support_baseline_requested` | `t0_true_requested`, sapsii | basal | revisar | SAPS puede usar informacion ICU amplia; aceptar solo si definido como basal. |
| `05_07_respiratory_t0_requested.sql` | `respiratory_t0_requested` | `base_windows_requested`, `daily_features_requested`, SOFA | basal/proxy | revisar | Usa `day_idx=0`; para 72h debe redefinirse o excluirse del MVP. |
| `06_01_clinical_domains_sci_requested.sql` | `clinical_domains_sci_requested` | `clinical_domains_sci_clean` | diario/outcome | dejar fuera | Dominios internos del outcome. |
| `06_02_improvement_flags_requested.sql` | `improvement_flags_requested` | `improvement_flags_clean` | diario/outcome | dejar fuera | Flags internos del outcome. |
| `06_03_clinical_improvement_72h_labels_requested.sql` | `clinical_improvement_72h_labels_requested` | `clinical_improvement_72h_labels_clean` | diario/outcome | adaptar | Debe etiquetar ventana X+1, no mismo `day_idx`. |
| `07_01_longitudinal_model_dataset_requested_variables.sql` | `longitudinal_model_dataset_requested_variables` | ventanas, labels, basales, daily, severity | final | adaptar | Join actual por mismo `day_idx` genera riesgo leakage. |
| `99_qc/00_schema_inventory_requested.sql` | ninguna | INFORMATION_SCHEMA | QC | adaptar | Anadir tablas/columnas 72h. |
| `99_qc/01_qc_duplicates_stay_day.sql` | ninguna | final dataset | QC | adaptar | Debe ser duplicates `stay_id + window_idx`. |
| `99_qc/02_qc_counts.sql` | ninguna | final dataset | QC | adaptar | Min/max `window_idx`. |
| `99_qc/03_qc_label_distribution.sql` | ninguna | final dataset | QC | conservar/adaptar | Cambiar tabla/label si se renombra. |
| `99_qc/04_qc_missingness.sql` | ninguna | final dataset | QC | adaptar | Cambiar `day_idx` por `window_idx` y columnas finales. |
| `99_qc/05_qc_allowed_columns.sql` | ninguna | INFORMATION_SCHEMA | QC | adaptar | Lista permitida actual es diaria. |
| `99_qc/06_qc_readiness_status.sql` | ninguna | CTE manual | QC | adaptar | Documenta `day_idx`; actualizar a 72h. |
| `99_qc/07_qc_prior_antibiotics_before_start.sql` | ninguna | final dataset | QC | conservar/adaptar | Util, pero contra nueva tabla final. |

## C) Riesgos de leakage detectados

El riesgo principal esta en `07_final_table`: une `daily_features_requested` y `daily_severity_support_requested` con `clinical_improvement_72h_labels_requested` usando el mismo `stay_id + day_idx`. Eso permite que predictores medidos en la ventana X se usen para outcome asociado a esa misma fila, no claramente para X+1.

En `04_daily_features` y `04_02_daily_severity_support`, las variables dinamicas se calculan dentro de `window_start/window_end` de la misma fila. Eso esta bien como medicion de ventana X, pero solo si en la tabla final se desplazan contra el outcome de X+1.

En `06_outcome`, los scripts copian labels/flags diarios ya hechos; no reconstruyen una etiqueta por ventanas 72h no solapadas. Ademas `06_01` y `06_02` contienen dominios/flags internos que estan bien excluidos del final, pero no deberian entrar como predictores.

En `02_windows`, el riesgo no es leakage directo sino herencia metodologica: copia ventanas diarias desde `bloque_1_base_windows_clean`, no crea ventanas 72h `T0 + 72h * n`.

## D) Definicion de T0 encontrada y dudas

T0 esta definido en docs como "primer inicio de antibiotico sistemico mapeado desde ingreso hospitalario hasta `LEAST(index_charttime + INTERVAL 48 HOUR, icu_outtime)`". Aparece en `RUN_ORDER_REQUESTED.md` y `VARIABLE_TRACEABILITY_REQUESTED.md`.

Operativamente, `01_02_t0_true_requested.sql` solo copia `true_t0` desde `bloque_t0_true`; no recalcula T0. `02_01_base_windows_requested.sql` copia `t0` desde `bloque_1_base_windows_clean`.

Duda clave: para el pipeline 72h, T0 esta claro como ancla, pero no esta implementada la creacion de ventanas 72h desde T0 en esta carpeta.

## E) Propuesta de pipeline minimo viable 72h

1. `00_03_index_stay_requested.sql`
2. `01_01_abx_spectrum_map_requested.sql`
3. `01_02_t0_true_requested.sql`
4. `01_04_baseline_regimen_summary_requested.sql`
5. `02_01_base_windows_requested.sql`, adaptado a `base_windows_72h_requested` con `window_idx`, `window_start`, `window_end`.
6. `04_01_daily_features_requested.sql`, adaptado a agregados 72h por `stay_id + window_idx`.
7. `04_02_daily_severity_support_requested.sql`, adaptado a soporte/severidad 72h por `stay_id + window_idx`.
8. `05_01`, `05_02`, `05_03`, `05_04` como basales.
9. Opcional/revisar: `05_06` SAPS y `05_07` respiratorio T0.
10. `06_03`, adaptado a outcome de ventana siguiente: predictores X -> label X+1.
11. `07_01`, adaptado a final `stay_id + window_idx`.
12. QC adaptados a `window_idx`.

## F) Lista de cambios minimos recomendados

Renombrar conceptualmente tablas y scripts clave a version 72h: `base_windows_72h_requested`, `window_features_72h_requested`, `window_severity_support_72h_requested`, `clinical_improvement_72h_window_labels_requested`, `longitudinal_72h_model_dataset_requested`.

Cambiar toda granularidad final de `day_idx` a `window_idx`.

Crear ventanas no solapadas desde `t0`: `window_idx=1` para `[T0, T0+72h)`, `window_idx=2` para `[T0+72h, T0+144h)`, hasta ~10 ventanas o 30 dias/follow-up.

Agregar variables dinamicas dentro de ventana X, pero unirlas al outcome de X+1 en la tabla final.

Excluir de MVP los scripts `03_*`, `06_01`, `06_02`, `05_05_source_control_requested.md`, MDR, source control, empiric adequate, RRT, dosis norepi-equivalente.

Actualizar QC de duplicados, counts, missingness y allowed columns para `stay_id + window_idx`.

No tocar `analysis/pipeline_final` ni `analysis/pipeline_requested_variables`; todo esto aplica solo a la carpeta auditada cuando se pase de auditoria a cambios.
