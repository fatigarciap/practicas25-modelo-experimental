CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.improvement_flags_requested` AS
SELECT
  subject_id,
  hadm_id,
  stay_id,
  day_idx,
  no_new_foci_flag,
  radiology_stable_flag,
  temp_in_range,
  wbc_normalizing,
  hemo_stable,
  lactate_normalizing,
  resp_improving,
  n_domains_ok,
  improved_today,
  sustained_improvement
FROM `strange-math-456415-c3.mimic_analysis.improvement_flags_clean`;
