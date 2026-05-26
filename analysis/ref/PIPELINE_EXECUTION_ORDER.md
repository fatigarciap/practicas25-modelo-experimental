# PIPELINE_EXECUTION_ORDER

## Objetivo

Este documento define el orden reproducible de ejecución del pipeline SQL oficial del proyecto longitudinal AMR days 72h.

El pipeline oficial vive en `analysis/sql/pipeline_72h_requested_clean/`. Los scripts legacy archivados en `archive_old_sql/` se conservan por trazabilidad histórica, pero no forman parte del pipeline oficial actual. El resultado principal del pipeline es el dataset longitudinal 72h y la tabla model-ready final. La Tabla 1 es un output descriptivo derivado.

## Reglas generales de ejecución

- Ejecutar scripts en orden secuencial.
- No ejecutar scripts de `archive_old_sql/` salvo auditoría histórica.
- No mezclar pipeline legacy diario con pipeline 72h.
- No modificar una tabla final sin ejecutar su QC correspondiente.
- Mantener el alineamiento temporal X(t) -> Y(t+1).
- No usar variables internas de construcción del outcome como predictores.
- Documentar cualquier cambio de schema antes de usarlo en modelado.

## Orden general del pipeline

| Orden | Bloque/script | Output principal | Propósito |
|---:|---|---|---|
| 1 | `00_cohort/` | Cohortes y candidatos iniciales | Selección inicial de estancias/candidatos microbiológicos |
| 2 | `01_antibiotics_t0/` | Definición de exposición antibiótica inicial y T0 | Anclar seguimiento clínico/terapéutico |
| 3 | `02_windows/` | `base_windows_72h_requested` | Construir ventanas consecutivas no solapadas de 72h |
| 4 | `03_events_outcome_only/` | Eventos clínicos usados para outcome | Identificar eventos clínicos relevantes dentro de ventanas |
| 5 | `04_daily_features/` | `window_features_72h_requested`, `window_severity_support_72h_requested` | Construir variables dinámicas de ventana |
| 6 | `05_baseline_predictors/` | `demographics_comorbidity_requested`, `microbiology_infection_requested`, `antibiotics_baseline_requested`, `infection_acquisition_requested`, `severity_support_baseline_requested` | Construir predictores basales |
| 7 | `06_outcome/` | `clinical_status_72h_window_labels_requested` | Construir estado clínico por ventana y outcome desplazado |
| 8 | `07_final_table/01_longitudinal_72h_dataset_requested_FINAL.sql` | `longitudinal_72h_dataset_requested` | Ensamblar dataset longitudinal completo |
| 9 | `07_final_table/02_longitudinal_72h_model_ready_final.sql` | `longitudinal_72h_model_ready_final` | Crear tabla final model-ready |
| 10 | `07_final_table/03_qc_model_ready_final.sql` | Resultados QC | Validar tabla model-ready |

## Orden de ejecución de Tabla 1

| Orden | Script | Output | Propósito |
|---:|---|---|---|
| 1 | `08_publ/02_table1/01_table1_baseline_stay_level_72h.sql` | `table1_baseline_stay_level_72h` | Base basal una fila por `stay_id`, `window_idx = 0` |
| 2 | `08_publ/02_table1/02_table1_continuous_72h.sql` | `table1_continuous_72h` | Resumir variables continuas como mediana [RIQ] |
| 3 | `08_publ/02_table1/03_table1_binary_72h.sql` | `table1_binary_72h` | Resumir variables binarias como n (%) |
| 4 | `08_publ/02_table1/04_table1_multicategory_72h.sql` | `table1_multicategory_72h` | Resumir variables multicategoría como n (%) por categoría |
| 5 | `08_publ/02_table1/05_table1_final_pivot_72h.sql` | `table1_stratified_72h_summary` | Construir Tabla 1 final estratificada |
| 6 | `08_publ/02_table1/06_qc_table1_72h.sql` | Resultados QC | Validar Tabla 1 |

## Tablas oficiales finales

| Tabla | Tipo | Uso |
|---|---|---|
| `longitudinal_72h_dataset_requested` | Longitudinal completa | Auditoría y trazabilidad del dataset longitudinal |
| `longitudinal_72h_model_ready_final` | Model-ready | Análisis y modelado |
| `table1_baseline_stay_level_72h` | Base descriptiva | Una fila por `stay_id` para descriptivos basales |
| `table1_stratified_72h_summary` | Tabla descriptiva final | Tabla 1 final estratificada |

## Tablas legacy/no oficiales

Las siguientes tablas o aliases pueden existir por compatibilidad histórica, pero no son tablas oficiales del análisis actual:

- `analytical_dataset_72h_requested`;
- `longitudinal_72h_model_dataset_requested`;
- `longitudinal_model_dataset_requested_variables`.

`longitudinal_model_dataset_requested_variables` procede del pipeline legacy diario y está archivada.

## Scripts legacy archivados

Los siguientes scripts están archivados en `analysis/sql/pipeline_72h_requested_clean/archive_old_sql/` y no forman parte del orden oficial de ejecución:

- `02_table1_continuous.sql`;
- `03_table1_biary.sql`;
- `04_table1_multicategory.sql`;
- `05_table1_final_pivot.sql`;
- `07_01_longitudinal_model_dataset_requested_variables.sql`.

## QC obligatorios

| Momento | QC | Objetivo |
|---|---|---|
| Después de tabla longitudinal | Duplicados por `stay_id + window_idx`, conteos, distribución outcome | Verificar unicidad longitudinal, tamaño de cohorte y coherencia del outcome |
| Después de model-ready | Columnas esperadas, missingness, outcome válido | Verificar que la tabla final es apta para análisis/modelado |
| Después de Tabla 1 | n basal, distribución outcome, duplicados por `stay_id`, `window_idx = 0`, pivot sin filas vacías | Verificar coherencia de la tabla descriptiva basal |

## Relación con documentos Quarto

| Documento | Contenido |
|---|---|
| `analysis/01_dataset.qmd` | Dataset, cohorte, T0, ventanas, outcome, QC |
| `analysis/02_tables.qmd` | Tabla 1, descriptivos, CONSORT |
| `analysis/03_model.qmd` | Preprocessing, splits, modelado |
| `analysis/04_figures.qmd` | Figuras finales |

## Notas de seguridad metodológica

- No usar `clinical_status_72h` actual como outcome del mismo intervalo para modelar.
- No usar variables derivadas directamente del outcome como predictores.
- Mantener splits agrupados por `stay_id` o `subject_id` en modelado.
- Mantener trazabilidad entre SQL, tablas BigQuery y documentos Quarto.
- Si se modifica un script final, actualizar el QC y este documento.
