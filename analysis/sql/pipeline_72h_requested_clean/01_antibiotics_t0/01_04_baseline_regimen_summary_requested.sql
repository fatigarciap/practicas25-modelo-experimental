CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.baseline_regimen_summary_requested` AS
SELECT
  stay_id,
  hadm_id,
  subject_id,
  microevent_id,
  true_t0,
  n_abx_t0,
  spectrum_level_t0,
  has_broad_t0,
  has_gp_resistant_t0,
  has_gn_mdr_t0
FROM `strange-math-456415-c3.mimic_analysis.baseline_regimen_summary_clean`;
