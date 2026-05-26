CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.table1_stratified_72h_summary` AS
WITH normalized AS (
  SELECT
    'Continuous' AS section,
    variable,
    CAST(NULL AS STRING) AS category,
    clinical_status_72h_next,
    summary_text
  FROM `strange-math-456415-c3.mimic_analysis.table1_continuous_72h`

  UNION ALL

  SELECT
    'Binary' AS section,
    variable,
    CAST(NULL AS STRING) AS category,
    clinical_status_72h_next,
    summary_text
  FROM `strange-math-456415-c3.mimic_analysis.table1_binary_72h`

  UNION ALL

  SELECT
    'Multicategory' AS section,
    variable,
    category,
    clinical_status_72h_next,
    summary_text
  FROM `strange-math-456415-c3.mimic_analysis.table1_multicategory_72h`
),
pivoted AS (
  SELECT
    section,
    variable,
    category,
    MAX(CASE WHEN clinical_status_72h_next = 'death' THEN summary_text END) AS death,
    MAX(CASE WHEN clinical_status_72h_next = 'no_improvement' THEN summary_text END) AS no_improvement,
    MAX(CASE WHEN clinical_status_72h_next = 'improvement' THEN summary_text END) AS improvement
  FROM normalized
  GROUP BY
    section,
    variable,
    category
)
SELECT
  section,
  variable,
  category,
  death,
  no_improvement,
  improvement
FROM pivoted
ORDER BY
  CASE section
    WHEN 'Continuous' THEN 1
    WHEN 'Binary' THEN 2
    WHEN 'Multicategory' THEN 3
    ELSE 4
  END,
  variable,
  category;
