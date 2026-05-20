-- 72h base windows for the longitudinal requested pipeline.
-- This script replaces the previous daily-window logic with non-overlapping
-- 72-hour windows anchored at T0.
-- MVP note: it uses base_windows_requested as a temporary basal source because
-- t0_true_requested does not currently contain all columns needed downstream.

CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.base_windows_72h_requested` AS
WITH basal AS (
  SELECT DISTINCT
    subject_id,
    hadm_id,
    stay_id,
    microevent_id,
    CAST(t0 AS TIMESTAMP) AS t0,
    CAST(index_charttime AS TIMESTAMP) AS index_charttime,
    CAST(icu_intime AS TIMESTAMP) AS icu_intime,
    CAST(icu_outtime AS TIMESTAMP) AS icu_outtime,
    CAST(deathtime AS TIMESTAMP) AS deathtime,
    CAST(followup_end AS TIMESTAMP) AS followup_end,
    specimen_type,
    organism_name,
    is_monomicrobial_event,
    n_abx_t0,
    spectrum_level_t0,
    has_broad_t0,
    has_gp_resistant_t0,
    has_gn_mdr_t0
  FROM `strange-math-456415-c3.mimic_analysis.base_windows_requested`
  WHERE t0 IS NOT NULL
    AND followup_end IS NOT NULL
    AND CAST(followup_end AS TIMESTAMP) > CAST(t0 AS TIMESTAMP)
),
planned_windows AS (
  SELECT
    b.*,
    window_idx,
    TIMESTAMP_ADD(b.t0, INTERVAL 72 * window_idx HOUR) AS window_start,
    TIMESTAMP_ADD(b.t0, INTERVAL 72 * (window_idx + 1) HOUR) AS planned_window_end
  FROM basal b
  CROSS JOIN UNNEST(GENERATE_ARRAY(0, 9)) AS window_idx
),
final_windows AS (
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
    window_idx,
    window_start,
    LEAST(planned_window_end, followup_end) AS window_end,
    planned_window_end
  FROM planned_windows
  WHERE window_start < followup_end
)
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
  window_idx,
  window_start,
  window_end,
  TIMESTAMP_DIFF(window_end, window_start, HOUR) AS window_hours_observed,
  TIMESTAMP_DIFF(window_end, window_start, MINUTE) AS window_minutes_observed,
  TIMESTAMP_DIFF(window_end, window_start, SECOND) AS window_seconds_observed,
  CASE
    WHEN planned_window_end <= followup_end THEN 1
    ELSE 0
  END AS has_full_72h_window
FROM final_windows
WHERE TIMESTAMP_DIFF(window_end, window_start, SECOND) > 0;
