SELECT
    users.* EXCEPT(created_date),
    CAST(users.created_date AS DATE) AS user_created_date,

    transactions.* EXCEPT(user_id),

    notifications.* EXCEPT(user_id),

    devices.* EXCEPT(user_id),

    CASE WHEN (users.birth_year < 2004 and users.birth_year >= 1994) and (total_amounts_in - total_amounts_out < 500) THEN 1 ELSE 0 END AS IS_JEUNE_CSP_MOINS,
    CASE WHEN transactions.nb_devises > 3 THEN 1 ELSE 0 END AS IS_GLOBTROTTEUR,
    CASE WHEN users.user_settings_crypto_unlocked = 1 THEN 1 ELSE 0 END AS IS_CRYPTO_USER,

    CASE 
        WHEN nb_transactions = 0 THEN EXTRACT(DATE FROM DATETIME_ADD(DATETIME(users.created_date), INTERVAL 14 DAY)) 
        ELSE EXTRACT(DATE FROM DATETIME_ADD(DATETIME(transactions.date_last_transaction), INTERVAL 1 MONTH)) 
    END AS date_churn


FROM {{ ref('stg_neo_bank__users') }} AS users

LEFT JOIN {{ ref('transactions_group_by_user') }} AS transactions
    USING (user_id)

LEFT JOIN {{ ref('notifications_group_by_user') }} AS notifications
    USING (user_id)

LEFT JOIN {{ ref('stg_neo_bank__devices') }} AS devices
    USING (user_id)

