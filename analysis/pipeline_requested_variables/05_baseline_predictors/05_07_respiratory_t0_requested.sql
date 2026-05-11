CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.respiratory_t0_requested` AS
WITH day0 AS (
  SELECT
    b.subject_id,
    b.hadm_id,
    b.stay_id,
    b.window_start,
    b.window_end,
    d.FiO2_median AS FiO2_t0
  FROM `strange-math-456415-c3.mimic_analysis.base_windows_requested` b
  LEFT JOIN `strange-math-456415-c3.mimic_analysis.daily_features_requested` d
    ON b.stay_id = d.stay_id
   AND b.day_idx = d.day_idx
  WHERE b.day_idx = 0
)
SELECT
  d.subject_id,
  d.hadm_id,
  d.stay_id,
  d.FiO2_t0,
  MIN(COALESCE(sofa.pao2fio2ratio_vent, sofa.pao2fio2ratio_novent)) AS PaO2_FiO2_t0
FROM day0 d
LEFT JOIN `physionet-data.mimiciv_3_1_derived.sofa` sofa
  ON d.stay_id = sofa.stay_id
 AND sofa.starttime < d.window_end
 AND sofa.endtime > d.window_start
GROUP BY
  d.subject_id,
  d.hadm_id,
  d.stay_id,
  d.FiO2_t0;
