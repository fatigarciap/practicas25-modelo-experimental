# Analysis

## Objetivo

Este directorio contiene la construcción, documentación y análisis reproducible del dataset longitudinal AMR days 72h, desarrollado sobre MIMIC-IV v3.1, BigQuery y SQL.

El objetivo es mantener separadas y trazables las fases de construcción del dataset, documentación metodológica, descriptivos, preparación para modelado y figuras finales, siguiendo una estructura compatible con `datascience_template`.

## Estructura del directorio

| Ruta | Contenido |
|---|---|
| `01_dataset.qmd` | Documento metodológico del dataset longitudinal |
| `02_tables.qmd` | Tablas descriptivas, Tabla 1 y CONSORT |
| `03_model.qmd` | Preprocessing, splits y modelado |
| `04_figures.qmd` | Figuras finales |
| `ref/` | Documentación metodológica y diccionarios |
| `sql/` | Pipeline SQL reproducible |
| `tables/` | Outputs tabulares exportados |
| `model/` | Resultados y objetos de modelado |
| `figures/` | Figuras finales |
| `render/` | Outputs renderizados |

## Dataset longitudinal 72h

La unidad de análisis es `stay_id + window_idx`: una fila por estancia UCI y ventana longitudinal de 72 horas desde T0. Los predictores se miden en la ventana actual t y el outcome se mide en la ventana siguiente t+1, manteniendo el alineamiento temporal `X(t) → Y(t+1)`.

La tabla longitudinal oficial es `longitudinal_72h_dataset_requested`. La tabla model-ready oficial es `longitudinal_72h_model_ready_final`.

| Métrica | Valor |
|---|---:|
| Estancias UCI | 4.372 |
| Pacientes | 3.882 |
| Ventanas longitudinales | 19.394 |
| Ventanas válidas para análisis/modelado | 13.070 |

## Tablas oficiales

| Tabla | Uso |
|---|---|
| `longitudinal_72h_dataset_requested` | Dataset longitudinal completo |
| `longitudinal_72h_model_ready_final` | Dataset model-ready |
| `table1_stratified_72h_summary` | Tabla 1 final estratificada |

## Documentación de referencia

| Documento | Uso |
|---|---|
| `ref/DATASET_DICTIONARY.md` | Diccionario de variables |
| `ref/PIPELINE_EXECUTION_ORDER.md` | Orden oficial de ejecución del pipeline |
| `01_dataset.qmd` | Metodología del dataset |
| `02_tables.qmd` | Metodología de descriptivos y Tabla 1 |

## Pipeline SQL oficial

El pipeline SQL oficial vive en `analysis/sql/pipeline_72h_requested_clean/`.

Bloques principales:

- `00_cohort/`;
- `01_antibiotics_t0/`;
- `02_windows/`;
- `03_events_outcome_only/`;
- `04_daily_features/`;
- `05_baseline_predictors/`;
- `06_outcome/`;
- `07_final_table/`;
- `08_publ/`;
- `archive_old_sql/`.

`archive_old_sql/` contiene scripts legacy conservados por trazabilidad, pero no forma parte del pipeline oficial actual.

## Orden recomendado de lectura

1. `01_dataset.qmd`
2. `ref/DATASET_DICTIONARY.md`
3. `ref/PIPELINE_EXECUTION_ORDER.md`
4. `02_tables.qmd`
5. `03_model.qmd`
6. `04_figures.qmd`

## Reglas metodológicas

- Mantener el alineamiento `X(t) → Y(t+1)`.
- No usar outcomes como predictores.
- No usar identificadores como predictores.
- No ejecutar scripts legacy salvo auditoría.
- No modificar tablas finales sin ejecutar QC.
- Mantener separación entre construcción del dataset, descriptivos, modelado y figuras.

## Estado actual

El dataset longitudinal está construido y la tabla model-ready está creada. La Tabla 1 fue reconstruida y validada. El diccionario de variables está creado y el orden de ejecución del pipeline queda documentado.

El próximo bloque de trabajo es la preparación del modelado en `03_model.qmd`.
