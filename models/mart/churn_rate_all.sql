WITH months AS (
  -- 1. Génère une liste de tous les mois à analyser (Renvoie des DATEs)
  SELECT DISTINCT DATE_TRUNC(month, MONTH) AS mois
  FROM UNNEST(GENERATE_DATE_ARRAY('2018-01-01', '2019-05-16', INTERVAL 1 MONTH)) AS month
),

user_monthly_status AS (
  -- 2. Pour chaque utilisateur et chaque mois, on regarde s'il était actif et s'il a churné
  SELECT 
    m.mois,
    user.user_id,
    -- Pas besoin d'EXTRACT car vos colonnes sont déjà des DATEs
    CASE 
      WHEN DATE_TRUNC(user.user_created_date, MONTH) <= m.mois 
       AND (user.date_churn IS NULL OR DATE_TRUNC(user.date_churn, MONTH) >= m.mois) 
      THEN 1 ELSE 0 
    END AS is_active,
    
    CASE 
      WHEN DATE_TRUNC(user.date_churn, MONTH) = m.mois 
      THEN 1 ELSE 0 
    END AS is_churned
  FROM months m
  CROSS JOIN {{ ref('users_full') }} user
)

-- 3. Agrégation finale par mois
SELECT
  FORMAT_DATE('%Y-%m', mois) AS mois_annee,
  SUM(is_active) AS utilisateurs_actifs,
  SUM(is_churned) AS utilisateurs_churnes,
  SAFE_DIVIDE(SUM(is_churned), SUM(is_active)) AS churn_rate
FROM user_monthly_status
WHERE is_active > 0 OR is_churned > 0
GROUP BY mois
ORDER BY mois DESC