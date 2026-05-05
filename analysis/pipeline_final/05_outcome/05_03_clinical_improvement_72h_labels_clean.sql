CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.clinical_improvement_72h_labels_clean` AS

WITH base AS (
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    day_idx,
    improved_today,
    sustained_improvement
  FROM `strange-math-456415-c3.mimic_analysis.improvement_flags_clean`
),

future_window AS (
  SELECT
    cur.subject_id,
    cur.hadm_id,
    cur.stay_id,
    cur.day_idx,

    cur.improved_today,
    cur.sustained_improvement,

    COUNT(fut.day_idx) AS n_future_days_observed,

    MAX(
      CASE
        WHEN fut.sustained_improvement = 1 THEN 1
        ELSE 0
      END
    ) AS clinical_improvement_72h,

    MIN(
      CASE
        WHEN fut.sustained_improvement = 1 THEN fut.day_idx
        ELSE NULL
      END
    ) AS first_future_sci_day,

    cur.day_idx + 1 AS label_window_start_day_idx,
    cur.day_idx + 3 AS label_window_end_day_idx

  FROM base cur
  LEFT JOIN base fut
    ON cur.stay_id = fut.stay_id
   AND fut.day_idx BETWEEN cur.day_idx + 1 AND cur.day_idx + 3

  GROUP BY
    cur.subject_id,
    cur.hadm_id,
    cur.stay_id,
    cur.day_idx,
    cur.improved_today,
    cur.sustained_improvement
)

SELECT
  *,

  CASE
    WHEN n_future_days_observed = 3 THEN 1
    ELSE 0
  END AS has_full_72h_label_window,

  CASE
    WHEN first_future_sci_day IS NOT NULL
      THEN first_future_sci_day - day_idx
    ELSE NULL
  END AS days_to_future_sci

FROM future_window;