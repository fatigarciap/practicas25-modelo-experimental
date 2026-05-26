# VARIABLE_TRACEABILITY_REQUESTED

## Principios

No modificar `analysis/pipeline_final/`. La nueva planificacion vive en `analysis/pipeline_requested_variables/` y reutiliza tablas ya existentes en `strange-math-456415-c3.mimic_analysis` como entradas verificadas.

T0 no es una medicion clinica: es el primer inicio de antibiotico sistemico mapeado desde ingreso hospitalario hasta `LEAST(index_charttime + INTERVAL 48 HOUR, icu_outtime)`. La definicion de cohorte, mejoria clinica y `clinical_improvement_72h` no cambia.

Las variables clinicas/laboratorio post-T0 usan opcion A: medianas diarias longitudinales por `stay_id + day_idx` desde `daily_features_clean`.

## Trazabilidad

| Variable final | Rol | Fuente real verificada | Columna real / regla | Granularidad | Estado | Observaciones |
|---|---|---|---|---|---|---|
| `subject_id` | id | `bloque_1_base_windows_clean` | `subject_id` | `stay_id + day_idx` | implemented | Directo. |
| `hadm_id` | id | `bloque_1_base_windows_clean` | `hadm_id` | `stay_id + day_idx` | implemented | Directo. |
| `stay_id` | id | `bloque_1_base_windows_clean` | `stay_id` | `stay_id + day_idx` | implemented | Directo. |
| `day_idx` | tiempo | `bloque_1_base_windows_clean` | `day_idx` | `stay_id + day_idx` | implemented | Directo. |
| `t0` | tiempo | `bloque_1_base_windows_clean` | `t0` | `stay_id + day_idx` | implemented | T0 antibiotico. |
| `index_charttime` | tiempo | `bloque_1_base_windows_clean` | `index_charttime` | `stay_id + day_idx` | implemented | Directo. |
| `clinical_improvement_72h` | outcome | `clinical_improvement_72h_labels_clean` | `clinical_improvement_72h` | `stay_id + day_idx` | implemented | Join por `stay_id + day_idx`. |
| `has_full_72h_label_window` | filtro | `clinical_improvement_72h_labels_clean` | `has_full_72h_label_window` | `stay_id + day_idx` | implemented | Conservar. |
| `age` | predictor | `patients`, `admissions` | `anchor_age`, `anchor_year`, `admittime` | `stay_id` | implemented | Edad al ingreso construible. |
| `sex` | predictor | `patients` | `gender` -> `sex` | `stay_id` | implemented | Renombrar. |
| `race` | predictor | `admissions` | `race` | `stay_id` | implemented | Join por `hadm_id`. |
| `insurance` | predictor | `admissions` | `insurance` | `stay_id` | implemented | Join por `hadm_id`. |
| `comorb_myocardial_infarct_bin` | predictor | `charlson` | `myocardial_infarct` | `stay_id` | implemented | Renombrar. |
| `comorb_congestive_heart_failure_bin` | predictor | `charlson` | `congestive_heart_failure` | `stay_id` | implemented | Renombrar. |
| `comorb_peripheral_vascular_disease_bin` | predictor | `charlson` | `peripheral_vascular_disease` | `stay_id` | implemented | Renombrar. |
| `comorb_cerebrovascular_disease_bin` | predictor | `charlson` | `cerebrovascular_disease` | `stay_id` | implemented | Renombrar. |
| `comorb_dementia_bin` | predictor | `charlson` | `dementia` | `stay_id` | implemented | Renombrar. |
| `comorb_chronic_pulmonary_disease_bin` | predictor | `charlson` | `chronic_pulmonary_disease` | `stay_id` | implemented | Renombrar. |
| `comorb_rheumatic_disease_bin` | predictor | `charlson` | `rheumatic_disease` | `stay_id` | implemented | Renombrar. |
| `comorb_peptic_ulcer_disease_bin` | predictor | `charlson` | `peptic_ulcer_disease` | `stay_id` | implemented | Renombrar. |
| `comorb_mild_liver_disease_bin` | predictor | `charlson` | `mild_liver_disease` | `stay_id` | implemented | Renombrar. |
| `comorb_diabetes_without_cc_bin` | predictor | `charlson` | `diabetes_without_cc` | `stay_id` | implemented | Renombrar. |
| `comorb_diabetes_with_cc_bin` | predictor | `charlson` | `diabetes_with_cc` | `stay_id` | implemented | Renombrar. |
| `comorb_paraplegia_bin` | predictor | `charlson` | `paraplegia` | `stay_id` | implemented | Renombrar. |
| `comorb_renal_disease_bin` | predictor | `charlson` | `renal_disease` | `stay_id` | implemented | Renombrar. |
| `comorb_malignant_cancer_bin` | predictor | `charlson` | `malignant_cancer` | `stay_id` | implemented | Renombrar. |
| `comorb_severe_liver_disease_bin` | predictor | `charlson` | `severe_liver_disease` | `stay_id` | implemented | Renombrar. |
| `comorb_metastatic_solid_tumor_bin` | predictor | `charlson` | `metastatic_solid_tumor` | `stay_id` | implemented | Renombrar. |
| `comorb_aids_bin` | predictor | `charlson` | `aids` | `stay_id` | implemented | Renombrar. |
| `charlson_index` | predictor | `charlson` | `charlson_comorbidity_index` | `stay_id` | implemented | Renombrar. |
| `microorganism` | predictor | `bloque_1_base_windows_clean` | `organism_name` -> `microorganism` | `stay_id` | implemented | Organismo indice. |
| `infection_site` | predictor | `bloque_1_base_windows_clean` | proxy desde `specimen_type` | `stay_id` | implemented_proxy | Requiere aceptar agrupacion de muestras. |
| `resistance_phenotype_or_MDR` | predictor | `bloque_0_antibiogram_detail_clean` | `susceptibility_ab_name`, `susceptibility_interpretation` | `stay_id` | pending_clinical_codelist | MDR definitivo requiere reglas clinicas. |
| `true_clinical_infection_source` | predictor | no directa | no directa | `stay_id` | pending_clinical_codelist | No model-ready. |
| `bacteremia` | predictor | `bloque_1_base_windows_clean` | proxy desde `specimen_type` sangre | `stay_id` | implemented_proxy | Proxy simple. |
| `polymicrobial_infection` | predictor | `bloque_1_base_windows_clean` | `is_monomicrobial_event` | `stay_id` | implemented_proxy | 0 para episodio indice monomicrobiano. |
| `n_abx_at_start` | predictor | `baseline_regimen_summary_clean` | `n_abx_t0` | `stay_id` | implemented | Renombrar. |
| `spectrum_level_at_start` | predictor | `baseline_regimen_summary_clean` | `spectrum_level_t0` | `stay_id` | implemented | Renombrar. |
| `has_broad_at_start` | predictor | `baseline_regimen_summary_clean` | `has_broad_t0` | `stay_id` | implemented | Renombrar. |
| `has_gp_resistant_at_start` | predictor | `baseline_regimen_summary_clean` | `has_gp_resistant_t0` | `stay_id` | implemented | Renombrar. |
| `has_gn_mdr_at_start` | predictor | `baseline_regimen_summary_clean` | `has_gn_mdr_t0` | `stay_id` | implemented | Renombrar. |
| `empiric_adequate_at_start` | predictor | regimen + antibiograma | `abx_name_std` vs `susceptibility_ab_name` | `stay_id` | pending_source_mapping | Mapping y decision `I` pendientes. |
| `prior_antibiotics_before_start` | predictor | `prescriptions`, `abx_spectrum_map_clean`, `bloque_t0_true` | `drug`, `starttime`, `true_t0`, `pattern` | `stay_id` | implemented | Construible ahora. |
| `source_control_done` | predictor | `procedures_icd`, `procedureevents` | codelist requerida | `stay_id` | pending_clinical_codelist | No model-ready. |
| `source_control_needed` | predictor | no directa | regla clinica requerida | `stay_id` | pending_clinical_codelist | No model-ready. |
| `time_to_source_control_hours` | predictor | `procedures_icd`, `procedureevents` | codelist + tiempo | `stay_id` | pending_clinical_codelist | No model-ready. |
| `infection_acquisition_type` | predictor | `admissions`, `bloque_t0_true` | `admittime`, `icu_intime`, `index_charttime` | `stay_id` | implemented_proxy | Proxy por tiempos. |
| `HR_post_t0` | predictor | `daily_features_clean` | `HR_median` | `stay_id + day_idx` | implemented | Mediana diaria. |
| `MAP_post_t0` | predictor | `daily_features_clean` | `MAP_median` | `stay_id + day_idx` | implemented | Mediana diaria. |
| `RR_post_t0` | predictor | `daily_features_clean` | `RR_median` | `stay_id + day_idx` | implemented | Mediana diaria. |
| `SpO2_post_t0` | predictor | `daily_features_clean` | `SpO2_median` | `stay_id + day_idx` | implemented | Mediana diaria. |
| `Temp_post_t0` | predictor | `daily_features_clean` | `Temp_median` | `stay_id + day_idx` | implemented | Mediana diaria. |
| `WBC_post_t0` | predictor | `daily_features_clean` | `WBC_median` | `stay_id + day_idx` | implemented | Mediana diaria. |
| `Lactate_post_t0` | predictor | `daily_features_clean` | `Lactate_median` | `stay_id + day_idx` | implemented | Mediana diaria. |
| `Creatinine_post_t0` | predictor | `daily_features_clean` | `Creatinine_median` | `stay_id + day_idx` | implemented | Mediana diaria. |
| `Bilirubin_post_t0` | predictor | `daily_features_clean` | `Bilirubin_median` | `stay_id + day_idx` | implemented | Mediana diaria. |
| `SAPS` | predictor | `sapsii` | `sapsii` | `stay_id` | implemented | No APACHE II. |
| `SOFA_post_t0` | predictor | `sofa` | `sofa_24hours` por ventana | `stay_id + day_idx` | implemented | Agregar por overlap/ventana diaria. |
| `mechanical_ventilation` | predictor | `ventilation` | `ventilation_status` por ventana | `stay_id + day_idx` | implemented | No existe tabla separada `ventilation_status`. |
| `vasopressors` | predictor | `vasoactive_agent` | cualquier farmaco no nulo/activo por ventana | `stay_id + day_idx` | implemented | Usar tabla derived. |
| `vasopressor_dose_norepi_equiv_at_t0` | predictor | `vasoactive_agent` / `inputevents` | dosis/equivalencias | `stay_id` | pending_source_mapping | No model-ready. |
| `renal_replacement_therapy_t0` | predictor | `procedureevents` / `chartevents` | itemids/fuente | `stay_id` | pending_source_mapping | No model-ready. |
| `FiO2_t0` | predictor | `daily_features_clean` | `FiO2_median` en `day_idx = 0` | `stay_id` | implemented_proxy | Proxy basal. |
| `PaO2_FiO2_t0` | predictor | `physionet-data.mimiciv_3_1_derived.sofa` | `MIN(COALESCE(pao2fio2ratio_vent, pao2fio2ratio_novent))` en ventana `day_idx = 0` | `stay_id` | implemented_proxy | Proxy SOFA basal; no emparejamiento manual PaO2 + FiO2. |

## Variables Internas Excluidas

No incluir: `improved_today`, `sustained_improvement`, `n_domains_ok`, `temp_in_range`, `wbc_normalizing`, `hemo_stable`, `lactate_normalizing`, `resp_improving`, `no_new_foci_flag`, `radiology_stable_flag`.
