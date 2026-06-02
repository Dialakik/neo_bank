SELECT
    u.* EXCEPT(created_date),
    u.created_date AS user_created_date,

    d.* EXCEPT(user_id),

    t.* EXCEPT(user_id, created_date),
    t.created_date AS transaction_created_date,

    n.* EXCEPT(user_id, created_date),
    n.created_date AS notification_created_date

FROM {{ ref('stg_neo_bank__users') }} AS u

LEFT JOIN {{ ref('stg_neo_bank__devices') }} AS d
    USING (user_id)

LEFT JOIN {{ ref('stg_neo_bank__transactions') }} AS t
    USING (user_id)

LEFT JOIN {{ ref('stg_neo_bank__notifications') }} AS n
    USING (user_id)