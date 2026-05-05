CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.longitudinal_model_ready_predictive_72h` AS

SELECT
  l.*,

  y.clinical_improvement_72h,
  y.n_future_days_observed,
  y.has_full_72h_label_window,
  y.first_future_sci_day,
  y.days_to_future_sci,
  y.label_window_start_day_idx,
  y.label_window_end_day_idx

FROM `strange-math-456415-c3.mimic_analysis.longitudinal_cohort_model_ready` l

LEFT JOIN `strange-math-456415-c3.mimic_analysis.clinical_improvement_72h_labels_clean` y
  ON l.stay_id = y.stay_id
 AND l.day_idx = y.day_idx;