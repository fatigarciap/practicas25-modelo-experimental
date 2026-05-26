-- Aggregate legacy daily measurements into non-overlapping 72h windows.
-- These are dynamic window variables measured in window t.
-- No outcome, labels, or improvement flags are calculated or read here.

CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.window_features_72h_requested` AS
WITH windows_72h AS (
  SELECT
    stay_id,
    window_idx,
    window_start,
    window_end
  FROM `strange-math-456415-c3.mimic_analysis.base_windows_72h_requested`
),
daily_windows AS (
  SELECT
    stay_id,
    day_idx,
    CAST(window_start AS TIMESTAMP) AS daily_day_start,
    CAST(window_end AS TIMESTAMP) AS daily_day_end
  FROM `strange-math-456415-c3.mimic_analysis.base_windows_requested`
),
daily_features AS (
  SELECT
    stay_id,
    day_idx,
    HR_median,
    MAP_median,
    SysBP_median,
    DiasBP_median,
    Temp_median,
    RR_median,
    SpO2_median,
    FiO2_median,
    WBC_median,
    Lactate_median,
    Creatinine_median,
    Bilirubin_median,
    Platelets_median,
    Hgb_median,
    spo2fio2_ratio
  FROM `strange-math-456415-c3.mimic_analysis.daily_features_requested`
),
antibiotics_window AS (
  SELECT
    w.stay_id,
    w.window_idx,
    COUNT(DISTINCT r.abx_name_std) AS n_abx_window,
    MAX(SAFE_CAST(r.spectrum_level AS INT64)) AS spectrum_level_window
  FROM windows_72h w
  LEFT JOIN `strange-math-456415-c3.mimic_analysis.baseline_regimen_detail_requested` r
    ON w.stay_id = r.stay_id
   AND CAST(r.start_ts AS TIMESTAMP) < w.window_end
   AND COALESCE(CAST(r.stop_ts AS TIMESTAMP), w.window_end) > w.window_start
  GROUP BY
    w.stay_id,
    w.window_idx
),
features_with_daily_windows AS (
  SELECT
    dw.stay_id,
    dw.day_idx,
    dw.daily_day_start,
    dw.daily_day_end,
    df.HR_median,
    df.MAP_median,
    df.SysBP_median,
    df.DiasBP_median,
    df.Temp_median,
    df.RR_median,
    df.SpO2_median,
    df.FiO2_median,
    df.WBC_median,
    df.Lactate_median,
    df.Creatinine_median,
    df.Bilirubin_median,
    df.Platelets_median,
    df.Hgb_median,
    df.spo2fio2_ratio
  FROM daily_windows dw
  LEFT JOIN daily_features df
    ON dw.stay_id = df.stay_id
   AND dw.day_idx = df.day_idx
)
SELECT
  w.stay_id,
  w.window_idx,
  w.window_start,
  w.window_end,
  COALESCE(a.n_abx_window, 0) AS n_abx_window,
  a.spectrum_level_window,
  APPROX_QUANTILES(CAST(d.HR_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS HR_median_window,
  APPROX_QUANTILES(CAST(d.MAP_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS MAP_median_window,
  APPROX_QUANTILES(CAST(d.SysBP_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS SysBP_median_window,
  APPROX_QUANTILES(CAST(d.DiasBP_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS DiasBP_median_window,
  APPROX_QUANTILES(CAST(d.Temp_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS Temp_median_window,
  APPROX_QUANTILES(CAST(d.RR_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS RR_median_window,
  APPROX_QUANTILES(CAST(d.SpO2_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS SpO2_median_window,
  APPROX_QUANTILES(CAST(d.FiO2_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS FiO2_median_window,
  APPROX_QUANTILES(CAST(d.WBC_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS WBC_median_window,
  APPROX_QUANTILES(CAST(d.Lactate_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS Lactate_median_window,
  APPROX_QUANTILES(CAST(d.Creatinine_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS Creatinine_median_window,
  APPROX_QUANTILES(CAST(d.Bilirubin_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS Bilirubin_median_window,
  APPROX_QUANTILES(CAST(d.Platelets_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS Platelets_median_window,
  APPROX_QUANTILES(CAST(d.Hgb_median AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS Hgb_median_window,
  APPROX_QUANTILES(CAST(d.spo2fio2_ratio AS FLOAT64), 100 IGNORE NULLS)[SAFE_OFFSET(50)] AS PaO2_FiO2_median_window,
  COUNT(d.day_idx) AS n_daily_rows_in_window,
  COUNTIF(d.HR_median IS NOT NULL) AS n_days_with_HR,
  COUNTIF(d.MAP_median IS NOT NULL) AS n_days_with_MAP,
  COUNTIF(d.Lactate_median IS NOT NULL) AS n_days_with_Lactate,
  COUNTIF(d.Creatinine_median IS NOT NULL) AS n_days_with_Creatinine,
  COUNTIF(d.spo2fio2_ratio IS NOT NULL) AS n_days_with_spo2fio2
FROM windows_72h w
LEFT JOIN features_with_daily_windows d
  ON w.stay_id = d.stay_id
 AND d.daily_day_start < w.window_end
 AND d.daily_day_end > w.window_start
LEFT JOIN antibiotics_window a
  ON w.stay_id = a.stay_id
 AND w.window_idx = a.window_idx
GROUP BY
  w.stay_id,
  w.window_idx,
  w.window_start,
  w.window_end,
  a.n_abx_window,
  a.spectrum_level_window;
