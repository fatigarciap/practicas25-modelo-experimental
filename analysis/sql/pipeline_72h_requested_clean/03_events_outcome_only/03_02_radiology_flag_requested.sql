CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.radiology_flag_requested` AS
SELECT
  subject_id,
  hadm_id,
  stay_id,
  day_idx,
  radiology_stable_flag
FROM `strange-math-456415-c3.mimic_analysis.radiology_flag_clean`;
