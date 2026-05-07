# VARIABLE_TRACEABILITY_REQUESTED

## Estados usados

- `implemented`: construible con logica ya existente o traslado directo a `analysis/pipeline_requested_variables/`.
- `implemented_proxy`: construible como proxy documentado; requiere aceptacion si se usa para modelado.
- `pending_clinical_codelist`: requiere codelist o regla clinica validada.
- `pending_source_mapping`: requiere confirmar tabla, columna, itemids, unidades o mapping tecnico.
- `not_model_ready`: no debe entrar en la tabla final productiva hasta resolver fuente/codelist.

## Decision post-T0

La tabla longitudinal principal debe usar opcion A: medianas diarias por ventanas desde T0 antibiotico, con granularidad `stay_id + day_idx`. No son primer valor tras T0. La opcion B, primer valor tras T0 por `stay_id`, queda como alternativa basal opcional.

## Tabla de trazabilidad

| Variable final | Rol | Definicion | Script propuesto en `analysis/pipeline_requested_variables/` | Granularidad | Estado | Observaciones |
|---|---|---|---|---|---|---|
| `subject_id` | id | Paciente | `00_cohort`, `02_windows`, `07_final_table` | `stay_id + day_idx` | implemented | Mantener. |
| `hadm_id` | id | Ingreso hospitalario | `00_cohort`, `02_windows`, `07_final_table` | `stay_id + day_idx` | implemented | Mantener. |
| `stay_id` | id | Estancia UCI | `00_cohort`, `02_windows`, `07_final_table` | `stay_id + day_idx` | implemented | Clave con `day_idx`. |
| `day_idx` | tiempo | Dia desde T0 antibiotico | `02_windows/02_01_base_windows_clean.sql` | `stay_id + day_idx` | implemented | Ventanas desde T0. |
| `t0` | tiempo | Primer inicio de antibiotico sistemico mapeado en ventana formal | `01_antibiotics_t0/01_02_t0_true.sql` | `stay_id` | implemented | T0 no es medicion clinica. |
| `index_charttime` | tiempo | Tiempo de evento microbiologico indice | `00_cohort/00_03_index_stay_clean.sql` | `stay_id` | implemented | No cambiar. |
| `clinical_improvement_72h` | outcome | SCI en futuros dias +1,+2,+3 | `06_outcome/06_03_clinical_improvement_72h_labels_clean.sql` | `stay_id + day_idx` | implemented | Outcome principal. |
| `has_full_72h_label_window` | filtro | Tres dias futuros observados | `06_outcome/06_03_clinical_improvement_72h_labels_clean.sql` | `stay_id + day_idx` | implemented | Conservar en final. |
| `age` | predictor | Edad al ingreso | `05_baseline_predictors/05_01_demographics_comorbidity_requested.sql` | `stay_id` | pending_source_mapping | Confirmar formula MIMIC-IV. |
| `sex` | predictor | Sexo registrado | `05_01` | `stay_id` | pending_source_mapping | Renombrar desde `gender`. |
| `race` | predictor | Raza admision | `05_01` | `stay_id` | pending_source_mapping | Puede requerir normalizacion. |
| `insurance` | predictor | Seguro admision | `05_01` | `stay_id` | pending_source_mapping | Basal. |
| comorbilidades Charlson binarias | predictor | Indicadores Charlson solicitados | `05_01` | `stay_id` | pending_source_mapping | Confirmar tabla/columnas derivadas o ICD. |
| `charlson_index` | predictor | Indice Charlson | `05_01` | `stay_id` | pending_source_mapping | Preferir tabla derivada validada. |
| `microorganism` | predictor | Organismo indice | `05_baseline_predictors/05_02_microbiology_infection_requested.sql` | `stay_id` | implemented | `organism_name` renombrado. |
| `infection_site` | predictor | Sitio proxy por tipo de muestra indice | `05_02` | `stay_id` | implemented_proxy | Validar mapeo specimen->sitio. |
| `resistance_phenotype_or_MDR` | predictor | Fenotipo/MDR por antibiograma | `05_02` o dedicado | `stay_id` | pending_clinical_codelist | Proxy posible, no model-ready definitivo. |
| `true_clinical_infection_source` | predictor | Fuente clinica real | `05_02` o dedicado | `stay_id` | pending_clinical_codelist | No observable directamente. |
| `bacteremia` | predictor | Muestra indice sangre | `05_02` | `stay_id` | implemented_proxy | Proxy por specimen. |
| `polymicrobial_infection` | predictor | Polimicrobia del episodio indice | `05_02` | `stay_id` | implemented_proxy | `0 para episodio indice monomicrobiano`; ventana ampliada requiere validacion. |
| `n_abx_at_start` | predictor | Numero de antibioticos activos en T0 | `05_baseline_predictors/05_03_antibiotics_baseline_requested.sql` | `stay_id` | implemented | Renombrado desde `n_abx_t0`. |
| `spectrum_level_at_start` | predictor | Maximo espectro activo en T0 | `05_03` | `stay_id` | implemented | Renombrado desde `spectrum_level_t0`. |
| `has_broad_at_start` | predictor | Alguno espectro >=3 | `05_03` | `stay_id` | implemented | Renombrado desde `has_broad_t0`. |
| `has_gp_resistant_at_start` | predictor | Cobertura GP resistente | `05_03` | `stay_id` | implemented | Renombrado desde `has_gp_resistant_t0`. |
| `has_gn_mdr_at_start` | predictor | Cobertura GN MDR | `05_03` | `stay_id` | implemented | Renombrado desde `has_gn_mdr_t0`. |
| `empiric_adequate_at_start` | predictor | Regimen T0 adecuado frente al antibiograma indice | `05_03` | `stay_id` | pending_source_mapping | Requiere mapa administrado-antibiograma y decision sobre `I`. |
| `prior_antibiotics_before_start` | predictor | Antibiotico mapeado antes de T0 | `05_03` | `stay_id` | implemented | Desde admision hasta antes de T0. |
| `source_control_done` | predictor | Control de foco realizado | `05_baseline_predictors/05_05_source_control_requested.sql` | `stay_id` | pending_clinical_codelist | No model-ready sin codelist. |
| `source_control_needed` | predictor | Necesidad de control de foco | `05_05` | `stay_id` | pending_clinical_codelist | No model-ready. |
| `time_to_source_control_hours` | predictor | Horas T0 a control de foco | `05_05` | `stay_id` | pending_clinical_codelist | Depende de codelist. |
| `infection_acquisition_type` | predictor | Tipo adquisicion por tiempos admision/UCI/cultivo | `05_baseline_predictors/05_04_infection_acquisition_requested.sql` | `stay_id` | implemented_proxy | Validar umbrales/categorias. |
| `HR_post_t0` | predictor | Mediana diaria HR desde T0 | `04_daily_features/04_01_daily_features_clean.sql` | `stay_id + day_idx` | implemented | Opcion A; no primer valor. |
| `MAP_post_t0` | predictor | Mediana diaria MAP desde T0 | `04_01` | `stay_id + day_idx` | implemented | Opcion A. |
| `RR_post_t0` | predictor | Mediana diaria RR desde T0 | `04_01` | `stay_id + day_idx` | implemented | Opcion A. |
| `SpO2_post_t0` | predictor | Mediana diaria SpO2 desde T0 | `04_01` | `stay_id + day_idx` | implemented | Opcion A. |
| `Temp_post_t0` | predictor | Mediana diaria temperatura desde T0 | `04_01` | `stay_id + day_idx` | implemented | Opcion A. |
| `WBC_post_t0` | predictor | Mediana diaria WBC desde T0 | `04_01` | `stay_id + day_idx` | implemented | Opcion A. |
| `Lactate_post_t0` | predictor | Mediana diaria lactato desde T0 | `04_01` | `stay_id + day_idx` | implemented | Opcion A. |
| `Creatinine_post_t0` | predictor | Mediana diaria creatinina desde T0 | `04_01` | `stay_id + day_idx` | implemented | Opcion A. |
| `Bilirubin_post_t0` | predictor | Mediana diaria bilirrubina desde T0 | `04_01` | `stay_id + day_idx` | implemented | Opcion A. |
| `SAPS` | predictor | SAPS/SAPSII basal UCI | `05_baseline_predictors/05_06_severity_support_baseline_requested.sql` | `stay_id` | pending_source_mapping | No APACHE II. |
| `SOFA_post_t0` | predictor | SOFA diario desde T0 | `04_daily_features/04_02_daily_severity_support_requested.sql` | `stay_id + day_idx` | pending_source_mapping | Agregar por ventana diaria. |
| `mechanical_ventilation` | predictor | Ventilacion en ventana diaria | `04_02` | `stay_id + day_idx` | pending_source_mapping | Validar fuente/categorias. |
| `vasopressors` | predictor | Vasopresor en ventana diaria | `04_02` | `stay_id + day_idx` | pending_source_mapping | Validar drogas/unidades. |
| `vasopressor_dose_norepi_equiv_at_t0` | predictor | Dosis norepi-equivalente en T0 | `05_06` | `stay_id` | pending_source_mapping | No model-ready hasta equivalencias. |
| `renal_replacement_therapy_t0` | predictor | RRT activa en T0 | `05_06` | `stay_id` | pending_source_mapping | Validar fuente. |
| `FiO2_t0` | predictor | FiO2 dia 0 o cercana a T0 | `05_baseline_predictors/05_07_respiratory_t0_requested.sql` | `stay_id` | pending_source_mapping | Definir mediana dia 0 vs valor cercano. |
| `PaO2_FiO2_t0` | predictor | PaO2/FiO2 cercano a T0 | `05_07` | `stay_id` | pending_source_mapping | Requiere itemids y ventana. |

## Variables internas de outcome excluidas

| Variable | Ubicacion conceptual nueva | Estado final |
|---|---|---|
| `improved_today` | `06_outcome/06_02_improvement_flags_clean.sql` | excluir |
| `sustained_improvement` | `06_outcome/06_02_improvement_flags_clean.sql` | excluir |
| `n_domains_ok` | `06_outcome/06_02_improvement_flags_clean.sql` | excluir |
| `temp_in_range` | `06_outcome/06_01_clinical_domains_sci_clean.sql` | excluir |
| `wbc_normalizing` | `06_outcome/06_01_clinical_domains_sci_clean.sql` | excluir |
| `hemo_stable` | `06_outcome/06_01_clinical_domains_sci_clean.sql` | excluir |
| `lactate_normalizing` | `06_outcome/06_01_clinical_domains_sci_clean.sql` | excluir |
| `resp_improving` | `06_outcome/06_01_clinical_domains_sci_clean.sql` | excluir |
| `no_new_foci_flag` | `03_events_outcome_only/03_04_new_foci_flag_clean.sql` | excluir |
| `radiology_stable_flag` | `03_events_outcome_only/03_02_radiology_flag_clean.sql` | excluir |
