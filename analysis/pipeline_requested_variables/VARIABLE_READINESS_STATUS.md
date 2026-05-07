# VARIABLE_READINESS_STATUS

## Tabla Final Productiva

`strange-math-456415-c3.mimic_analysis.longitudinal_model_dataset_requested_variables`

Granularidad: `stay_id + day_idx`.

Incluye solo variables `implemented` e `implemented_proxy` aceptadas. No incluye variables pendientes con `NULL` ni placeholders model-ready.

## Implemented

| Variable/grupo | Fuente |
|---|---|
| ids y tiempos | `base_windows_requested` |
| `clinical_improvement_72h`, `has_full_72h_label_window` | `clinical_improvement_72h_labels_requested` |
| `age`, `sex`, `race`, `insurance` | `patients`, `admissions` |
| Charlson completo y `charlson_index` | `mimiciv_3_1_derived.charlson` |
| `microorganism` | `index_stay_requested.organism_name` |
| `n_abx_at_start`, `spectrum_level_at_start`, `has_broad_at_start`, `has_gp_resistant_at_start`, `has_gn_mdr_at_start` | `baseline_regimen_summary_requested` |
| `prior_antibiotics_before_start` | `prescriptions` + `abx_spectrum_map_requested` |
| clinicas/lab post-T0 | `daily_features_requested`, medianas diarias por ventana desde T0 |
| `SAPS` | `mimiciv_3_1_derived.sapsii.sapsii` |
| `SOFA_post_t0` | `mimiciv_3_1_derived.sofa.sofa_24hours` por ventana diaria |
| `mechanical_ventilation` | `mimiciv_3_1_derived.ventilation.ventilation_status` por ventana diaria; proxy que puede requerir validacion del significado exacto de los estados |
| `vasopressors` | `mimiciv_3_1_derived.vasoactive_agent` como binaria diaria por ventana, requiriendo valor positivo del farmaco |

## Implemented Proxy

| Variable | Proxy |
|---|---|
| `infection_site` | Agrupacion desde `specimen_type`. |
| `bacteremia` | `specimen_type` compatible con sangre. |
| `polymicrobial_infection` | `0 para episodio indice monomicrobiano`; no cambia la cohorte. |
| `infection_acquisition_type` | Tiempos de admision/UCI/cultivo. |
| `FiO2_t0` | `daily_features_requested.FiO2_median` en `day_idx = 0`. |

## Pending Clinical Codelist

No entran en la tabla final productiva:

- `resistance_phenotype_or_MDR`
- `true_clinical_infection_source`
- `source_control_done`
- `source_control_needed`
- `time_to_source_control_hours`

## Pending Source Mapping

No entran en la tabla final productiva:

- `empiric_adequate_at_start`
- `vasopressor_dose_norepi_equiv_at_t0`
- `renal_replacement_therapy_t0`
- `PaO2_FiO2_t0`

## QC Recomendado Adicional

- `prior_antibiotics_before_start` debe tener QC especifico, porque T0 se define como el primer antibiotico sistemico mapeado desde ingreso. Si su prevalencia sale alta, puede indicar inconsistencia entre definicion de T0, diccionario antibiotico o filtros de prescripciones.

## Excluidas Como Variables Internas Del Outcome

Nunca incluir como predictores finales:

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
