# DATASET_DICTIONARY

## Objetivo

Este archivo documenta las variables principales de la tabla longitudinal de 72 horas y de la tabla model-ready final del proyecto longitudinal AMR days desarrollado sobre MIMIC-IV v3.1, BigQuery y SQL.

El diccionario se organiza por bloques conceptuales para facilitar la trazabilidad, el análisis descriptivo y la preparación posterior de matrices de modelado, sin sustituir la documentación metodológica principal del dataset.

## Tabla oficial longitudinal

- `longitudinal_72h_dataset_requested`

## Tabla oficial model-ready

- `longitudinal_72h_model_ready_final`

## Unidad de análisis

Una fila representa una estancia UCI (`stay_id`) en una ventana longitudinal de 72 horas (`window_idx`). La unidad longitudinal queda definida por la combinación `stay_id + window_idx`.

Los predictores se miden en la ventana actual t. Los outcomes se miden en la ventana siguiente t+1.

## Convenciones de uso

- Los identificadores se conservan para trazabilidad y auditoría, pero no deben usarse como predictores.
- Las variables basales son constantes por estancia UCI.
- Las variables dinámicas se resumen en la ventana actual t.
- Los outcomes están desplazados a la ventana siguiente t+1.
- Las variables categóricas son candidatas a encoding durante el preprocessing.
- Las variables con missingness son candidatas a imputación o tratamiento específico durante el modelado.
- Las variables internas de construcción del outcome no deben usarse como predictores.

## 1. Identificación y tiempo

| Variable | Tipo | Definición operativa | Rol analítico | Notas |
|---|---|---|---|---|
| `subject_id` | Identificador | Identificador del paciente | Trazabilidad | No usar como predictor directo |
| `hadm_id` | Identificador | Identificador de la hospitalización | Trazabilidad | No usar como predictor directo |
| `stay_id` | Identificador | Identificador de la estancia UCI | Trazabilidad y agrupación | Junto con `window_idx` define la unidad longitudinal |
| `window_idx` | Entera | Índice de ventana longitudinal de 72 horas desde T0 | Tiempo longitudinal | Junto con `stay_id` define la unidad longitudinal |
| `t0` | Timestamp | Inicio del seguimiento clínico/terapéutico | Trazabilidad temporal | Conservado para auditoría temporal |
| `index_charttime` | Timestamp | Momento del evento microbiológico índice | Trazabilidad temporal | Conservado para relacionar microbiología y T0 |

## 2. Demografía

| Variable | Tipo | Definición operativa | Rol analítico | Notas |
|---|---|---|---|---|
| `age` | Numérica | Edad del paciente | Predictor basal | Variable continua |
| `sex` | Categórica | Sexo registrado | Predictor basal | Requiere encoding si se usa en modelos |
| `race` | Categórica | Categoría de raza/etnia registrada | Predictor basal | Puede requerir decisión específica por interpretabilidad, sesgo o sensibilidad |
| `insurance` | Categórica | Tipo de seguro registrado | Predictor basal | Puede requerir decisión específica por interpretabilidad, sesgo o sensibilidad |

## 3. Comorbilidad

| Variable | Tipo | Definición operativa | Rol analítico | Notas |
|---|---|---|---|---|
| `charlson_index` | Numérica | Índice de comorbilidad de Charlson | Predictor basal | Resume carga global de comorbilidad |
| `comorb_myocardial_infarct_bin` | Binaria | Antecedente de infarto de miocardio | Predictor basal | Codificación 0/1 |
| `comorb_congestive_heart_failure_bin` | Binaria | Antecedente de insuficiencia cardiaca congestiva | Predictor basal | Codificación 0/1 |
| `comorb_peripheral_vascular_disease_bin` | Binaria | Antecedente de enfermedad vascular periférica | Predictor basal | Codificación 0/1 |
| `comorb_cerebrovascular_disease_bin` | Binaria | Antecedente de enfermedad cerebrovascular | Predictor basal | Codificación 0/1 |
| `comorb_dementia_bin` | Binaria | Antecedente de demencia | Predictor basal | Codificación 0/1 |
| `comorb_chronic_pulmonary_disease_bin` | Binaria | Antecedente de enfermedad pulmonar crónica | Predictor basal | Codificación 0/1 |
| `comorb_rheumatic_disease_bin` | Binaria | Antecedente de enfermedad reumática | Predictor basal | Codificación 0/1 |
| `comorb_peptic_ulcer_disease_bin` | Binaria | Antecedente de enfermedad ulcerosa péptica | Predictor basal | Codificación 0/1 |
| `comorb_mild_liver_disease_bin` | Binaria | Antecedente de enfermedad hepática leve | Predictor basal | Codificación 0/1 |
| `comorb_diabetes_without_cc_bin` | Binaria | Diabetes sin complicaciones crónicas | Predictor basal | Codificación 0/1 |
| `comorb_diabetes_with_cc_bin` | Binaria | Diabetes con complicaciones crónicas | Predictor basal | Codificación 0/1 |
| `comorb_paraplegia_bin` | Binaria | Antecedente de paraplejia | Predictor basal | Codificación 0/1 |
| `comorb_renal_disease_bin` | Binaria | Antecedente de enfermedad renal | Predictor basal | Codificación 0/1 |
| `comorb_malignant_cancer_bin` | Binaria | Antecedente de cáncer maligno | Predictor basal | Codificación 0/1 |
| `comorb_severe_liver_disease_bin` | Binaria | Antecedente de enfermedad hepática severa | Predictor basal | Codificación 0/1 |
| `comorb_metastatic_solid_tumor_bin` | Binaria | Antecedente de tumor sólido metastásico | Predictor basal | Codificación 0/1 |
| `comorb_aids_bin` | Binaria | Antecedente de AIDS | Predictor basal | Codificación 0/1 |

## 4. Microbiología e infección

| Variable | Tipo | Definición operativa | Rol analítico | Notas |
|---|---|---|---|---|
| `microorganism` | Categórica | Microorganismo asociado al evento infeccioso índice | Predictor basal | Definido por la versión final implementada del pipeline |
| `infection_site` | Categórica | Sitio infeccioso asociado al evento índice | Predictor basal | Requiere encoding si se usa en modelos |
| `bacteremia` | Binaria | Indicador de bacteriemia | Predictor basal | Codificación 0/1 |
| `polymicrobial_infection` | Binaria | Indicador de infección polimicrobiana | Predictor basal | Codificación 0/1; conservar para trazabilidad y revisar variabilidad antes de modelado |
| `infection_acquisition_type` | Categórica | Tipo de adquisición de la infección | Predictor basal | Definido por la versión final implementada del pipeline |

## 5. Antibióticos basales

| Variable | Tipo | Definición operativa | Rol analítico | Notas |
|---|---|---|---|---|
| `n_abx_at_start` | Numérica | Número de antibióticos al inicio del seguimiento | Predictor basal | Refleja exposición antibiótica inicial |
| `spectrum_level_at_start` | Ordinal/categórica | Nivel de espectro antibiótico al inicio | Predictor basal | Puede tratarse como ordinal o categórica según modelado |
| `has_broad_at_start` | Binaria | Presencia de antibiótico de amplio espectro al inicio | Predictor basal | Codificación 0/1 |
| `has_gp_resistant_at_start` | Binaria | Cobertura frente a Gram positivos resistentes al inicio | Predictor basal | Codificación 0/1 |
| `has_gn_mdr_at_start` | Binaria | Cobertura frente a Gram negativos MDR al inicio | Predictor basal | Codificación 0/1 |
| `prior_antibiotics_before_start` | Binaria | Exposición antibiótica previa al inicio del seguimiento | Predictor basal | Codificación 0/1 |

## 6. Antibióticos por ventana

| Variable | Tipo | Definición operativa | Rol analítico | Notas |
|---|---|---|---|---|
| `n_abx_window` | Numérica | Número de antibióticos registrados en la ventana actual | Predictor dinámico | Medido en ventana t |
| `spectrum_level_window` | Ordinal/categórica | Nivel de espectro observado en la ventana actual | Predictor dinámico | Puede ser NULL si no hay antibiótico en ventana |
| `has_abx_window` | Binaria | Presencia de antibiótico en la ventana actual | Predictor dinámico | 1 si hay antibiótico en ventana, 0 si no |
| `spectrum_level_window_filled` | Ordinal/categórica | Nivel de espectro con categoría explícita para ausencia de antibiótico | Predictor dinámico | 0 si no hay antibiótico; 1-4 si hay nivel de espectro |

## 7. Constantes vitales por ventana

| Variable | Tipo | Definición operativa | Rol analítico | Notas |
|---|---|---|---|---|
| `HR_median_window` | Numérica continua | Mediana de frecuencia cardiaca en la ventana actual | Predictor dinámico | Puede presentar missingness clínicamente esperable |
| `MAP_median_window` | Numérica continua | Mediana de presión arterial media en la ventana actual | Predictor dinámico | Puede presentar missingness clínicamente esperable |
| `RR_median_window` | Numérica continua | Mediana de frecuencia respiratoria en la ventana actual | Predictor dinámico | Puede presentar missingness clínicamente esperable |
| `SpO2_median_window` | Numérica continua | Mediana de saturación periférica de oxígeno en la ventana actual | Predictor dinámico | Puede presentar missingness clínicamente esperable |
| `Temp_median_window` | Numérica continua | Mediana de temperatura en la ventana actual | Predictor dinámico | Puede presentar missingness clínicamente esperable |

## 8. Laboratorio por ventana

| Variable | Tipo | Definición operativa | Rol analítico | Notas |
|---|---|---|---|---|
| `WBC_median_window` | Numérica continua | Mediana de leucocitos en la ventana actual | Predictor dinámico | Resumida dentro de la ventana t |
| `Lactate_median_window` | Numérica continua | Mediana de lactato en la ventana actual | Predictor dinámico | Puede tener missingness relevante |
| `Creatinine_median_window` | Numérica continua | Mediana de creatinina en la ventana actual | Predictor dinámico | Resumida dentro de la ventana t |
| `Bilirubin_median_window` | Numérica continua | Mediana de bilirrubina en la ventana actual | Predictor dinámico | Puede tener missingness relevante |

## 9. Severidad y soporte orgánico

| Variable | Tipo | Definición operativa | Rol analítico | Notas |
|---|---|---|---|---|
| `SAPS` | Numérica | Score de severidad basal | Predictor basal | Constante por estancia |
| `mechanical_ventilation_window` | Binaria | Uso de ventilación mecánica en la ventana actual | Predictor dinámico | Codificación 0/1 |
| `vasopressors_window` | Binaria | Uso de vasopresores en la ventana actual | Predictor dinámico | Codificación 0/1 |
| `FiO2_median_window` | Numérica continua | Mediana de FiO2 en la ventana actual | Predictor dinámico | Puede presentar missingness clínicamente esperable |
| `PaO2_FiO2_median_window` | Numérica continua | Mediana de PaO2/FiO2 en la ventana actual | Predictor dinámico | Puede presentar missingness clínicamente esperable |
| `qc_SOFA_max_72h` | Numérica | Valor máximo SOFA derivado por ventana según nomenclatura actual del pipeline | Variable dinámica candidata | Conserva la nomenclatura actual del pipeline; decidir uso final en preprocessing |
| `qc_SOFA_mean_72h` | Numérica | Valor medio SOFA derivado por ventana según nomenclatura actual del pipeline | Variable dinámica candidata | Conserva la nomenclatura actual del pipeline; decidir uso final en preprocessing |

## 10. Outcomes

| Variable | Tipo | Definición operativa | Rol analítico | Notas |
|---|---|---|---|---|
| `clinical_improvement_72h_next` | Binaria | 1 = `improvement`; 0 = `death` o `no_improvement` en la ventana siguiente | Outcome principal | Medido en t+1; no usar como predictor |
| `clinical_status_72h_next` | Categórica | Estado clínico en la ventana siguiente | Outcome secundario interpretable | Categorías: `death`, `no_improvement`, `improvement` |
| `clinical_status_72h_next_ord` | Ordinal numérica | Codificación ordinal del estado clínico en la ventana siguiente | Outcome secundario/sensibilidad | `death = 0`; `no_improvement = 1`; `improvement = 2` |

Los outcomes se miden en la ventana siguiente t+1. No deben tratarse como predictores.

## 11. Variables no predictoras o de trazabilidad

Los identificadores, los tiempos absolutos y las variables internas de construcción del outcome deben conservarse para auditoría, trazabilidad y control de calidad, pero no usarse como predictores directos en modelos.

Este grupo incluye identificadores como `subject_id`, `hadm_id` y `stay_id`, marcadores temporales como `t0` e `index_charttime`, y cualquier variable auxiliar usada únicamente para derivar ventanas, eventos o estados clínicos.

## 12. Notas para preprocessing

- Las variables categóricas requerirán encoding.
- Las variables numéricas con missingness requerirán una estrategia de imputación.
- Los splits deben agruparse por `stay_id` o `subject_id` para evitar contaminación entre train/test.
- El alineamiento X(t) → Y(t+1) debe mantenerse en cualquier export o matriz de modelado.
- Las decisiones específicas de modelado se documentarán en `analysis/03_model.qmd`.
