-- Aggregate legacy daily predictors into non-overlapping 72h windows.
-- These are dynamic predictors measured in window X.
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
  AVG(CAST(d.HR_median AS FLOAT64)) AS HR_mean_72h,
  AVG(CAST(d.MAP_median AS FLOAT64)) AS MAP_mean_72h,
  AVG(CAST(d.SysBP_median AS FLOAT64)) AS SysBP_mean_72h,
  AVG(CAST(d.DiasBP_median AS FLOAT64)) AS DiasBP_mean_72h,
  AVG(CAST(d.Temp_median AS FLOAT64)) AS Temp_mean_72h,
  AVG(CAST(d.RR_median AS FLOAT64)) AS RR_mean_72h,
  AVG(CAST(d.SpO2_median AS FLOAT64)) AS SpO2_mean_72h,
  AVG(CAST(d.FiO2_median AS FLOAT64)) AS FiO2_mean_72h,
  AVG(CAST(d.WBC_median AS FLOAT64)) AS WBC_mean_72h,
  AVG(CAST(d.Lactate_median AS FLOAT64)) AS Lactate_mean_72h,
  AVG(CAST(d.Creatinine_median AS FLOAT64)) AS Creatinine_mean_72h,
  AVG(CAST(d.Bilirubin_median AS FLOAT64)) AS Bilirubin_mean_72h,
  AVG(CAST(d.Platelets_median AS FLOAT64)) AS Platelets_mean_72h,
  AVG(CAST(d.Hgb_median AS FLOAT64)) AS Hgb_mean_72h,
  AVG(CAST(d.spo2fio2_ratio AS FLOAT64)) AS spo2fio2_ratio_mean_72h,
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
GROUP BY
  w.stay_id,
  w.window_idx,
  w.window_start,
  w.window_end;
