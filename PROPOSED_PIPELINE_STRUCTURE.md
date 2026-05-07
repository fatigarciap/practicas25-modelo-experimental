# PROPOSED_PIPELINE_STRUCTURE

## Carpeta nueva propuesta

La nueva version debe vivir en paralelo a `analysis/pipeline_final/`:

```text
analysis/pipeline_requested_variables/
  00_cohort/
  01_antibiotics_t0/
  02_windows/
  03_events_outcome_only/
  04_daily_features/
  05_baseline_predictors/
  06_outcome/
  07_final_table/
  99_qc/
```

`analysis/pipeline_final/` queda como legado intacto. No se crean scripts SQL finales todavia.

## Estructura recomendada detallada

```text
analysis/pipeline_requested_variables/
  00_cohort/
    00_01_episode_candidates_clean.sql
    00_02_antibiogram_detail_clean.sql
    00_03_index_stay_clean.sql
    00_04_microbiology_infection_features_requested.sql
    00_05_resistance_phenotype_requested.sql

  01_antibiotics_t0/
    01_01_abx_spectrum_map_clean.sql
    01_02_t0_true.sql
    01_03_baseline_regimen_detail_clean.sql
    01_04_baseline_regimen_summary_clean.sql
    01_05_antibiotic_requested_features.sql

  02_windows/
    02_01_base_windows_clean.sql

  03_events_outcome_only/
    03_01_radiology_worsening_events_clean.sql
    03_02_radiology_flag_clean.sql
    03_03_new_foci_events_clean.sql
    03_04_new_foci_flag_clean.sql

  04_daily_features/
    04_01_daily_features_clean.sql
    04_02_daily_severity_support_requested.sql

  05_baseline_predictors/
    05_01_demographics_comorbidity_requested.sql
    05_02_microbiology_infection_requested.sql
    05_03_antibiotics_baseline_requested.sql
    05_04_infection_acquisition_requested.sql
    05_05_source_control_requested.sql
    05_06_severity_support_baseline_requested.sql
    05_07_respiratory_t0_requested.sql
    05_08_first_value_post_t0_optional.sql

  06_outcome/
    06_01_clinical_domains_sci_clean.sql
    06_02_improvement_flags_clean.sql
    06_03_clinical_improvement_72h_labels_clean.sql

  07_final_table/
    07_01_longitudinal_model_dataset_requested_variables.sql

  99_qc/
    99_01_qc_t0_definition.sql
    99_02_qc_label_distribution.sql
    99_03_qc_final_counts.sql
    99_04_qc_duplicates_stay_day.sql
    99_05_qc_missingness_requested_variables.sql
    99_06_qc_allowed_columns.sql
    99_07_qc_variable_readiness_status.sql
```

`05_08_first_value_post_t0_optional.sql` es opcional y no recomendado para la tabla principal. Solo aplica si el equipo decide construir opcion B como variables basales por `stay_id`.

## Reglas invariantes

- No cambiar cohorte inicial.
- No cambiar T0.
- No cambiar `clinical_improvement_72h`.
- No cambiar la definicion de mejoria clinica.
- No usar `APACHE_II`; usar SAPS/SAPSII solo con fuente validada.
- No usar `SELECT *` en la tabla final.
- No incluir variables fuera de la lista cerrada.
- No incluir variables internas del outcome.
- No rellenar variables complejas con `CAST(NULL AS ...)` como si fueran model-ready.

## Tabla final propuesta

Nombre:

`strange-math-456415-c3.mimic_analysis.longitudinal_model_dataset_requested_variables`

Granularidad:

`stay_id + day_idx`

Debe incluir:

- identificadores necesarios;
- variables temporales necesarias;
- `clinical_improvement_72h`;
- `has_full_72h_label_window`;
- variables finales permitidas con estado `implemented`;
- variables `implemented_proxy` solo si el equipo acepta explicitamente el proxy.

No debe incluir variables `pending_clinical_codelist`, `pending_source_mapping` o `not_model_ready` en version productiva hasta resolver validacion.

No debe incluir:

- `improved_today`
- `sustained_improvement`
- `n_domains_ok`
- `temp_in_range`
- `wbc_normalizing`
- `hemo_stable`
- `lactate_normalizing`
- `resp_improving`
- `no_new_foci_flag`
- `radiology_stable_flag`

## Variables clinicas/laboratorio post-T0

### Opcion A recomendada: diarias longitudinales

`HR_post_t0`, `MAP_post_t0`, `RR_post_t0`, `SpO2_post_t0`, `Temp_post_t0`, `WBC_post_t0`, `Lactate_post_t0`, `Creatinine_post_t0`, `Bilirubin_post_t0` son medianas diarias en ventanas construidas desde T0 antibiotico.

Granularidad: `stay_id + day_idx`.

Esta es la opcion recomendada porque la unidad final de analisis y el outcome son longitudinales.

### Opcion B alternativa: primer valor tras T0

Construye el primer valor observado tras T0 para cada variable como predictor basal por `stay_id`.

Granularidad: `stay_id`.

No recomendada para la tabla longitudinal principal. Si se implementa, debe estar en `05_baseline_predictors/05_08_first_value_post_t0_optional.sql` y documentarse aparte.

## Readiness de variables complejas

| Variable | Estado | Decision |
|---|---|---|
| `source_control_done` | `pending_clinical_codelist` | No model-ready hasta codelist |
| `source_control_needed` | `pending_clinical_codelist` | No model-ready |
| `time_to_source_control_hours` | `pending_clinical_codelist` | No model-ready |
| `vasopressor_dose_norepi_equiv_at_t0` | `pending_source_mapping` | No model-ready hasta mapear drogas, unidades y equivalencias |
| `renal_replacement_therapy_t0` | `pending_source_mapping` | Implementable solo tras validar fuente |
| `true_clinical_infection_source` | `pending_clinical_codelist` | No model-ready |
| `resistance_phenotype_or_MDR` | `pending_clinical_codelist` | Proxy posible, pero MDR definitivo requiere reglas clinicas |
| `PaO2_FiO2_t0` | `pending_source_mapping` | No model-ready hasta mapear PaO2, FiO2 y ventana temporal |
| `polymicrobial_infection` | `implemented_proxy` | `0 para episodio indice monomicrobiano`; ventana ampliada requiere validacion |

## QC propuesto

Los QC deben vivir en `analysis/pipeline_requested_variables/99_qc/` y cubrir:

- duplicados por `stay_id + day_idx`;
- recuento de filas, estancias y pacientes;
- distribucion de `clinical_improvement_72h`;
- prevalencia positiva;
- missingness por variable final;
- variables finales requeridas ausentes;
- columnas no permitidas coladas en tabla final;
- variables internas del outcome coladas en tabla final;
- resumen por estado `implemented`, `implemented_proxy`, `pending_clinical_codelist`, `pending_source_mapping`, `not_model_ready`.
