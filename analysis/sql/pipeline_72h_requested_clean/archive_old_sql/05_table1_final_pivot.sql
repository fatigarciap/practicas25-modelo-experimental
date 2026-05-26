CREATE OR REPLACE TABLE `strange-math-456415-c3.mimic_analysis.table1_stratified_72h_summary` AS

WITH final_union AS (

  SELECT * FROM `strange-math-456415-c3.mimic_analysis.table1_continuous_72h`

  UNION ALL

  SELECT * FROM `strange-math-456415-c3.mimic_analysis.table1_binary_72h`

  UNION ALL

  SELECT * FROM `strange-math-456415-c3.mimic_analysis.table1_multicategory_72h`

)

SELECT
  row_order,
  characteristic,

  death_n_101,
  no_improvement_n_2077,
  improvement_n_699

FROM final_union
ORDER BY row_order;