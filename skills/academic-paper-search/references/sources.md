# Las 21 fuentes: cobertura, requisitos y fiabilidad medida

Medición hecha el 2026-08-03 con `paper_search.py doctor --query obesity` desde un
sandbox de Claude Code en la nube (IP de datacenter compartida), con
`PAPER_SEARCH_MCP_UNPAYWALL_EMAIL` configurado. **15/21 devolvieron resultados.**

La disponibilidad depende del entorno: desde una IP residencial normalmente funcionan
más fuentes (los scrapers dejan de estar bloqueados); desde CI o sandboxes, menos.
Corre `doctor` en cada entorno nuevo antes de asumir cobertura.

## Fuentes verificadas

| Fuente | Cobertura | Clave | Estado medido | Notas |
|---|---|---|---|---|
| `pubmed` | Biomedicina, 37M+ registros | no | OK | La referencia en salud. **Nunca devuelve vacío** — ver abajo. |
| `europepmc` | Biomedicina + texto completo abierto | no | OK | Mejor que PubMed cuando quieres el PDF, no solo la cita. |
| `pmc` | Texto completo abierto de PubMed Central | no | OK | Todo lo que devuelve es descargable. |
| `crossref` | 150M+ DOIs, todas las disciplinas | no | OK | Metadatos, no abstracts. Ideal para verificar citas. |
| `openalex` | 250M+ obras, sucesor de MS Academic | no | OK* | *Sin email da 429 desde IPs compartidas. Trae conteo de citas. |
| `arxiv` | Preprints física/mate/CS/estadística | no | OK | PDF siempre disponible. |
| `medrxiv` | Preprints en salud | no | OK | Sin revisión por pares — dilo al citar. |
| `biorxiv` | Preprints en biología | no | OK | Ídem. |
| `doaj` | 20k revistas de acceso abierto | no | OK | Buena cobertura de revistas latinoamericanas. |
| `zenodo` | Datasets, software, literatura gris | no | OK† | †Bug upstream en 0.1.4; este skill lo evita (ver abajo). |
| `hal` | Repositorio académico francés | no | OK† | Ídem. |
| `openaire` | Agregador europeo de acceso abierto | no | OK | |
| `dblp` | Bibliografía de ciencias de la computación | no | OK | Solo CS; para salud devuelve ruido. |
| `core` | 200M+ artículos de repositorios | opcional | OK | Con clave gratuita de core.ac.uk mejora bastante. |
| `google_scholar` | Todo, incluida literatura gris | no | OK | Frágil: bloquea por bot. Nunca lo pongas como única fuente. |

## Fuentes que no respondieron en este entorno

| Fuente | Estado | Causa probable |
|---|---|---|
| `semantic` | vacío | Rate limit de Semantic Scholar (429) desde IP compartida. Con `PAPER_SEARCH_MCP_SEMANTIC_SCHOLAR_API_KEY` funciona. Vale la pena: aporta conteos de citas e influencia. |
| `unpaywall` | vacío | No es un buscador por texto libre: resuelve DOIs. Úsalo vía `download`, no vía `search`. |
| `iacr` | vacío | Solo criptografía. Un 0 para "obesity" es correcto, no una falla. |
| `base` | vacío | Scraper de bielefeld.de; bloquea IPs de datacenter. |
| `citeseerx` | vacío | Ídem. |
| `ssrn` | vacío | Ídem; SSRN es agresivo con el anti-bot. |

## Tiers

| Tier | Fuentes | Cuándo |
|---|---|---|
| `default` | pubmed, europepmc, crossref, openalex, semantic | Punto de partida para casi todo. |
| `biomedical` | pubmed, europepmc, pmc, medrxiv, biorxiv, doaj | Salud, epidemiología, economía de la salud. |
| `openaccess` | europepmc, pmc, doaj, openalex, zenodo, hal, core | Cuando necesitas el PDF, no solo la cita. |
| `preprints` | arxiv, medrxiv, biorxiv, ssrn, zenodo | Evidencia reciente aún no publicada. |
| `cs` | arxiv, dblp, semantic, openalex, iacr | Ciencias de la computación. |
| `all` | las 21 | Temas interdisciplinarios. Más lento y con más fuentes fallando. |

## Dos comportamientos que hay que conocer

### PubMed nunca devuelve vacío

PubMed aplica *automatic term mapping*: descarta los términos que no reconoce y expande
el resto. Una consulta que no corresponde a nada igual devuelve papers plausibles y
completamente fuera de tema. En el piloto, `"zzqxwv nonexistent qqzz frobnicate"` devolvió
tres artículos reales — sobre hipertensión, paro cardíaco y métodos de consenso — porque
PubMed se quedó solo con la palabra "nonexistent".

Por eso el CLI calcula un `relevance` (fracción de las palabras de contenido de tu
consulta presentes en título+abstract), marca `LOW RELEVANCE` bajo 0.34, y advierte si
más de la mitad del conjunto cae ahí. Umbral calibrado: consultas reales dan mediana
0.60–0.80; la consulta basura dio 0.25 uniforme.

**Cero resultados casi nunca significa "no hay literatura". Significa que la consulta no
matcheó.** Reformula antes de concluir que un tema no está estudiado.

### El bug de fechas de zenodo y hal

En `paper-search-mcp` 0.1.4, `Paper.to_dict()` llama `.isoformat()` sobre
`published_date`, pero zenodo y hal devuelven la fecha como string. Vía servidor MCP eso
lanza `'str' object has no attribute 'isoformat'` y ambas fuentes fallan siempre.

Este skill no usa `to_dict()`: normaliza los objetos `Paper` con `_normalize()`, que
acepta `datetime`, string o `None`. Por eso aquí zenodo y hal funcionan y vía MCP no.

## Descarga: la cadena de respaldo

`download` intenta, en orden:

1. El descargador nativo de la fuente.
2. Repositorios de acceso abierto por DOI o título.
3. Unpaywall (requiere el email configurado).
4. Sci-Hub — **solo con `--allow-scihub`**.

Sci-Hub está desactivado a propósito: distribuye artículos con derechos reservados sin
permiso del editor y es ilegal en varias jurisdicciones. Cuando un PDF no se consigue por
las tres primeras vías, lo correcto es reportar que está tras muro de pago y ofrecer el
abstract, el acceso institucional o préstamo interbibliotecario.
