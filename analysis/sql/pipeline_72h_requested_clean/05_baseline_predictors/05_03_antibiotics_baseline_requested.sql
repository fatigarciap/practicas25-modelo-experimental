CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.antibiotics_baseline_requested` AS
WITH t0 AS (
  SELECT
    t.subject_id,
    t.hadm_id,
    t.stay_id,
    t.true_t0,
    CAST(a.admittime AS TIMESTAMP) AS admittime
  FROM `strange-math-456415-c3.mimic_analysis.t0_true_requested` t
  LEFT JOIN `physionet-data.mimiciv_3_1_hosp.admissions` a
    ON t.hadm_id = a.hadm_id
),
prior_abx AS (
  SELECT
    t.stay_id,
    1 AS prior_antibiotics_before_start
  FROM t0 t
  JOIN `physionet-data.mimiciv_3_1_hosp.prescriptions` p
    ON t.hadm_id = p.hadm_id
  JOIN `strange-math-456415-c3.mimic_analysis.abx_spectrum_map_requested` m
    ON REGEXP_CONTAINS(LOWER(p.drug), m.pattern)
  WHERE p.drug IS NOT NULL
    AND p.starttime IS NOT NULL
    AND CAST(p.starttime AS TIMESTAMP) >= t.admittime
    AND CAST(p.starttime AS TIMESTAMP) < t.true_t0
    AND NOT REGEXP_CONTAINS(LOWER(p.drug), r'oral|enema|flush|dwell')
  GROUP BY t.stay_id
)
SELECT
  s.subject_id,
  s.hadm_id,
  s.stay_id,
  s.n_abx_t0 AS n_abx_at_start,
  s.spectrum_level_t0 AS spectrum_level_at_start,
  s.has_broad_t0 AS has_broad_at_start,
  s.has_gp_resistant_t0 AS has_gp_resistant_at_start,
  s.has_gn_mdr_t0 AS has_gn_mdr_at_start,
  COALESCE(p.prior_antibiotics_before_start, 0) AS prior_antibiotics_before_start
FROM `strange-math-456415-c3.mimic_analysis.baseline_regimen_summary_requested` s
LEFT JOIN prior_abx p
  ON s.stay_id = p.stay_id;
