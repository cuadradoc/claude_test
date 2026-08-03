---
name: academic-paper-search
description: Busca y descarga papers académicos desde 20+ fuentes abiertas (PubMed, Europe PMC, Crossref, OpenAlex, Semantic Scholar, arXiv, medRxiv, bioRxiv, DOAJ, Zenodo, HAL, CORE, SSRN, DBLP y más) usando la librería paper-search-mcp, sin necesidad de registrar un servidor MCP. Úsala cuando el usuario pida buscar literatura científica, revisar el estado del arte, encontrar referencias o evidencia sobre un tema, bajar el PDF o el texto completo de un paper, resolver un DOI, o verificar que una cita existe realmente. Gatilla ante frases como "busca papers sobre X", "qué dice la literatura de X", "bájame este paper", "encuentra el PDF de", "búsqueda bibliográfica", "revisión de literatura", "search the literature for", "find papers on", "download this paper". No la uses para redactar o revisar un manuscrito propio (usa manuscript-pipeline o research-standards), ni para verificar números contra archivos de resultados (usa manuscript-crosscheck).
---

# Búsqueda y descarga de papers académicos

Un CLI portátil sobre [`paper-search-mcp`](https://github.com/openags/paper-search-mcp)
que consulta 21 fuentes académicas en paralelo, deduplica por DOI/título y descarga
PDFs con cadena de respaldo de acceso abierto.

## Por qué CLI y no servidor MCP

`paper-search-mcp` expone ~70 herramientas MCP. Registrarlas carga ~70 esquemas en el
contexto de **cada** sesión, en todos los clientes. Este skill llama a las mismas clases
de la librería por línea de comandos: mismas fuentes, mismo código, sin costo de contexto
ni configuración por cliente. (Si aun así quieres el servidor MCP registrado, está en
`references/mcp-server-setup.md`.)

## Uso

El script se autoinstala sus dependencias con `uv run`. Sustituye `$SKILL` por la ruta
de este skill.

```bash
# Búsqueda (fuentes por defecto: pubmed, europepmc, crossref, openalex, semantic)
uv run $SKILL/scripts/paper_search.py search "obesity economic burden Chile" --max 10

# Por dominio: biomedical | preprints | cs | openaccess | all | default
uv run $SKILL/scripts/paper_search.py search "GLP-1 cost effectiveness" \
    --sources biomedical --max 15 --out ./output/lit/glp1.json

# Fuentes específicas, mezclando tiers y nombres sueltos
uv run $SKILL/scripts/paper_search.py search "population attributable fraction obesity" \
    --sources "pubmed,europepmc,openalex"

# Descargar un PDF (el id viene del campo `id: fuente:paper_id` de la búsqueda)
uv run $SKILL/scripts/paper_search.py download --source europepmc --id PMC1234567 \
    --doi 10.1234/abcd --out ./downloads

# Texto completo extraído
uv run $SKILL/scripts/paper_search.py read --source arxiv --id 2301.12345 \
    --save-text ./downloads/2301.12345.txt

# Metadatos de un DOI (útil para verificar que una cita existe)
uv run $SKILL/scripts/paper_search.py doi 10.1016/S0140-6736(17)32129-3

# Diagnóstico: qué fuentes funcionan en ESTE entorno ahora mismo
uv run $SKILL/scripts/paper_search.py doctor
```

Sin `uv`: `pip install paper-search-mcp==0.1.4` y luego `python $SKILL/scripts/paper_search.py ...`.

### Windows (PowerShell)

El CLI es Python puro y funciona igual, pero la sintaxis del shell cambia: PowerShell
continúa líneas con backtick (`` ` ``), no con `\`. Lo más simple es escribir cada comando
en una sola línea:

```powershell
uv run $env:USERPROFILE\.claude\skills\academic-paper-search\scripts\paper_search.py search "obesity economic burden" --sources semantic --max 3
```

Instalación: `powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -Email tu@email.com`
(`install.sh` es solo para Linux, macOS, WSL y Git Bash). Si falta `uv`:
`powershell -c "irm https://astral.sh/uv/install.ps1 | iex"` y reabre la terminal.

## Cómo usar los resultados

`search` imprime un resumen compacto (título, autores, año, DOI, citas, en qué fuentes
apareció) y escribe **todos** los registros con abstracts completos al JSON de `--out`.
Lee el resumen para elegir; abre el JSON solo si necesitas los abstracts completos.

El campo `found_in` lista todas las fuentes donde apareció el paper. El ranking prioriza
relevancia léxica, luego corroboración entre fuentes, luego citas y año — un paper que
aparece en cuatro bases suele ser más central que uno que aparece en una.

### Ninguna fuente devuelve vacío honestamente

Esta es la trampa principal. PubMed y varios agregadores aplican *automatic term
mapping*: descartan los términos que no reconocen y responden una pregunta más amplia.
Una consulta que no matchea nada igual devuelve papers reales y plausibles, pero fuera de
tema. En el piloto, una consulta de puro ruido devolvió tres artículos sobre hipertensión
y paro cardíaco.

El CLI marca cada resultado con `relevance` (fracción de las palabras de contenido de la
consulta presentes en título+abstract), etiqueta `LOW RELEVANCE` bajo 0.34, y si más de
la mitad del conjunto cae ahí imprime un WARNING nombrando las fuentes culpables.

Cuando veas ese WARNING: **los primeros resultados siguen sirviendo** (el orden es por
relevancia), la cola es ruido. Ajusta con `--sources` más acotado o `--min-relevance 0.34`.
Nunca presentes la cola como evidencia de nada, y no interpretes "0 resultados" como
"no hay literatura sobre esto" — casi siempre significa que la consulta no matcheó.

## Reglas de uso

1. **Verifica antes de citar.** Estos resultados vienen de APIs, no de tu memoria. Nunca
   cites un paper que no aparezca en la salida del CLI. Si necesitas confirmar una cita
   que ya tienes, usa `doi` o busca el título exacto — un DOI que no resuelve es señal de
   referencia inventada o mal transcrita.
2. **Empieza acotado.** `--sources default --max 10` primero. Sube a `--sources all` solo
   si el tema es interdisciplinario o la búsqueda inicial vino pobre: `all` es más lento y
   agrega fuentes que fallan seguido.
3. **Fuentes vacías no son errores.** Varias devuelven 0 sin API key o desde IPs
   compartidas. `doctor` distingue "vacío" de "error real". Si una fuente clave viene
   vacía, dilo en vez de asumir que no hay literatura.
4. **Un solo `--out` por tema.** Escribe a rutas distintas por consulta; el archivo se
   sobreescribe.
5. **Sci-Hub está activado por defecto**, por decisión explícita del dueño del repo.
   `download` intenta en orden: fuente nativa → repositorios de acceso abierto →
   Unpaywall → Sci-Hub. Las tres primeras vías son las que resuelven la mayoría de los
   casos; Sci-Hub solo entra cuando todas fallaron.

   Sci-Hub distribuye artículos con derechos reservados sin permiso del editor y su
   estatus legal varía por jurisdicción. Con `--no-scihub` la cadena se corta después de
   Unpaywall — usa ese flag si el destino del PDF es una publicación, un repositorio
   compartido o cualquier contexto institucional donde la procedencia importe.

   Cuando un PDF no se consigue por ninguna vía, informa que está tras muro de pago y
   ofrece el abstract, el acceso institucional o préstamo interbibliotecario.

## Configuración opcional

Todo funciona sin credenciales, pero un email mejora bastante los límites de tasa.
Guárdalo en `~/.config/paper-search-mcp/.env`:

```bash
PAPER_SEARCH_MCP_UNPAYWALL_EMAIL=tu@email.com   # polite pool de OpenAlex/Crossref/Unpaywall
PAPER_SEARCH_MCP_CORE_API_KEY=                  # gratis en core.ac.uk; sin esto CORE funciona pero rate-limiteada
PAPER_SEARCH_MCP_SEMANTIC_SCHOLAR_API_KEY=      # sube el límite de Semantic Scholar
```

Sin el email, OpenAlex y Crossref responden 429 desde IPs compartidas (sandboxes en la
nube, CI). Es la causa más común de "una fuente devuelve 0".

## Referencias

- `references/sources.md` — las 21 fuentes: cobertura, qué necesita clave, fiabilidad
  medida, y qué tier elegir por tipo de pregunta.
- `references/mcp-server-setup.md` — registrar el servidor MCP completo, si lo quieres.
- `tests/pilot_test.py` — suite de humo: corre `python tests/pilot_test.py` para validar
  la instalación en un entorno nuevo.

## Interacción con otros conectores

Si la sesión ya tiene conectores de investigación (PubMed, Consensus, Elicit, Scite,
Scholar Gateway), son complementarios, no redundantes: aquellos aportan síntesis,
contexto de citación y filtros por tipo de estudio; este skill aporta cobertura amplia
multi-fuente y **descarga real de PDFs y texto completo**, que los conectores no hacen.
Para una revisión seria, usa ambos.
