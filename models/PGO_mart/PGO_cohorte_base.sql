
--> donne 4, le plus haut quartile, pour pouvoir déterminer ensuite le paramètre is_core : u.quartile_nb_transactions = cq.q
WITH core_q AS (
  SELECT quartile_nb_transactions AS q
  FROM {{ ref('PGO_users_full') }}
  GROUP BY q ORDER BY AVG(nb_transactions) DESC LIMIT 1
)
SELECT
  u.user_id,
  DATE_TRUNC(u.user_created_date, MONTH) AS cohort_month,
  DATE_TRUNC(DATE(u.date_last_transaction), MONTH) AS last_txn_month,
  -- ////////////////
  CASE
    WHEN u.nb_transactions > 0
      THEN DATE_ADD(DATE_TRUNC(DATE(u.date_last_transaction), MONTH), INTERVAL 2 MONTH)
    ELSE DATE_ADD(DATE_TRUNC(u.user_created_date, MONTH), INTERVAL 1 MONTH)
  END AS churn_month,
   -- ////////////////
  u.quartile_nb_transactions = cq.q                              AS is_core,
  u.nb_devises >= 3                                             AS is_traveler,
  (EXTRACT(YEAR FROM u.user_created_date) - u.birth_year) < 25  AS is_young,
  u.plan != 'STANDARD'                                          AS is_paid,    -- adapte 'STANDARD' à ton tier gratuit
  u.user_settings_crypto_unlocked = 1                          AS is_crypto,
  u.plan, u.country, u.device_type
FROM {{ ref('PGO_users_full') }} u
CROSS JOIN core_q cq
order by user_id