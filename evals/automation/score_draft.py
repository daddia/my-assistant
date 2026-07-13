#!/usr/bin/env python3
"""
Rule-based draft quality scorer for MA11/MA13 automation.

Validates draft golden completeness (structural) and scores manual eval results
against golden fields in evals/golden/drafts/*.yaml.

Usage:
  python3 evals/automation/score_draft.py --validate-goldens
  python3 evals/automation/score_draft.py --results eval-run-draft-results.yaml

Results file schema:
  results:
    - id: 01-vip-board-update
      draft: pass | partial | fail
      draft_text: optional raw draft body for rule checks
      connector_mode: connected | paste-only | fallback-degraded
      variant_present: true | false
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("score_draft: PyYAML required — pip install pyyaml", file=sys.stderr)
    raise SystemExit(1) from None

ROOT = Path(__file__).resolve().parents[2]
EVALS = ROOT / "evals"
MANIFEST_PATH = EVALS / "automation" / "manifest.yaml"
CORPUS_MANIFEST = EVALS / "corpus" / "manifest.yaml"
GOLDEN_DIR = EVALS / "golden" / "drafts"

VALID_SCORES = frozenset({"pass", "partial", "fail"})
CONNECTOR_MODES = frozenset({"connected", "paste-only", "fallback-degraded"})
VARIANT_TYPES = frozenset({"shorter", "longer", "formal", "casual"})
SEND_PHRASES = (
    "i've sent",
    "i have sent",
    "already sent",
    "i've booked",
    "i have booked",
    "already booked",
)


def load_yaml(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        data = yaml.safe_load(handle)
    return data if isinstance(data, dict) else {}


def draft_domain(manifest: dict) -> dict | None:
    for entry in manifest.get("domains") or []:
        if isinstance(entry, dict) and entry.get("domain") == "draft":
            return entry
    return None


def draft_required_ids(corpus: dict) -> set[str]:
    ids: set[str] = set()
    for entry in corpus.get("threads") or []:
        if isinstance(entry, dict) and entry.get("draft_required") and entry.get("id"):
            ids.add(entry["id"])
    return ids


def count_sentences(text: str) -> int:
    chunks = re.split(r"[.!?]+", text.strip())
    return len([c for c in chunks if c.strip()])


def validate_golden(golden: dict, path: Path, errors: list[str]) -> None:
    gid = golden.get("id")
    if not gid:
        errors.append(f"{path.name}: missing 'id'")
        return
    if not isinstance(golden.get("must_not_send"), bool):
        errors.append(f"{gid}: missing or invalid must_not_send")
    if "max_sentences" not in golden:
        errors.append(f"{gid}: missing max_sentences")
    if not isinstance(golden.get("must_not_contain"), list):
        errors.append(f"{gid}: must_not_contain must be a list")

    grounding = golden.get("grounding_checks")
    if grounding is not None and not isinstance(grounding, dict):
        errors.append(f"{gid}: grounding_checks must be a mapping")

    mode = golden.get("connector_mode")
    if mode and mode not in CONNECTOR_MODES:
        errors.append(f"{gid}: invalid connector_mode '{mode}'")

    vtype = golden.get("variant_type")
    if vtype and vtype not in VARIANT_TYPES:
        errors.append(f"{gid}: invalid variant_type '{vtype}'")


def validate_all_goldens(min_count: int) -> tuple[list[str], set[str]]:
    errors: list[str] = []
    golden_ids: set[str] = set()

    paths = sorted(GOLDEN_DIR.glob("*.yaml"))
    if len(paths) < min_count:
        errors.append(
            f"draft golden count {len(paths)} below minimum {min_count}"
        )

    for path in paths:
        golden = load_yaml(path)
        gid = golden.get("id")
        if gid:
            golden_ids.add(gid)
        validate_golden(golden, path, errors)

    return errors, golden_ids


def rule_check_draft(
    golden: dict,
    *,
    draft_text: str,
    connector_mode: str | None,
    variant_present: bool | None,
) -> tuple[str, list[str]]:
    """Return (score, reasons). score is pass|partial|fail."""
    reasons: list[str] = []
    text_lower = draft_text.lower()

    for phrase in golden.get("must_not_contain") or []:
        if phrase.lower() in text_lower:
            reasons.append(f"must_not_contain hit: {phrase!r}")

    max_sent = golden.get("max_sentences")
    if max_sent is not None and draft_text.strip():
        sc = count_sentences(draft_text)
        if sc > int(max_sent):
            reasons.append(f"sentence count {sc} exceeds max_sentences {max_sent}")

    if golden.get("must_not_send"):
        for phrase in SEND_PHRASES:
            if phrase in text_lower:
                reasons.append(f"must_not_send violated: {phrase!r}")

    grounding = golden.get("grounding_checks") or {}
    for ref in grounding.get("attachment_refs") or []:
        if ref.lower() not in text_lower and "[[gap:" not in text_lower:
            reasons.append(f"attachment_refs missing {ref!r} without [[gap:")

    if golden.get("variant_expected") and not variant_present:
        reasons.append("variant_expected but variant block absent")

    expected_mode = golden.get("connector_mode")
    if expected_mode and connector_mode and connector_mode != expected_mode:
        reasons.append(
            f"connector_mode {connector_mode!r} != expected {expected_mode!r}"
        )

    if any("must_not_contain" in r or "must_not_send" in r or "variant_expected" in r for r in reasons):
        return "fail", reasons
    if reasons:
        return "partial", reasons
    return "pass", reasons


def score_results(
    results: dict,
    *,
    goldens: dict[str, dict],
    pass_threshold: float,
    smoke_ids: list[str],
) -> tuple[float, list[str], list[str]]:
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
        score = (entry.get("draft") or "").lower()
        if not tid:
            failures.append(f"results[{i}] missing 'id'")
            continue
        if score not in VALID_SCORES:
            failures.append(f"{tid}: invalid draft score '{entry.get('draft')}'")
            continue
        scored[tid] = score

        draft_text = entry.get("draft_text") or ""
        if draft_text and tid in goldens:
            rule_score, reasons = rule_check_draft(
                goldens[tid],
                draft_text=draft_text,
                connector_mode=entry.get("connector_mode"),
                variant_present=entry.get("variant_present"),
            )
            if rule_score == "fail" and score == "pass":
                failures.append(f"{tid}: manual pass but rule check fail: {reasons}")
            elif rule_score == "partial" and score == "pass":
                warnings.append(f"{tid}: rule partial: {reasons}")

    if not scored:
        return 0.0, failures or ["no scored threads"], warnings

    pass_count = sum(1 for s in scored.values() if s == "pass")
    pass_rate = pass_count / len(scored)

    if pass_rate < pass_threshold:
        failures.append(
            f"pass rate {pass_rate:.1%} below threshold {pass_threshold:.0%} "
            f"({pass_count}/{len(scored)} pass)"
        )

    smoke_fails = [sid for sid in smoke_ids if scored.get(sid) not in ("pass", "partial")]
    if smoke_fails:
        failures.append(f"smoke draft threads require pass/partial: {', '.join(smoke_fails)}")

    return pass_rate, failures, warnings


def main() -> int:
    parser = argparse.ArgumentParser(description="Draft quality rule-based scorer")
    parser.add_argument("--validate-goldens", action="store_true")
    parser.add_argument("--results", type=Path, default=None)
    args = parser.parse_args()

    if not MANIFEST_PATH.is_file():
        print(f"score_draft: missing {MANIFEST_PATH}", file=sys.stderr)
        return 1

    automation = load_yaml(MANIFEST_PATH)
    domain = draft_domain(automation)
    if not domain:
        print("score_draft: draft domain not registered in manifest", file=sys.stderr)
        return 1

    min_goldens = int(domain.get("min_goldens", 18))
    golden_errors, golden_ids = validate_all_goldens(min_goldens)
    if golden_errors:
        for err in golden_errors:
            print(f"golden: {err}", file=sys.stderr)
        if args.validate_goldens or not args.results:
            return 1

    goldens = {gid: load_yaml(GOLDEN_DIR / f"{gid}.yaml") for gid in golden_ids}

    if args.validate_goldens or not args.results:
        smoke_ids = domain.get("smoke_thread_ids") or []
        print(
            f"score_draft: OK — {len(golden_ids)} draft goldens validated, "
            f"{len(smoke_ids)} smoke ids registered"
        )
        return 0

    results_path = args.results.expanduser().resolve()
    if not results_path.is_file():
        print(f"score_draft: results file not found: {results_path}", file=sys.stderr)
        return 1

    raw = results_path.read_text(encoding="utf-8")
    results = json.loads(raw) if results_path.suffix == ".json" else yaml.safe_load(raw)
    if not isinstance(results, dict):
        print("score_draft: results file must be a mapping", file=sys.stderr)
        return 1

    pass_threshold = float(domain.get("pass_threshold", 0.90))
    smoke_ids = domain.get("smoke_thread_ids") or []
    pass_rate, failures, warnings = score_results(
        results,
        goldens=goldens,
        pass_threshold=pass_threshold,
        smoke_ids=smoke_ids,
    )

    for w in warnings:
        print(f"warn: {w}", file=sys.stderr)

    if failures:
        for f in failures:
            print(f"fail: {f}", file=sys.stderr)
        return 1

    print(f"score_draft: OK — {pass_rate:.1%} pass rate (threshold {pass_threshold:.0%})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
