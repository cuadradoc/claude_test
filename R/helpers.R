# =============================================================================
# R/helpers.R
# Funciones auxiliares: carga de paquetes, formateo y guardado de resultados
# =============================================================================

#' Carga (e instala si es necesario) los paquetes requeridos.
load_packages <- function() {
  # Asegurar locale UTF-8 para manejar correctamente caracteres especiales
  Sys.setlocale("LC_ALL", "C.utf8")

  required <- c("dplyr", "tidyr", "ggplot2", "scales", "openxlsx", "knitr")
  for (pkg in required) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      message(sprintf("Instalando paquete: %s", pkg))
      install.packages(pkg, repos = "https://cloud.r-project.org")
    }
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
  }
}

# =============================================================================
# FORMATEO DE NÚMEROS
# =============================================================================

#' Formatea un valor en USD como texto legible (millones o miles de millones).
fmt_usd <- function(x, digits = 2) {
  if (abs(x) >= 1e9) {
    sprintf("USD %.2f mil millones", x / 1e9)
  } else if (abs(x) >= 1e6) {
    sprintf("USD %.1f millones", x / 1e6)
  } else {
    sprintf("USD %.0f", x)
  }
}

#' Formatea porcentaje del PIB.
fmt_pct_gdp <- function(pct) sprintf("%.2f%% del PIB", pct)

#' Formatea número entero con separadores de miles.
fmt_int <- function(x) formatC(round(x), format = "d", big.mark = ",")

# =============================================================================
# IMPRESIÓN DE RESULTADOS EN CONSOLA
# =============================================================================

#' Imprime resumen ejecutivo del análisis determinístico.
#'
#' @param results  Objeto devuelto por `run_model()`.
print_summary <- function(results) {

  s <- results$summary
  p <- results$params

  cat("\n")
  cat("================================================================\n")
  cat("  CARGA ECONÓMICA DE LA OBESIDAD EN CHILE\n")
  cat(sprintf("  Año base: %d  |  Tipo de cambio: %.0f CLP/USD\n",
              p$year, p$exchange_rate))
  cat("================================================================\n\n")

  cat(sprintf("Población obesa (adultos):   %s personas\n",
              fmt_int(s$n_obese)))
  cat(sprintf("Prevalencia obesidad:         %.1f%%\n",
              p$prev_obesity * 100))
  cat(sprintf("Casos atribuibles (total):    %s\n\n",
              fmt_int(s$n_cases_total)))

  cat("--- COSTOS DIRECTOS ---\n")
  dc <- results$direct_costs[order(-results$direct_costs$total_cost_usd), ]
  for (i in seq_len(nrow(dc))) {
    cat(sprintf("  %-35s %s  (FAP: %.1f%%)\n",
                dc$label[i],
                fmt_usd(dc$total_cost_usd[i]),
                dc$paf[i] * 100))
  }
  cat(sprintf("  %-35s %s\n", "TOTAL DIRECTO:",
              fmt_usd(s$total_direct_usd)))

  cat("\n--- COSTOS INDIRECTOS ---\n")
  cat(sprintf("  %-35s %s\n", "Ausentismo laboral:", fmt_usd(s$cost_absenteeism)))
  cat(sprintf("  %-35s %s\n", "Presentismo:",        fmt_usd(s$cost_presenteeism)))
  cat(sprintf("  %-35s %s\n", "Mortalidad prematura:", fmt_usd(s$cost_mortality)))
  cat(sprintf("  %-35s %s\n", "TOTAL INDIRECTO:",     fmt_usd(s$total_indirect_usd)))

  cat("\n================================================================\n")
  cat(sprintf("  COSTO TOTAL:   %s\n",     fmt_usd(s$total_cost_usd)))
  cat(sprintf("  %% del PIB:    %s\n",     fmt_pct_gdp(s$pct_gdp)))
  cat(sprintf("  Per cápita:    %s\n",     fmt_usd(s$per_capita_usd)))
  cat(sprintf("  Por obeso/a:   %s\n",     fmt_usd(s$per_obese_usd)))
  cat("================================================================\n\n")
}

# =============================================================================
# GUARDADO DE RESULTADOS
# =============================================================================

#' Crea directorios si no existen.
ensure_dir <- function(...) {
  for (d in c(...)) {
    if (!dir.exists(d)) dir.create(d, recursive = TRUE)
  }
}

#' Guarda tablas del análisis determinístico (CSV + Excel).
#'
#' @param results     Objeto devuelto por `run_model()`.
#' @param output_dir  Directorio de salida.
save_outputs <- function(results, output_dir = "output/tables") {

  ensure_dir(output_dir)

  s  <- results$summary
  dc <- results$direct_costs

  # --- Tabla 1: Costos directos por condición ---
  tab_direct <- data.frame(
    Condicion         = dc$label,
    Prevalencia_pct   = round(dc$prevalence * 100, 1),
    Riesgo_Relativo   = round(dc$rr, 2),
    FAP_pct           = round(dc$paf * 100, 1),
    Casos_Atribuibles = round(dc$cases_attributable),
    Costo_Unitario_USD= round(dc$unit_cost_usd),
    Costo_Total_MUSD  = round(dc$total_cost_usd / 1e6, 1),
    stringsAsFactors  = FALSE
  )
  tab_direct <- tab_direct[order(-tab_direct$Costo_Total_MUSD), ]

  write.csv(tab_direct,
            file(file.path(output_dir, "tabla1_costos_directos.csv"), encoding = "UTF-8"),
            row.names = FALSE)

  # --- Tabla 2: Resumen de costos ---
  tab_summary <- data.frame(
    Componente    = c("Costos directos", "  Ausentismo", "  Presentismo",
                      "  Mortalidad prematura", "Costos indirectos", "TOTAL"),
    Monto_MUSD    = c(s$total_direct_usd,
                      s$cost_absenteeism, s$cost_presenteeism,
                      s$cost_mortality,   s$total_indirect_usd,
                      s$total_cost_usd) / 1e6,
    Porcentaje    = c(s$total_direct_usd / s$total_cost_usd * 100,
                      s$cost_absenteeism / s$total_cost_usd * 100,
                      s$cost_presenteeism / s$total_cost_usd * 100,
                      s$cost_mortality / s$total_cost_usd * 100,
                      s$total_indirect_usd / s$total_cost_usd * 100,
                      100),
    stringsAsFactors = FALSE
  )
  tab_summary$Monto_MUSD <- round(tab_summary$Monto_MUSD, 1)
  tab_summary$Porcentaje <- round(tab_summary$Porcentaje, 1)

  write.csv(tab_summary,
            file(file.path(output_dir, "tabla2_resumen_costos.csv"), encoding = "UTF-8"),
            row.names = FALSE)

  # --- Excel con ambas tablas ---
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "Costos Directos")
  openxlsx::addWorksheet(wb, "Resumen")
  openxlsx::writeData(wb, "Costos Directos", tab_direct)
  openxlsx::writeData(wb, "Resumen",         tab_summary)
  openxlsx::saveWorkbook(wb, file.path(output_dir, "resultados_determinisitcos.xlsx"),
                         overwrite = TRUE)

  cat(sprintf("Tablas guardadas en: %s\n", output_dir))
  invisible(list(direct = tab_direct, summary = tab_summary))
}

#' Guarda resumen de resultados PSA (CSV + percentiles).
#'
#' @param psa_df     Data frame devuelto por `run_psa()`.
#' @param output_dir Directorio de salida.
save_psa_summary <- function(psa_df, output_dir = "output/tables") {

  ensure_dir(output_dir)

  numeric_cols <- names(psa_df)[sapply(psa_df, is.numeric)]

  psa_summary <- do.call(rbind, lapply(numeric_cols, function(col) {
    x <- psa_df[[col]]
    data.frame(
      Variable = col,
      Media    = round(mean(x, na.rm = TRUE), 2),
      Mediana  = round(median(x, na.rm = TRUE), 2),
      P2_5     = round(quantile(x, 0.025, na.rm = TRUE), 2),
      P97_5    = round(quantile(x, 0.975, na.rm = TRUE), 2),
      SD       = round(sd(x, na.rm = TRUE), 2),
      stringsAsFactors = FALSE
    )
  }))

  write.csv(psa_summary,
            file(file.path(output_dir, "tabla3_psa_summary.csv"), encoding = "UTF-8"),
            row.names = FALSE)

  cat(sprintf("Resumen PSA guardado en: %s\n", output_dir))
  invisible(psa_summary)
}
