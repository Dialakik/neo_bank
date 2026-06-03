SELECT
user_id,
COUNT(*) as nb_transactions,
SUM(CASE WHEN direction = 'OUTBOUND' THEN 1 ELSE 0 END) AS nb_transactions_out,
SUM(CASE WHEN direction = 'INBOUND' THEN 1 ELSE 0 END) AS nb_transactions_in,
ntile(4) OVER (ORDER BY COUNT(*)) as quartile_nb_transactions, -- quartile sur le nombre de transaction
ntile(4) OVER (ORDER BY SUM(CASE WHEN direction = 'OUTBOUND' THEN 1 ELSE 0 END)) as quartile_nb_transactions_out, -- quartile sur le nombre de transaction
ntile(4) OVER (ORDER BY SUM(CASE WHEN direction = 'INBOUND' THEN 1 ELSE 0 END)) as quartile_nb_transactions_in, -- quartile sur le nombre de transaction


SUM(amount_usd) AS total_amounts,
SUM(CASE WHEN direction = 'OUTBOUND' THEN amount_usd ELSE 0 END) AS total_amounts_out,
SUM(CASE WHEN direction = 'INBOUND' THEN amount_usd ELSE 0 END) AS total_amounts_in,
ntile(4) OVER (ORDER BY SUM(amount_usd)) as quartile_total_amounts, -- quartile sur le montant total
ntile(4) OVER (ORDER BY SUM(CASE WHEN direction = 'OUTBOUND' THEN amount_usd ELSE 0 END)) as quartile_total_amounts_out, -- quartile sur le montant total
ntile(4) OVER (ORDER BY SUM(CASE WHEN direction = 'INBOUND' THEN amount_usd ELSE 0 END)) as quartile_total_amounts_in, -- quartile sur le montant total

COUNT(DISTINCT transactions_currency) as nb_devises,
CASE WHEN COUNT(DISTINCT transactions_currency) > 4 THEN 1 ELSE 0 END AS is_globtrotter,
MIN(created_date) as date_first_transaction,
MAX(created_date) as date_last_transaction,

--CAST(DATETIME_ADD(DATETIME(MAX(created_date)), INTERVAL 3 MONTH) AS TIMESTAMP) AS date_churn
EXTRACT(DATE FROM DATETIME_ADD(DATETIME(MAX(created_date)), INTERVAL 3 MONTH)) AS date_churn
FROM {{ ref('stg_neo_bank__transactions') }} AS notif
GROUP BY user_id

