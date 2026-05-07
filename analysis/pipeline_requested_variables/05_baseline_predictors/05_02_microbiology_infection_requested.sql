CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.microbiology_infection_requested` AS
SELECT
  subject_id,
  hadm_id,
  stay_id,
  organism_name AS microorganism,
  CASE
    WHEN LOWER(specimen_type) LIKE '%blood%' THEN 'bloodstream'
    WHEN LOWER(specimen_type) LIKE '%urine%' THEN 'urinary'
    WHEN LOWER(specimen_type) LIKE '%sputum%'
      OR LOWER(specimen_type) LIKE '%resp%'
      OR LOWER(specimen_type) LIKE '%bronch%' THEN 'respiratory'
    WHEN LOWER(specimen_type) LIKE '%wound%'
      OR LOWER(specimen_type) LIKE '%abscess%' THEN 'skin_soft_tissue'
    WHEN LOWER(specimen_type) LIKE '%csf%' THEN 'central_nervous_system'
    ELSE 'other_or_unknown'
  END AS infection_site,
  CASE WHEN LOWER(specimen_type) LIKE '%blood%' THEN 1 ELSE 0 END AS bacteremia,
  CASE WHEN is_monomicrobial_event THEN 0 ELSE 1 END AS polymicrobial_infection
FROM `strange-math-456415-c3.mimic_analysis.index_stay_requested`;
