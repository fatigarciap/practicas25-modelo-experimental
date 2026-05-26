# PROPOSED_PIPELINE_STRUCTURE

## Carpeta De Trabajo

Trabajar solo en:

```text
analysis/pipeline_requested_variables/
```

No modificar:

```text
analysis/pipeline_final/
```

## Estructura Implementada

```text
analysis/pipeline_requested_variables/
  00_cohort/
    00_01_episode_candidates_requested.sql
    00_02_antibiogram_detail_requested.sql
    00_03_index_stay_requested.sql

  01_antibiotics_t0/
    01_01_abx_spectrum_map_requested.sql
    01_02_t0_true_requested.sql
    01_03_baseline_regimen_detail_requested.sql
    01_04_baseline_regimen_summary_requested.sql

  02_windows/
    02_01_base_windows_requested.sql

  03_events_outcome_only/
    03_01_radiology_worsening_events_requested.sql
    03_02_radiology_flag_requested.sql
    03_03_new_foci_events_requested.sql
    03_04_new_foci_flag_requested.sql

  04_daily_features/
    04_01_daily_features_requested.sql
    04_02_daily_severity_support_requested.sql

  05_baseline_predictors/
    05_01_demographics_comorbidity_requested.sql
    05_02_microbiology_infection_requested.sql
    05_03_antibiotics_baseline_requested.sql
    05_04_infection_acquisition_requested.sql
    05_05_source_control_requested.md
    05_06_severity_support_baseline_requested.sql
    05_07_respiratory_t0_requested.sql

  06_outcome/
    06_01_clinical_domains_sci_requested.sql
    06_02_improvement_flags_requested.sql
    06_03_clinical_improvement_72h_labels_requested.sql

  07_final_table/
    07_01_longitudinal_model_dataset_requested_variables.sql

  99_qc/
    00_schema_inventory_requested.sql
    01_qc_duplicates_stay_day.sql
    02_qc_counts.sql
    03_qc_label_distribution.sql
    04_qc_missingness.sql
    05_qc_allowed_columns.sql
    06_qc_readiness_status.sql
```

## Reglas Conservadas

- No cambiar cohorte inicial.
- No cambiar T0.
- No cambiar definicion de mejoria clinica.
- No cambiar outcome `clinical_improvement_72h`.
- T0 es inicio de antibiotico sistemico mapeado, no medicion clinica.
- No usar `APACHE_II`.

## Tabla Final

Nombre:

`strange-math-456415-c3.mimic_analysis.longitudinal_model_dataset_requested_variables`

Granularidad:

`stay_id + day_idx`

Incluye `clinical_improvement_72h` y `has_full_72h_label_window`.

No incluye variables internas del outcome:

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

## Variables Incluidas En Primera Version Productiva

- ids, tiempos, outcome y filtro.
- Demografia.
- Charlson completo.
- `microorganism`.
- `infection_site` como proxy.
- `bacteremia` como proxy.
- `polymicrobial_infection` como proxy documentado.
- Variables de antibioticos T0 construibles.
- `prior_antibiotics_before_start`.
- `infection_acquisition_type` como proxy.
- Variables clinicas/lab diarias por ventana desde T0.
- `SAPS`.
- `SOFA_post_t0`.
- `mechanical_ventilation`.
- `vasopressors`.
- `FiO2_t0` como proxy.
- `PaO2_FiO2_t0` como `implemented_proxy`, derivado de SOFA en dia 0 desde T0.

## Variables No Incluidas Todavia

- `resistance_phenotype_or_MDR`
- `true_clinical_infection_source`
- `source_control_done`
- `source_control_needed`
- `time_to_source_control_hours`
- `empiric_adequate_at_start`
- `vasopressor_dose_norepi_equiv_at_t0`
- `renal_replacement_therapy_t0`

Estas quedan documentadas en `VARIABLE_READINESS_STATUS.md` y `VARIABLES_REQUIRING_EPIDEMIOLOGY_DEFINITION.md`.

## Variables Post-T0

Usar opcion A: medianas diarias longitudinales desde `daily_features_requested`:

- `HR_median AS HR_post_t0`
- `MAP_median AS MAP_post_t0`
- `RR_median AS RR_post_t0`
- `SpO2_median AS SpO2_post_t0`
- `Temp_median AS Temp_post_t0`
- `WBC_median AS WBC_post_t0`
- `Lactate_median AS Lactate_post_t0`
- `Creatinine_median AS Creatinine_post_t0`
- `Bilirubin_median AS Bilirubin_post_t0`
