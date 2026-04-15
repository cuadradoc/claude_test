# =============================================================================
# scripts/run_psa.R
# FASE 3: Análisis de Sensibilidad Probabilístico (PSA) - Monte Carlo
#
# Uso:
#   Rscript scripts/run_psa.R            # 1000 iteraciones (default)
#   N_SIM=100 Rscript scripts/run_psa.R  # prueba rápida con 100 iteraciones
# =============================================================================

# Número de simulaciones (puede sobreescribirse con variable de entorno)
n_sim <- as.integer(Sys.getenv("N_SIM", unset = "1000"))

cat("================================================================\n")
cat(sprintf("  FASE 3: PSA Monte Carlo (%d iteraciones)\n", n_sim))
cat("================================================================\n\n")

source("R/helpers.R")
source("R/parameters.R")
source("R/model_core.R")

load_packages()
ensure_dir("output/psa", "output/tables")

# ---------------------------------------------------------------------------
# Cargar caso base (debe existir desde FASE 2)
# ---------------------------------------------------------------------------
if (!file.exists("output/psa/results_base.rds")) {
  stop("No se encontró output/psa/results_base.rds.\n",
       "Ejecute primero: Rscript scripts/run_deterministic.R")
}
results_base <- readRDS("output/psa/results_base.rds")
base_total   <- results_base$summary$total_cost_usd
base_pct_gdp <- results_base$summary$pct_gdp

cat(sprintf("Caso base: %s (%.2f%% PIB)\n\n",
            fmt_usd(base_total), base_pct_gdp))

# ---------------------------------------------------------------------------
# Ejecutar PSA
# ---------------------------------------------------------------------------
set.seed(42)
t_start   <- proc.time()
psa_df    <- run_psa(n_sim = n_sim, seed = 42)
t_elapsed <- (proc.time() - t_start)[["elapsed"]]

cat(sprintf("\nTiempo de ejecución PSA: %.1f segundos\n\n", t_elapsed))

# ---------------------------------------------------------------------------
# Resultados de la PSA
# ---------------------------------------------------------------------------
cat("--- RESULTADOS PSA (IC 95%%) ---\n")
cat(sprintf("  Costo total:\n"))
cat(sprintf("    Media:    %s\n",    fmt_usd(mean(psa_df$total_cost_usd))))
cat(sprintf("    IC 95%%:  %s  -  %s\n",
            fmt_usd(quantile(psa_df$total_cost_usd, 0.025)),
            fmt_usd(quantile(psa_df$total_cost_usd, 0.975))))
cat(sprintf("  %% del PIB:\n"))
cat(sprintf("    Media:    %.2f%%\n", mean(psa_df$pct_gdp)))
cat(sprintf("    IC 95%%:  %.2f%%  -  %.2f%%\n",
            quantile(psa_df$pct_gdp, 0.025),
            quantile(psa_df$pct_gdp, 0.975)))
cat("\n")

# ---------------------------------------------------------------------------
# Guardar resultados PSA
# ---------------------------------------------------------------------------
saveRDS(psa_df, "output/psa/psa_results.rds")
cat("Resultados PSA guardados en: output/psa/psa_results.rds\n")

psa_summary <- save_psa_summary(psa_df, "output/tables")

# Guardar CSV completo de iteraciones
write.csv(psa_df,
          file("output/psa/psa_iterations.csv", encoding = "UTF-8"),
          row.names = FALSE)
cat("Iteraciones completas guardadas en: output/psa/psa_iterations.csv\n")

cat("\n")
cat("================================================================\n")
cat("  FASE 3 completada exitosamente.\n")
cat("  Siguiente paso: Rscript scripts/generate_figures.R\n")
cat("================================================================\n")
