SELECT
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays,

  COUNTIF(clinical_improvement_72h = 1) AS n_clinical_improvement_72h,
  ROUND(100 * COUNTIF(clinical_improvement_72h = 1) / COUNT(*), 2)
    AS pct_clinical_improvement_72h,

  COUNTIF(clinical_improvement_72h = 0) AS n_no_clinical_improvement_72h,
  ROUND(100 * COUNTIF(clinical_improvement_72h = 0) / COUNT(*), 2)
    AS pct_no_clinical_improvement_72h,

  COUNTIF(has_full_72h_label_window = 1) AS n_full_72h_window,
  ROUND(100 * COUNTIF(has_full_72h_label_window = 1) / COUNT(*), 2)
    AS pct_full_72h_window,

  COUNTIF(has_full_72h_label_window = 0) AS n_incomplete_72h_window,
  ROUND(100 * COUNTIF(has_full_72h_label_window = 0) / COUNT(*), 2)
    AS pct_incomplete_72h_window,

  COUNTIF(days_to_future_sci = 1) AS n_sci_in_1_day,
  COUNTIF(days_to_future_sci = 2) AS n_sci_in_2_days,
  COUNTIF(days_to_future_sci = 3) AS n_sci_in_3_days

FROM `strange-math-456415-c3.mimic_analysis.clinical_improvement_72h_labels_clean`;