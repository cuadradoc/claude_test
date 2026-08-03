# Pilot report — academic-paper-search

- Runner: `uv run`
- Python: 3.11.15
- Wall time: 48s
- Polite-pool email: set

## Required tests

| # | Test | Result | Detail | s |
|---|------|--------|--------|---|
| 1 | CLI starts and resolves dependencies | PASS | uv resolved paper-search-mcp and argparse loaded | 0.1 |
| 2 | search: default tier returns deduplicated results | PASS | 19 unique from 20 raw hits; live sources: crossref, europepmc, openalex, pubmed | 16.4 |
| 3 | search: records carry the fields citation work needs | PASS | 19 records: 18 with DOI, 17 with abstract, 19 with title | 0.0 |
| 4 | search: same paper from several sources merges into one record | PASS | 1 papers corroborated by >1 source; no duplicate DOIs among 18 DOI-bearing records | 0.0 |
| 5 | search: finds a specific known paper by title | PASS | found: Health Effects of Overweight and Obesity in 195 Countries over 25 Year (2017) doi:10.1056/nejmoa1614362 | 2.0 |
| 6 | search: a failing source degrades gracefully | PASS | survived with 9 papers; errors recorded: none | 2.1 |
| 7 | search: nonsense query is flagged as low relevance | PASS | 3 off-topic results returned by PubMed, all flagged, warning shown | 1.8 |
| 8 | search: --min-relevance filters term-mapping noise | PASS | 0 results after filtering, valid JSON, exit 0 | 1.7 |
| 9 | search: relevance filter keeps genuinely on-topic papers | PASS | 17/19 real results score >= 0.34 (median 0.80, threshold 0.34) | 0.0 |
| 10 | doi: resolves a real DOI to metadata | PASS | resolved: worldwide trends in body-mass index, underweight, overweight, and obesity from 1 | 1.4 |
| 11 | download: Sci-Hub fallback is off unless explicitly requested | PASS | default path is native -> OA repositories -> Unpaywall; Sci-Hub only with --allow-scihub | 0.1 |

## Optional tests (environment-dependent)

| # | Test | Result | Detail | s |
|---|------|--------|--------|---|
| 1 | download: fetches an open-access PDF | PASS | 2303.08774.pdf, 5122 KB, valid PDF header | 1.9 |
| 2 | read: extracts full text from a PDF | PASS | 284,850 chars extracted | 2.5 |
| 3 | doctor: reports per-source availability | PASS | 12 OK, 9 empty, 0 error (of 21 sources) | 17.8 |

## Source availability in this environment

| source | status | detail |
|---|---|---|
| arxiv | OK (2) | |
| biorxiv | OK (2) | |
| crossref | OK (2) | |
| dblp | OK (2) | |
| doaj | OK (2) | |
| europepmc | OK (2) | |
| hal | OK (2) | |
| medrxiv | OK (2) | |
| openaire | OK (2) | |
| pmc | OK (2) | |
| pubmed | OK (2) | |
| zenodo | OK (2) | |
| base | empty | returned 0 results (rate limit, missing API key, or no match) |
| citeseerx | empty | returned 0 results (rate limit, missing API key, or no match) |
| core | empty | returned 0 results (rate limit, missing API key, or no match) |
| google_scholar | empty | returned 0 results (rate limit, missing API key, or no match) |
| iacr | empty | returned 0 results (rate limit, missing API key, or no match) |
| openalex | empty | returned 0 results (rate limit, missing API key, or no match) |
| semantic | empty | returned 0 results (rate limit, missing API key, or no match) |
| ssrn | empty | returned 0 results (rate limit, missing API key, or no match) |
| unpaywall | empty | returned 0 results (rate limit, missing API key, or no match) |

12/21 sources returned results for "obesity".
Polite-pool email: set
CORE API key: not set — CORE will return nothing

