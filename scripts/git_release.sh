#!/usr/bin/env bash
# =============================================================================
# scripts/git_release.sh
# FASE 6: Crear release en Git (tag anotado + push)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "================================================================"
echo "  FASE 6: Crear Release Git"
echo "================================================================"

# ---------------------------------------------------------------------------
# Verificar estado del repositorio
# ---------------------------------------------------------------------------
echo ""
echo "Verificando estado del repositorio..."

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo ""
  echo "Hay cambios sin commitear. ¿Desea hacer commit automático? [s/N]"
  read -r respuesta
  if [[ "$respuesta" =~ ^[sS]$ ]]; then
    git add R/ scripts/ CLAUDE.md .gitignore
    git commit -m "chore: guardar estado antes del release"
    echo "Commit realizado."
  else
    echo "Abortando. Haga commit de sus cambios antes de crear el release."
    exit 1
  fi
fi

# ---------------------------------------------------------------------------
# Determinar versión del release
# ---------------------------------------------------------------------------
echo ""

# Obtener último tag semántico
LAST_TAG=$(git tag --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' \
           | head -1 2>/dev/null || echo "")

if [ -z "$LAST_TAG" ]; then
  SUGGESTED="v1.0.0"
else
  # Auto-incrementar versión patch
  MAJOR=$(echo "$LAST_TAG" | cut -d. -f1 | tr -d 'v')
  MINOR=$(echo "$LAST_TAG" | cut -d. -f2)
  PATCH=$(echo "$LAST_TAG" | cut -d. -f3)
  SUGGESTED="v${MAJOR}.${MINOR}.$((PATCH + 1))"
  echo "Último tag: $LAST_TAG"
fi

echo "Versión sugerida: $SUGGESTED"
echo "Ingrese versión (Enter para usar '$SUGGESTED'):"
read -r USER_VERSION

VERSION="${USER_VERSION:-$SUGGESTED}"

# Validar formato semver
if ! echo "$VERSION" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "Error: formato inválido. Use vX.Y.Z (ej. v1.0.0)"
  exit 1
fi

# Verificar que el tag no exista ya
if git tag | grep -q "^${VERSION}$"; then
  echo "Error: el tag $VERSION ya existe."
  exit 1
fi

# ---------------------------------------------------------------------------
# Descripción del release
# ---------------------------------------------------------------------------
echo ""
echo "Descripción del release (Enter para usar descripción por defecto):"
read -r USER_DESC

if [ -z "$USER_DESC" ]; then
  DESCRIPTION="Modelo de carga económica de la obesidad en Chile — ${VERSION}

Análisis completados:
  - FASE 2: Análisis determinístico (caso base)
  - FASE 3: PSA Monte Carlo
  - FASE 4: Figuras de publicación
  - FASE 5: Validación del modelo

Generado: $(date '+%Y-%m-%d %H:%M %Z')"
else
  DESCRIPTION="$USER_DESC"
fi

# ---------------------------------------------------------------------------
# Crear tag anotado
# ---------------------------------------------------------------------------
echo ""
echo "Creando tag anotado: $VERSION"

git tag -a "$VERSION" -m "$DESCRIPTION"
echo "Tag '$VERSION' creado localmente."

# ---------------------------------------------------------------------------
# Push del tag al remoto
# ---------------------------------------------------------------------------
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo ""
echo "Haciendo push de commits y tag a origin/$BRANCH..."

# Push commits
git push -u origin "$BRANCH"

# Push tag
RETRY=0
MAX_RETRY=4
WAIT=2

while [ $RETRY -le $MAX_RETRY ]; do
  if git push origin "$VERSION"; then
    echo ""
    echo "================================================================"
    echo "  FASE 6 completada. Release '$VERSION' publicado."
    echo "  Branch: $BRANCH"
    echo "================================================================"
    exit 0
  else
    RETRY=$((RETRY + 1))
    if [ $RETRY -le $MAX_RETRY ]; then
      echo "  Push falló. Reintentando en ${WAIT}s... (intento $RETRY/$MAX_RETRY)"
      sleep $WAIT
      WAIT=$((WAIT * 2))
    fi
  fi
done

echo "Error: no se pudo hacer push del tag después de $MAX_RETRY intentos."
echo "Intente manualmente: git push origin $VERSION"
exit 1
