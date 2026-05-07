CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.respiratory_t0_requested` AS
SELECT
  subject_id,
  hadm_id,
  stay_id,
  FiO2_median AS FiO2_t0
FROM `strange-math-456415-c3.mimic_analysis.daily_features_requested`
WHERE day_idx = 0;
