#!/usr/bin/env bash
# Install the academic-paper-search skill so every Claude surface can use it.
#
#   bash scripts/install.sh              # local install + build upload bundle
#   bash scripts/install.sh --email me@x # also write the polite-pool email
#
# Two destinations, because they cover different surfaces:
#   1. ~/.claude/skills/  -> Claude Code on this machine, immediately.
#   2. a .zip to upload at claude.ai -> syncs to every surface tied to the
#      account: claude.ai chat, Projects, Cowork, and cloud Code sessions.
# Local files do not sync upward, so step 2 is what makes it truly global.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_NAME="$(basename "$SKILL_DIR")"
DEST="${HOME}/.claude/skills/${SKILL_NAME}"
EMAIL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --email) EMAIL="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

echo "==> Skill source: $SKILL_DIR"

# --- prerequisites -----------------------------------------------------------
if command -v uv >/dev/null 2>&1; then
  echo "==> uv found: $(uv --version)"
else
  echo "!!  uv not found. The CLI can still run if you install the library:"
  echo "      pip install paper-search-mcp==0.1.4"
  echo "    To install uv (recommended, handles deps automatically):"
  echo "      curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

# --- 1. local Claude Code ----------------------------------------------------
mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -R "$SKILL_DIR" "$DEST"
chmod +x "$DEST/scripts/paper_search.py" 2>/dev/null || true
echo "==> Installed for local Claude Code: $DEST"

# --- 2. polite-pool credentials ---------------------------------------------
ENV_FILE="${HOME}/.config/paper-search-mcp/.env"
if [[ -n "$EMAIL" ]]; then
  mkdir -p "$(dirname "$ENV_FILE")"
  if [[ -f "$ENV_FILE" ]] && grep -q '^PAPER_SEARCH_MCP_UNPAYWALL_EMAIL=' "$ENV_FILE"; then
    echo "==> Email already set in $ENV_FILE — leaving it alone"
  else
    printf 'PAPER_SEARCH_MCP_UNPAYWALL_EMAIL=%s\n' "$EMAIL" >> "$ENV_FILE"
    chmod 600 "$ENV_FILE"
    echo "==> Wrote polite-pool email to $ENV_FILE"
  fi
elif [[ ! -f "$ENV_FILE" ]]; then
  echo "!!  No polite-pool email configured. OpenAlex and Crossref will return 429"
  echo "    from shared IPs. Fix with: bash scripts/install.sh --email you@example.com"
fi

# --- 3. bundle for claude.ai (this is what reaches every surface) ------------
BUNDLE="${SKILL_DIR}/../${SKILL_NAME}.zip"
if command -v zip >/dev/null 2>&1; then
  rm -f "$BUNDLE"
  ( cd "$(dirname "$SKILL_DIR")" \
    && zip -qr "${SKILL_NAME}.zip" "$SKILL_NAME" \
         -x '*/__pycache__/*' '*.pyc' '*/.venv/*' )
  echo "==> Upload bundle: $(cd "$(dirname "$SKILL_DIR")" && pwd)/${SKILL_NAME}.zip"
else
  echo "!!  zip not installed; skipping bundle. Install zip or upload the folder directly."
fi

cat <<'EOF'

Next steps
----------
1. Local Claude Code: ready now. Start a session and ask it to search for papers.

2. Every other surface (claude.ai chat, Projects, Cowork, cloud Code sessions):
   upload the .zip at claude.ai -> Settings -> Capabilities -> Skills -> Upload skill.
   That copy syncs to the account, which is what makes it available everywhere.

3. Verify the install:
     python tests/pilot_test.py
     uv run scripts/paper_search.py doctor

Note on cloud sandboxes: they need outbound network access to reach the academic
APIs. If `doctor` reports every source as empty or errored, the sandbox has no
egress -- that is an environment setting, not a problem with this skill.
EOF
