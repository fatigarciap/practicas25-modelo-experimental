CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.infection_acquisition_requested` AS
SELECT
  t.subject_id,
  t.hadm_id,
  t.stay_id,
  CASE
    WHEN TIMESTAMP_DIFF(CAST(t.index_charttime AS TIMESTAMP), CAST(a.admittime AS TIMESTAMP), HOUR) <= 48
      THEN 'community_or_early_hospital'
    WHEN TIMESTAMP_DIFF(CAST(t.index_charttime AS TIMESTAMP), CAST(t.icu_intime AS TIMESTAMP), HOUR) >= 48
      THEN 'icu_acquired'
    ELSE 'hospital_acquired_pre_icu_or_early_icu'
  END AS infection_acquisition_type
FROM `strange-math-456415-c3.mimic_analysis.t0_true_requested` t
LEFT JOIN `physionet-data.mimiciv_3_1_hosp.admissions` a
  ON t.hadm_id = a.hadm_id;
