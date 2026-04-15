# =============================================================================
# scripts/generate_figures.R
# FASE 4: Generación de figuras de publicación
# =============================================================================

cat("================================================================\n")
cat("  FASE 4: Generación de Figuras\n")
cat("================================================================\n\n")

source("R/helpers.R")
source("R/parameters.R")
source("R/model_core.R")

load_packages()
ensure_dir("output/figures")

# ---------------------------------------------------------------------------
# Cargar resultados previos
# ---------------------------------------------------------------------------
if (!file.exists("output/psa/results_base.rds")) {
  stop("Faltan resultados. Ejecute primero las fases 2 y 3.")
}
results_base <- readRDS("output/psa/results_base.rds")
psa_df       <- if (file.exists("output/psa/psa_results.rds")) {
  readRDS("output/psa/psa_results.rds")
} else {
  NULL
}
tornado_data <- if (file.exists("output/tables/tabla4_tornado.csv")) {
  read.csv("output/tables/tabla4_tornado.csv", stringsAsFactors = FALSE)
} else {
  NULL
}

# Tema base para todas las figuras (estilo publicación)
theme_publication <- function(base_size = 12) {
  ggplot2::theme_bw(base_size = base_size) +
  ggplot2::theme(
    panel.grid.minor  = ggplot2::element_blank(),
    panel.grid.major  = ggplot2::element_line(colour = "grey90"),
    strip.background  = ggplot2::element_rect(fill = "grey95"),
    legend.background = ggplot2::element_blank(),
    legend.key        = ggplot2::element_blank(),
    plot.title        = ggplot2::element_text(face = "bold", size = base_size + 2),
    plot.subtitle     = ggplot2::element_text(colour = "grey40"),
    axis.title        = ggplot2::element_text(face = "bold")
  )
}

save_fig <- function(p, filename, width = 8, height = 5) {
  path <- file.path("output/figures", filename)
  ggplot2::ggsave(path, plot = p, width = width, height = height,
                  dpi = 300, bg = "white")
  cat(sprintf("  Guardada: %s\n", path))
  invisible(p)
}

# ---------------------------------------------------------------------------
# FIGURA 1: Desglose de costos directos por condición (barras horizontales)
# ---------------------------------------------------------------------------
cat("Generando Figura 1: Costos directos por condición...\n")

dc <- results_base$direct_costs
dc <- dc[order(dc$total_cost_usd), ]
dc$label_f <- factor(dc$label, levels = dc$label)

fig1 <- ggplot2::ggplot(dc,
    ggplot2::aes(x = total_cost_usd / 1e6, y = label_f)) +
  ggplot2::geom_col(fill = "#2166ac", alpha = 0.85, width = 0.7) +
  ggplot2::geom_text(
    ggplot2::aes(label = sprintf("USD %.0f M", total_cost_usd / 1e6)),
    hjust = -0.05, size = 3.2
  ) +
  ggplot2::scale_x_continuous(
    expand = ggplot2::expansion(mult = c(0, 0.25)),
    labels = scales::label_comma(suffix = " M")
  ) +
  ggplot2::labs(
    title    = "Costos directos atribuibles a obesidad por condición",
    subtitle = sprintf("Chile %d — caso base determinístico",
                       results_base$params$year),
    x        = "Costo anual (millones USD)",
    y        = NULL,
    caption  = "FAP: Fracción Atribuible Poblacional. Fuentes: ENS 2016-17, FONASA, INE 2023."
  ) +
  theme_publication()

save_fig(fig1, "fig1_costos_directos.png", width = 9, height = 6)

# ---------------------------------------------------------------------------
# FIGURA 2: Estructura de costos (directo vs indirecto) — gráfico de torta
# ---------------------------------------------------------------------------
cat("Generando Figura 2: Estructura de costos directos vs indirectos...\n")

s <- results_base$summary
df_pie <- data.frame(
  Componente = c("Costos directos", "Ausentismo", "Presentismo",
                 "Mortalidad prematura"),
  Monto      = c(s$total_direct_usd, s$cost_absenteeism,
                 s$cost_presenteeism, s$cost_mortality),
  stringsAsFactors = FALSE
)
df_pie$Pct <- df_pie$Monto / s$total_cost_usd * 100
df_pie$Componente <- factor(df_pie$Componente, levels = df_pie$Componente)

colores <- c("#2166ac", "#74add1", "#fdae61", "#d73027")

fig2 <- ggplot2::ggplot(df_pie,
    ggplot2::aes(x = "", y = Monto, fill = Componente)) +
  ggplot2::geom_col(width = 1, colour = "white", linewidth = 0.5) +
  ggplot2::coord_polar("y") +
  ggplot2::scale_fill_manual(values = colores) +
  ggplot2::geom_text(
    ggplot2::aes(label = sprintf("%s\n%.1f%%", Componente, Pct)),
    position = ggplot2::position_stack(vjust = 0.5),
    size = 3.5, colour = "white", fontface = "bold"
  ) +
  ggplot2::labs(
    title    = "Estructura de la carga económica de la obesidad",
    subtitle = sprintf("Costo total: %s (%.2f%% del PIB)",
                       fmt_usd(s$total_cost_usd), s$pct_gdp),
    caption  = sprintf("Chile %d.", results_base$params$year)
  ) +
  ggplot2::theme_void(base_size = 12) +
  ggplot2::theme(
    legend.position = "none",
    plot.title      = ggplot2::element_text(face = "bold", hjust = 0.5),
    plot.subtitle   = ggplot2::element_text(hjust = 0.5, colour = "grey40")
  )

save_fig(fig2, "fig2_estructura_costos.png", width = 7, height = 6)

# ---------------------------------------------------------------------------
# FIGURA 3: Diagrama tornado (sensibilidad one-way)
# ---------------------------------------------------------------------------
if (!is.null(tornado_data)) {
  cat("Generando Figura 3: Diagrama de tornado...\n")

  top_n  <- min(12, nrow(tornado_data))
  td     <- tornado_data[seq_len(top_n), ]
  base_c <- td$base[1]

  # Etiquetas más legibles
  label_map <- c(
    prev_obesity          = "Prevalencia obesidad",
    rr_dm2                = "RR Diabetes tipo 2",
    rr_htn                = "RR Hipertensión",
    rr_nafld              = "RR EHGNA",
    cost_dm2              = "Costo unitario diabetes",
    cost_ihd              = "Costo unitario cardiopatía",
    cost_nafld            = "Costo unitario EHGNA",
    days_lost_obese       = "Días ausentismo (obesos)",
    presenteeism_factor   = "Factor presentismo",
    obesity_attr_deaths   = "Muertes atribuibles",
    ypll_per_death        = "AVPP por muerte",
    mortality_friction    = "Factor friccional"
  )
  td$param_label <- dplyr::coalesce(label_map[td$parameter], td$parameter)
  td$param_label <- factor(td$param_label, levels = rev(td$param_label))

  fig3 <- ggplot2::ggplot(td) +
    ggplot2::geom_segment(
      ggplot2::aes(x = low / 1e9, xend = high / 1e9,
                   y = param_label, yend = param_label),
      colour = "#2166ac", linewidth = 6, alpha = 0.7
    ) +
    ggplot2::geom_vline(xintercept = base_c / 1e9,
                        linetype = "dashed", colour = "grey30") +
    ggplot2::scale_x_continuous(labels = scales::label_comma(suffix = " B")) +
    ggplot2::labs(
      title    = "Diagrama de tornado — sensibilidad one-way (±20%)",
      subtitle = sprintf("Caso base: %s", fmt_usd(base_c)),
      x        = "Costo total (miles de millones USD)",
      y        = NULL
    ) +
    theme_publication()

  save_fig(fig3, "fig3_tornado.png", width = 9, height = 6)
} else {
  cat("  Omitiendo Fig. 3: datos tornado no disponibles.\n")
}

# ---------------------------------------------------------------------------
# FIGURA 4: Distribución PSA (histograma + densidad)
# ---------------------------------------------------------------------------
if (!is.null(psa_df)) {
  cat("Generando Figura 4: Distribución PSA del costo total...\n")

  psa_plot <- data.frame(cost_b = psa_df$total_cost_usd / 1e9)
  ci_low   <- quantile(psa_plot$cost_b, 0.025)
  ci_high  <- quantile(psa_plot$cost_b, 0.975)
  base_b   <- results_base$summary$total_cost_usd / 1e9

  fig4 <- ggplot2::ggplot(psa_plot, ggplot2::aes(x = cost_b)) +
    ggplot2::geom_histogram(
      ggplot2::aes(y = ggplot2::after_stat(density)),
      bins = 40, fill = "#74add1", colour = "white", alpha = 0.8
    ) +
    ggplot2::geom_density(colour = "#2166ac", linewidth = 1) +
    ggplot2::geom_vline(xintercept = base_b,
                        colour = "black", linetype = "solid", linewidth = 1) +
    ggplot2::geom_vline(xintercept = c(ci_low, ci_high),
                        colour = "#d73027", linetype = "dashed", linewidth = 0.8) +
    ggplot2::annotate("text", x = base_b, y = Inf,
                      label = "Caso base", vjust = 2, hjust = -0.1,
                      fontface = "bold", size = 3.5) +
    ggplot2::annotate("text", x = ci_low, y = Inf,
                      label = sprintf("IC2.5%%\n%.2f B", ci_low),
                      vjust = 2, hjust = 1.1, colour = "#d73027", size = 3) +
    ggplot2::annotate("text", x = ci_high, y = Inf,
                      label = sprintf("IC97.5%%\n%.2f B", ci_high),
                      vjust = 2, hjust = -0.1, colour = "#d73027", size = 3) +
    ggplot2::scale_x_continuous(labels = scales::label_comma(suffix = " B")) +
    ggplot2::labs(
      title    = sprintf("Distribución PSA del costo total (n = %d iteraciones)",
                         nrow(psa_df)),
      subtitle = sprintf("IC 95%%: %.2f B – %.2f B USD", ci_low, ci_high),
      x        = "Costo total (miles de millones USD)",
      y        = "Densidad"
    ) +
    theme_publication()

  save_fig(fig4, "fig4_psa_distribucion.png", width = 8, height = 5)

  # Figura 5: % PIB vs costos directos (scatter PSA)
  cat("Generando Figura 5: Scatter PSA (% PIB vs proporción directos)...\n")

  psa_scatter <- data.frame(
    pct_gdp     = psa_df$pct_gdp,
    prop_direct = psa_df$total_direct_usd / psa_df$total_cost_usd * 100
  )

  fig5 <- ggplot2::ggplot(psa_scatter,
      ggplot2::aes(x = pct_gdp, y = prop_direct)) +
    ggplot2::geom_point(alpha = 0.15, size = 1.2, colour = "#2166ac") +
    ggplot2::geom_density2d(colour = "#d73027", linewidth = 0.6) +
    ggplot2::labs(
      title    = "Dispersión PSA: % del PIB vs composición de costos",
      subtitle = "Cada punto representa una iteración Monte Carlo",
      x        = "Costo total (% del PIB)",
      y        = "Costos directos (% del total)"
    ) +
    theme_publication()

  save_fig(fig5, "fig5_psa_scatter.png", width = 7, height = 5)

} else {
  cat("  Omitiendo Figs. 4-5: resultados PSA no disponibles.\n")
  cat("  Ejecute primero: Rscript scripts/run_psa.R\n")
}

cat("\n")
cat("================================================================\n")
cat("  FASE 4 completada. Figuras en: output/figures/\n")
cat("  Siguiente paso: Rscript scripts/run_validation.R\n")
cat("================================================================\n")
