# 05_05_source_control_requested

`source_control_done`, `source_control_needed` and `time_to_source_control_hours` are not model-ready in the first productive requested-variables dataset.

| Variable | Status | Reason |
|---|---|---|
| `source_control_done` | `pending_clinical_codelist` | Requires validated procedure/source-control codelist. |
| `source_control_needed` | `pending_clinical_codelist` | Requires clinical criteria by infection source/site. |
| `time_to_source_control_hours` | `pending_clinical_codelist` | Depends on validated source-control event definition and timing rule. |

Candidate sources available after schema inventory:

- `physionet-data.mimiciv_3_1_hosp.procedures_icd`
- `physionet-data.mimiciv_3_1_hosp.d_icd_procedures`
- `physionet-data.mimiciv_3_1_icu.procedureevents`

Do not add these variables to `longitudinal_model_dataset_requested_variables` until the codelist and timing window are approved.
