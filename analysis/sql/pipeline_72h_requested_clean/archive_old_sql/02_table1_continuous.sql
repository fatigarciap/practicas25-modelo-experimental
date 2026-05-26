CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.table1_binary_72h` AS

WITH base AS (
  SELECT *
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`
  WHERE clinical_status_72h_next IS NOT NULL
),

totals AS (
  SELECT
    clinical_status_72h_next,
    COUNT(*) AS total_n
  FROM base
  GROUP BY clinical_status_72h_next
),

binary_long AS (

  SELECT 9 AS row_order, 'Male sex' AS characteristic, b.clinical_status_72h_next,
    FORMAT('%d (%.1f%%)', COUNTIF(sex = 'M'), 100 * COUNTIF(sex = 'M') / t.total_n) AS summary
  FROM base b JOIN totals t USING (clinical_status_72h_next)
  GROUP BY b.clinical_status_72h_next, t.total_n

  UNION ALL

  SELECT 10, 'Bacteremia', b.clinical_status_72h_next,
    FORMAT('%d (%.1f%%)', COUNTIF(bacteremia = 1), 100 * COUNTIF(bacteremia = 1) / t.total_n)
  FROM base b JOIN totals t USING (clinical_status_72h_next)
  GROUP BY b.clinical_status_72h_next, t.total_n

  UNION ALL

  SELECT 11, 'Gram-negative MDR at start', b.clinical_status_72h_next,
    FORMAT('%d (%.1f%%)', COUNTIF(has_gn_mdr_at_start = 1), 100 * COUNTIF(has_gn_mdr_at_start = 1) / t.total_n)
  FROM base b JOIN totals t USING (clinical_status_72h_next)
  GROUP BY b.clinical_status_72h_next, t.total_n

  UNION ALL

  SELECT 12, 'Gram-positive resistant at start', b.clinical_status_72h_next,
    FORMAT('%d (%.1f%%)', COUNTIF(has_gp_resistant_at_start = 1), 100 * COUNTIF(has_gp_resistant_at_start = 1) / t.total_n)
  FROM base b JOIN totals t USING (clinical_status_72h_next)
  GROUP BY b.clinical_status_72h_next, t.total_n

  UNION ALL

  SELECT 13, 'Broad-spectrum antibiotics at start', b.clinical_status_72h_next,
    FORMAT('%d (%.1f%%)', COUNTIF(has_broad_at_start = 1), 100 * COUNTIF(has_broad_at_start = 1) / t.total_n)
  FROM base b JOIN totals t USING (clinical_status_72h_next)
  GROUP BY b.clinical_status_72h_next, t.total_n

  UNION ALL

  SELECT 14, 'Mechanical ventilation', b.clinical_status_72h_next,
    FORMAT('%d (%.1f%%)', COUNTIF(mechanical_ventilation_window = 1), 100 * COUNTIF(mechanical_ventilation_window = 1) / t.total_n)
  FROM base b JOIN totals t USING (clinical_status_72h_next)
  GROUP BY b.clinical_status_72h_next, t.total_n

  UNION ALL

  SELECT 15, 'Vasopressors', b.clinical_status_72h_next,
    FORMAT('%d (%.1f%%)', COUNTIF(vasopressors_window = 1), 100 * COUNTIF(vasopressors_window = 1) / t.total_n)
  FROM base b JOIN totals t USING (clinical_status_72h_next)
  GROUP BY b.clinical_status_72h_next, t.total_n
),

wide AS (
  SELECT *
  FROM binary_long
  PIVOT (
    MAX(summary)
    FOR clinical_status_72h_next IN (
      'death',
      'no_improvement',
      'improvement'
    )
  )
)

SELECT
  row_order,
  characteristic,
  death AS death_n_101,
  no_improvement AS no_improvement_n_2077,
  improvement AS improvement_n_699
FROM wide
ORDER BY row_order;