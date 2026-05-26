-- Build the ordinal longitudinal 72h outcome for each observation window.
-- Unit: one row per stay_id + window_idx.
-- clinical_status_72h is the state observed inside the current 72h window.
-- clinical_status_72h_next is created with LEAD(...) within stay_id.
-- Daily outcome internals are used only here and are not analytical variables.

CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.clinical_status_72h_window_labels_requested` AS
WITH windows AS (
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    window_idx,
    window_start,
    window_end,
    has_full_72h_window,
    deathtime
  FROM `strange-math-456415-c3.mimic_analysis.base_windows_72h_requested`
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
window_outcome_agg AS (
  SELECT
    w.stay_id,
    w.window_idx,
    COUNT(d.day_idx) AS n_daily_outcome_rows_in_window,
    COUNTIF(d.sustained_improvement = 1) AS n_sustained_improvement_days_in_window
  FROM windows w
  LEFT JOIN daily_outcomes_with_windows d
    ON w.stay_id = d.stay_id
   AND d.daily_window_start < w.window_end
   AND d.daily_window_end > w.window_start
  GROUP BY
    w.stay_id,
    w.window_idx
),
current_status AS (
  SELECT
    w.subject_id,
    w.hadm_id,
    w.stay_id,
    w.window_idx,
    w.window_start,
    w.window_end,
    w.has_full_72h_window,
    COALESCE(a.n_daily_outcome_rows_in_window, 0) AS n_daily_outcome_rows_in_window,
    COALESCE(a.n_sustained_improvement_days_in_window, 0) AS n_sustained_improvement_days_in_window,
    CASE
      WHEN w.deathtime IS NOT NULL
       AND w.deathtime >= w.window_start
       AND w.deathtime < w.window_end THEN 1
      ELSE 0
    END AS death_in_window,
    CASE
      WHEN w.deathtime IS NOT NULL
       AND w.deathtime >= w.window_start
       AND w.deathtime < w.window_end THEN 'death'
      WHEN COALESCE(a.n_sustained_improvement_days_in_window, 0) > 0 THEN 'improvement'
      WHEN w.has_full_72h_window = 1 THEN 'no_improvement'
      ELSE NULL
    END AS clinical_status_72h
  FROM windows w
  LEFT JOIN window_outcome_agg a
    ON w.stay_id = a.stay_id
   AND w.window_idx = a.window_idx
),
shifted AS (
  SELECT
    *,
    LEAD(window_idx) OVER (PARTITION BY stay_id ORDER BY window_idx) AS next_window_idx,
    LEAD(window_start) OVER (PARTITION BY stay_id ORDER BY window_idx) AS next_window_start,
    LEAD(window_end) OVER (PARTITION BY stay_id ORDER BY window_idx) AS next_window_end,
    LEAD(has_full_72h_window) OVER (PARTITION BY stay_id ORDER BY window_idx) AS next_has_full_72h_window,
    LEAD(clinical_status_72h) OVER (PARTITION BY stay_id ORDER BY window_idx) AS clinical_status_72h_next
  FROM current_status
)
SELECT
  subject_id,
  hadm_id,
  stay_id,
  window_idx,
  window_start,
  window_end,
  has_full_72h_window,
  clinical_status_72h,
  clinical_status_72h_next,
  next_window_idx,
  next_window_start,
  next_window_end,
  CASE WHEN next_window_idx IS NOT NULL THEN 1 ELSE 0 END AS has_next_window,
  COALESCE(next_has_full_72h_window, 0) AS next_has_full_72h_window,
  CASE
    WHEN next_window_idx = window_idx + 1
     AND clinical_status_72h_next IS NOT NULL THEN 1
    ELSE 0
  END AS has_valid_next_status,
  n_daily_outcome_rows_in_window,
  n_sustained_improvement_days_in_window,
  death_in_window
FROM shifted;

-- Backward-compatible table name for older run orders.
CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.clinical_improvement_72h_window_labels_requested` AS
SELECT *
FROM `strange-math-456415-c3.mimic_analysis.clinical_status_72h_window_labels_requested`;
