CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.daily_severity_support_requested` AS
WITH windows AS (
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    day_idx,
    window_start,
    window_end
  FROM `strange-math-456415-c3.mimic_analysis.base_windows_requested`
), 
sofa_daily AS (
  SELECT
    w.stay_id,
    w.day_idx,
    MAX(s.sofa_24hours) AS SOFA_post_t0
  FROM windows w
  LEFT JOIN `physionet-data.mimiciv_3_1_derived.sofa` s
    ON w.stay_id = s.stay_id
   AND CAST(s.starttime AS TIMESTAMP) < w.window_end
   AND CAST(s.endtime AS TIMESTAMP) > w.window_start
  GROUP BY w.stay_id, w.day_idx
),
vent_daily AS (
  SELECT
    w.stay_id,
    w.day_idx,
    -- Methodological note:
    -- This proxy depends on derived.ventilation.ventilation_status.
    -- Before treating it as a definitive mechanical ventilation variable,
    -- validate whether the observed statuses represent invasive ventilation,
    -- non-invasive ventilation, or any ventilatory support.
    MAX(
      CASE
        WHEN v.ventilation_status IS NOT NULL
         AND REGEXP_CONTAINS(LOWER(v.ventilation_status), r'vent|trach')
        THEN 1 ELSE 0
      END
    ) AS mechanical_ventilation
  FROM windows w
  LEFT JOIN `physionet-data.mimiciv_3_1_derived.ventilation` v
    ON w.stay_id = v.stay_id
   AND CAST(v.starttime AS TIMESTAMP) < w.window_end
   AND CAST(v.endtime AS TIMESTAMP) > w.window_start
  GROUP BY w.stay_id, w.day_idx
),
vaso_daily AS (
  SELECT
    w.stay_id,
    w.day_idx,
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
    ) AS vasopressors
  FROM windows w
  LEFT JOIN `physionet-data.mimiciv_3_1_derived.vasoactive_agent` va
    ON w.stay_id = va.stay_id
   AND CAST(va.starttime AS TIMESTAMP) < w.window_end
   AND CAST(va.endtime AS TIMESTAMP) > w.window_start
  GROUP BY w.stay_id, w.day_idx
)
SELECT
  w.subject_id,
  w.hadm_id,
  w.stay_id,
  w.day_idx,
  s.SOFA_post_t0,
  COALESCE(v.mechanical_ventilation, 0) AS mechanical_ventilation,
  COALESCE(va.vasopressors, 0) AS vasopressors
FROM windows w
LEFT JOIN sofa_daily s
  ON w.stay_id = s.stay_id
 AND w.day_idx = s.day_idx
LEFT JOIN vent_daily v
  ON w.stay_id = v.stay_id
 AND w.day_idx = v.day_idx
LEFT JOIN vaso_daily va
  ON w.stay_id = va.stay_id
 AND w.day_idx = va.day_idx;
