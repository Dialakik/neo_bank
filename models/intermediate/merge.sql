SELECT
    u.*,
    d.*,
    t.*,
    n.*
FROM {{ ref('stg_neo_bank__users') }} AS u
LEFT JOIN {{ ref('stg_neo_bank__devices') }} AS d
    USING (user_id)
LEFT JOIN {{ ref('stg_neo_bank__transactions') }} AS t
    USING (user_id)
LEFT JOIN {{ ref('stg_neo_bank__notifications') }} AS n
    USING (user_id)