SELECT
user_id,
count(*) as nb_transactions,
SUM(CASE WHEN direction = 'OUTBOUND' THEN amount_usd ELSE 0 END) AS total_amounts_transactions_out,
SUM(CASE WHEN direction = 'INBOUND' THEN amount_usd ELSE 0 END) AS total_amounts_transactions_in,
SUM(CASE WHEN direction = 'OUTBOUND' THEN 1 ELSE 0 END) AS nb_transactions_out,
SUM(CASE WHEN direction = 'INBOUND' THEN 1 ELSE 0 END) AS nb_transactions_in,
MIN(created_date) as date_first_transaction,
MAX(created_date) as date_last_transaction
FROM {{ ref('stg_neo_bank__transactions') }} AS notif
GROUP BY user_id
