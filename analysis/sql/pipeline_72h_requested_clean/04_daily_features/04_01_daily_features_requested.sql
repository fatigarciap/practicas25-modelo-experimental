CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.daily_features_requested` AS
SELECT
  subject_id,
  hadm_id,
  stay_id,
  day_idx,
  window_start,
  window_end,
  HR_median,
  MAP_median,
  SysBP_median,
  DiasBP_median,
  Temp_median,
  RR_median,
  SpO2_median,
  FiO2_median,
  WBC_median,
  Lactate_median,
  Creatinine_median,
  Bilirubin_median,
  Platelets_median,
  Hgb_median,
  spo2fio2_ratio
FROM `strange-math-456415-c3.mimic_analysis.daily_features_clean`;
