# PIPELINE_AUDIT_VARIABLES_REQUESTED

## Resumen ejecutivo revisado

`analysis/pipeline_final/` queda como legado intacto. La nueva version del pipeline debe vivir en paralelo en `analysis/pipeline_requested_variables/`. No se propone crear, mover, renombrar ni modificar fisicamente ningun script dentro de `analysis/pipeline_final/`.

La logica central existente se conserva:

- Cohorte inicial: estancias UCI con evento microbiologico elegible dentro de UCI, microorganismos cerrados, interpretacion `R`, `S` o `I`, episodio indice como primer evento elegible por `stay_id`.
- T0: no es una medicion clinica. Es el primer inicio de antibiotico sistemico mapeado dentro del diccionario/lista de antibioticos del proyecto, desde ingreso hospitalario hasta `LEAST(index_charttime + INTERVAL 48 HOUR, icu_outtime)`.
- Outcome: `clinical_improvement_72h`, con `sustained_improvement` en dias futuros `day_idx + 1`, `day_idx + 2`, `day_idx + 3`.
- Definicion de mejoria clinica: no se modifica.

El problema principal del legado esta en la capa final: `06_02` usa `SELECT l.*`, `06_03` usa `SELECT * EXCEPT`, se arrastran variables internas del outcome y se elimina `has_full_72h_label_window`, que debe conservarse.

La nueva tabla final se mantiene como `longitudinal_model_dataset_requested_variables`, con granularidad `stay_id + day_idx`, seleccion explicita, `clinical_improvement_72h`, `has_full_72h_label_window` y solo variables permitidas.

## Decision sobre variables clinicas/laboratorio post-T0

Las variables clinicas/laboratorio post-T0 deben interpretarse en relacion con T0 antibiotico.

| Opcion | Definicion | Granularidad | Recomendacion |
|---|---|---|---|
| A | Medianas diarias en ventanas desde T0, como `daily_features_clean` | `stay_id + day_idx` | Recomendada para el modelo longitudinal |
| B | Primer valor observado tras T0 | `stay_id` | Alternativa basal; requiere script especifico y documentacion separada |

Recomendacion: opcion A. `HR_post_t0`, `MAP_post_t0`, `RR_post_t0`, `SpO2_post_t0`, `Temp_post_t0`, `WBC_post_t0`, `Lactate_post_t0`, `Creatinine_post_t0`, `Bilirubin_post_t0` deben describirse como variables longitudinales diarias por `stay_id + day_idx`, no como primer valor tras T0.

## Auditoria de scripts legados

| Script en `analysis/pipeline_final/` | Tabla generada | Granularidad | Decision | Uso en `analysis/pipeline_requested_variables/` |
|---|---|---|---|---|
| `00_cohort/00_01_episode_candidates_clean.sql` | `bloque_0_episode_candidates_clean` | evento microbiologico; multiples por `stay_id` | KEEP_AS_IS | Replicar logica sin cambiar cohorte |
| `00_cohort/00_02_antibiogram_detail_clean.sql` | `bloque_0_antibiogram_detail_clean` | `stay_id + microevent_id + antibiotico` | KEEP_AS_IS | Replicar para antibiograma/trazabilidad |
| `00_cohort/00_03_index_stay_clean.sql` | `bloque_0b_index_stay_clean` | `stay_id` | KEEP_AS_IS | Replicar indice por primer evento elegible |
| `01_antibiotics_t0/01_01_abx_spectrum_map_clean.sql` | `abx_spectrum_map_clean` | mapa antibiotico | KEEP_AS_IS | Replicar diccionario T0 |
| `01_antibiotics_t0/01_01_t0_true.sql` | `bloque_t0_true` | `stay_id` | KEEP_AS_IS | Replicar T0 sin cambios |
| `01_antibiotics_t0/01_03_baseline_regimen_detail_clean.sql` | `baseline_regimen_detail_clean` | `stay_id + abx_name_std` | KEEP_AS_IS | Replicar regimen activo T0 |
| `01_antibiotics_t0/01_04_baseline_regimen_summary_clean.sql` | `baseline_regimen_summary_clean` | `stay_id` | KEEP_MODIFY en nueva rama | Renombrar variables solicitadas en capa nueva |
| `01_antibiotics_t0/01_05_baseline_regimen_multihot_clean.sql` | `baseline_regimen_multihot_clean` | `stay_id` | DROP_FROM_MAIN_FLOW | No entra en lista cerrada final |
| `02_windows/02_01_base_windows_clean.sql` | `bloque_1_base_windows_clean` | `stay_id + day_idx` | KEEP_MODIFY en nueva rama | Replicar ventanas desde T0; no exponer multihot |
| `03_events/03_01_radiology_worsening_events_clean.sql` | `radiology_worsening_events_clean` | `stay_id + charttime` | KEEP_AS_IS | Mover conceptualmente a `03_events_outcome_only/` |
| `03_events/03_02_radiology_flag_clean.sql` | `radiology_flag_clean` | `stay_id + day_idx` | KEEP_AS_IS | Solo soporte outcome |
| `03_events/03_03_new_foci_events_clean.sql` | `new_foci_events_clean` | `stay_id + charttime` | KEEP_AS_IS | Solo soporte outcome |
| `03_events/03_04_new_foci_flag_clean.sql` | `new_foci_flag_clean` | `stay_id + day_idx` | KEEP_AS_IS | Solo soporte outcome |
| `04_daily_features/04_01_daily_features_clean.sql` | `daily_features_clean` | `stay_id + day_idx` | KEEP_MODIFY en nueva rama | Usar opcion A: medianas diarias longitudinales |
| `05_outcome/05_01_clinical_domains_sci_clean.sql` | `clinical_domains_sci_clean` | `stay_id + day_idx` | KEEP_AS_IS | Replicar en `06_outcome/`; no predictor |
| `05_outcome/05_02_improvement_flags_clean.sql` | `improvement_flags_clean` | `stay_id + day_idx` | KEEP_AS_IS | Replicar mejoria sostenida; no predictor |
| `05_outcome/05_03_clinical_improvement_72h_labels_clean.sql` | `clinical_improvement_72h_labels_clean` | `stay_id + day_idx` | KEEP_AS_IS | Replicar outcome sin cambios |
| `06_final_table/06_01_longitudinal_cohort_model_ready.sql` | `longitudinal_cohort_model_ready` | `stay_id + day_idx` | DROP_FROM_MAIN_FLOW | No replicar como final |
| `06_final_table/06_02_longitudinal_model_ready_predictive_72h.sql` | `longitudinal_model_ready_predictive_72h` | `stay_id + day_idx` | RENAME_OR_REFACTOR | Sustituir por final explicita en `07_final_table/` |
| `06_final_table/06_03_longitudinal_model_ready_predictive_72h_clean.sql` | `model_dataset_72h_clean` | `stay_id + day_idx` | DROP_FROM_MAIN_FLOW | No replicar |
| `99_qc/01_qc_t0_new_definition.sql` | QC | resumen | KEEP_AS_IS | Adaptar en `99_qc/` nuevo |
| `99_qc/02_qc_predictive_72h_label.sql` | QC | resumen | KEEP_MODIFY | Adaptar a nueva tabla |
| `99_qc/03_qc_model_ready_predictive_72h.sql` | QC | resumen | KEEP_MODIFY | Reapuntar a nueva tabla final |

## Variables internas excluidas de la tabla final

No deben incluirse: `improved_today`, `sustained_improvement`, `n_domains_ok`, `temp_in_range`, `wbc_normalizing`, `hemo_stable`, `lactate_normalizing`, `resp_improving`, `no_new_foci_flag`, `radiology_stable_flag`.

## Variables implementadas, pendientes y no model-ready

| Categoria | Variables |
|---|---|
| `implemented` | ids/tiempo, `clinical_improvement_72h`, `has_full_72h_label_window`, `microorganism` por renombrado, resumen antibiotico T0 por renombrado, variables clinicas/lab diarias por renombrado |
| `implemented_proxy` | `infection_site` por tipo de muestra, `bacteremia` por muestra sangre, `infection_acquisition_type` por tiempos, `polymicrobial_infection = 0 para episodio indice monomicrobiano` |
| `pending_clinical_codelist` | `source_control_done`, `source_control_needed`, `time_to_source_control_hours`, `true_clinical_infection_source`, definicion definitiva de `resistance_phenotype_or_MDR` |
| `pending_source_mapping` | demografia, Charlson, `empiric_adequate_at_start`, `SAPS`, `SOFA_post_t0`, ventilacion, vasopresores, `vasopressor_dose_norepi_equiv_at_t0`, `renal_replacement_therapy_t0`, `FiO2_t0`, `PaO2_FiO2_t0` |
| `not_model_ready` | variables complejas sin codelist/mapping validado; no deben entrar como columnas finales productivas con `NULL` placeholder |

## Variables complejas

| Variable | Estado | Decision |
|---|---|---|
| `source_control_done` | `pending_clinical_codelist` | No model-ready hasta codelist |
| `source_control_needed` | `pending_clinical_codelist` | No model-ready |
| `time_to_source_control_hours` | `pending_clinical_codelist` | No model-ready |
| `vasopressor_dose_norepi_equiv_at_t0` | `pending_source_mapping` | Requiere drogas, unidades y equivalencias |
| `renal_replacement_therapy_t0` | `pending_source_mapping` | Implementable solo con fuente validada |
| `true_clinical_infection_source` | `pending_clinical_codelist` | No observable directamente |
| `resistance_phenotype_or_MDR` | `pending_clinical_codelist` | Proxy posible, MDR definitivo requiere reglas |
| `PaO2_FiO2_t0` | `pending_source_mapping` | Requiere PaO2, FiO2 y ventana temporal |
