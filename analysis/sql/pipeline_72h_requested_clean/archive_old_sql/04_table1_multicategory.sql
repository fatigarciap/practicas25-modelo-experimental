CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.table1_multicategory_72h` AS

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

multicat_long AS (

  -- RESPIRATORY
  SELECT
    16 AS row_order,
    'Infection site: Respiratory' AS characteristic,
    b.clinical_status_72h_next,

    FORMAT(
      '%d (%.1f%%)',
      COUNTIF(infection_site = 'respiratory'),
      100 * COUNTIF(infection_site = 'respiratory') / t.total_n
    ) AS summary

  FROM base b
  JOIN totals t USING (clinical_status_72h_next)

  GROUP BY
    b.clinical_status_72h_next,
    t.total_n

  UNION ALL

  -- URINARY
  SELECT
    17,
    'Infection site: Urinary',
    b.clinical_status_72h_next,

    FORMAT(
      '%d (%.1f%%)',
      COUNTIF(infection_site = 'urinary'),
      100 * COUNTIF(infection_site = 'urinary') / t.total_n
    )

  FROM base b
  JOIN totals t USING (clinical_status_72h_next)

  GROUP BY
    b.clinical_status_72h_next,
    t.total_n

  UNION ALL

  -- BLOODSTREAM
  SELECT
    18,
    'Infection site: Bloodstream',
    b.clinical_status_72h_next,

    FORMAT(
      '%d (%.1f%%)',
      COUNTIF(infection_site = 'bloodstream'),
      100 * COUNTIF(infection_site = 'bloodstream') / t.total_n
    )

  FROM base b
  JOIN totals t USING (clinical_status_72h_next)

  GROUP BY
    b.clinical_status_72h_next,
    t.total_n

  UNION ALL

  -- OTHER
  SELECT
    19,
    'Infection site: Other/Unknown',
    b.clinical_status_72h_next,

    FORMAT(
      '%d (%.1f%%)',
      COUNTIF(infection_site = 'other_or_unknown'),
      100 * COUNTIF(infection_site = 'other_or_unknown') / t.total_n
    )

  FROM base b
  JOIN totals t USING (clinical_status_72h_next)

  GROUP BY
    b.clinical_status_72h_next,
    t.total_n

)

,

wide AS (
  SELECT *
  FROM multicat_long
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