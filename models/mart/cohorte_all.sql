WITH base_users AS (
  SELECT
    user_id,
    -- 1. On identifie le mois de départ (la cohorte)
    DATE_TRUNC(user_created_date, MONTH) AS mois_cohorte,

    user_created_date AS date_inscription,
    date_churn
  FROM {{ ref('users_full') }}
  -- Filtrage sur ta période cible
  WHERE user_created_date BETWEEN '2018-01-01' AND '2019-05-15'
),

calcul_survie AS (
  SELECT
    user_id,
    mois_cohorte,
    -- 2. On calcule combien de mois l'utilisateur est resté actif avant de churner
    -- Si date_churn est NULL, on prend la date d'aujourd'hui (2026-06-04) pour simuler sa présence actuelle
    DATE_DIFF(COALESCE(date_churn, CURRENT_DATE()), date_inscription, MONTH) AS mois_actifs
  FROM base_users
)   

-- 3. On agrège mois par mois pour créer la matrice de cohorte
SELECT
  mois_cohorte,
  COUNT(DISTINCT user_id) AS volume_initial,
  
  -- % d'utilisateurs encore là le mois même (M0) -> Logiquement 100%
  ROUND(COUNT(DISTINCT CASE WHEN mois_actifs >= 0 THEN user_id END) * 100.0 / COUNT(DISTINCT user_id), 1) AS mois_0_retention_pct,
  
  -- % d'utilisateurs encore là après 1 mois (M+1)
  ROUND(COUNT(DISTINCT CASE WHEN mois_actifs >= 1 THEN user_id END) * 100.0 / COUNT(DISTINCT user_id), 1) AS mois_1_retention_pct,
  
  -- % d'utilisateurs encore là après 2 mois (M+2)
  ROUND(COUNT(DISTINCT CASE WHEN mois_actifs >= 2 THEN user_id END) * 100.0 / COUNT(DISTINCT user_id), 1) AS mois_2_retention_pct,
  
  -- % d'utilisateurs encore là après 3 mois (M+3)
  ROUND(COUNT(DISTINCT CASE WHEN mois_actifs >= 3 THEN user_id END) * 100.0 / COUNT(DISTINCT user_id), 1) AS mois_3_retention_pct,
  
  -- % d'utilisateurs encore là après 6 mois (M+6)
  ROUND(COUNT(DISTINCT CASE WHEN mois_actifs >= 6 THEN user_id END) * 100.0 / COUNT(DISTINCT user_id), 1) AS mois_6_retention_pct

FROM calcul_survie
GROUP BY mois_cohorte
ORDER BY mois_cohorte ASC