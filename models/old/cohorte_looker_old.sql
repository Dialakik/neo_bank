WITH bounds AS (
  SELECT MAX(last_txn_month) AS data_max_month, MIN(cohort_month) AS first_cohort
  FROM {{ ref('cohorte_base') }}
),
expanded AS (
  SELECT b.user_id, b.cohort_month, b.churn_month, seg
  FROM {{ ref('cohorte_base') }} b,
  UNNEST(ARRAY_CONCAT(
    ['Global'],
    IF(b.is_core,     ['Core'],      ARRAY<STRING>[]),
    IF(b.is_traveler, ['Voyageurs'], ARRAY<STRING>[]),
    IF(b.is_young,    ['Jeunes'],    ARRAY<STRING>[]),
    [IF(b.is_paid,    'Payants', 'Free')],
    [IF(b.is_crypto,  'Crypto', 'Non-crypto')]
  )) AS seg
)
SELECT
  e.seg,
  month_offset,
  COUNT(*) AS cohort_size,
  COUNTIF(month_offset < DATE_DIFF(e.churn_month, e.cohort_month, MONTH)) AS active_users,
  ROUND(COUNTIF(month_offset < DATE_DIFF(e.churn_month, e.cohort_month, MONTH)) / COUNT(*), 4) AS retention_rate
FROM expanded e
CROSS JOIN bounds bo
CROSS JOIN UNNEST(GENERATE_ARRAY(0, DATE_DIFF(bo.data_max_month, bo.first_cohort, MONTH))) AS month_offset
WHERE month_offset <= DATE_DIFF(bo.data_max_month, e.cohort_month, MONTH)
GROUP BY seg, month_offset
ORDER BY seg, month_offset