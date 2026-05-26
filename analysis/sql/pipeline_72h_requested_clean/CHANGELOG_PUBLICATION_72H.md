# CHANGELOG_PUBLICATION_72H

## Resumen

Se reorienta el pipeline hacia una cohorte analitica longitudinal en UCI con ventanas no solapadas de 72 horas y outcome ordinal desplazado. La unidad de analisis final es:

```text
stay_id + window_idx
```

`window_idx` es base cero:

- `0`: T0 a T0 + 72h
- `1`: T0 + 72h a T0 + 144h
- `2`: T0 + 144h a T0 + 216h

## Scripts Modificados

- `02_windows/02_01_base_windows_72h_requested.sql`
- `04_daily_features/04_01_window_features_72h_requested.sql`
- `04_daily_features/04_02_window_severity_support_72h_requested.sql`
- `06_outcome/06_03_clinical_improvement_72h_window_labels_requested.sql`
- `07_final_table/07_01_longitudinal_72h_model_dataset_requested.sql`
- `99_qc/01_qc_duplicates_stay_day.sql`
- `99_qc/02_qc_counts.sql`
- `99_qc/03_qc_label_distribution.sql`
- `99_qc/04_qc_missingness.sql`
- `99_qc/05_qc_allowed_columns.sql`
- `99_qc/06_qc_readiness_status.sql`
- `99_qc/07_qc_prior_antibiotics_before_start.sql`
- `RUN_ORDER_REQUESTED.md`

## Tablas Generadas Por Script

| Script | Tabla principal |
| --- | --- |
| `02_01_base_windows_72h_requested.sql` | `base_windows_72h_requested` |
| `04_01_window_features_72h_requested.sql` | `window_features_72h_requested` |
| `04_02_window_severity_support_72h_requested.sql` | `window_severity_support_72h_requested` |
| `06_03_clinical_improvement_72h_window_labels_requested.sql` | `clinical_status_72h_window_labels_requested` |
| `06_03_clinical_improvement_72h_window_labels_requested.sql` | `clinical_improvement_72h_window_labels_requested` como alias compatible |
| `07_01_longitudinal_72h_model_dataset_requested.sql` | `longitudinal_72h_dataset_requested` |
| `07_01_longitudinal_72h_model_dataset_requested.sql` | `analytical_dataset_72h_requested` como alias analitico |
| `07_01_longitudinal_72h_model_dataset_requested.sql` | `longitudinal_72h_model_dataset_requested` como alias compatible |

## Definicion De clinical_status_72h

`clinical_status_72h` es un outcome ordinal longitudinal de tres clases observado dentro de cada ventana de 72 horas:

1. `death`
2. `no_improvement`
3. `improvement`

Regla implementada:

- `death`: muerte dentro de `[window_start, window_end)`.
- `improvement`: al menos un dia con `sustained_improvement = 1` dentro de la ventana, si no hay muerte en esa ventana.
- `no_improvement`: no cumple muerte ni mejoria sostenida dentro de la ventana.

Los componentes diarios usados para construir el outcome permanecen en tablas intermedias y QC, no como variables analiticas principales.

## Definicion De clinical_status_72h_next

`clinical_status_72h_next` es el estado clinico de la siguiente ventana de 72 horas dentro del mismo `stay_id`:

```sql
LEAD(clinical_status_72h) OVER (PARTITION BY stay_id ORDER BY window_idx)
```

Esto permite analizar:

```text
clinical_status_72h_next ~ variables_window_t + baseline_variables + (1 | stay_id)
```

El modelo no se implementa en esta fase.

## Variables Basales

Numericas:

- `age`
- `charlson_index`
- `SAPS`
- `n_abx_at_start`
- `spectrum_level_at_start`

Binarias:

- `comorb_myocardial_infarct_bin`
- `comorb_congestive_heart_failure_bin`
- `comorb_peripheral_vascular_disease_bin`
- `comorb_cerebrovascular_disease_bin`
- `comorb_dementia_bin`
- `comorb_chronic_pulmonary_disease_bin`
- `comorb_rheumatic_disease_bin`
- `comorb_peptic_ulcer_disease_bin`
- `comorb_mild_liver_disease_bin`
- `comorb_diabetes_without_cc_bin`
- `comorb_diabetes_with_cc_bin`
- `comorb_paraplegia_bin`
- `comorb_renal_disease_bin`
- `comorb_malignant_cancer_bin`
- `comorb_severe_liver_disease_bin`
- `comorb_metastatic_solid_tumor_bin`
- `comorb_aids_bin`
- `bacteremia`
- `polymicrobial_infection`
- `has_broad_at_start`
- `has_gp_resistant_at_start`
- `has_gn_mdr_at_start`
- `prior_antibiotics_before_start`

Categoricas:

- `sex`
- `race`
- `insurance`
- `microorganism`
- `infection_site`
- `infection_acquisition_type`

## Variables Dinamicas Por Ventana

- `window_idx`
- `n_abx_window`
- `spectrum_level_window`
- `HR_median_window`
- `MAP_median_window`
- `RR_median_window`
- `SpO2_median_window`
- `Temp_median_window`
- `WBC_median_window`
- `Lactate_median_window`
- `Creatinine_median_window`
- `Bilirubin_median_window`
- `FiO2_median_window`
- `PaO2_FiO2_median_window`
- `mechanical_ventilation_window`
- `vasopressors_window`

## Variables Solo QC / Internas Del Outcome

No se incluyen como variables analiticas principales:

- `improved_today`
- `sustained_improvement`
- `n_domains_ok`
- `no_new_foci_flag`
- `radiology_stable_flag`
- `clinical_improvement_72h` binaria legacy

La tabla final conserva algunas variables con prefijo `qc_` para auditar disponibilidad de mediciones y agregacion, no para usarlas como covariables principales.

## QC Implementado

Los scripts de `99_qc` comprueban:

- numero de filas finales
- numero de `stay_id` unicos
- duplicados por `stay_id + window_idx`
- distribucion de `window_idx`
- distribucion de `clinical_status_72h`
- distribucion de `clinical_status_72h_next`
- filas sin siguiente ventana/status
- filas validas para analisis con `clinical_status_72h_next` no nulo
- coherencia temporal `window_start < window_end`
- coherencia del desplazamiento `next_window_idx = window_idx + 1`
- missingness por variable principal

## Dudas Metodologicas Pendientes

- Validar si `PaO2_FiO2_median_window` puede aceptarse usando el proxy disponible `spo2fio2_ratio`, o si debe reconstruirse con PaO2/FiO2 directamente.
- Confirmar si `n_abx_window` y `spectrum_level_window` deben basarse solo en el regimen con intervalos disponibles actualmente o reconstruirse desde prescripciones completas longitudinales.
- Definir si las ventanas parciales al final del seguimiento deben excluirse de todos los analisis o solo marcarse con flags de disponibilidad.
- Validar la jerarquia exacta del outcome cuando mejora y muerte ocurren en la misma ventana; actualmente muerte tiene prioridad.
- Definir reglas clinicas para MDR/fenotipo de resistencia, source control y adecuacion empirica antes de incorporarlas.
- Decidir si la categoria `death` debe ser tratada como peor estado ordinal estricto en todos los analisis o modelarse como evento competitivo en analisis secundarios.
