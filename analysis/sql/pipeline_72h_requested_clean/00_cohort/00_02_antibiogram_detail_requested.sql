CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.antibiogram_detail_requested` AS
SELECT
  stay_id,
  hadm_id,
  microevent_id,
  index_charttime,
  specimen_type,
  organism_name,
  susceptibility_ab_name,
  susceptibility_interpretation
FROM `strange-math-456415-c3.mimic_analysis.bloque_0_antibiogram_detail_clean`;
