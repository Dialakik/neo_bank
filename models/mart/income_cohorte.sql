WITH base AS (
  SELECT
    user_id,
    DATE_TRUNC(user_created_date, MONTH) AS cohort_month,
    DATE_TRUNC(DATE(date_last_transaction), MONTH) AS last_txn_month,
    CASE
      WHEN nb_transactions > 0
        THEN DATE_ADD(DATE_TRUNC(DATE(date_last_transaction), MONTH), INTERVAL 2 MONTH)
      ELSE DATE_ADD(DATE_TRUNC(user_created_date, MONTH), INTERVAL 1 MONTH)
    END AS churn_month,
    CASE
      WHEN quartile_total_amounts_in IS NULL THEN 'Aucun inflow'
      ELSE CONCAT('Q', CAST(quartile_total_amounts_in AS STRING))
    END AS segment_inflow
  FROM `neobankprojectlewagon.dbt_lpignataro.users_full`
),
bounds AS (
  SELECT MAX(last_txn_month) AS data_max_month, MIN(cohort_month) AS first_cohort
  FROM base
)
SELECT
  b.segment_inflow,
  month_offset,
  COUNT(*) AS cohort_size,
  COUNTIF(month_offset < DATE_DIFF(b.churn_month, b.cohort_month, MONTH)) AS active_users,
  ROUND(COUNTIF(month_offset < DATE_DIFF(b.churn_month, b.cohort_month, MONTH)) / COUNT(*), 4) AS retention_rate
FROM base b
CROSS JOIN bounds bo
CROSS JOIN UNNEST(GENERATE_ARRAY(0, DATE_DIFF(bo.data_max_month, bo.first_cohort, MONTH))) AS month_offset
WHERE month_offset <= DATE_DIFF(bo.data_max_month, b.cohort_month, MONTH)
GROUP BY segment_inflow, month_offset
ORDER BY segment_inflow, month_offset