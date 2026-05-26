CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.table1_multicategory_72h` AS
WITH long_format AS (
  SELECT
    'race' AS variable,
    COALESCE(CAST(race AS STRING), 'Missing') AS category,
    clinical_status_72h_next
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'insurance' AS variable,
    COALESCE(CAST(insurance AS STRING), 'Missing') AS category,
    clinical_status_72h_next
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'microorganism' AS variable,
    COALESCE(CAST(microorganism AS STRING), 'Missing') AS category,
    clinical_status_72h_next
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'infection_site' AS variable,
    COALESCE(CAST(infection_site AS STRING), 'Missing') AS category,
    clinical_status_72h_next
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'infection_acquisition_type' AS variable,
    COALESCE(CAST(infection_acquisition_type AS STRING), 'Missing') AS category,
    clinical_status_72h_next
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'spectrum_level_at_start' AS variable,
    COALESCE(CAST(spectrum_level_at_start AS STRING), 'Missing') AS category,
    clinical_status_72h_next
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`

  UNION ALL

  SELECT
    'spectrum_level_window_filled' AS variable,
    COALESCE(CAST(spectrum_level_window_filled AS STRING), 'Missing') AS category,
    clinical_status_72h_next
  FROM `strange-math-456415-c3.mimic_analysis.table1_baseline_stay_level_72h`
),
category_counts AS (
  SELECT
    variable,
    category,
    clinical_status_72h_next,
    COUNT(*) AS n_category
  FROM long_format
  GROUP BY
    variable,
    category,
    clinical_status_72h_next
),
totals AS (
  SELECT
    variable,
    clinical_status_72h_next,
    COUNT(*) AS n_total
  FROM long_format
  GROUP BY
    variable,
    clinical_status_72h_next
)
SELECT
  c.variable,
  c.category,
  c.clinical_status_72h_next,
  t.n_total,
  c.n_category,
  SAFE_DIVIDE(c.n_category, t.n_total) * 100 AS pct_category,
  FORMAT('%d (%.1f%%)', c.n_category, SAFE_DIVIDE(c.n_category, t.n_total) * 100) AS summary_text
FROM category_counts c
JOIN totals t
  ON c.variable = t.variable
 AND c.clinical_status_72h_next = t.clinical_status_72h_next
ORDER BY
  c.variable,
  c.category,
  c.clinical_status_72h_next;
