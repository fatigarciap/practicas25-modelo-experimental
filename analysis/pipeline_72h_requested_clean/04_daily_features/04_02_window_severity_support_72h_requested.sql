-- Aggregate severity and organ-support predictors within each 72h window X.
-- No outcome, labels, or improvement flags are calculated or read here.
-- The X -> X+1 temporal alignment is applied later in the final model table.

CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.window_severity_support_72h_requested` AS
WITH windows AS (
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    window_idx,
    window_start,
    window_end
  FROM `strange-math-456415-c3.mimic_analysis.base_windows_72h_requested`
),
sofa_window AS (
  SELECT
    w.stay_id,
    w.window_idx,
    MAX(CAST(s.sofa_24hours AS FLOAT64)) AS SOFA_max_72h,
    AVG(CAST(s.sofa_24hours AS FLOAT64)) AS SOFA_mean_72h
  FROM windows w
  LEFT JOIN `physionet-data.mimiciv_3_1_derived.sofa` s
    ON w.stay_id = s.stay_id
   AND CAST(s.starttime AS TIMESTAMP) < w.window_end
   AND CAST(s.endtime AS TIMESTAMP) > w.window_start
  GROUP BY
    w.stay_id,
    w.window_idx
),
vent_window AS (
  SELECT
    w.stay_id,
    w.window_idx,
    MAX(
      CASE
        WHEN v.ventilation_status IS NOT NULL
         AND REGEXP_CONTAINS(LOWER(v.ventilation_status), r'vent|trach')
        THEN 1 ELSE 0
      END
    ) AS mechanical_ventilation_72h
  FROM windows w
  LEFT JOIN `physionet-data.mimiciv_3_1_derived.ventilation` v
    ON w.stay_id = v.stay_id
   AND CAST(v.starttime AS TIMESTAMP) < w.window_end
   AND CAST(v.endtime AS TIMESTAMP) > w.window_start
  GROUP BY
    w.stay_id,
    w.window_idx
),
vaso_window AS (
  SELECT
    w.stay_id,
    w.window_idx,
    MAX(
      CASE
        WHEN COALESCE(va.dopamine, 0) > 0
          OR COALESCE(va.epinephrine, 0) > 0
          OR COALESCE(va.norepinephrine, 0) > 0
          OR COALESCE(va.phenylephrine, 0) > 0
          OR COALESCE(va.vasopressin, 0) > 0
          OR COALESCE(va.dobutamine, 0) > 0
          OR COALESCE(va.milrinone, 0) > 0
        THEN 1 ELSE 0
      END
    ) AS vasopressors_72h
  FROM windows w
  LEFT JOIN `physionet-data.mimiciv_3_1_derived.vasoactive_agent` va
    ON w.stay_id = va.stay_id
   AND CAST(va.starttime AS TIMESTAMP) < w.window_end
   AND CAST(va.endtime AS TIMESTAMP) > w.window_start
  GROUP BY
    w.stay_id,
    w.window_idx
)
SELECT
  w.subject_id,
  w.hadm_id,
  w.stay_id,
  w.window_idx,
  w.window_start,
  w.window_end,
  s.SOFA_max_72h,
  s.SOFA_mean_72h,
  COALESCE(v.mechanical_ventilation_72h, 0) AS mechanical_ventilation_72h,
  COALESCE(va.vasopressors_72h, 0) AS vasopressors_72h
FROM windows w
LEFT JOIN sofa_window s
  ON w.stay_id = s.stay_id
 AND w.window_idx = s.window_idx
LEFT JOIN vent_window v
  ON w.stay_id = v.stay_id
 AND w.window_idx = v.window_idx
LEFT JOIN vaso_window va
  ON w.stay_id = va.stay_id
 AND w.window_idx = va.window_idx;
