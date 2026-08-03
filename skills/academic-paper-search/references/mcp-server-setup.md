# Alternativa: registrar el servidor MCP completo

Este skill no lo necesita — usa el CLI. Esta guía existe por si quieres las ~70
herramientas MCP de `paper-search-mcp` expuestas directamente.

## El costo

El servidor define ~70 herramientas (`search_arxiv`, `download_arxiv`,
`read_arxiv_paper`, ... una tripleta por fuente). Todos esos esquemas se cargan en el
contexto de **cada** sesión del cliente donde lo registres, se use o no. El CLI de este
skill llama a las mismas clases con cero herramientas adicionales.

Registra el servidor MCP solo si necesitas que otro agente u orquestador invoque las
herramientas por nombre sin pasar por un shell.

## Claude Code (todos los proyectos del usuario)

```bash
uv tool install paper-search-mcp

claude mcp add paper-search --scope user \
  --env PAPER_SEARCH_MCP_UNPAYWALL_EMAIL=tu@email.com \
  -- uv tool run paper-search-mcp
```

`--scope user` lo deja disponible en todos tus proyectos locales de Claude Code.
Verifica con `claude mcp list`.

## Claude Desktop

Edita el archivo de configuración:

- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`
- Linux: `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "paper-search-mcp": {
      "command": "uv",
      "args": ["tool", "run", "paper-search-mcp"],
      "env": {
        "PAPER_SEARCH_MCP_UNPAYWALL_EMAIL": "tu@email.com"
      }
    }
  }
}
```

Reinicia Claude Desktop.

## Vía Smithery

```bash
npx -y @smithery/cli install @openags/paper-search-mcp --client claude
```

## Limitación importante

Un servidor MCP configurado localmente **no** viaja a las sesiones en la nube
(claude.ai, Claude Code on the web, Cowork): esos entornos se levantan en contenedores
efímeros que no leen tu configuración local. Solo funciona donde lo instalaste.

Esa es exactamente la razón por la que este skill es un CLI: un skill sí se sincroniza a
todas las superficies, y el script se autoinstala sus dependencias con `uv run` en
cualquier contenedor donde caiga.

## Credenciales

Guárdalas en `~/.config/paper-search-mcp/.env` en vez de incrustarlas en la config del
cliente — la librería lo lee automáticamente:

```bash
PAPER_SEARCH_MCP_UNPAYWALL_EMAIL=tu@email.com
PAPER_SEARCH_MCP_CORE_API_KEY=
PAPER_SEARCH_MCP_SEMANTIC_SCHOLAR_API_KEY=
```

## Bugs conocidos en 0.1.4

- `search_zenodo` y `search_hal` fallan siempre vía MCP con
  `'str' object has no attribute 'isoformat'` (`Paper.to_dict()` asume `datetime`).
  El CLI de este skill no usa `to_dict()` y por eso ambas fuentes sí funcionan.
- `download_with_fallback` trae `use_scihub=True` por defecto. El CLI de este skill lo
  invierte a opt-in. Si registras el servidor MCP, esa protección no aplica.
