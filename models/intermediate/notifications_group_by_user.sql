SELECT
user_id,
count(*) as nb_notifications
FROM {{ ref('stg_neo_bank__notifications') }} AS notif
GROUP BY user_id
