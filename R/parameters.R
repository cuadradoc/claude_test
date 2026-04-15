# =============================================================================
# R/parameters.R
# Parámetros del modelo de carga económica de obesidad en Chile
#
# Fuentes:
#   - INE 2023 (demografía)
#   - ENS 2016-17 (prevalencias)
#   - Banco Central Chile 2023 (PIB, salarios)
#   - Meta-análisis Lancet 2017, Bhaskaran 2014 (riesgos relativos)
#   - FONASA, MINSAL (costos unitarios)
# =============================================================================

#' Define todos los parámetros del modelo.
#'
#' @param psa  Lógico. Si TRUE, muestrea de distribuciones de incertidumbre.
#' @param seed Entero. Semilla aleatoria (sólo relevante cuando psa = TRUE).
#' @return Lista nombrada con todos los parámetros del modelo.

define_parameters <- function(psa = FALSE, seed = NULL) {

  if (psa && !is.null(seed)) set.seed(seed)

  p <- list()

  # ---------------------------------------------------------------------------
  # PARÁMETROS DEMOGRÁFICOS (INE 2023)
  # ---------------------------------------------------------------------------
  p$year               <- 2023
  p$pop_total          <- 19458310   # Población total Chile
  p$pop_adult          <- 14700000   # Adultos 15+ años
  p$pop_working_age    <- 8800000    # Edad laboral 20-64 años
  p$employment_rate    <- 0.575      # Tasa de empleo (INE Q4 2023)
  p$pop_employed       <- p$pop_working_age * p$employment_rate
  p$prop_female_adult  <- 0.514      # Proporción mujeres en adultos

  # ---------------------------------------------------------------------------
  # PARÁMETROS ECONÓMICOS (Banco Central Chile 2023)
  # ---------------------------------------------------------------------------
  p$gdp_usd            <- 344e9     # PIB Chile 2023 (USD)
  p$exchange_rate      <- 850       # CLP por USD (promedio 2023)
  p$gdp_clp            <- p$gdp_usd * p$exchange_rate
  p$gdp_percapita_usd  <- p$gdp_usd / p$pop_total
  p$wage_annual_usd    <- 14400     # Salario promedio anual (USD)
  p$wage_daily_usd     <- p$wage_annual_usd / 240  # 240 días hábiles/año

  # ---------------------------------------------------------------------------
  # PREVALENCIA DE OBESIDAD (ENS 2016-17, proyectado a 2023)
  # ---------------------------------------------------------------------------
  if (psa) {
    p$prev_obesity <- rbeta_pert(1, min = 0.320, mode = 0.344, max = 0.370)
  } else {
    p$prev_obesity <- 0.344   # 34.4% (IMC ≥ 30)
  }

  p$prev_overweight    <- 0.398   # Sobrepeso IMC 25-29.9
  p$prev_obese_severe  <- 0.036   # Obesidad severa IMC ≥ 40
  p$n_obese            <- round(p$pop_adult * p$prev_obesity)

  # ---------------------------------------------------------------------------
  # PREVALENCIA DE COMORBILIDADES EN ADULTOS CHILENOS
  # Fuentes: ENS 2016-17, MINSAL boletines epidemiológicos 2022-23
  # ---------------------------------------------------------------------------
  p$prev_dm2    <- 0.123   # Diabetes mellitus tipo 2
  p$prev_htn    <- 0.276   # Hipertensión arterial
  p$prev_ihd    <- 0.035   # Cardiopatía isquémica
  p$prev_stroke <- 0.025   # ACV / enfermedad cerebrovascular
  p$prev_oa     <- 0.082   # Osteoartritis
  p$prev_osa    <- 0.050   # Apnea obstructiva del sueño
  p$prev_dep    <- 0.172   # Depresión
  p$prev_crc    <- 0.003   # Cáncer colorrectal (prevalencia 5 años)
  p$prev_bca    <- 0.004   # Cáncer de mama (mujeres, prevalencia 5 años)
  p$prev_endo   <- 0.001   # Cáncer endometrial (mujeres)
  p$prev_rcc    <- 0.001   # Cáncer renal
  p$prev_nafld  <- 0.235   # Hígado graso no alcohólico (EHGNA)

  # ---------------------------------------------------------------------------
  # RIESGOS RELATIVOS (obesidad IMC ≥ 30 vs. peso normal)
  # Fuentes: Collaborators 2017 Lancet, Bhaskaran 2014 Lancet,
  #          WHO Global Action Plan, meta-análisis específicos
  # Distribución PSA: log-normal (σ calibrado desde IC 95%)
  # ---------------------------------------------------------------------------
  rr_defaults <- c(
    dm2    = 7.19,  # Diabetes tipo 2
    htn    = 1.65,  # Hipertensión
    ihd    = 1.72,  # Cardiopatía isquémica
    stroke = 1.35,  # ACV
    oa     = 1.96,  # Osteoartritis
    osa    = 2.50,  # Apnea del sueño
    dep    = 1.38,  # Depresión
    crc    = 1.20,  # Cáncer colorrectal
    bca    = 1.12,  # Cáncer mama
    endo   = 3.22,  # Cáncer endometrial
    rcc    = 1.54,  # Cáncer renal
    nafld  = 3.50   # EHGNA
  )

  rr_sigma <- c(
    dm2    = 0.10, htn    = 0.08, ihd    = 0.09, stroke = 0.10,
    oa     = 0.08, osa    = 0.12, dep    = 0.10, crc    = 0.10,
    bca    = 0.08, endo   = 0.12, rcc    = 0.11, nafld  = 0.10
  )

  for (cond in names(rr_defaults)) {
    key <- paste0("rr_", cond)
    if (psa) {
      p[[key]] <- rlnorm(1, meanlog = log(rr_defaults[cond]),
                         sdlog = rr_sigma[cond])
    } else {
      p[[key]] <- rr_defaults[cond]
    }
  }

  # ---------------------------------------------------------------------------
  # COSTOS UNITARIOS DIRECTOS (USD por caso por año, precios 2023)
  # Fuentes: FONASA prestaciones valoradas, Arteaga et al. 2013,
  #          estudios de costo-efectividad en Chile, ajuste PPP
  # Distribución PSA: gamma (CV = 20%, shape = 25)
  # ---------------------------------------------------------------------------
  cost_defaults <- c(
    dm2    = 1000,  # Diabetes: consultas + medicamentos + complicaciones
    htn    =  400,  # Hipertensión: control + fármacos
    ihd    = 2000,  # Cardiopatía isquémica: hospitalizaciones + procedimientos
    stroke = 2500,  # ACV: hospitalización + rehabilitación
    oa     =  600,  # Osteoartritis: fisioterapia + analgésicos + cirugía
    osa    =  300,  # Apnea: CPAP + seguimiento
    dep    =  500,  # Depresión: psicoterapia + antidepresivos
    crc    = 4000,  # Cáncer colorrectal: quimio + cirugía
    bca    = 4000,  # Cáncer mama: tratamiento oncológico
    endo   = 3500,  # Cáncer endometrial: cirugía + tratamiento
    rcc    = 4000,  # Cáncer renal: nefrectomía + inmunoterapia
    nafld  =  800   # EHGNA: seguimiento + tratamiento complicaciones
  )

  for (cond in names(cost_defaults)) {
    key <- paste0("cost_", cond)
    shape <- 25   # CV = 1/sqrt(shape) ≈ 20%
    if (psa) {
      p[[key]] <- rgamma(1, shape = shape,
                         rate  = shape / cost_defaults[cond])
    } else {
      p[[key]] <- cost_defaults[cond]
    }
  }

  # ---------------------------------------------------------------------------
  # PARÁMETROS DE COSTOS INDIRECTOS
  # ---------------------------------------------------------------------------

  # Ausentismo laboral
  if (psa) {
    p$days_lost_obese     <- rgamma(1, shape = 16, rate = 16 / 8.2)
    p$days_lost_non_obese <- rgamma(1, shape = 16, rate = 16 / 3.5)
    p$presenteeism_factor <- rbeta(1, shape1 = 6, shape2 = 234)  # ~2.5%
    p$mortality_friction  <- rbeta_pert(1, min = 0.55, mode = 0.65, max = 0.75)
  } else {
    p$days_lost_obese     <- 8.2    # Días perdidos/año trabajador obeso
    p$days_lost_non_obese <- 3.5    # Días perdidos/año trabajador no obeso
    p$presenteeism_factor <- 0.025  # Pérdida productividad presente (2.5%)
    p$mortality_friction  <- 0.65   # Factor de costo friccional
  }

  # Mortalidad prematura atribuible a obesidad
  if (psa) {
    p$obesity_attr_deaths <- round(rgamma(1, shape = 25, rate = 25 / 13000))
    p$ypll_per_death      <- rgamma(1, shape = 16, rate = 16 / 10)
  } else {
    p$obesity_attr_deaths <- 13000  # Muertes/año atribuibles a obesidad en Chile
    p$ypll_per_death      <- 10     # Años vida productiva perdidos por muerte
  }

  return(p)
}

# =============================================================================
# FUNCIONES AUXILIARES DE DISTRIBUCIONES
# =============================================================================

#' Distribución beta PERT (parameterizada por mín, moda, máx).
#' Útil para modelar proporciones con límites conocidos.
#'
#' @param n      Número de muestras.
#' @param min    Valor mínimo.
#' @param mode   Valor más probable (moda).
#' @param max    Valor máximo.
#' @param lambda Factor de forma (default 4 = PERT estándar).
rbeta_pert <- function(n, min, mode, max, lambda = 4) {
  mu     <- (min + lambda * mode + max) / (lambda + 2)
  alpha1 <- (mu - min) * (2 * mode - min - max) / ((mode - mu) * (max - min))
  alpha2 <- alpha1 * (max - mu) / (mu - min)
  if (alpha1 <= 0 || alpha2 <= 0) return(rep(mode, n))
  min + (max - min) * rbeta(n, alpha1, alpha2)
}
