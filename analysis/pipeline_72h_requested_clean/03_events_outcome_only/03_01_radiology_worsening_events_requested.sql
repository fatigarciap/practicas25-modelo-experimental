CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.radiology_worsening_events_requested` AS
SELECT
  stay_id,
  hadm_id,
  charttime,
  radiology_worsening_flag
FROM `strange-math-456415-c3.mimic_analysis.radiology_worsening_events_clean`;
