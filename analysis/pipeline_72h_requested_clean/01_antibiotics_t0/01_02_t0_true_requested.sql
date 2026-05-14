CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.t0_true_requested` AS
SELECT
  subject_id,
  hadm_id,
  stay_id,
  microevent_id,
  index_charttime,
  episode_anchor_source,
  icu_intime,
  icu_outtime,
  specimen_type,
  organism_name,
  is_monomicrobial_event,
  true_t0
FROM `strange-math-456415-c3.mimic_analysis.bloque_t0_true`;
