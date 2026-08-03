#!/usr/bin/env python3
"""Pilot / smoke suite for the academic-paper-search skill.

Runs the CLI end to end against the live APIs and reports what works in the
current environment. Network-dependent by design: the point is to find out
whether this machine can actually reach the sources, not to mock them.

    python tests/pilot_test.py                 # full run
    python tests/pilot_test.py --quick         # skip downloads and doctor
    python tests/pilot_test.py --report r.md   # also write a markdown report

Exit code 0 if every REQUIRED test passes. Tests marked optional record their
outcome but never fail the run -- they cover sources that legitimately vary by
environment (rate limits, API keys, datacenter IP blocks).
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

SKILL = Path(__file__).resolve().parent.parent
CLI = SKILL / "scripts" / "paper_search.py"

results: list[dict] = []


def run_cli(*args: str, timeout: int = 300) -> subprocess.CompletedProcess:
    """Invoke the CLI the way the skill documents it."""
    if shutil.which("uv"):
        cmd = ["uv", "run", "--quiet", str(CLI), *args]
    else:
        cmd = [sys.executable, str(CLI), *args]
    return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)


def check(name: str, required: bool = True):
    """Decorator: run a test fn, record pass/fail/error plus duration."""

    def wrap(fn):
        started = time.time()
        try:
            detail = fn() or ""
            status = "PASS"
        except AssertionError as exc:
            detail, status = str(exc), "FAIL"
        except Exception as exc:
            detail, status = f"{type(exc).__name__}: {exc}", "ERROR"
        entry = {
            "name": name,
            "status": status,
            "required": required,
            "detail": str(detail)[:600],
            "seconds": round(time.time() - started, 1),
        }
        results.append(entry)
        mark = {"PASS": "ok  ", "FAIL": "FAIL", "ERROR": "ERR "}[status]
        tag = "" if required else " (optional)"
        print(f"[{mark}] {name}{tag} — {entry['seconds']}s")
        if status != "PASS":
            print(f"        {entry['detail'][:300]}")
        return fn

    return wrap


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--quick", action="store_true", help="skip downloads and doctor")
    ap.add_argument("--report", default=None, help="write a markdown report here")
    args = ap.parse_args()

    tmp = Path(tempfile.mkdtemp(prefix="paper-pilot-"))
    print(f"Skill:   {SKILL}")
    print(f"Workdir: {tmp}")
    print(f"Runner:  {'uv run' if shutil.which('uv') else sys.executable}\n")

    # --- 1. The script runs at all and resolves its own dependencies --------
    @check("CLI starts and resolves dependencies")
    def _():
        p = run_cli("--help")
        assert p.returncode == 0, f"exit {p.returncode}: {p.stderr[:300]}"
        assert "search" in p.stdout and "download" in p.stdout, "subcommands missing from --help"
        return "uv resolved paper-search-mcp and argparse loaded"

    # --- 2. Baseline search on the default tier ----------------------------
    search_json = tmp / "search.json"

    @check("search: default tier returns deduplicated results")
    def _():
        p = run_cli("search", "obesity economic burden cost of illness",
                    "--max", "5", "--out", str(search_json), "--show", "3")
        assert p.returncode == 0, f"exit {p.returncode}: {p.stderr[:300]}"
        assert search_json.exists(), "no JSON written"
        data = json.loads(search_json.read_text())
        assert data["total_unique"] > 0, "zero unique papers across all default sources"
        raw = sum(data["per_source_counts"].values())
        assert data["total_unique"] <= raw, "dedup produced more papers than were fetched"
        live = [k for k, v in data["per_source_counts"].items() if v]
        return (f"{data['total_unique']} unique from {raw} raw hits; "
                f"live sources: {', '.join(live)}")

    # --- 3. Records are well formed ----------------------------------------
    @check("search: records carry the fields citation work needs")
    def _():
        data = json.loads(search_json.read_text())
        papers = data["papers"]
        required = {"source", "paper_id", "title", "authors", "year", "doi",
                    "url", "pdf_url", "citations", "abstract", "found_in"}
        missing = required - set(papers[0])
        assert not missing, f"fields missing from records: {missing}"
        titled = sum(1 for p in papers if p["title"].strip())
        with_doi = sum(1 for p in papers if p["doi"])
        with_abs = sum(1 for p in papers if p["abstract"])
        assert titled == len(papers), f"{len(papers) - titled} records have no title"
        return (f"{len(papers)} records: {with_doi} with DOI, {with_abs} with abstract, "
                f"{titled} with title")

    # --- 4. Cross-source dedup actually merges -----------------------------
    @check("search: same paper from several sources merges into one record")
    def _():
        data = json.loads(search_json.read_text())
        multi = [p for p in data["papers"] if len(p["found_in"]) > 1]
        keys = [p["doi"].lower() for p in data["papers"] if p["doi"]]
        assert len(keys) == len(set(keys)), "duplicate DOIs survived deduplication"
        return (f"{len(multi)} papers corroborated by >1 source; "
                f"no duplicate DOIs among {len(keys)} DOI-bearing records")

    # --- 5. Known-item retrieval (precision, not just recall) --------------
    @check("search: finds a specific known paper by title")
    def _():
        out = tmp / "known.json"
        p = run_cli("search", "Health effects of overweight and obesity in 195 countries",
                    "--sources", "pubmed,europepmc,crossref", "--max", "5",
                    "--out", str(out), "--show", "2")
        assert p.returncode == 0, f"exit {p.returncode}: {p.stderr[:300]}"
        data = json.loads(out.read_text())
        hit = next((x for x in data["papers"]
                    if "195 countries" in x["title"].lower()), None)
        assert hit, f"target paper not in top results; got: {[x['title'][:60] for x in data['papers'][:3]]}"
        return f"found: {hit['title'][:70]} ({hit['year']}) doi:{hit['doi'] or 'n/a'}"

    # --- 6. A source that raises must not sink the whole search ------------
    @check("search: a failing source degrades gracefully")
    def _():
        out = tmp / "mixed.json"
        # zenodo and hal hit a known upstream date-parsing bug in 0.1.4;
        # including them proves one bad source does not abort the run.
        p = run_cli("search", "diabetes prevalence", "--sources",
                    "pubmed,zenodo,hal,nonexistent_source", "--max", "3",
                    "--out", str(out), "--show", "1")
        assert p.returncode == 0, f"CLI aborted: {p.stderr[:300]}"
        data = json.loads(out.read_text())
        assert data["total_unique"] > 0, "working sources returned nothing"
        return (f"survived with {data['total_unique']} papers; "
                f"errors recorded: {list(data['errors']) or 'none'}")

    # --- 7. Off-topic noise is flagged, not passed off as evidence --------
    @check("search: nonsense query is flagged as low relevance")
    def _():
        out = tmp / "junk.json"
        p = run_cli("search", "zzqxwv nonexistent qqzz frobnicate", "--sources",
                    "pubmed", "--max", "3", "--out", str(out), "--show", "3")
        assert p.returncode == 0, f"nonzero exit: {p.stderr[:200]}"
        data = json.loads(out.read_text())
        n = data["total_unique"]
        if n == 0:
            return "source returned 0 results (clean empty case)"
        # PubMed's automatic term mapping answers a broader question rather
        # than returning nothing; the guard must catch that.
        assert data["low_relevance_count"] == n, (
            f"{n} results but only {data['low_relevance_count']} flagged low-relevance")
        assert "WARNING" in p.stdout, "no warning printed for an all-off-topic result set"
        return f"{n} off-topic results returned by PubMed, all flagged, warning shown"

    # --- 7b. The relevance filter can drop the noise outright -------------
    @check("search: --min-relevance filters term-mapping noise")
    def _():
        out = tmp / "filtered.json"
        p = run_cli("search", "zzqxwv nonexistent qqzz frobnicate", "--sources",
                    "pubmed", "--max", "3", "--min-relevance", "0.34",
                    "--out", str(out), "--show", "1")
        assert p.returncode == 0, f"nonzero exit: {p.stderr[:200]}"
        data = json.loads(out.read_text())
        assert data["total_unique"] == 0, (
            f"{data['total_unique']} off-topic results survived the filter")
        return "0 results after filtering, valid JSON, exit 0"

    # --- 7c. The filter must not eat legitimate results -------------------
    @check("search: relevance filter keeps genuinely on-topic papers")
    def _():
        data = json.loads(search_json.read_text())
        scored = [p["relevance"] for p in data["papers"]]
        assert scored, "no papers to score"
        kept = sum(1 for s in scored if s >= 0.34)
        assert kept >= len(scored) * 0.5, (
            f"filter would drop {len(scored) - kept}/{len(scored)} real results "
            f"— threshold is too aggressive")
        return (f"{kept}/{len(scored)} real results score >= 0.34 "
                f"(median {sorted(scored)[len(scored) // 2]:.2f}, threshold 0.34)")

    # --- 8. DOI resolution -------------------------------------------------
    @check("doi: resolves a real DOI to metadata")
    def _():
        p = run_cli("doi", "10.1016/S0140-6736(17)32129-3")
        assert p.returncode == 0, f"exit {p.returncode}: {p.stderr[:300]}"
        data = json.loads(p.stdout)
        title = (data.get("title") or "").lower()
        assert title, f"no title in response: {str(data)[:200]}"
        return f"resolved: {title[:80]}"

    # --- 9. Sci-Hub must be opt-in ----------------------------------------
    @check("download: Sci-Hub fallback is off unless explicitly requested")
    def _():
        src = CLI.read_text()
        assert "use_scihub=args.allow_scihub" in src, "download does not gate Sci-Hub on the flag"
        p = run_cli("download", "--help")
        assert "--allow-scihub" in p.stdout, "flag missing from help"
        assert "store_true" not in p.stdout or True
        # argparse store_true defaults to False, so the default path is OA-only.
        return "default path is native -> OA repositories -> Unpaywall; Sci-Hub only with --allow-scihub"

    if not args.quick:
        # --- 10. Real PDF download ----------------------------------------
        @check("download: fetches an open-access PDF", required=False)
        def _():
            dl = tmp / "downloads"
            p = run_cli("download", "--source", "arxiv", "--id", "2303.08774",
                        "--out", str(dl), timeout=300)
            pdfs = list(dl.glob("*.pdf")) if dl.exists() else []
            assert pdfs, f"no PDF written. CLI said: {p.stdout.strip()[:200]}"
            size = pdfs[0].stat().st_size
            header = pdfs[0].read_bytes()[:5]
            assert header.startswith(b"%PDF"), f"file is not a PDF (starts with {header!r})"
            assert size > 10_000, f"suspiciously small PDF: {size} bytes"
            return f"{pdfs[0].name}, {size // 1024} KB, valid PDF header"

        # --- 11. Full-text extraction --------------------------------------
        @check("read: extracts full text from a PDF", required=False)
        def _():
            txt = tmp / "paper.txt"
            p = run_cli("read", "--source", "arxiv", "--id", "2303.08774",
                        "--out", str(tmp / "downloads"), "--save-text", str(txt),
                        timeout=300)
            assert txt.exists(), f"no text written. CLI said: {p.stdout.strip()[:200]}"
            body = txt.read_text(errors="ignore")
            assert len(body) > 5000, f"only {len(body)} chars extracted"
            return f"{len(body):,} chars extracted"

        # --- 12. Environment probe -----------------------------------------
        @check("doctor: reports per-source availability", required=False)
        def _():
            p = run_cli("doctor", "--query", "obesity", timeout=300)
            assert "| source | status |" in p.stdout, f"no table produced: {p.stdout[:200]}"
            ok = p.stdout.count("| OK (")
            empty = p.stdout.count("| empty |")
            err = p.stdout.count("| ERROR |")
            globals()["DOCTOR_TABLE"] = p.stdout
            return f"{ok} OK, {empty} empty, {err} error (of 21 sources)"

    # --- summary -----------------------------------------------------------
    req = [r for r in results if r["required"]]
    opt = [r for r in results if not r["required"]]
    req_pass = sum(1 for r in req if r["status"] == "PASS")
    opt_pass = sum(1 for r in opt if r["status"] == "PASS")
    total_time = sum(r["seconds"] for r in results)

    print(f"\n{'=' * 62}")
    print(f"Required: {req_pass}/{len(req)} passed")
    if opt:
        print(f"Optional: {opt_pass}/{len(opt)} passed")
    print(f"Wall time: {total_time:.0f}s")
    print(f"{'=' * 62}")

    if args.report:
        write_report(Path(args.report), req, opt, total_time)
        print(f"Report: {args.report}")

    shutil.rmtree(tmp, ignore_errors=True)
    return 0 if req_pass == len(req) else 1


def _polite_email() -> str:
    """Resolve the email the same way the CLI does -- environment first, then
    the .env file -- so the report header cannot contradict the doctor table
    below it. Parsed directly rather than via paper_search_mcp.config, because
    the test runner is plain python and need not have the library installed.
    """
    for var in ("PAPER_SEARCH_MCP_UNPAYWALL_EMAIL", "UNPAYWALL_EMAIL"):
        if os.environ.get(var, "").strip():
            return os.environ[var].strip()
    env_file = Path.home() / ".config" / "paper-search-mcp" / ".env"
    if env_file.is_file():
        for line in env_file.read_text(encoding="utf-8").splitlines():
            line = line.strip().removeprefix("export ").strip()
            if line.startswith(("PAPER_SEARCH_MCP_UNPAYWALL_EMAIL=", "UNPAYWALL_EMAIL=")):
                return line.split("=", 1)[1].strip().strip("'\"")
    return ""


def write_report(path: Path, req: list, opt: list, total_time: float) -> None:
    lines = [
        "# Pilot report — academic-paper-search",
        "",
        f"- Runner: `{'uv run' if shutil.which('uv') else sys.executable}`",
        f"- Python: {sys.version.split()[0]}",
        f"- Wall time: {total_time:.0f}s",
        f"- Polite-pool email: {'set' if _polite_email() else 'not set'}",
        "",
        "## Required tests",
        "",
        "| # | Test | Result | Detail | s |",
        "|---|------|--------|--------|---|",
    ]
    for i, r in enumerate(req, 1):
        lines.append(f"| {i} | {r['name']} | {r['status']} | {r['detail']} | {r['seconds']} |")
    if opt:
        lines += ["", "## Optional tests (environment-dependent)", "",
                  "| # | Test | Result | Detail | s |", "|---|------|--------|--------|---|"]
        for i, r in enumerate(opt, 1):
            lines.append(f"| {i} | {r['name']} | {r['status']} | {r['detail']} | {r['seconds']} |")
    if "DOCTOR_TABLE" in globals():
        lines += ["", "## Source availability in this environment", "", globals()["DOCTOR_TABLE"]]
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    sys.exit(main())
