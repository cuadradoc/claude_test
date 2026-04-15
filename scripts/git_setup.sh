#!/usr/bin/env bash
# =============================================================================
# scripts/git_setup.sh
# FASE 0+1: Configuración inicial del repositorio Git
# Ejecutar UNA SOLA VEZ al inicio del proyecto.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "================================================================"
echo "  FASE 0+1: Configuración inicial del proyecto"
echo "  Directorio: $PROJECT_DIR"
echo "================================================================"
cd "$PROJECT_DIR"

# ---------------------------------------------------------------------------
# FASE 0: Crear estructura de directorios
# ---------------------------------------------------------------------------
echo ""
echo "[FASE 0] Creando estructura de directorios..."

mkdir -p R scripts data/{raw,processed} output/{tables,figures,psa}

# Archivo placeholder para directorios vacíos (git no versiona directorios)
for dir in data/raw data/processed output/tables output/figures output/psa; do
    touch "$dir/.gitkeep"
done

echo "  Directorios creados."

# ---------------------------------------------------------------------------
# Verificar dependencias de R
# ---------------------------------------------------------------------------
echo ""
echo "[FASE 0] Verificando paquetes de R..."

Rscript --vanilla - << 'REOF'
required <- c("dplyr", "tidyr", "ggplot2", "scales", "openxlsx", "knitr")
missing  <- required[!sapply(required, requireNamespace, quietly = TRUE)]
if (length(missing) > 0) {
  cat(sprintf("  Instalando: %s\n", paste(missing, collapse = ", ")))
  install.packages(missing, repos = "https://cloud.r-project.org", quiet = TRUE)
  cat("  Paquetes instalados.\n")
} else {
  cat("  Todos los paquetes requeridos están disponibles.\n")
}
REOF

# ---------------------------------------------------------------------------
# FASE 1: Primer commit
# ---------------------------------------------------------------------------
echo ""
echo "[FASE 1] Realizando commit inicial..."

# Verificar que git está inicializado
if [ ! -d ".git" ]; then
    git init
    echo "  Repositorio Git inicializado."
fi

# Agregar archivos al staging (excluyendo output/ y data/raw/ via .gitignore)
git add .gitignore CLAUDE.md R/ scripts/ data/processed/.gitkeep \
        output/tables/.gitkeep output/figures/.gitkeep output/psa/.gitkeep \
        2>/dev/null || true

# Crear commit solo si hay cambios staged
if git diff --cached --quiet; then
    echo "  No hay cambios nuevos para commitear."
else
    git commit -m "feat: inicializar estructura del proyecto

Modelo de carga económica de la obesidad en Chile.
- Parámetros demográficos y epidemiológicos (ENS 2016-17)
- Modelo de costos directos e indirectos
- Scripts para análisis determinístico y PSA
- Estructura de directorios para outputs"

    echo "  Commit inicial creado."
fi

# Push al repositorio remoto
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
echo ""
echo "[FASE 1] Haciendo push a origin/$BRANCH..."

git push -u origin "$BRANCH" || {
    echo "  Advertencia: push falló. Verifique la conexión y los permisos."
    exit 1
}

echo ""
echo "================================================================"
echo "  FASE 0+1 completada exitosamente."
echo "  Siguiente paso: Rscript scripts/run_deterministic.R"
echo "================================================================"
