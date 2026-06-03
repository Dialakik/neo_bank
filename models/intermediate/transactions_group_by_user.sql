SELECT
user_id,
count(*) as nb_transactions,
SUM(CASE WHEN direction = 'OUTBOUND' THEN amount_usd ELSE 0 END) AS total_amounts_transactions_out,
SUM(CASE WHEN direction = 'INBOUND' THEN amount_usd ELSE 0 END) AS total_amounts_transactions_in,
SUM(CASE WHEN direction = 'OUTBOUND' THEN 1 ELSE 0 END) AS nb_transactions_out,
SUM(CASE WHEN direction = 'INBOUND' THEN 1 ELSE 0 END) AS nb_transactions_in,
MIN(created_date) as date_first_transaction,
MAX(created_date) as date_last_transaction,
--CAST(DATETIME_ADD(DATETIME(MAX(created_date)), INTERVAL 3 MONTH) AS TIMESTAMP) AS date_churn
EXTRACT(DATE FROM DATETIME_ADD(DATETIME(MAX(created_date)), INTERVAL 3 MONTH)) AS date_churn
FROM {{ ref('stg_neo_bank__transactions') }} AS notif
GROUP BY user_id
