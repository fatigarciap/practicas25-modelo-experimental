CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.new_foci_events_requested` AS
SELECT
  stay_id,
  hadm_id,
  charttime,
  new_focus_flag
FROM `strange-math-456415-c3.mimic_analysis.new_foci_events_clean`;
