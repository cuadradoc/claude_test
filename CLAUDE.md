# Modelo de Carga Económica de la Obesidad en Chile

## Descripción
Modelo de costo-de-enfermedad (cost-of-illness) para estimar la carga económica
de la obesidad en Chile, usando enfoque de prevalencia con costos directos e
indirectos. Incluye análisis de sensibilidad probabilístico (PSA) con simulación
Monte Carlo.

## Estructura del Proyecto

```
├── R/
│   ├── parameters.R      # Parámetros del modelo y distribuciones para PSA
│   ├── model_core.R      # Funciones principales del modelo
│   └── helpers.R         # Funciones auxiliares y carga de paquetes
├── scripts/
│   ├── git_setup.sh      # FASE 0+1: Configuración inicial (ejecutar UNA VEZ)
│   ├── run_deterministic.R  # FASE 2: Análisis determinístico
│   ├── run_psa.R            # FASE 3: Análisis de sensibilidad probabilístico
│   ├── generate_figures.R   # FASE 4: Generación de figuras
│   ├── run_validation.R     # FASE 5: Validación del modelo
│   └── git_release.sh       # FASE 6: Crear release en Git
├── output/
│   ├── tables/   # Tablas CSV y Excel
│   ├── figures/  # Figuras PNG y PDF
│   └── psa/      # Resultados PSA (RDS)
└── data/
    ├── raw/      # Datos crudos (no versionados)
    └── processed/ # Datos procesados
```

## Ejecución Completa

```bash
# FASE 0+1 (solo UNA VEZ)
bash scripts/git_setup.sh

# FASE 2: Determinístico (2-5 min)
Rscript scripts/run_deterministic.R

# FASE 3: PSA (20 min con 1000 iter / 2 min con 100 iter)
Rscript scripts/run_psa.R
N_SIM=100 Rscript scripts/run_psa.R  # prueba rápida

# FASE 4: Figuras (3 min)
Rscript scripts/generate_figures.R

# FASE 5: Validación (1 min)
Rscript scripts/run_validation.R

# FASE 6: Release
bash scripts/git_release.sh
```

## Dependencias R

```r
install.packages(c("dplyr", "tidyr", "ggplot2", "scales",
                   "openxlsx", "knitr", "kableExtra"))
```

## Fuentes de Datos Principales

- **Demografía**: INE Chile 2023
- **Prevalencia obesidad**: ENS 2016-2017 (MINSAL)
- **Prevalencia comorbilidades**: ENS 2016-2017, MINSAL
- **Riesgos relativos**: Meta-análisis (Lancet 2017, WHO, Bhaskaran et al. 2014)
- **Costos unitarios**: FONASA prestaciones valoradas, literatura nacional
- **PIB y salarios**: Banco Central de Chile 2023, INE

## Notas Metodológicas

- **Enfoque**: Prevalencia (cost-of-illness)
- **Perspectiva**: Societal (directos + indirectos)
- **Año base**: 2023
- **Moneda**: USD (tipo de cambio 850 CLP/USD)
- **Fracción Atribuible Poblacional (FAP)**:
  `FAP = p*(RR-1) / (p*(RR-1) + 1)`
- **Costos indirectos**: Capital humano (ausentismo + presentismo + mortalidad prematura)
- **PSA**: Distribuciones beta (prevalencias), log-normal (RR), gamma (costos)
