SELECT
  COUNT(*)                                                       AS base_users,
  ROUND(COUNTIF(nb_transactions > 0) / COUNT(*), 3)             AS taux_activation,
  ROUND(COUNTIF(plan != 'STANDARD') / COUNT(*), 3)             AS pct_premium,
  ROUND(AVG(total_amounts_out), 0)                              AS depense_moy_par_user,
  ROUND(APPROX_QUANTILES(total_amounts_out, 100)[OFFSET(50)], 0) AS depense_mediane,
  ROUND(AVG(nb_transactions), 1)                                AS nb_transac_moyen,
  ROUND(COUNTIF(date_churn > '2019-05-16')/ COUNT(*),1) AS taux_retention
FROM `neobankprojectlewagon.dbt_lpignataro.users_full`
WHERE IS_GLOBTROTTEUR = 1 