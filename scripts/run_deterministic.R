# =============================================================================
# scripts/run_deterministic.R
# FASE 2: Análisis determinístico (caso base)
# =============================================================================

cat("================================================================\n")
cat("  FASE 2: Análisis Determinístico - Caso Base\n")
cat("================================================================\n\n")

# Cargar funciones del modelo
source("R/helpers.R")
source("R/parameters.R")
source("R/model_core.R")

load_packages()

# Asegurar directorios de salida
ensure_dir("output/tables", "output/figures", "output/psa")

# ---------------------------------------------------------------------------
# Definir parámetros del caso base
# ---------------------------------------------------------------------------
cat("Definiendo parámetros del caso base...\n")
params_base <- define_parameters(psa = FALSE)

cat(sprintf("  Año base:              %d\n",    params_base$year))
cat(sprintf("  Población adulta:      %s\n",    formatC(params_base$pop_adult, big.mark=".", format="d")))
cat(sprintf("  Prevalencia obesidad:  %.1f%%\n", params_base$prev_obesity * 100))
cat(sprintf("  N° personas obesas:    %s\n",    formatC(params_base$n_obese, big.mark=".", format="d")))
cat(sprintf("  PIB (USD):             %.1f mil millones\n", params_base$gdp_usd / 1e9))
cat("\n")

# ---------------------------------------------------------------------------
# Ejecutar modelo
# ---------------------------------------------------------------------------
cat("Ejecutando modelo...\n")
results_base <- run_model(params_base)

# ---------------------------------------------------------------------------
# Mostrar resultados
# ---------------------------------------------------------------------------
print_summary(results_base)

# ---------------------------------------------------------------------------
# Guardar outputs
# ---------------------------------------------------------------------------
cat("Guardando resultados...\n")
tables_saved <- save_outputs(results_base, "output/tables")

# Guardar objeto R para uso en fases posteriores
saveRDS(results_base, "output/psa/results_base.rds")
cat("Resultados base guardados en: output/psa/results_base.rds\n")

# ---------------------------------------------------------------------------
# Análisis de sensibilidad univariado (tornado)
# ---------------------------------------------------------------------------
cat("\nEjecutando análisis de sensibilidad univariado (tornado)...\n")
tornado_data <- run_tornado(params_base)

write.csv(tornado_data, "output/tables/tabla4_tornado.csv",
          row.names = FALSE, fileEncoding = "UTF-8")
cat("Datos del tornado guardados en: output/tables/tabla4_tornado.csv\n")

cat("\n")
cat("================================================================\n")
cat("  FASE 2 completada exitosamente.\n")
cat("  Siguiente paso: Rscript scripts/run_psa.R\n")
cat("================================================================\n")
