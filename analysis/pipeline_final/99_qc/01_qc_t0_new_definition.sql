SELECT
  COUNT(*) AS n_with_t0,

  COUNTIF(true_t0 < icu_intime) AS n_t0_before_icu,
  ROUND(100 * COUNTIF(true_t0 < icu_intime) / COUNT(*), 2) AS pct_t0_before_icu,

  COUNTIF(true_t0 >= icu_intime AND true_t0 <= icu_outtime) AS n_t0_during_icu,
  ROUND(100 * COUNTIF(true_t0 >= icu_intime AND true_t0 <= icu_outtime) / COUNT(*), 2) AS pct_t0_during_icu,

  COUNTIF(true_t0 > icu_outtime) AS n_t0_after_icu,
  ROUND(100 * COUNTIF(true_t0 > icu_outtime) / COUNT(*), 2) AS pct_t0_after_icu,

  APPROX_QUANTILES(TIMESTAMP_DIFF(index_charttime, true_t0, HOUR), 100)[OFFSET(0)] AS min_hours_t0_to_culture,
  APPROX_QUANTILES(TIMESTAMP_DIFF(index_charttime, true_t0, HOUR), 100)[OFFSET(25)] AS p25_hours_t0_to_culture,
  APPROX_QUANTILES(TIMESTAMP_DIFF(index_charttime, true_t0, HOUR), 100)[OFFSET(50)] AS median_hours_t0_to_culture,
  APPROX_QUANTILES(TIMESTAMP_DIFF(index_charttime, true_t0, HOUR), 100)[OFFSET(75)] AS p75_hours_t0_to_culture,
  APPROX_QUANTILES(TIMESTAMP_DIFF(index_charttime, true_t0, HOUR), 100)[OFFSET(100)] AS max_hours_t0_to_culture

FROM `strange-math-456415-c3.mimic_analysis.bloque_t0_true`;