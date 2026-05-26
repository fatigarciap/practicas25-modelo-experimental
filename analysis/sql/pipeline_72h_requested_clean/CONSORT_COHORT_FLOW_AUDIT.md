# CONSORT cohort flow audit

Source audited: current scripts under `analysis/pipeline_72h_requested_clean/`.

Scope note: this audit does not use old notebooks and does not execute SQL. Several cohort-defining decisions are already materialized in upstream `*_clean` tables. When a `requested` script only copies from a `*_clean` table, the criterion is marked as not directly auditable in the current scripts.

## Executive summary

The publication 72h pipeline builds a longitudinal table at `stay_id + window_idx` level. The final table is:

- `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`
- Alias tables:
  - `analytical_dataset_72h_requested`
  - `longitudinal_72h_model_dataset_requested`

The final SQL does not apply a `WHERE` filter to keep only rows with a valid next outcome. Instead, it carries:

- `clinical_status_72h`
- `clinical_status_72h_next`
- `next_window_idx`
- `has_valid_next_status`

Therefore, "ventanas validas con clinical_status_72h_next" should be counted as a final analytic subset with:

```sql
WHERE has_valid_next_status = 1
```

## Cohort flow, as implemented or materialized

```text
All MIMIC-IV ICU stays
down
Microbiology episode candidates materialized upstream
down
Index stay/event materialized upstream
down
T0 and baseline antibiotic regimen materialized upstream
down
Daily base windows materialized upstream
down
72h windows generated from T0
down
Window-level covariates and 72h clinical status labels
down
Final longitudinal 72h dataset
down
Analytic subset: rows with has_valid_next_status = 1
```

The more detailed conceptual flow supplied by the investigator:

```text
Todas las estancias UCI MIMIC-IV
down
Estancias con evento microbiologico dentro de UCI
down
Estancias con microorganismo incluido
down
Exclusion de tipos de muestra no validos / posible contaminacion
down
Eventos monomicrobianos
down
Seleccion del primer evento indice por estancia
down
Estancias con T0 valido / antibiotico basal valido
down
Cohorte analitica longitudinal
down
Ventanas 72h generadas
down
Ventanas validas con clinical_status_72h_next
```

is partly upstream of the current `requested` SQL scripts. The exact organism inclusion list, specimen exclusion list, monomicrobial definition, and first-index-event ranking rule are not present as SQL logic in the audited `requested` scripts.

## Sequential audit table

| Step | Script | Output table | Input table(s) | Level | Type | SQL condition or operation |
|---|---|---|---|---|---|---|
| 0 | Not created by pipeline | MIMIC-IV ICU source | `physionet-data.mimiciv_3_1_icu.icustays` | `stay_id` | Source universe | All ICU stays. No pipeline script creates this denominator. |
| 1 | `00_cohort/00_01_episode_candidates_requested.sql` | `episode_candidates_requested` | `bloque_0_episode_candidates_clean` | `microevent_id`, `stay_id` | Inclusion/materialized upstream | Direct projection. No `WHERE`, `QUALIFY`, or ranking in current script. |
| 2 | `00_cohort/00_02_antibiogram_detail_requested.sql` | `antibiogram_detail_requested` | `bloque_0_antibiogram_detail_clean` | `microevent_id`, antibiotic test row | Transformation/materialized upstream | Direct projection of antibiogram rows. No cohort filter in current script. |
| 3 | `00_cohort/00_03_index_stay_requested.sql` | `index_stay_requested` | `bloque_0b_index_stay_clean` | `stay_id`, `microevent_id` | Deduplication/materialized upstream | Direct projection. The first-index-event selection is not visible in this script. |
| 4 | `01_antibiotics_t0/01_01_abx_spectrum_map_requested.sql` | `abx_spectrum_map_requested` | `abx_spectrum_map_clean` | antibiotic pattern | Transformation/materialized upstream | Direct projection of antibiotic mapping. |
| 5 | `01_antibiotics_t0/01_02_t0_true_requested.sql` | `t0_true_requested` | `bloque_t0_true` | `stay_id`, `microevent_id` | Inclusion/materialized upstream | Direct projection of `true_t0`. The T0 derivation rule is not recomputed here. |
| 6 | `01_antibiotics_t0/01_03_baseline_regimen_detail_requested.sql` | `baseline_regimen_detail_requested` | `baseline_regimen_detail_clean` | `stay_id`, antibiotic interval | Transformation/materialized upstream | Direct projection of baseline antibiotic intervals with `start_ts`, `stop_ts`. |
| 7 | `01_antibiotics_t0/01_04_baseline_regimen_summary_requested.sql` | `baseline_regimen_summary_requested` | `baseline_regimen_summary_clean` | `stay_id` | Transformation/materialized upstream | Direct projection of `n_abx_t0`, `spectrum_level_t0`, and coverage flags. |
| 8 | `02_windows/02_01_base_windows_requested.sql` | `base_windows_requested` | `bloque_1_base_windows_clean` | `stay_id`, `day_idx` | Transformation/materialized upstream | Direct projection of daily windows and baseline fields. |
| 9 | `02_windows/02_01_base_windows_72h_requested.sql` | `base_windows_72h_requested` | `base_windows_requested` | `stay_id`, `window_idx` | Inclusion + transformation | Keeps distinct basal records with `t0 IS NOT NULL`, `followup_end IS NOT NULL`, and `followup_end > t0`; generates `window_idx` 0 to 9; keeps `window_start < followup_end`; final keeps positive-duration windows. |
| 10 | `04_daily_features/04_01_window_features_72h_requested.sql` | `window_features_72h_requested` | `base_windows_72h_requested`, `base_windows_requested`, `daily_features_requested`, `baseline_regimen_detail_requested` | `stay_id`, `window_idx` | Transformation | Aggregates daily features into 72h windows. Antibiotic exposure is interval overlap: `r.start_ts < window_end` and `COALESCE(r.stop_ts, window_end) > window_start`. No cohort exclusion. |
| 11 | `04_daily_features/04_02_window_severity_support_72h_requested.sql` | `window_severity_support_72h_requested` | `base_windows_72h_requested`, MIMIC derived SOFA/ventilation/vasoactive tables | `stay_id`, `window_idx` | Transformation | Aggregates SOFA, ventilation, and vasopressors by interval overlap. No cohort exclusion. |
| 12 | `05_baseline_predictors/05_01_demographics_comorbidity_requested.sql` | `demographics_comorbidity_requested` | `t0_true_requested`, MIMIC patients/admissions/charlson | `stay_id` | Transformation | Builds baseline demographics and Charlson comorbidities with `LEFT JOIN`. No comorbidity exclusions. |
| 13 | `05_baseline_predictors/05_02_microbiology_infection_requested.sql` | `microbiology_infection_requested` | `index_stay_requested` | `stay_id` | Transformation | Maps `specimen_type` to infection-site proxy, bacteremia flag, and `polymicrobial_infection = CASE WHEN is_monomicrobial_event THEN 0 ELSE 1 END`. No exclusion in this script. |
| 14 | `05_baseline_predictors/05_03_antibiotics_baseline_requested.sql` | `antibiotics_baseline_requested` | `baseline_regimen_summary_requested`, `t0_true_requested`, MIMIC prescriptions, `abx_spectrum_map_requested` | `stay_id` | Transformation | Renames T0 regimen summary. Derives prior antibiotics before T0 with prescriptions from admission to `< true_t0`, excluding drug strings matching `oral|enema|flush|dwell`. No cohort exclusion. |
| 15 | `05_baseline_predictors/05_04_infection_acquisition_requested.sql` | `infection_acquisition_requested` | `t0_true_requested`, MIMIC admissions | `stay_id` | Transformation | Categorizes acquisition: `index_charttime - admittime <= 48h`, `index_charttime - icu_intime >= 48h`, else middle category. No cohort exclusion. |
| 16 | `05_baseline_predictors/05_06_severity_support_baseline_requested.sql` | `severity_support_baseline_requested` | `t0_true_requested`, MIMIC derived SAPS-II | `stay_id` | Transformation | `SELECT DISTINCT` base stays from `t0_true_requested`; left join max SAPS-II. No cohort exclusion. |
| 17 | `05_baseline_predictors/05_07_respiratory_t0_requested.sql` | `respiratory_t0_requested` | `base_windows_requested`, `daily_features_requested`, MIMIC derived SOFA | `stay_id` | Transformation | Uses only `day_idx = 0` for respiratory T0 variables. No cohort exclusion. |
| 18 | `06_outcome/06_03_clinical_improvement_72h_window_labels_requested.sql` | `clinical_status_72h_window_labels_requested` | `base_windows_72h_requested`, `base_windows_requested`, `improvement_flags_requested` | `stay_id`, `window_idx` | Transformation + validity flag | Defines current-window status: death in window, else improvement if sustained improvement exists, else no_improvement only if full 72h window, else `NULL`. Creates next status using `LEAD(clinical_status_72h)` by `stay_id ORDER BY window_idx`. |
| 19 | `07_final_table/07_01_longitudinal_72h_model_dataset_requested.sql` | `longitudinal_72h_dataset_requested` | 72h base windows, window features, labels, baseline predictors | `stay_id`, `window_idx` | Final assembly | Uses `LEFT JOIN`s and no `WHERE` filter. Carries `has_valid_next_status`; does not restrict to valid next-status rows. |

## Explicit inclusion and exclusion criteria found in current SQL

### Explicit inclusion criteria

| Criterion | Script | Table generated | Input | Level | SQL |
|---|---|---|---|---|---|
| Valid T0/follow-up for 72h window generation | `02_windows/02_01_base_windows_72h_requested.sql` | `base_windows_72h_requested` | `base_windows_requested` | `stay_id` | `WHERE t0 IS NOT NULL AND followup_end IS NOT NULL AND followup_end > t0` |
| Window begins before follow-up end | `02_windows/02_01_base_windows_72h_requested.sql` | `base_windows_72h_requested` | generated planned windows | `stay_id`, `window_idx` | `WHERE window_start < followup_end` |
| Positive observed window duration | `02_windows/02_01_base_windows_72h_requested.sql` | `base_windows_72h_requested` | final windows | `stay_id`, `window_idx` | `WHERE TIMESTAMP_DIFF(window_end, window_start, SECOND) > 0` |
| Valid next outcome flag | `06_outcome/06_03_clinical_improvement_72h_window_labels_requested.sql` | `clinical_status_72h_window_labels_requested` | current status windows | `stay_id`, `window_idx` | `CASE WHEN next_window_idx = window_idx + 1 AND clinical_status_72h_next IS NOT NULL THEN 1 ELSE 0 END` |

### Explicit exclusions

No direct row-exclusion criteria for organisms, specimen types, polymicrobial cultures, comorbidities, or baseline severity are visible in the current `requested` SQL scripts.

The only explicit exclusion-like condition in the audited scripts is for deriving a predictor, not for excluding patients/windows:

| Criterion | Script | Table generated | Input | Level | Type | SQL |
|---|---|---|---|---|---|---|
| Exclude non-systemic/local prescription strings from prior-antibiotic predictor | `05_baseline_predictors/05_03_antibiotics_baseline_requested.sql` | `antibiotics_baseline_requested` | MIMIC prescriptions | prescription row | Predictor derivation | `NOT REGEXP_CONTAINS(LOWER(p.drug), r'oral|enema|flush|dwell')` |

## Specific methodological clarifications

### Are comorbidities excluded?

No. In the current scripts, comorbidities are baseline variables only. `05_01_demographics_comorbidity_requested.sql` starts from distinct `subject_id`, `hadm_id`, `stay_id` in `t0_true_requested` and left joins Charlson comorbidity variables. There is no `WHERE` clause excluding any comorbidity.

### Are polymicrobial infections excluded?

Not explicitly in the current `requested` SQL. The pipeline carries `is_monomicrobial_event` from upstream clean tables. `05_02_microbiology_infection_requested.sql` derives:

```sql
CASE WHEN is_monomicrobial_event THEN 0 ELSE 1 END AS polymicrobial_infection
```

This is a variable derivation, not an exclusion. If the cohort is already monomicrobial, that filtering happened upstream in `bloque_0_episode_candidates_clean` or `bloque_0b_index_stay_clean`, not in the audited scripts.

### How is monomicrobial defined?

The current `requested` SQL does not define monomicrobial from raw microbiology rows. It imports the boolean `is_monomicrobial_event` from upstream tables:

- `episode_candidates_requested`
- `index_stay_requested`
- `t0_true_requested`
- `base_windows_requested`
- `base_windows_72h_requested`

The actual definition, for example a count of distinct organisms per `microevent_id`, is not visible in the audited scripts.

### Which specimen types are excluded?

The exact excluded specimen types for possible contamination or low clinical relevance are not visible in the current `requested` SQL. The scripts retain `specimen_type` and later map it to coarse categories:

- blood -> `bloodstream`
- urine -> `urinary`
- sputum/resp/bronch -> `respiratory`
- wound/abscess -> `skin_soft_tissue`
- csf -> `central_nervous_system`
- otherwise -> `other_or_unknown`

No specimen exclusion list appears in the current scripts. If such exclusion exists, it is already embedded in `bloque_0_episode_candidates_clean` or `bloque_0b_index_stay_clean`.

### Which microorganisms are included?

The current scripts do not contain an organism inclusion list. `organism_name` is imported from upstream clean tables and renamed to `microorganism` in `05_02_microbiology_infection_requested.sql`. The included organisms must be enumerated from the current output tables or recovered from the upstream clean-table construction.

### How is the first index event selected?

`00_03_index_stay_requested.sql` creates `index_stay_requested` by direct projection from `bloque_0b_index_stay_clean`. It does not show `ROW_NUMBER`, `QUALIFY`, `ORDER BY`, or tie-breaking logic. Therefore, first-event selection is materialized upstream and is not auditable in this script.

### How is T0 defined?

The current `requested` SQL imports T0:

- `01_02_t0_true_requested.sql` copies `true_t0` from `bloque_t0_true`.
- `02_01_base_windows_requested.sql` copies `t0` from `bloque_1_base_windows_clean`.
- `02_01_base_windows_72h_requested.sql` anchors 72h windows at `t0`.

The operational T0 derivation is not recomputed in current `requested` SQL. Current scripts require non-null `t0` for 72h windows.

### Is antibiotic exposure required in a +/-48h window, or is baseline regimen at T0 used?

In the current audited scripts, no `+/-48h` antibiotic inclusion criterion is visible. Baseline antibiotic exposure is imported as a T0 regimen:

- `baseline_regimen_summary_requested` imports `n_abx_t0`, `spectrum_level_t0`, and coverage flags from `baseline_regimen_summary_clean`.
- `antibiotics_baseline_requested` renames these as `n_abx_at_start`, `spectrum_level_at_start`, etc.
- `window_features_72h_requested` derives time-varying antibiotic exposure from `baseline_regimen_detail_requested` interval overlap with each 72h window.

The only explicit 48h rules in current scripts are not antibiotic inclusion windows:

- infection acquisition category using `index_charttime - admittime <= 48h`
- infection acquisition category using `index_charttime - icu_intime >= 48h`

### How is the final longitudinal cohort generated?

`07_01_longitudinal_72h_model_dataset_requested.sql` starts from `base_windows_72h_requested` and left joins window covariates, outcome labels, and baseline predictors. It produces one row per `stay_id + window_idx`.

No final `WHERE` clause restricts to valid next-status rows. For modeling the next-window outcome, the intended analytic subset should be counted or filtered with:

```sql
WHERE has_valid_next_status = 1
```

## Pending methodological doubts

These points cannot be resolved from the current audited SQL alone:

1. Exact raw microbiology inclusion criteria.
2. Exact microorganism inclusion list.
3. Exact specimen-type exclusion list for contamination or low clinical relevance.
4. Exact definition of `is_monomicrobial_event`.
5. Tie-breaking rule for first index event per stay.
6. Exact derivation of `true_t0`.
7. Exact definition used upstream for `baseline_regimen_summary_clean` and whether an antibiotic-at-T0 criterion is required before a stay enters `bloque_1_base_windows_clean`.
8. Whether the publication analysis should physically filter the final table to `has_valid_next_status = 1` or keep the full longitudinal table and filter in modeling code.
9. Whether `clinical_status_72h = NULL` for incomplete current windows should be reported as censored/incomplete in descriptive CONSORT counts.

## Proposed BigQuery queries for CONSORT counts

These are proposed counting queries only. They were not executed during this audit.

### 1. Main sequential counts

```sql
WITH counts AS (
  SELECT
    0 AS step_order,
    'all_icu_stays' AS step,
    COUNT(DISTINCT stay_id) AS n_stays,
    COUNT(DISTINCT hadm_id) AS n_hadm,
    COUNT(DISTINCT subject_id) AS n_subjects,
    CAST(NULL AS INT64) AS n_microevents,
    CAST(NULL AS INT64) AS n_windows
  FROM `physionet-data.mimiciv_3_1_icu.icustays`

  UNION ALL
  SELECT
    1,
    'episode_candidates_requested',
    COUNT(DISTINCT stay_id),
    COUNT(DISTINCT hadm_id),
    COUNT(DISTINCT subject_id),
    COUNT(DISTINCT microevent_id),
    NULL
  FROM `strange-math-456415-c3.mimic_analysis.episode_candidates_requested`

  UNION ALL
  SELECT
    2,
    'index_stay_requested',
    COUNT(DISTINCT stay_id),
    COUNT(DISTINCT hadm_id),
    COUNT(DISTINCT subject_id),
    COUNT(DISTINCT microevent_id),
    NULL
  FROM `strange-math-456415-c3.mimic_analysis.index_stay_requested`

  UNION ALL
  SELECT
    3,
    't0_true_requested',
    COUNT(DISTINCT stay_id),
    COUNT(DISTINCT hadm_id),
    COUNT(DISTINCT subject_id),
    COUNT(DISTINCT microevent_id),
    NULL
  FROM `strange-math-456415-c3.mimic_analysis.t0_true_requested`

  UNION ALL
  SELECT
    4,
    'baseline_regimen_summary_requested',
    COUNT(DISTINCT stay_id),
    COUNT(DISTINCT hadm_id),
    COUNT(DISTINCT subject_id),
    COUNT(DISTINCT microevent_id),
    NULL
  FROM `strange-math-456415-c3.mimic_analysis.baseline_regimen_summary_requested`

  UNION ALL
  SELECT
    5,
    'base_windows_72h_requested',
    COUNT(DISTINCT stay_id),
    COUNT(DISTINCT hadm_id),
    COUNT(DISTINCT subject_id),
    COUNT(DISTINCT microevent_id),
    COUNT(*)
  FROM `strange-math-456415-c3.mimic_analysis.base_windows_72h_requested`

  UNION ALL
  SELECT
    6,
    'longitudinal_72h_dataset_requested',
    COUNT(DISTINCT stay_id),
    COUNT(DISTINCT hadm_id),
    COUNT(DISTINCT subject_id),
    COUNT(DISTINCT microevent_id),
    COUNT(*)
  FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`

  UNION ALL
  SELECT
    7,
    'valid_next_status_rows',
    COUNT(DISTINCT stay_id),
    COUNT(DISTINCT hadm_id),
    COUNT(DISTINCT subject_id),
    COUNT(DISTINCT microevent_id),
    COUNT(*)
  FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`
  WHERE has_valid_next_status = 1
)
SELECT *
FROM counts
ORDER BY step_order;
```

### 2. Distribution of monomicrobial flag across stages

```sql
SELECT
  'episode_candidates_requested' AS table_name,
  is_monomicrobial_event,
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays,
  COUNT(DISTINCT microevent_id) AS n_microevents
FROM `strange-math-456415-c3.mimic_analysis.episode_candidates_requested`
GROUP BY is_monomicrobial_event

UNION ALL

SELECT
  'index_stay_requested',
  is_monomicrobial_event,
  COUNT(*),
  COUNT(DISTINCT stay_id),
  COUNT(DISTINCT microevent_id)
FROM `strange-math-456415-c3.mimic_analysis.index_stay_requested`
GROUP BY is_monomicrobial_event

UNION ALL

SELECT
  'longitudinal_72h_dataset_requested',
  is_monomicrobial_event,
  COUNT(*),
  COUNT(DISTINCT stay_id),
  COUNT(DISTINCT microevent_id)
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`
GROUP BY is_monomicrobial_event;
```

### 3. Organisms present after upstream inclusion

```sql
SELECT
  organism_name,
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays,
  COUNT(DISTINCT microevent_id) AS n_microevents
FROM `strange-math-456415-c3.mimic_analysis.index_stay_requested`
GROUP BY organism_name
ORDER BY n_stays DESC, organism_name;
```

### 4. Specimen types present after upstream exclusion

```sql
SELECT
  specimen_type,
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays,
  COUNT(DISTINCT microevent_id) AS n_microevents
FROM `strange-math-456415-c3.mimic_analysis.index_stay_requested`
GROUP BY specimen_type
ORDER BY n_stays DESC, specimen_type;
```

### 5. T0 and baseline antibiotic availability

```sql
SELECT
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays,
  COUNTIF(true_t0 IS NULL) AS n_rows_true_t0_null,
  COUNT(DISTINCT IF(true_t0 IS NULL, stay_id, NULL)) AS n_stays_true_t0_null
FROM `strange-math-456415-c3.mimic_analysis.t0_true_requested`;
```

```sql
SELECT
  COUNT(*) AS n_rows,
  COUNT(DISTINCT stay_id) AS n_stays,
  COUNTIF(n_abx_t0 IS NULL) AS n_rows_n_abx_t0_null,
  COUNTIF(n_abx_t0 = 0) AS n_rows_n_abx_t0_zero,
  COUNTIF(spectrum_level_t0 IS NULL) AS n_rows_spectrum_level_t0_null
FROM `strange-math-456415-c3.mimic_analysis.baseline_regimen_summary_requested`;
```

### 6. 72h window completeness and next-status validity

```sql
SELECT
  has_full_72h_window,
  COUNT(*) AS n_windows,
  COUNT(DISTINCT stay_id) AS n_stays
FROM `strange-math-456415-c3.mimic_analysis.base_windows_72h_requested`
GROUP BY has_full_72h_window
ORDER BY has_full_72h_window DESC;
```

```sql
SELECT
  clinical_status_72h,
  clinical_status_72h_next,
  has_valid_next_status,
  COUNT(*) AS n_windows,
  COUNT(DISTINCT stay_id) AS n_stays
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`
GROUP BY
  clinical_status_72h,
  clinical_status_72h_next,
  has_valid_next_status
ORDER BY
  has_valid_next_status DESC,
  clinical_status_72h,
  clinical_status_72h_next;
```

### 7. Final modeling denominator

```sql
SELECT
  COUNT(*) AS n_model_rows,
  COUNT(DISTINCT stay_id) AS n_model_stays,
  COUNT(DISTINCT hadm_id) AS n_model_hadm,
  COUNT(DISTINCT subject_id) AS n_model_subjects,
  COUNT(DISTINCT microevent_id) AS n_model_microevents
FROM `strange-math-456415-c3.mimic_analysis.longitudinal_72h_dataset_requested`
WHERE has_valid_next_status = 1;
```

