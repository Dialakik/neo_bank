SELECT
  ROUND(COUNTIF(plan <> "STANDARD") / COUNT(*), 2) AS premium_global,
  ROUND(COUNTIF(IS_CRYPTO_USER = 1 and plan <> "STANDARD") / COUNTIF(IS_CRYPTO_USER = 1), 2) AS premium_crypto,
  ROUND(COUNTIF(IS_GLOBTROTTEUR = 1 and plan <> "STANDARD") / COUNTIF(IS_GLOBTROTTEUR = 1), 2) AS premium_voyageur,
  ROUND(COUNTIF(IS_JEUNE_CSP_MOINS = 1 and plan <> "STANDARD") / COUNTIF(IS_JEUNE_CSP_MOINS = 1), 2) AS premium_jeune_csp_moins,
  ROUND(AVG(total_amounts_in), 2) AS moyenne_depense_globale,
  ROUND(AVG(CASE WHEN IS_CRYPTO_USER = 1 THEN total_amounts_in END), 2) AS moyenne_depense_crypto,
  ROUND(AVG(CASE WHEN IS_GLOBTROTTEUR = 1 THEN total_amounts_in END), 2) AS moyenne_depense_voyageur,
  ROUND(AVG(CASE WHEN IS_JEUNE_CSP_MOINS = 1 THEN total_amounts_in END), 2) AS moyenne_depense_jeune_csp_moins,
  ROUND(AVG(nb_transactions), 2) AS moyenne_nb_transactions_globale,
  ROUND(AVG(CASE WHEN IS_CRYPTO_USER = 1 THEN nb_transactions END), 2) AS moyenne_nb_transactions_crypto,
FROM {{ ref('users_full') }}