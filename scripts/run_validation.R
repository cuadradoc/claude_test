# =============================================================================
# scripts/run_validation.R
# FASE 5: Validación interna y externa del modelo
# =============================================================================

cat("================================================================\n")
cat("  FASE 5: Validación del Modelo\n")
cat("================================================================\n\n")

source("R/helpers.R")
source("R/parameters.R")
source("R/model_core.R")

load_packages()
ensure_dir("output/tables")

# ---------------------------------------------------------------------------
# Cargar resultados previos
# ---------------------------------------------------------------------------
if (!file.exists("output/psa/results_base.rds")) {
  stop("Faltan resultados. Ejecute primero las fases 2, 3 y 4.")
}
results_base <- readRDS("output/psa/results_base.rds")
psa_df       <- if (file.exists("output/psa/psa_results.rds")) {
  readRDS("output/psa/psa_results.rds")
} else {
  NULL
}

params_base <- results_base$params
summary_b   <- results_base$summary
dc          <- results_base$direct_costs

# Registro de tests de validación
validation_log <- list()
n_pass <- 0L
n_fail <- 0L

check <- function(name, condition, msg_pass, msg_fail) {
  if (condition) {
    cat(sprintf("  [PASS] %s: %s\n", name, msg_pass))
    n_pass <<- n_pass + 1L
  } else {
    cat(sprintf("  [FAIL] %s: %s\n", name, msg_fail))
    n_fail <<- n_fail + 1L
  }
  validation_log[[length(validation_log) + 1]] <<- list(
    test = name, pass = condition,
    message = if (condition) msg_pass else msg_fail
  )
}

# =============================================================================
# VALIDACIÓN 1: Consistencia interna — parámetros
# =============================================================================
cat("--- Validación 1: Parámetros ---\n")

check("Prevalencia obesidad",
  params_base$prev_obesity > 0 & params_base$prev_obesity < 1,
  sprintf("%.1f%% (rango: 0-100%%)", params_base$prev_obesity * 100),
  "Prevalencia fuera de rango [0,1]")

check("Riesgos relativos > 1 (excepto stroke, bca)",
  all(c(params_base$rr_dm2, params_base$rr_htn, params_base$rr_ihd,
        params_base$rr_oa, params_base$rr_osa, params_base$rr_dep,
        params_base$rr_endo, params_base$rr_nafld) > 1),
  "Todos los RR son > 1",
  "Algún RR ≤ 1 donde se esperaba > 1")

check("Costos unitarios positivos",
  all(vapply(paste0("cost_", dc$id), function(k) params_base[[k]] > 0,
             logical(1))),
  "Todos los costos son positivos",
  "Algún costo unitario es ≤ 0")

check("Población obesa coherente",
  params_base$n_obese > 0 & params_base$n_obese < params_base$pop_adult,
  sprintf("%s personas (< pop. adulta %s)",
          fmt_int(params_base$n_obese), fmt_int(params_base$pop_adult)),
  "n_obese fuera del rango esperado")

cat("\n")

# =============================================================================
# VALIDACIÓN 2: FAP plausibles (0–1)
# =============================================================================
cat("--- Validación 2: Fracciones Atribuibles Poblacionales ---\n")

check("Todas las FAP en [0, 1]",
  all(dc$paf >= 0 & dc$paf <= 1),
  sprintf("FAP rango: [%.3f, %.3f]", min(dc$paf), max(dc$paf)),
  "Alguna FAP fuera de [0, 1]")

check("FAP diabetes (> 50%% esperado)",
  dc$paf[dc$id == "dm2"] > 0.50,
  sprintf("FAP DM2 = %.1f%%", dc$paf[dc$id == "dm2"] * 100),
  sprintf("FAP DM2 = %.1f%% (se esperaba > 50%%)",
          dc$paf[dc$id == "dm2"] * 100))

check("FAP stroke (< FAP diabetes)",
  dc$paf[dc$id == "stroke"] < dc$paf[dc$id == "dm2"],
  "FAP stroke < FAP diabetes (coherente con RR menores)",
  "FAP stroke ≥ FAP diabetes (incoherente)")

cat("\n")

# =============================================================================
# VALIDACIÓN 3: Magnitud de costos — plausibilidad
# =============================================================================
cat("--- Validación 3: Plausibilidad de costos ---\n")

# Referencia: estudios similares para LATAM estiman 1–4% del PIB
check("Costo total en rango plausible (0.5–4% PIB)",
  summary_b$pct_gdp >= 0.5 & summary_b$pct_gdp <= 4.0,
  sprintf("%.2f%% del PIB — dentro del rango de literatura (0.5–4%%)",
          summary_b$pct_gdp),
  sprintf("%.2f%% del PIB — fuera del rango de literatura",
          summary_b$pct_gdp))

# Costos directos deben ser < costo total
check("Costos directos < costo total",
  summary_b$total_direct_usd < summary_b$total_cost_usd,
  sprintf("Directos = %.1f%% del total",
          summary_b$total_direct_usd / summary_b$total_cost_usd * 100),
  "Costos directos ≥ costo total (error de suma)")

# Costo por obeso debe estar en rango razonable ($500 – $10,000)
check("Costo por persona obesa ($500–$10,000)",
  summary_b$per_obese_usd >= 500 & summary_b$per_obese_usd <= 10000,
  sprintf("USD %.0f por persona obesa", summary_b$per_obese_usd),
  sprintf("USD %.0f por persona obesa — fuera de rango esperado",
          summary_b$per_obese_usd))

# El mayor componente directo debe ser diabetes o EHGNA (ambas fuertemente
# ligadas a obesidad y con alta prevalencia en Chile — ENS 2016-17)
top_cond  <- dc$id[which.max(dc$total_cost_usd)]
top_label <- dc$label[which.max(dc$total_cost_usd)]
check("Mayor costo directo es DM2 o EHGNA",
  top_cond %in% c("dm2", "nafld"),
  sprintf("%s (epidemiológicamente consistente para Chile)", top_label),
  sprintf("Mayor costo directo: %s — revisar parámetros", top_label))

cat("\n")

# =============================================================================
# VALIDACIÓN 4: Validación cruzada — comparación con literatura
# =============================================================================
cat("--- Validación 4: Comparación con estimaciones publicadas ---\n")

# Referencia: Atella et al. (2017) Europa: ~3% PIB
# Referencia: Rtveladze et al. (2013) México: ~2.1% PIB
# Referencia: Tremmel et al. (2017) Global: 2.47% PIB
# Chile se espera en rango 1.0–2.5% PIB
check("Rango esperado para Chile (1.0–2.5% PIB)",
  summary_b$pct_gdp >= 1.0 & summary_b$pct_gdp <= 2.5,
  sprintf("%.2f%% PIB — compatible con Tremmel 2017 (global: 2.47%%)",
          summary_b$pct_gdp),
  sprintf("%.2f%% PIB — revisar parámetros o supuestos",
          summary_b$pct_gdp))

cat("\n")

# =============================================================================
# VALIDACIÓN 5: PSA — coherencia de distribuciones
# =============================================================================
if (!is.null(psa_df)) {
  cat("--- Validación 5: PSA ---\n")

  n_sim <- nrow(psa_df)
  psa_ci_low  <- quantile(psa_df$pct_gdp, 0.025)
  psa_ci_high <- quantile(psa_df$pct_gdp, 0.975)

  check("IC 95% PSA contiene el caso base",
    summary_b$pct_gdp >= psa_ci_low & summary_b$pct_gdp <= psa_ci_high,
    sprintf("Caso base (%.2f%%) dentro IC 95%% [%.2f%%, %.2f%%]",
            summary_b$pct_gdp, psa_ci_low, psa_ci_high),
    sprintf("Caso base (%.2f%%) FUERA del IC 95%% PSA",
            summary_b$pct_gdp))

  check("PSA sin valores negativos de costo",
    all(psa_df$total_cost_usd > 0),
    sprintf("Min. costo PSA: %s", fmt_usd(min(psa_df$total_cost_usd))),
    "Existen iteraciones con costo total ≤ 0 (error de muestreo)")

  check("PSA convergencia: CV(costo total) < 30%",
    sd(psa_df$total_cost_usd) / mean(psa_df$total_cost_usd) < 0.30,
    sprintf("CV = %.1f%%",
            sd(psa_df$total_cost_usd) / mean(psa_df$total_cost_usd) * 100),
    sprintf("CV = %.1f%% — alta variabilidad, verificar distribuciones",
            sd(psa_df$total_cost_usd) / mean(psa_df$total_cost_usd) * 100))

  cat("\n")
}

# =============================================================================
# REPORTE FINAL
# =============================================================================
cat("================================================================\n")
cat(sprintf("  RESULTADO DE VALIDACIÓN: %d PASS / %d FAIL\n",
            n_pass, n_fail))

if (n_fail == 0) {
  cat("  Estado: MODELO VALIDADO — todos los checks pasaron.\n")
} else {
  cat(sprintf("  Estado: REVISAR — %d check(s) fallaron.\n", n_fail))
  cat("  Ver output/tables/validation_report.csv para detalles.\n")
}
cat("================================================================\n\n")

# Guardar reporte de validación
val_df <- do.call(rbind, lapply(validation_log, as.data.frame,
                                stringsAsFactors = FALSE))
write.csv(val_df,
          file("output/tables/tabla5_validacion.csv", encoding = "UTF-8"),
          row.names = FALSE)
cat("Reporte de validación guardado en: output/tables/tabla5_validacion.csv\n")

cat("\n")
cat("  Siguiente paso: bash scripts/git_release.sh\n")

# Salir con código de error si hay fallas
if (n_fail > 0) quit(status = 1)
