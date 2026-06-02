SELECT
    users.* EXCEPT(created_date),
    users.created_date AS user_created_date,

    transactions.* EXCEPT(user_id),

    notifications.* EXCEPT(user_id),

    devices.* EXCEPT(user_id)

FROM {{ ref('stg_neo_bank__users') }} AS users

LEFT JOIN {{ ref('transactions_group_by_user') }} AS transactions
    USING (user_id)

LEFT JOIN {{ ref('notifications_group_by_user') }} AS notifications
    USING (user_id)

LEFT JOIN {{ ref('stg_neo_bank__devices') }} AS devices
    USING (user_id)