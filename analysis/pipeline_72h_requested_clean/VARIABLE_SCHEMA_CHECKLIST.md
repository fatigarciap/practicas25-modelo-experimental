# VARIABLE_SCHEMA_CHECKLIST

Checklist actualizado con el inventario real de BigQuery. No usar nombres fuera de esta tabla sin nueva comprobacion de esquema.

| Variable final | Tabla candidata | Columna candidata | Existe si/no/desconocido | Accion necesaria |
|---|---|---|---|---|
| `subject_id` | `bloque_1_base_windows_clean` | `subject_id` | si | Usar directo. |
| `hadm_id` | `bloque_1_base_windows_clean` | `hadm_id` | si | Usar directo. |
| `stay_id` | `bloque_1_base_windows_clean` | `stay_id` | si | Usar directo. |
| `day_idx` | `bloque_1_base_windows_clean` | `day_idx` | si | Usar directo. |
| `t0` | `bloque_1_base_windows_clean` | `t0` | si | Usar directo; T0 antibiotico. |
| `index_charttime` | `bloque_1_base_windows_clean` | `index_charttime` | si | Usar directo. |
| `clinical_improvement_72h` | `clinical_improvement_72h_labels_clean` | `clinical_improvement_72h` | si | Join por `stay_id + day_idx`. |
| `has_full_72h_label_window` | `clinical_improvement_72h_labels_clean` | `has_full_72h_label_window` | si | Conservar en final. |
| `age` | `patients`, `admissions` | `anchor_age`, `anchor_year`, `admittime` | si | Construir edad al ingreso. |
| `sex` | `patients` | `gender` | si | Renombrar a `sex`. |
| `race` | `admissions` | `race` | si | Usar por `hadm_id`. |
| `insurance` | `admissions` | `insurance` | si | Usar por `hadm_id`. |
| `comorb_myocardial_infarct_bin` | `charlson` | `myocardial_infarct` | si | Renombrar. |
| `comorb_congestive_heart_failure_bin` | `charlson` | `congestive_heart_failure` | si | Renombrar. |
| `comorb_peripheral_vascular_disease_bin` | `charlson` | `peripheral_vascular_disease` | si | Renombrar. |
| `comorb_cerebrovascular_disease_bin` | `charlson` | `cerebrovascular_disease` | si | Renombrar. |
| `comorb_dementia_bin` | `charlson` | `dementia` | si | Renombrar. |
| `comorb_chronic_pulmonary_disease_bin` | `charlson` | `chronic_pulmonary_disease` | si | Renombrar. |
| `comorb_rheumatic_disease_bin` | `charlson` | `rheumatic_disease` | si | Renombrar. |
| `comorb_peptic_ulcer_disease_bin` | `charlson` | `peptic_ulcer_disease` | si | Renombrar. |
| `comorb_mild_liver_disease_bin` | `charlson` | `mild_liver_disease` | si | Renombrar. |
| `comorb_diabetes_without_cc_bin` | `charlson` | `diabetes_without_cc` | si | Renombrar. |
| `comorb_diabetes_with_cc_bin` | `charlson` | `diabetes_with_cc` | si | Renombrar. |
| `comorb_paraplegia_bin` | `charlson` | `paraplegia` | si | Renombrar. |
| `comorb_renal_disease_bin` | `charlson` | `renal_disease` | si | Renombrar. |
| `comorb_malignant_cancer_bin` | `charlson` | `malignant_cancer` | si | Renombrar. |
| `comorb_severe_liver_disease_bin` | `charlson` | `severe_liver_disease` | si | Renombrar. |
| `comorb_metastatic_solid_tumor_bin` | `charlson` | `metastatic_solid_tumor` | si | Renombrar. |
| `comorb_aids_bin` | `charlson` | `aids` | si | Renombrar. |
| `charlson_index` | `charlson` | `charlson_comorbidity_index` | si | Renombrar. |
| `microorganism` | `bloque_1_base_windows_clean` | `organism_name` | si | Renombrar. |
| `infection_site` | `bloque_1_base_windows_clean` | `specimen_type` | si | Proxy desde specimen; validar agrupaciones. |
| `resistance_phenotype_or_MDR` | `bloque_0_antibiogram_detail_clean` | `susceptibility_ab_name`, `susceptibility_interpretation` | si | Pendiente codelist clinico MDR. |
| `true_clinical_infection_source` | varias | no directa | no | Pendiente validacion/codelist clinica. |
| `bacteremia` | `bloque_1_base_windows_clean` | `specimen_type` | si | Proxy sangre. |
| `polymicrobial_infection` | `bloque_1_base_windows_clean` | `is_monomicrobial_event` | si | Proxy 0 para indice monomicrobiano. |
| `n_abx_at_start` | `baseline_regimen_summary_clean` | `n_abx_t0` | si | Renombrar. |
| `spectrum_level_at_start` | `baseline_regimen_summary_clean` | `spectrum_level_t0` | si | Renombrar. |
| `has_broad_at_start` | `baseline_regimen_summary_clean` | `has_broad_t0` | si | Renombrar. |
| `has_gp_resistant_at_start` | `baseline_regimen_summary_clean` | `has_gp_resistant_t0` | si | Renombrar. |
| `has_gn_mdr_at_start` | `baseline_regimen_summary_clean` | `has_gn_mdr_t0` | si | Renombrar. |
| `empiric_adequate_at_start` | regimen + antibiogram | `abx_name_std`, `susceptibility_ab_name`, `susceptibility_interpretation` | si | Pendiente mapping administrado-antibiograma. |
| `prior_antibiotics_before_start` | `prescriptions`, `abx_spectrum_map_clean`, `bloque_t0_true` | `drug`, `starttime`, `true_t0`, `pattern` | si | Construible con diccionario T0. |
| `source_control_done` | `procedures_icd`, `procedureevents` | `icd_code`, `itemid`, tiempos | si | Pendiente codelist clinico. |
| `source_control_needed` | clinica | no directa | no | Pendiente codelist clinico. |
| `time_to_source_control_hours` | `procedures_icd`, `procedureevents` | `chartdate`, `starttime` | si | Pendiente codelist y regla temporal. |
| `infection_acquisition_type` | `admissions`, `bloque_t0_true` | `admittime`, `icu_intime`, `index_charttime` | si | Proxy por tiempos. |
| `HR_post_t0` | `daily_features_clean` | `HR_median` | si | Mediana diaria longitudinal. |
| `MAP_post_t0` | `daily_features_clean` | `MAP_median` | si | Mediana diaria longitudinal. |
| `RR_post_t0` | `daily_features_clean` | `RR_median` | si | Mediana diaria longitudinal. |
| `SpO2_post_t0` | `daily_features_clean` | `SpO2_median` | si | Mediana diaria longitudinal. |
| `Temp_post_t0` | `daily_features_clean` | `Temp_median` | si | Mediana diaria longitudinal. |
| `WBC_post_t0` | `daily_features_clean` | `WBC_median` | si | Mediana diaria longitudinal. |
| `Lactate_post_t0` | `daily_features_clean` | `Lactate_median` | si | Mediana diaria longitudinal. |
| `Creatinine_post_t0` | `daily_features_clean` | `Creatinine_median` | si | Mediana diaria longitudinal. |
| `Bilirubin_post_t0` | `daily_features_clean` | `Bilirubin_median` | si | Mediana diaria longitudinal. |
| `SAPS` | `sapsii` | `sapsii` | si | Construir por `stay_id`. |
| `SOFA_post_t0` | `sofa` | `sofa_24hours`, `starttime`, `endtime` | si | Agregar por ventana diaria. |
| `mechanical_ventilation` | `ventilation` | `ventilation_status`, `starttime`, `endtime` | si | Detectar soporte por ventana diaria. |
| `vasopressors` | `vasoactive_agent` | `dopamine`, `epinephrine`, `norepinephrine`, `phenylephrine`, `vasopressin`, `dobutamine`, `milrinone` | si | Cualquier farmaco activo en ventana diaria. |
| `vasopressor_dose_norepi_equiv_at_t0` | `vasoactive_agent` / `inputevents` | multiples | si | Pendiente equivalencias/unidades. |
| `renal_replacement_therapy_t0` | `procedureevents` / `chartevents` | `itemid`, tiempos | si | Pendiente fuente/mapping validado. |
| `FiO2_t0` | `daily_features_clean` | `FiO2_median` | si | Proxy basal `day_idx = 0`. |
| `PaO2_FiO2_t0` | `sofa` | `pao2fio2ratio_novent`, `pao2fio2ratio_vent`, `starttime`, `endtime` | si | Proxy basal SOFA en dia 0 desde T0; usar peor ratio por solapamiento temporal. |
