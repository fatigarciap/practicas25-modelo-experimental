# PIPELINE_AUDIT_VARIABLES_REQUESTED

## Implemented Proxy

| Variable | Estado | Fuente/regla |
|---|---|---|
| `PaO2_FiO2_t0` | implemented_proxy | Proxy basal derivado desde `physionet-data.mimiciv_3_1_derived.sofa` en ventana `day_idx = 0`, usando `MIN(COALESCE(pao2fio2ratio_vent, pao2fio2ratio_novent))`. |

## Variables Pendientes

- `resistance_phenotype_or_MDR`
- `true_clinical_infection_source`
- `source_control_done`
- `source_control_needed`
- `time_to_source_control_hours`
- `empiric_adequate_at_start`
- `vasopressor_dose_norepi_equiv_at_t0`
- `renal_replacement_therapy_t0`

Nota: `PaO2_FiO2_t0` no queda pendiente; entra en la primera version productiva como proxy derivado de SOFA, no mediante emparejamiento manual PaO2 + FiO2.
