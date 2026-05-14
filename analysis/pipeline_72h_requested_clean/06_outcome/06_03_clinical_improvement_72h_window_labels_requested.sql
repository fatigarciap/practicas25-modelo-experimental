-- Build 72h clinical improvement labels for the longitudinal requested pipeline.
-- For predictors measured in window X, the outcome is measured in window X+1.
-- This temporal shift avoids leakage from same-window dynamic predictors.
-- Daily internal flags are used only to construct the outcome, never as predictors.

CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.clinical_improvement_72h_window_labels_requested` AS
WITH current_windows AS (
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    window_idx,
    window_start,
    window_end,
    deathtime
  FROM `strange-math-456415-c3.mimic_analysis.base_windows_72h_requested`
),
window_pairs AS (
  SELECT
    b.subject_id,
    b.hadm_id,
    b.stay_id,
    b.window_idx,
    b.window_start,
    b.window_end,
    next_b.window_idx AS outcome_window_idx,
    next_b.window_start AS outcome_window_start,
    next_b.window_end AS outcome_window_end,
    next_b.has_full_72h_window AS outcome_has_full_72h_window,
    next_b.deathtime,
    CASE WHEN next_b.window_idx IS NOT NULL THEN 1 ELSE 0 END AS has_future_window
  FROM current_windows b
  LEFT JOIN `strange-math-456415-c3.mimic_analysis.base_windows_72h_requested` next_b
    ON b.stay_id = next_b.stay_id
   AND next_b.window_idx = b.window_idx + 1
),
daily_windows AS (
  SELECT DISTINCT
    stay_id,
    day_idx,
    CAST(window_start AS TIMESTAMP) AS daily_window_start,
    CAST(window_end AS TIMESTAMP) AS daily_window_end
  FROM `strange-math-456415-c3.mimic_analysis.base_windows_requested`
),
daily_outcomes AS (
  SELECT
    stay_id,
    day_idx,
    MAX(CASE WHEN sustained_improvement = 1 THEN 1 ELSE 0 END) AS sustained_improvement
  FROM `strange-math-456415-c3.mimic_analysis.improvement_flags_requested`
  GROUP BY
    stay_id,
    day_idx
),
daily_outcomes_with_windows AS (
  SELECT
    dw.stay_id,
    dw.day_idx,
    dw.daily_window_start,
    dw.daily_window_end,
    dout.sustained_improvement
  FROM daily_windows dw
  LEFT JOIN daily_outcomes dout
    ON dw.stay_id = dout.stay_id
   AND dw.day_idx = dout.day_idx
),
outcome_agg AS (
  SELECT
    wp.stay_id,
    wp.window_idx,
    COUNT(d.day_idx) AS n_daily_outcome_rows_in_outcome_window,
    COUNTIF(d.sustained_improvement = 1) AS n_sustained_improvement_days_in_outcome_window
  FROM window_pairs wp
  LEFT JOIN daily_outcomes_with_windows d
    ON wp.stay_id = d.stay_id
   AND d.daily_window_start < wp.outcome_window_end
   AND d.daily_window_end > wp.outcome_window_start
  GROUP BY
    wp.stay_id,
    wp.window_idx
),
classified AS (
  SELECT
    wp.subject_id,
    wp.hadm_id,
    wp.stay_id,
    wp.window_idx,
    wp.window_start,
    wp.window_end,
    wp.outcome_window_idx,
    wp.outcome_window_start,
    wp.outcome_window_end,
    wp.has_future_window,
    COALESCE(oa.n_daily_outcome_rows_in_outcome_window, 0) AS n_daily_outcome_rows_in_outcome_window,
    COALESCE(oa.n_sustained_improvement_days_in_outcome_window, 0) AS n_sustained_improvement_days_in_outcome_window,
    CASE
      WHEN wp.has_future_window = 0 THEN 0
      WHEN wp.deathtime IS NOT NULL
       AND wp.deathtime >= wp.outcome_window_start
       AND wp.deathtime < wp.outcome_window_end THEN 1
      ELSE 0
    END AS death_in_outcome_window,
    CASE
      WHEN wp.has_future_window = 0 THEN NULL
      WHEN wp.outcome_has_full_72h_window = 0 THEN NULL
      WHEN wp.deathtime IS NOT NULL
       AND wp.deathtime >= wp.outcome_window_start
       AND wp.deathtime < wp.outcome_window_end THEN NULL
      WHEN COALESCE(oa.n_sustained_improvement_days_in_outcome_window, 0) > 0 THEN 1
      ELSE 0
    END AS clinical_improvement_72h
  FROM window_pairs wp
  LEFT JOIN outcome_agg oa
    ON wp.stay_id = oa.stay_id
   AND wp.window_idx = oa.window_idx
)
SELECT
  subject_id,
  hadm_id,
  stay_id,
  window_idx,
  window_start,
  window_end,
  outcome_window_idx,
  outcome_window_start,
  outcome_window_end,
  has_future_window,
  clinical_improvement_72h,
  CASE
    WHEN has_future_window = 0 THEN 'censored_or_incomplete'
    WHEN death_in_outcome_window = 1 THEN 'death'
    WHEN clinical_improvement_72h = 1 THEN 'improvement'
    WHEN clinical_improvement_72h = 0 THEN 'no_improvement'
    ELSE 'censored_or_incomplete'
  END AS clinical_status_72h,
  n_daily_outcome_rows_in_outcome_window,
  n_sustained_improvement_days_in_outcome_window,
  CASE WHEN has_future_window = 1 THEN 1 ELSE 0 END AS outcome_from_next_window
FROM classified;
