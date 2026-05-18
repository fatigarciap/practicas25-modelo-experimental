CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.severity_support_baseline_requested` AS
WITH base AS (
  SELECT DISTINCT
    subject_id,
    hadm_id,
    stay_id
  FROM `strange-math-456415-c3.mimic_analysis.t0_true_requested`
),
saps AS (
  SELECT
    stay_id,
    MAX(sapsii) AS SAPS
  FROM `physionet-data.mimiciv_3_1_derived.sapsii`
  GROUP BY stay_id
)
SELECT
  b.subject_id,
  b.hadm_id,
  b.stay_id,
  s.SAPS
FROM base b
LEFT JOIN saps s
  ON b.stay_id = s.stay_id;
