#!/usr/bin/env python3
"""
Rule-based inbox triage scorer for MA11/MA12 automation.

Validates golden completeness (structural) and scores manual eval results
against the pass threshold in evals/automation/manifest.yaml.

Usage:
  # Structural golden validation (CI — no agent output required)
  python3 evals/automation/score_inbox.py --validate-goldens

  # Score a manual eval run log (YAML or JSON)
  python3 evals/automation/score_inbox.py --results eval-run-results.yaml

Results file schema:
  results:
    - id: 01-vip-board-update
      triage: pass | partial | fail
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("score_inbox: PyYAML required — pip install pyyaml", file=sys.stderr)
    raise SystemExit(1) from None

ROOT = Path(__file__).resolve().parents[2]
EVALS = ROOT / "evals"
MANIFEST_PATH = EVALS / "automation" / "manifest.yaml"
CORPUS_MANIFEST = EVALS / "corpus" / "manifest.yaml"
GOLDEN_DIR = EVALS / "golden" / "triage"

VALID_BUCKETS = frozenset(
    {"VIP", "Needs-reply", "FYI", "Marketing", "Ambiguous", "Long-thread", "Scheduling"}
)
VALID_ACTIONS = frozenset(
    {"reply", "calendar-hold", "task", "follow-up-watch", "archive"}
)
VALID_SCORES = frozenset({"pass", "partial", "fail"})


def load_yaml(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        data = yaml.safe_load(handle)
    return data if isinstance(data, dict) else {}


def inbox_domain(manifest: dict) -> dict | None:
    for entry in manifest.get("domains") or []:
        if isinstance(entry, dict) and entry.get("domain") == "inbox":
            return entry
    return None


def validate_golden(golden: dict, path: Path, errors: list[str]) -> None:
    gid = golden.get("id")
    if not gid:
        errors.append(f"{path.name}: missing 'id'")
        return

    bucket = golden.get("expected_bucket")
    if bucket and bucket not in VALID_BUCKETS:
        errors.append(f"{gid}: unknown expected_bucket '{bucket}'")

    if "draft_required" not in golden:
        errors.append(f"{gid}: missing 'draft_required'")

    action = golden.get("action")
    if action and action not in VALID_ACTIONS:
        errors.append(f"{gid}: unknown action '{action}'")

    if golden.get("task_capture_proposed") and not golden.get("task_capture_line"):
        errors.append(f"{gid}: task_capture_proposed without task_capture_line")

    if golden.get("batch_digest_expected") and bucket not in ("FYI", "Marketing"):
        errors.append(f"{gid}: batch_digest_expected on non-FYI/Marketing bucket")

    vip = golden.get("vip_priority")
    if vip is not None:
        if not isinstance(vip, dict):
            errors.append(f"{gid}: vip_priority must be a mapping")
        else:
            for key in ("rank", "tier", "sender"):
                if key not in vip:
                    errors.append(f"{gid}: vip_priority missing '{key}'")

    acceptable = golden.get("acceptable_buckets")
    if acceptable is not None and not isinstance(acceptable, list):
        errors.append(f"{gid}: acceptable_buckets must be a list")


def validate_all_goldens(corpus_ids: set[str]) -> list[str]:
    errors: list[str] = []
    golden_ids: set[str] = set()

    for path in sorted(GOLDEN_DIR.glob("*.yaml")):
        golden = load_yaml(path)
        gid = golden.get("id")
        if gid:
            golden_ids.add(gid)
            if gid not in corpus_ids:
                errors.append(f"golden {path.name} id '{gid}' not in corpus manifest")
        validate_golden(golden, path, errors)

    missing = corpus_ids - golden_ids
    for mid in sorted(missing):
        errors.append(f"corpus thread '{mid}' has no golden triage file")

    extra = golden_ids - corpus_ids
    for eid in sorted(extra):
        errors.append(f"golden '{eid}' has no corpus manifest entry")

    return errors


def score_results(
    results: dict,
    *,
    corpus_ids: set[str],
    pass_threshold: float,
    smoke_ids: list[str],
) -> tuple[float, list[str], list[str]]:
    """Return (pass_rate, failures, warnings)."""
    entries = results.get("results")
    if not isinstance(entries, list):
        return 0.0, ["results file missing 'results' list"], []

    scored: dict[str, str] = {}
    failures: list[str] = []
    warnings: list[str] = []

    for i, entry in enumerate(entries):
        if not isinstance(entry, dict):
            failures.append(f"results[{i}] must be a mapping")
            continue
        tid = entry.get("id")
        score = (entry.get("triage") or "").lower()
        if not tid:
            failures.append(f"results[{i}] missing 'id'")
            continue
        if score not in VALID_SCORES:
            failures.append(f"{tid}: invalid triage score '{entry.get('triage')}'")
            continue
        scored[tid] = score

    missing = corpus_ids - set(scored.keys())
    if missing:
        warnings.append(
            f"{len(missing)} corpus threads not scored (omitted from denominator): "
            + ", ".join(sorted(missing)[:5])
            + ("…" if len(missing) > 5 else "")
        )

    if not scored:
        return 0.0, failures or ["no scored threads"], warnings

    pass_count = sum(1 for s in scored.values() if s == "pass")
    pass_rate = pass_count / len(scored)

    if pass_rate < pass_threshold:
        failures.append(
            f"pass rate {pass_rate:.1%} below threshold {pass_threshold:.0%} "
            f"({pass_count}/{len(scored)} pass)"
        )

    smoke_missing = [sid for sid in smoke_ids if sid not in scored]
    if smoke_missing:
        warnings.append(f"smoke threads not in results: {', '.join(smoke_missing)}")
    else:
        smoke_fails = [sid for sid in smoke_ids if scored.get(sid) != "pass"]
        if smoke_fails:
            failures.append(
                f"smoke subset requires pass: failed {', '.join(smoke_fails)}"
            )

    partial_only = [tid for tid, s in scored.items() if s == "partial"]
    if partial_only and pass_rate >= pass_threshold:
        warnings.append(
            f"{len(partial_only)} partial scores (acceptable if ≥{pass_threshold:.0%} pass)"
        )

    return pass_rate, failures, warnings


def main() -> int:
    parser = argparse.ArgumentParser(description="Inbox triage rule-based scorer")
    parser.add_argument(
        "--validate-goldens",
        action="store_true",
        help="Validate golden triage files (default when no --results)",
    )
    parser.add_argument(
        "--results",
        type=Path,
        default=None,
        help="Path to manual eval results YAML/JSON",
    )
    args = parser.parse_args()

    if not MANIFEST_PATH.is_file():
        print(f"score_inbox: missing {MANIFEST_PATH}", file=sys.stderr)
        return 1

    automation = load_yaml(MANIFEST_PATH)
    domain = inbox_domain(automation)
    if not domain:
        print("score_inbox: inbox domain not registered in manifest", file=sys.stderr)
        return 1

    corpus = load_yaml(CORPUS_MANIFEST)
    threads = corpus.get("threads") or []
    corpus_ids = {t["id"] for t in threads if isinstance(t, dict) and t.get("id")}

    golden_errors = validate_all_goldens(corpus_ids)
    if golden_errors:
        for err in golden_errors:
            print(f"golden: {err}", file=sys.stderr)
        if args.validate_goldens or not args.results:
            return 1

    if args.validate_goldens or not args.results:
        smoke_ids = domain.get("smoke_thread_ids") or []
        smoke_missing = [sid for sid in smoke_ids if sid not in corpus_ids]
        if smoke_missing:
            print(
                f"score_inbox: smoke_thread_ids not in corpus: {smoke_missing}",
                file=sys.stderr,
            )
            return 1
        print(
            f"score_inbox: OK — {len(corpus_ids)} goldens validated, "
            f"{len(smoke_ids)} smoke ids registered"
        )
        return 0

    results_path = args.results.expanduser().resolve()
    if not results_path.is_file():
        print(f"score_inbox: results file not found: {results_path}", file=sys.stderr)
        return 1

    raw = results_path.read_text(encoding="utf-8")
    if results_path.suffix == ".json":
        results = json.loads(raw)
    else:
        results = yaml.safe_load(raw)
    if not isinstance(results, dict):
        print("score_inbox: results file must be a mapping at top level", file=sys.stderr)
        return 1

    pass_threshold = float(domain.get("pass_threshold", 0.90))
    smoke_ids = domain.get("smoke_thread_ids") or []
    pass_rate, failures, warnings = score_results(
        results,
        corpus_ids=corpus_ids,
        pass_threshold=pass_threshold,
        smoke_ids=smoke_ids,
    )

    for w in warnings:
        print(f"warn: {w}", file=sys.stderr)

    if failures:
        for f in failures:
            print(f"fail: {f}", file=sys.stderr)
        return 1

    print(f"score_inbox: OK — {pass_rate:.1%} pass rate (threshold {pass_threshold:.0%})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
