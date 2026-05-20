-- OBSOLETE for the publication-oriented 72h longitudinal dataset.
-- Kept for traceability only. Use
-- 06_outcome/06_03_clinical_improvement_72h_window_labels_requested.sql instead.

CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.clinical_improvement_72h_labels_requested` AS
SELECT
  subject_id,
  hadm_id,
  stay_id,
  day_idx,
  improved_today,
  sustained_improvement,
  n_future_days_observed,
  clinical_improvement_72h,
  first_future_sci_day,
  label_window_start_day_idx,
  label_window_end_day_idx,
  has_full_72h_label_window,
  days_to_future_sci
FROM `strange-math-456415-c3.mimic_analysis.clinical_improvement_72h_labels_clean`;
