SELECT
    users.* EXCEPT(created_date),
    CAST(users.created_date AS DATE) AS user_created_date,

    transactions.* EXCEPT(user_id),

    notifications.* EXCEPT(user_id),

    devices.* EXCEPT(user_id),
    CASE 
        WHEN (users.birth_year > 30 and users.birth_year <= 40) and transactions.is_globtrotter = 1 THEN "30s GLOBE TROTTEUR" 
        WHEN users.user_settings_crypto_unlocked = 1 THEN "CRYPTO LOVER" 
        WHEN (users.birth_year > 15 and users.birth_year <= 25) and (total_amounts_in - total_amounts_out < 500) THEN "Jeune en galère" 
        WHEN total_amounts_in - total_amounts_out > 2000 THEN "EPARGNANT"
        ELSE "other people less interesting" END as persona

FROM {{ ref('stg_neo_bank__users') }} AS users

LEFT JOIN {{ ref('transactions_group_by_user') }} AS transactions
    USING (user_id)

LEFT JOIN {{ ref('notifications_group_by_user') }} AS notifications
    USING (user_id)

LEFT JOIN {{ ref('stg_neo_bank__devices') }} AS devices
    USING (user_id)

--where user_id = "user_4565"