CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.abx_spectrum_map_requested` AS
SELECT
  match_priority,
  pattern,
  abx_name_std,
  spectrum_level,
  spectrum_label,
  coverage_domain
FROM `strange-math-456415-c3.mimic_analysis.abx_spectrum_map_clean`;
