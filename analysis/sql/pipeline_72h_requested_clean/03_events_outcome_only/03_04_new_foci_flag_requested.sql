CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.new_foci_flag_requested` AS
SELECT
  subject_id,
  hadm_id,
  stay_id,
  day_idx,
  no_new_foci_flag
FROM `strange-math-456415-c3.mimic_analysis.new_foci_flag_clean`;
