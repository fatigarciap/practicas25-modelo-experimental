CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.base_windows_requested` AS
SELECT
  subject_id,
  hadm_id,
  stay_id,
  microevent_id,
  t0,
  index_charttime,
  icu_intime,
  icu_outtime,
  deathtime,
  followup_end,
  specimen_type,
  organism_name,
  is_monomicrobial_event,
  n_abx_t0,
  spectrum_level_t0,
  has_broad_t0,
  has_gp_resistant_t0,
  has_gn_mdr_t0,
  day_idx,
  window_start,
  window_end
FROM `strange-math-456415-c3.mimic_analysis.bloque_1_base_windows_clean`;
