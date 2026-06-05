SELECT
    users.*,
    transactions.* EXCEPT(user_id)

FROM {{ ref('stg_neo_bank__transactions') }} AS transactions

JOIN {{ ref('users_full') }} AS users
    USING (user_id)
order by user_id