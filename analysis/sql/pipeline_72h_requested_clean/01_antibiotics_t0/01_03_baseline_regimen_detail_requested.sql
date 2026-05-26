CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.baseline_regimen_detail_requested` AS
SELECT
  subject_id,
  hadm_id,
  stay_id,
  microevent_id,
  true_t0,
  abx_name_std,
  spectrum_level,
  spectrum_label,
  coverage_domain,
  start_ts,
  stop_ts
FROM `strange-math-456415-c3.mimic_analysis.baseline_regimen_detail_clean`;
