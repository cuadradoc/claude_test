#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "paper-search-mcp==0.1.4",
# ]
# ///
"""Portable CLI over openags/paper-search-mcp.

Calls the library's platform searchers directly instead of running the MCP
server, so the same code works in any environment with a shell: Claude Code
(local and cloud), Cowork, or a plain terminal. No MCP registration, no
70 extra tool schemas in context.

Run with `uv run paper_search.py ...` (deps resolve automatically) or install
`paper-search-mcp` yourself and run with plain `python`.

Commands:
  search    Search one or many sources, deduplicate, rank, emit markdown + JSON
  download  Fetch a PDF, with open-access fallback chain
  read      Download and extract full text
  doi       Look up a single DOI via Crossref
  doctor    Probe every source and report which ones work here right now
"""

from __future__ import annotations

import argparse
import concurrent.futures
import json
import logging
import os
import re
import sys
from datetime import datetime
from pathlib import Path

logging.basicConfig(level=logging.CRITICAL)
for _n in ("paper_search_mcp", "urllib3", "httpx", "requests"):
    logging.getLogger(_n).setLevel(logging.CRITICAL)

# Sources grouped by how dependable they proved in testing. `default` is what
# runs when the caller does not name sources; see references/sources.md.
TIERS = {
    "default": ["pubmed", "europepmc", "crossref", "openalex", "semantic"],
    "biomedical": ["pubmed", "europepmc", "pmc", "medrxiv", "biorxiv", "doaj"],
    "preprints": ["arxiv", "medrxiv", "biorxiv", "ssrn", "zenodo"],
    "cs": ["arxiv", "dblp", "semantic", "openalex", "iacr"],
    "openaccess": ["europepmc", "pmc", "doaj", "openalex", "zenodo", "hal", "core"],
    "all": [
        "arxiv", "pubmed", "pmc", "europepmc", "biorxiv", "medrxiv", "crossref",
        "openalex", "semantic", "doaj", "dblp", "openaire", "zenodo", "hal",
        "ssrn", "core", "base", "citeseerx", "iacr", "google_scholar", "unpaywall",
    ],
}


def _searchers():
    """Map source name -> (searcher instance, callable(query, n) -> list[Paper])."""
    from paper_search_mcp.academic_platforms.arxiv import ArxivSearcher
    from paper_search_mcp.academic_platforms.base_search import BASESearcher
    from paper_search_mcp.academic_platforms.biorxiv import BioRxivSearcher
    from paper_search_mcp.academic_platforms.citeseerx import CiteSeerXSearcher
    from paper_search_mcp.academic_platforms.core import CORESearcher
    from paper_search_mcp.academic_platforms.crossref import CrossRefSearcher
    from paper_search_mcp.academic_platforms.dblp import DBLPSearcher
    from paper_search_mcp.academic_platforms.doaj import DOAJSearcher
    from paper_search_mcp.academic_platforms.europepmc import EuropePMCSearcher
    from paper_search_mcp.academic_platforms.google_scholar import GoogleScholarSearcher
    from paper_search_mcp.academic_platforms.hal import HALSearcher
    from paper_search_mcp.academic_platforms.iacr import IACRSearcher
    from paper_search_mcp.academic_platforms.medrxiv import MedRxivSearcher
    from paper_search_mcp.academic_platforms.openaire import OpenAiresearcher
    from paper_search_mcp.academic_platforms.openalex import OpenAlexSearcher
    from paper_search_mcp.academic_platforms.pmc import PMCSearcher
    from paper_search_mcp.academic_platforms.pubmed import PubMedSearcher
    from paper_search_mcp.academic_platforms.semantic import SemanticSearcher
    from paper_search_mcp.academic_platforms.ssrn import SSRNSearcher
    from paper_search_mcp.academic_platforms.unpaywall import (
        UnpaywallResolver, UnpaywallSearcher,
    )
    from paper_search_mcp.academic_platforms.zenodo import ZenodoSearcher

    resolver = UnpaywallResolver()
    return {
        "arxiv": ArxivSearcher(),
        "pubmed": PubMedSearcher(),
        "pmc": PMCSearcher(),
        "europepmc": EuropePMCSearcher(),
        "biorxiv": BioRxivSearcher(),
        "medrxiv": MedRxivSearcher(),
        "crossref": CrossRefSearcher(),
        "openalex": OpenAlexSearcher(),
        "semantic": SemanticSearcher(),
        "doaj": DOAJSearcher(),
        "dblp": DBLPSearcher(),
        "openaire": OpenAiresearcher(),
        "zenodo": ZenodoSearcher(),
        "hal": HALSearcher(),
        "ssrn": SSRNSearcher(),
        "core": CORESearcher(),
        "base": BASESearcher(),
        "citeseerx": CiteSeerXSearcher(),
        "iacr": IACRSearcher(),
        "google_scholar": GoogleScholarSearcher(),
        "unpaywall": UnpaywallSearcher(resolver=resolver),
    }


def _config_email() -> str:
    """Polite-pool email from the environment or ~/.config/paper-search-mcp/.env.

    The library only loads that file lazily inside its own get_env(), so calling
    load_env_file() here is what lets an installer-written .env reach us.
    """
    try:
        from paper_search_mcp.config import load_env_file

        load_env_file()
    except Exception:
        pass
    return (
        os.environ.get("PAPER_SEARCH_MCP_UNPAYWALL_EMAIL")
        or os.environ.get("UNPAYWALL_EMAIL")
        or ""
    ).strip()


def _polite(searchers: dict) -> None:
    """Identify ourselves to OpenAlex/Crossref/Unpaywall polite pools.

    These APIs give identified clients higher rate limits. The email comes from
    PAPER_SEARCH_MCP_UNPAYWALL_EMAIL or UNPAYWALL_EMAIL; without it, shared
    IPs (CI, cloud sandboxes) get 429s.
    """
    email = _config_email()
    if not email:
        return
    ua = f"academic-paper-search-skill/1.0 (mailto:{email})"
    for s in searchers.values():
        session = getattr(s, "session", None)
        if session is not None and hasattr(session, "headers"):
            session.headers.update({"User-Agent": ua, "From": email})


def _year_of(paper) -> str:
    """Publication year as a string. Upstream sources disagree on the type of
    published_date -- datetime, ISO string, or None -- so handle all three."""
    d = getattr(paper, "published_date", None)
    if isinstance(d, datetime):
        return str(d.year)
    if isinstance(d, str):
        m = re.search(r"(19|20)\d{2}", d)
        if m:
            return m.group(0)
    return ""


def _normalize(paper, source: str) -> dict:
    """Paper dataclass -> plain dict.

    Deliberately not Paper.to_dict(): that calls .isoformat() on published_date,
    which raises for the sources that return dates as strings (zenodo, hal).
    """
    authors = getattr(paper, "authors", None) or []
    if isinstance(authors, str):
        authors = [a.strip() for a in authors.split(";") if a.strip()]
    doi = (getattr(paper, "doi", "") or "").strip()
    doi = re.sub(r"^https?://(dx\.)?doi\.org/", "", doi, flags=re.I)
    return {
        "source": getattr(paper, "source", "") or source,
        "paper_id": getattr(paper, "paper_id", "") or "",
        "title": (getattr(paper, "title", "") or "").strip(),
        "authors": [str(a) for a in authors],
        "year": _year_of(paper),
        "doi": doi,
        "url": getattr(paper, "url", "") or "",
        "pdf_url": getattr(paper, "pdf_url", "") or "",
        "citations": getattr(paper, "citations", 0) or 0,
        "abstract": _clean_abstract(getattr(paper, "abstract", "")),
    }


def _clean_abstract(text: str) -> str:
    """Strip the markup some sources embed in abstracts.

    Europe PMC returns structured abstracts as raw HTML (`<h4>Background</h4>`),
    which is noise in a terminal and in any downstream citation.
    """
    if not text:
        return ""
    text = re.sub(r"</(h\d|p|div|sec)>", " ", text, flags=re.I)
    text = re.sub(r"<[^>]{1,80}>", "", text)
    text = (text.replace("&amp;", "&").replace("&lt;", "<")
                .replace("&gt;", ">").replace("&quot;", '"').replace("&#39;", "'"))
    return re.sub(r"\s+", " ", text).strip()


# Calibrated against real queries in this repo's pilot run: on-topic result sets
# score a median of 0.60-0.80 with a p25 of 0.40-0.60, while a query PubMed
# could not match at all came back uniformly at 0.25. 0.34 ("under a third of
# the query's content words appear") sits in the gap.
LOW_RELEVANCE = 0.34

STOPWORDS = {
    "the", "a", "an", "of", "and", "or", "in", "on", "for", "to", "with", "by",
    "from", "at", "as", "is", "are", "be", "its", "their", "this", "that",
    "study", "studies", "analysis", "review", "paper", "papers", "research",
    "effect", "effects", "role", "using", "based", "new", "topic", "about",
}


def _content_terms(text: str) -> set[str]:
    return {w for w in re.findall(r"[a-z]{3,}", text.lower()) if w not in STOPWORDS}


def _relevance(rec: dict, query_terms: set[str]) -> float:
    """Fraction of the query's content words present in title+abstract.

    A blunt lexical check, not semantic ranking. It exists because some
    sources never return empty: PubMed's automatic term mapping silently drops
    unmatched terms and expands what remains, so a query that matches nothing
    still comes back with plausible-looking, entirely off-topic papers. Low
    overlap across the whole result set is the signal that this happened.
    """
    if not query_terms:
        return 1.0
    haystack = _content_terms(f"{rec['title']} {rec['abstract']}")
    return len(query_terms & haystack) / len(query_terms)


def _key(rec: dict) -> str:
    """Dedup key: DOI when present, else a normalized title."""
    if rec["doi"]:
        return "doi:" + rec["doi"].lower()
    title = re.sub(r"[^a-z0-9]+", "", rec["title"].lower())
    return "title:" + (title or rec["paper_id"].lower())


def _merge(records: list[dict]) -> list[dict]:
    """Collapse duplicates across sources, keeping the richest copy and
    recording every source the paper was found in."""
    merged: dict[str, dict] = {}
    for rec in records:
        k = _key(rec)
        if k not in merged:
            rec["found_in"] = [rec["source"]]
            merged[k] = rec
            continue
        cur = merged[k]
        if rec["source"] not in cur["found_in"]:
            cur["found_in"].append(rec["source"])
        for field in ("doi", "pdf_url", "url", "abstract", "year"):
            if not cur.get(field) and rec.get(field):
                cur[field] = rec[field]
        cur["citations"] = max(cur.get("citations", 0), rec.get("citations", 0))
    return list(merged.values())


def cmd_search(args) -> int:
    sources = _resolve_sources(args.sources)
    searchers = _searchers()
    _polite(searchers)

    results: dict[str, list[dict]] = {}
    errors: dict[str, str] = {}

    def run(name: str):
        s = searchers[name]
        if name == "semantic" and args.year:
            papers = s.search(args.query, year=args.year, max_results=args.max)
        elif name == "iacr":
            papers = s.search(args.query, args.max, fetch_details=False)
        else:
            papers = s.search(args.query, args.max)
        return [_normalize(p, name) for p in papers]

    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        futures = {pool.submit(run, n): n for n in sources if n in searchers}
        for fut in concurrent.futures.as_completed(futures, timeout=args.timeout + 10):
            name = futures[fut]
            try:
                results[name] = fut.result(timeout=args.timeout)
            except Exception as exc:  # one bad source must not sink the search
                errors[name] = f"{type(exc).__name__}: {exc}"[:200]
                results[name] = []

    papers = _merge([r for recs in results.values() for r in recs])

    query_terms = _content_terms(args.query)
    for p in papers:
        p["relevance"] = round(_relevance(p, query_terms), 2)
    if args.min_relevance > 0:
        papers = [p for p in papers if p["relevance"] >= args.min_relevance]

    # Rank by lexical relevance, then cross-source corroboration, then citations.
    papers.sort(
        key=lambda p: (p["relevance"], len(p["found_in"]), p["citations"], p["year"]),
        reverse=True,
    )

    off_topic = sum(1 for p in papers if p["relevance"] < LOW_RELEVANCE)
    payload = {
        "query": args.query,
        "sources_requested": sources,
        "per_source_counts": {k: len(v) for k, v in sorted(results.items())},
        "errors": errors,
        "total_unique": len(papers),
        "low_relevance_count": off_topic,
        "papers": papers,
    }

    out = Path(args.out).expanduser()
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")

    if args.format == "json":
        print(json.dumps(payload, indent=2, ensure_ascii=False))
        return 0

    _print_markdown(payload, out, limit=args.show)
    return 0


def _print_markdown(payload: dict, out: Path, limit: int) -> None:
    """Compact report for the agent's context; full records stay in the JSON."""
    live = {k: v for k, v in payload["per_source_counts"].items() if v}
    dead = [k for k, v in payload["per_source_counts"].items() if not v]
    print(f"# {payload['total_unique']} unique papers — \"{payload['query']}\"\n")
    print(f"Sources with hits: {', '.join(f'{k} ({v})' for k, v in live.items()) or 'none'}")
    if dead:
        print(f"No results: {', '.join(dead)}")
    for name, err in payload["errors"].items():
        print(f"  ! {name}: {err}")

    total = payload["total_unique"]
    low = payload["low_relevance_count"]
    if total and low / total > 0.5:
        # Name the sources responsible so the advice is actionable: usually a
        # couple of them are dragging in noise, not the query being wrong.
        blame: dict[str, int] = {}
        for p in payload["papers"]:
            if p["relevance"] < LOW_RELEVANCE:
                for src in p["found_in"]:
                    blame[src] = blame.get(src, 0) + 1
        worst = sorted(blame.items(), key=lambda kv: -kv[1])[:3]
        culprits = ", ".join(f"{s} ({n})" for s, n in worst)
        print(
            f"\nWARNING: {low}/{total} results share almost no vocabulary with the query.\n"
            f"  Mostly from: {culprits}\n"
            "  Sources never return an honest empty set — they drop unmatched terms and\n"
            "  answer a broader question instead. Results are ranked by relevance, so the\n"
            "  top entries below are still the best matches; the tail is noise.\n"
            "  To clean it up: drop the noisy sources, or add --min-relevance 0.34."
        )
    print(f"\nFull records (abstracts, all fields): {out}\n")

    for i, p in enumerate(payload["papers"][:limit], 1):
        authors = p["authors"]
        who = ", ".join(authors[:3]) + (" et al." if len(authors) > 3 else "")
        print(f"## {i}. {p['title'] or '(untitled)'}")
        print(f"{who or '(authors n/a)'} · {p['year'] or 'n.d.'} · found in: {', '.join(p['found_in'])}")
        bits = []
        if p["doi"]:
            bits.append(f"doi:{p['doi']}")
        if p["citations"]:
            bits.append(f"{p['citations']} citations")
        bits.append("PDF available" if p["pdf_url"] else "no direct PDF")
        if p.get("relevance", 1.0) < LOW_RELEVANCE:
            bits.append("LOW RELEVANCE")
        print(" · ".join(bits))
        print(f"id: {p['source']}:{p['paper_id']}")
        if p["abstract"]:
            print(f"\n> {p['abstract'][:400]}{'…' if len(p['abstract']) > 400 else ''}")
        print()


def cmd_download(args) -> int:
    import asyncio

    from paper_search_mcp import server as S

    save = str(Path(args.out).expanduser())
    Path(save).mkdir(parents=True, exist_ok=True)
    result = asyncio.run(
        S.download_with_fallback(
            source=args.source,
            paper_id=args.id,
            doi=args.doi or "",
            title=args.title or "",
            save_path=save,
            # Sci-Hub is opt-in: it distributes paywalled papers without
            # publisher permission and is unlawful in many jurisdictions.
            use_scihub=args.allow_scihub,
        )
    )
    print(result)
    return 0 if os.path.exists(result) else 1


def cmd_read(args) -> int:
    import asyncio

    from paper_search_mcp import server as S

    readers = {
        "arxiv": S.read_arxiv_paper, "pubmed": S.read_pubmed_paper,
        "biorxiv": S.read_biorxiv_paper, "medrxiv": S.read_medrxiv_paper,
        "semantic": S.read_semantic_paper, "crossref": S.read_crossref_paper,
        "iacr": S.read_iacr_paper, "doaj": S.read_doaj_paper,
        "zenodo": S.read_zenodo_paper, "hal": S.read_hal_paper,
        "dblp": S.read_dblp_paper, "openaire": S.read_openaire_paper,
        "citeseerx": S.read_citeseerx_paper, "base": S.read_base_paper,
        "ssrn": S.read_ssrn_paper, "openalex": S.read_openalex_paper,
    }
    if args.source not in readers:
        print(f"No full-text reader for '{args.source}'. Available: {', '.join(sorted(readers))}", file=sys.stderr)
        return 2
    save = str(Path(args.out).expanduser())
    text = asyncio.run(readers[args.source](args.id, save))
    if args.save_text:
        dest = Path(args.save_text).expanduser()
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(text, encoding="utf-8")
        print(f"{len(text)} chars written to {dest}")
    else:
        print(text[: args.chars])
    return 0


def cmd_doi(args) -> int:
    import asyncio

    from paper_search_mcp import server as S

    print(json.dumps(asyncio.run(S.get_crossref_paper_by_doi(args.doi)), indent=2, ensure_ascii=False))
    return 0


def cmd_doctor(args) -> int:
    """Probe every source with a trivial query and report what works here.

    Source availability is environment-specific: shared IPs get rate-limited,
    some sources need API keys, some scrape sites that block datacenters.
    """
    searchers = _searchers()
    _polite(searchers)
    query = args.query
    rows = []

    def probe(name):
        s = searchers[name]
        try:
            papers = s.search(query, 2) if name != "iacr" else s.search(query, 2, fetch_details=False)
            return name, len(papers), ""
        except Exception as exc:
            return name, -1, f"{type(exc).__name__}: {exc}"[:120]

    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        futures = [pool.submit(probe, n) for n in TIERS["all"]]
        for fut in concurrent.futures.as_completed(futures, timeout=args.timeout):
            try:
                rows.append(fut.result())
            except Exception as exc:
                rows.append(("?", -1, str(exc)[:120]))

    rows.sort(key=lambda r: (-r[1], r[0]))
    ok = sum(1 for _, n, _ in rows if n > 0)
    print(f"| source | status | detail |\n|---|---|---|")
    for name, n, err in rows:
        if n > 0:
            print(f"| {name} | OK ({n}) | |")
        elif n == 0:
            print(f"| {name} | empty | returned 0 results (rate limit, missing API key, or no match) |")
        else:
            print(f"| {name} | ERROR | {err} |")
    print(f"\n{ok}/{len(rows)} sources returned results for \"{query}\".")
    email = _config_email()
    print(f"Polite-pool email: {'set' if email else 'NOT set — expect 429s from OpenAlex/Crossref/Unpaywall'}")
    print(f"CORE API key: {'set' if os.environ.get('PAPER_SEARCH_MCP_CORE_API_KEY') or os.environ.get('CORE_API_KEY') else 'not set — CORE will return nothing'}")
    return 0 if ok else 1


def _resolve_sources(spec: str) -> list[str]:
    """Accept a tier name, a comma-separated list, or a mix of both."""
    out: list[str] = []
    for token in (spec or "default").split(","):
        token = token.strip().lower()
        if not token:
            continue
        if token in TIERS:
            out.extend(TIERS[token])
        else:
            out.append(token)
    seen, uniq = set(), []
    for s in out:
        if s not in seen:
            seen.add(s)
            uniq.append(s)
    return uniq


def main() -> int:
    ap = argparse.ArgumentParser(prog="paper_search", description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("search", help="search across sources")
    s.add_argument("query")
    s.add_argument("--sources", default="default",
                   help=f"tier or comma list. Tiers: {', '.join(TIERS)}")
    s.add_argument("--max", type=int, default=10, help="max results per source")
    s.add_argument("--year", default=None, help="year filter (Semantic Scholar only), e.g. 2020-2024")
    s.add_argument("--out", default="./paper_search_results.json", help="where to write full JSON")
    s.add_argument("--show", type=int, default=15, help="how many to print")
    s.add_argument("--format", choices=["md", "json"], default="md")
    s.add_argument("--timeout", type=int, default=60, help="per-source timeout in seconds")
    s.add_argument("--min-relevance", type=float, default=0.0,
                   help="drop results whose query-term overlap is below this (0-1). "
                        "0.34 filters most PubMed term-mapping noise")
    s.set_defaults(func=cmd_search)

    d = sub.add_parser("download", help="download a PDF with OA fallback chain")
    d.add_argument("--source", required=True)
    d.add_argument("--id", required=True, help="source-native paper id")
    d.add_argument("--doi", default="")
    d.add_argument("--title", default="")
    d.add_argument("--out", default="./downloads")
    d.add_argument("--allow-scihub", action="store_true",
                   help="opt in to the Sci-Hub fallback (off by default; see references/sources.md)")
    d.set_defaults(func=cmd_download)

    r = sub.add_parser("read", help="download and extract full text")
    r.add_argument("--source", required=True)
    r.add_argument("--id", required=True)
    r.add_argument("--out", default="./downloads")
    r.add_argument("--chars", type=int, default=6000, help="chars to print when not saving")
    r.add_argument("--save-text", default=None, help="write full text here instead of printing")
    r.set_defaults(func=cmd_read)

    x = sub.add_parser("doi", help="Crossref metadata for one DOI")
    x.add_argument("doi")
    x.set_defaults(func=cmd_doi)

    h = sub.add_parser("doctor", help="probe all sources in this environment")
    h.add_argument("--query", default="obesity")
    h.add_argument("--timeout", type=int, default=90)
    h.set_defaults(func=cmd_doctor)

    args = ap.parse_args()
    try:
        return args.func(args)
    except ImportError:
        print(
            "paper-search-mcp is not installed. Either run this script with "
            "`uv run paper_search.py ...` (dependencies resolve automatically) "
            "or install it: pip install paper-search-mcp==0.1.4",
            file=sys.stderr,
        )
        return 3
    except KeyboardInterrupt:
        return 130


if __name__ == "__main__":
    sys.exit(main())
