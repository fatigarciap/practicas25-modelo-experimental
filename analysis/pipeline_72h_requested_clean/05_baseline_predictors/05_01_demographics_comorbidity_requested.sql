CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.demographics_comorbidity_requested` AS
WITH base AS (
  SELECT DISTINCT
    subject_id,
    hadm_id,
    stay_id
  FROM `strange-math-456415-c3.mimic_analysis.t0_true_requested`
)
SELECT
  b.subject_id,
  b.hadm_id,
  b.stay_id,
  p.anchor_age + EXTRACT(YEAR FROM a.admittime) - p.anchor_year AS age,
  p.gender AS sex,
  a.race,
  a.insurance,
  c.myocardial_infarct AS comorb_myocardial_infarct_bin,
  c.congestive_heart_failure AS comorb_congestive_heart_failure_bin,
  c.peripheral_vascular_disease AS comorb_peripheral_vascular_disease_bin,
  c.cerebrovascular_disease AS comorb_cerebrovascular_disease_bin,
  c.dementia AS comorb_dementia_bin,
  c.chronic_pulmonary_disease AS comorb_chronic_pulmonary_disease_bin,
  c.rheumatic_disease AS comorb_rheumatic_disease_bin,
  c.peptic_ulcer_disease AS comorb_peptic_ulcer_disease_bin,
  c.mild_liver_disease AS comorb_mild_liver_disease_bin,
  c.diabetes_without_cc AS comorb_diabetes_without_cc_bin,
  c.diabetes_with_cc AS comorb_diabetes_with_cc_bin,
  c.paraplegia AS comorb_paraplegia_bin,
  c.renal_disease AS comorb_renal_disease_bin,
  c.malignant_cancer AS comorb_malignant_cancer_bin,
  c.severe_liver_disease AS comorb_severe_liver_disease_bin,
  c.metastatic_solid_tumor AS comorb_metastatic_solid_tumor_bin,
  c.aids AS comorb_aids_bin,
  c.charlson_comorbidity_index AS charlson_index
FROM base b
LEFT JOIN `physionet-data.mimiciv_3_1_hosp.patients` p
  ON b.subject_id = p.subject_id
LEFT JOIN `physionet-data.mimiciv_3_1_hosp.admissions` a
  ON b.hadm_id = a.hadm_id
LEFT JOIN `physionet-data.mimiciv_3_1_derived.charlson` c
  ON b.subject_id = c.subject_id
 AND b.hadm_id = c.hadm_id;
