# =============================================================================
# R/model_core.R
# Funciones principales del modelo de carga económica de obesidad
# =============================================================================

#' Calcula la Fracción Atribuible Poblacional (FAP / PAF).
#'
#' Fórmula de Levin: FAP = p*(RR-1) / (p*(RR-1) + 1)
#'
#' @param prev_obesity  Prevalencia de obesidad en la población.
#' @param rr            Riesgo relativo de la condición dado obesidad.
#' @return FAP escalar entre 0 y 1.

compute_paf <- function(prev_obesity, rr) {
  (prev_obesity * (rr - 1)) / (prev_obesity * (rr - 1) + 1)
}

# =============================================================================
# MODELO PRINCIPAL
# =============================================================================

#' Ejecuta el modelo completo de carga económica.
#'
#' @param params  Lista de parámetros generada por `define_parameters()`.
#' @return Lista con componentes: direct_costs, indirect, summary.

run_model <- function(params) {

  p <- params

  pop_female_adult <- p$pop_adult * p$prop_female_adult

  # ---------------------------------------------------------------------------
  # COSTOS DIRECTOS (por condición)
  # ---------------------------------------------------------------------------

  conditions <- data.frame(
    id        = c("dm2","htn","ihd","stroke","oa","osa",
                  "dep","crc","bca","endo","rcc","nafld"),
    label     = c("Diabetes tipo 2","Hipertensión","Cardiopatía isquémica",
                  "ACV / Enf. cerebrovascular","Osteoartritis",
                  "Apnea obstructiva del sueño","Depresión",
                  "Cáncer colorrectal","Cáncer de mama",
                  "Cáncer endometrial","Cáncer renal","EHGNA"),
    female_only = c(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,
                    FALSE,FALSE,TRUE,TRUE,FALSE,FALSE),
    stringsAsFactors = FALSE
  )

  # Extraer prevalencias, RR y costos unitarios de la lista de parámetros
  conditions$prevalence   <- vapply(conditions$id,
    function(x) p[[paste0("prev_",  x)]], numeric(1))
  conditions$rr           <- vapply(conditions$id,
    function(x) p[[paste0("rr_",    x)]], numeric(1))
  conditions$unit_cost_usd <- vapply(conditions$id,
    function(x) p[[paste0("cost_",  x)]], numeric(1))

  conditions$ref_pop <- ifelse(
    conditions$female_only, pop_female_adult, p$pop_adult
  )

  conditions$paf <- compute_paf(p$prev_obesity, conditions$rr)

  conditions$cases_total        <- conditions$ref_pop * conditions$prevalence
  conditions$cases_attributable <- conditions$cases_total * conditions$paf
  conditions$total_cost_usd     <- conditions$cases_attributable *
                                    conditions$unit_cost_usd

  total_direct_usd <- sum(conditions$total_cost_usd)

  # ---------------------------------------------------------------------------
  # COSTOS INDIRECTOS
  # ---------------------------------------------------------------------------

  # Obesos en edad y condición de trabajar
  n_obese_employed <- p$n_obese *
    (p$pop_working_age / p$pop_adult) *
    p$employment_rate

  # 1. Ausentismo: días extra perdidos × salario diario
  extra_days       <- p$days_lost_obese - p$days_lost_non_obese
  cost_absent_usd  <- n_obese_employed * extra_days * p$wage_daily_usd

  # 2. Presentismo: pérdida productividad en el trabajo
  cost_present_usd <- n_obese_employed * 240 *
                       p$wage_daily_usd * p$presenteeism_factor

  # 3. Mortalidad prematura (enfoque capital humano con factor friccional)
  cost_mort_usd    <- p$obesity_attr_deaths * p$ypll_per_death *
                       p$wage_annual_usd    * p$mortality_friction

  total_indirect_usd <- cost_absent_usd + cost_present_usd + cost_mort_usd

  # ---------------------------------------------------------------------------
  # RESUMEN AGREGADO
  # ---------------------------------------------------------------------------

  total_cost_usd <- total_direct_usd + total_indirect_usd

  summary_stats <- list(
    total_direct_usd   = total_direct_usd,
    total_indirect_usd = total_indirect_usd,
    cost_absenteeism   = cost_absent_usd,
    cost_presenteeism  = cost_present_usd,
    cost_mortality     = cost_mort_usd,
    total_cost_usd     = total_cost_usd,
    pct_gdp            = total_cost_usd / p$gdp_usd * 100,
    per_capita_usd     = total_cost_usd / p$pop_total,
    per_obese_usd      = total_cost_usd / p$n_obese,
    n_obese            = p$n_obese,
    n_cases_total      = sum(conditions$cases_attributable)
  )

  list(
    params       = params,
    direct_costs = conditions,
    indirect     = list(
      absenteeism  = cost_absent_usd,
      presenteeism = cost_present_usd,
      mortality    = cost_mort_usd,
      total        = total_indirect_usd
    ),
    summary      = summary_stats
  )
}

# =============================================================================
# ANÁLISIS DE SENSIBILIDAD PROBABILÍSTICO (PSA)
# =============================================================================

#' Ejecuta PSA mediante simulación Monte Carlo.
#'
#' @param n_sim  Número de iteraciones (default 1000).
#' @param seed   Semilla aleatoria para reproducibilidad.
#' @return Data frame con una fila por iteración y columnas de resumen.

run_psa <- function(n_sim = 1000, seed = 42) {

  set.seed(seed)

  cat(sprintf("Iniciando PSA con %d iteraciones...\n", n_sim))
  pb <- txtProgressBar(min = 0, max = n_sim, style = 3)

  results <- vector("list", n_sim)

  for (i in seq_len(n_sim)) {
    params_i    <- define_parameters(psa = TRUE)
    model_i     <- run_model(params_i)
    results[[i]] <- as.data.frame(model_i$summary)
    setTxtProgressBar(pb, i)
  }

  close(pb)
  cat("\n")

  do.call(rbind, results)
}

# =============================================================================
# ANÁLISIS DE SENSIBILIDAD UNIVARIADO (Tornado)
# =============================================================================

#' Genera datos para diagrama de tornado (análisis one-way).
#'
#' Varía cada parámetro ±20% y registra el impacto en el costo total.
#'
#' @param params_base  Parámetros del caso base.
#' @return Data frame con impacto por parámetro.

run_tornado <- function(params_base) {

  base_result <- run_model(params_base)
  base_cost   <- base_result$summary$total_cost_usd

  # Parámetros a variar y sus rangos (±20% del valor base)
  param_keys <- c(
    "prev_obesity",   "rr_dm2",    "rr_htn",   "rr_nafld",
    "cost_dm2",       "cost_ihd",  "cost_nafld",
    "days_lost_obese","presenteeism_factor","obesity_attr_deaths",
    "ypll_per_death", "mortality_friction"
  )

  tornado_rows <- lapply(param_keys, function(key) {
    base_val <- params_base[[key]]

    # Variación baja (-20%)
    p_low        <- params_base
    p_low[[key]] <- base_val * 0.80
    cost_low     <- run_model(p_low)$summary$total_cost_usd

    # Variación alta (+20%)
    p_high        <- params_base
    p_high[[key]] <- base_val * 1.20
    cost_high     <- run_model(p_high)$summary$total_cost_usd

    data.frame(
      parameter = key,
      base      = base_cost,
      low       = cost_low,
      high      = cost_high,
      swing     = abs(cost_high - cost_low),
      stringsAsFactors = FALSE
    )
  })

  df <- do.call(rbind, tornado_rows)
  df[order(-df$swing), ]
}
