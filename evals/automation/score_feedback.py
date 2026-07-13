#!/usr/bin/env python3
"""
Rule-based feedback loop scorer for MA11/MA13 automation.

Validates feedback golden completeness and scores manual eval results.

Usage:
  python3 evals/automation/score_feedback.py --validate-goldens
  python3 evals/automation/score_feedback.py --results eval-run-feedback-results.yaml

Results file schema:
  results:
    - id: fb-03-heavy-rewrite-tone
      feedback: pass | partial | fail
      profile_diff_count: 0
      hunk_count: 1
      class_handled: good | light-edit | heavy-rewrite
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("score_feedback: PyYAML required — pip install pyyaml", file=sys.stderr)
    raise SystemExit(1) from None

ROOT = Path(__file__).resolve().parents[2]
EVALS = ROOT / "evals"
MANIFEST_PATH = EVALS / "automation" / "manifest.yaml"
GOLDEN_DIR = EVALS / "feedback" / "golden"
FIXTURE_MANIFEST = EVALS / "feedback" / "manifest.yaml"

FEEDBACK_CLASSES = frozenset({"good", "light-edit", "heavy-rewrite"})
VALID_SCORES = frozenset({"pass", "partial", "fail"})


def load_yaml(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        data = yaml.safe_load(handle)
    return data if isinstance(data, dict) else {}


def feedback_domain(manifest: dict) -> dict | None:
    for entry in manifest.get("domains") or []:
        if isinstance(entry, dict) and entry.get("domain") == "feedback":
            return entry
    return None


def validate_golden(golden: dict, path: Path, errors: list[str]) -> None:
    fid = golden.get("fixture_id")
    if not fid:
        errors.append(f"{path.name}: missing fixture_id")
        return

    fclass = golden.get("feedback_class")
    if fclass and fclass not in FEEDBACK_CLASSES:
        errors.append(f"{fid}: invalid feedback_class '{fclass}'")

    pdiff = golden.get("profile_diff_expected")
    if not isinstance(pdiff, dict):
        errors.append(f"{fid}: missing profile_diff_expected mapping")
        return

    if pdiff.get("required"):
        min_h = pdiff.get("min_hunks", 0)
        max_h = pdiff.get("max_hunks", 99)
        specs = pdiff.get("hunk_specs")
        if min_h >= 1 and (not specs or not isinstance(specs, list)):
            errors.append(
                f"{fid}: profile-diff golden requires hunk_specs with min_hunks >= 1"
            )
        elif isinstance(specs, list):
            for j, spec in enumerate(specs):
                if not isinstance(spec, dict):
                    errors.append(f"{fid}: hunk_specs[{j}] must be a mapping")
                    continue
                for key in ("section", "action", "rationale_patterns"):
                    if key not in spec:
                        errors.append(f"{fid}: hunk_specs[{j}] missing '{key}'")

    queue = golden.get("queue_items")
    if not isinstance(queue, dict):
        errors.append(f"{fid}: missing queue_items mapping")


def validate_all_goldens(min_profile_diff: int) -> tuple[list[str], set[str]]:
    errors: list[str] = []
    golden_ids: set[str] = set()
    profile_diff_goldens = 0

    for path in sorted(GOLDEN_DIR.glob("*.yaml")):
        golden = load_yaml(path)
        fid = golden.get("fixture_id")
        if fid:
            golden_ids.add(fid)
        validate_golden(golden, path, errors)

        pdiff = golden.get("profile_diff_expected") or {}
        if pdiff.get("required") and (pdiff.get("min_hunks") or 0) >= 1:
            specs = pdiff.get("hunk_specs") or []
            if specs:
                profile_diff_goldens += 1

    if profile_diff_goldens < min_profile_diff:
        errors.append(
            f"profile-diff goldens with full hunk_specs: {profile_diff_goldens}; "
            f"minimum is {min_profile_diff} (fb-03, fb-04, fb-05)"
        )

    return errors, golden_ids


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
        fid = entry.get("id")
        score = (entry.get("feedback") or "").lower()
        if not fid:
            failures.append(f"results[{i}] missing 'id'")
            continue
        if score not in VALID_SCORES:
            failures.append(f"{fid}: invalid feedback score '{entry.get('feedback')}'")
            continue
        scored[fid] = score

        golden = goldens.get(fid, {})
        pdiff = golden.get("profile_diff_expected") or {}
        queue = golden.get("queue_items") or {}
        hunk_count = entry.get("hunk_count")
        diff_count = entry.get("profile_diff_count")

        if pdiff.get("required"):
            min_h = pdiff.get("min_hunks", 1)
            max_h = pdiff.get("max_hunks", 99)
            if hunk_count is not None and not (min_h <= hunk_count <= max_h):
                failures.append(
                    f"{fid}: hunk_count {hunk_count} outside [{min_h}, {max_h}]"
                )
            min_q = queue.get("profile_diff_min", 0)
            if diff_count is not None and diff_count < min_q:
                failures.append(f"{fid}: profile_diff_count {diff_count} < min {min_q}")

        expected_class = golden.get("feedback_class")
        handled = entry.get("class_handled")
        if expected_class and handled and handled != expected_class:
            failures.append(f"{fid}: class_handled {handled!r} != expected {expected_class!r}")

        if golden.get("feedback_class") == "good" and diff_count and diff_count > 0:
            failures.append(f"{fid}: good class must not produce profile diff")

    if not scored:
        return 0.0, failures or ["no scored fixtures"], warnings

    pass_count = sum(1 for s in scored.values() if s == "pass")
    pass_rate = pass_count / len(scored)

    if pass_rate < pass_threshold:
        failures.append(
            f"pass rate {pass_rate:.1%} below threshold {pass_threshold:.0%}"
        )

    smoke_missing = [sid for sid in smoke_ids if sid not in scored]
    if smoke_missing:
        warnings.append(f"smoke fixtures not scored: {', '.join(smoke_missing)}")
    else:
        smoke_fails = [sid for sid in smoke_ids if scored.get(sid) != "pass"]
        if smoke_fails:
            failures.append(f"smoke feedback requires pass: {', '.join(smoke_fails)}")

    return pass_rate, failures, warnings


def main() -> int:
    parser = argparse.ArgumentParser(description="Feedback loop rule-based scorer")
    parser.add_argument("--validate-goldens", action="store_true")
    parser.add_argument("--results", type=Path, default=None)
    args = parser.parse_args()

    if not MANIFEST_PATH.is_file():
        print(f"score_feedback: missing {MANIFEST_PATH}", file=sys.stderr)
        return 1

    automation = load_yaml(MANIFEST_PATH)
    domain = feedback_domain(automation)
    if not domain:
        print("score_feedback: feedback domain not registered in manifest", file=sys.stderr)
        return 1

    min_profile_diff = int(domain.get("min_profile_diff_goldens", 3))
    golden_errors, golden_ids = validate_all_goldens(min_profile_diff)
    if golden_errors:
        for err in golden_errors:
            print(f"golden: {err}", file=sys.stderr)
        if args.validate_goldens or not args.results:
            return 1

    goldens = {}
    for path in GOLDEN_DIR.glob("*.yaml"):
        g = load_yaml(path)
        fid = g.get("fixture_id")
        if fid:
            goldens[fid] = g

    if args.validate_goldens or not args.results:
        smoke_ids = domain.get("smoke_fixture_ids") or []
        print(
            f"score_feedback: OK — {len(golden_ids)} feedback goldens validated, "
            f"{min_profile_diff} profile-diff hunk specs required, "
            f"{len(smoke_ids)} smoke ids registered"
        )
        return 0

    results_path = args.results.expanduser().resolve()
    if not results_path.is_file():
        print(f"score_feedback: results file not found: {results_path}", file=sys.stderr)
        return 1

    raw = results_path.read_text(encoding="utf-8")
    results = json.loads(raw) if results_path.suffix == ".json" else yaml.safe_load(raw)
    if not isinstance(results, dict):
        print("score_feedback: results file must be a mapping", file=sys.stderr)
        return 1

    pass_threshold = float(domain.get("pass_threshold", 1.0))
    smoke_ids = domain.get("smoke_fixture_ids") or []
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

    print(f"score_feedback: OK — {pass_rate:.1%} pass rate (threshold {pass_threshold:.0%})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
