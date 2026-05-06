CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.model_dataset_72h_clean` AS
SELECT * EXCEPT (
  n_future_days_observed,
  has_full_72h_label_window,
  first_future_sci_day,
  days_to_future_sci,
  label_window_start_day_idx,
  label_window_end_day_idx
)
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_model_ready_predictive_72h`
WHERE has_full_72h_label_window = 1;