#!/usr/bin/env python3
"""
Structural validation for the evals/ fixture tree.

Checks corpus manifests, golden files, config parity, PII patterns, and
cross-references across all eval corpora.

Usage: python3 scripts/validate_fixtures.py

Requires PyYAML: pip install pyyaml

Exits 0 on success, non-zero on failure.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print(
        "validate-fixtures: PyYAML required — pip install pyyaml",
        file=sys.stderr,
    )
    raise SystemExit(1) from None

ROOT = Path(__file__).resolve().parents[1]
EVALS_DIR = ROOT / "evals"

MIN_THREADS = 25
MIN_INJECTION = 10

REQUIRED_DIRS = [
    EVALS_DIR / "corpus/threads",
    EVALS_DIR / "golden/triage",
    EVALS_DIR / "golden/drafts",
    EVALS_DIR / "rubric",
    EVALS_DIR / "injection/fixtures",
    EVALS_DIR / "notetaker/fixtures",
    EVALS_DIR / "notetaker/golden",
    EVALS_DIR / "notetaker/rubric",
    EVALS_DIR / "calendar/fixtures",
    EVALS_DIR / "calendar/golden",
    EVALS_DIR / "calendar/rubric",
    EVALS_DIR / "schedule-health/fixtures",
    EVALS_DIR / "schedule-health/golden",
    EVALS_DIR / "feedback/fixtures",
    EVALS_DIR / "feedback/golden",
    EVALS_DIR / "feedback/rubric",
    EVALS_DIR / "connectors/fixtures",
    EVALS_DIR / "connectors/golden",
    EVALS_DIR / "connectors/rubric",
    EVALS_DIR / "starter-profiles",
    EVALS_DIR / "health-check/fixtures",
    EVALS_DIR / "health-check/golden",
    EVALS_DIR / "demo/assets",
]

REQUIRED_FILES = [
    EVALS_DIR / "corpus/manifest.yaml",
    EVALS_DIR / "injection/manifest.yaml",
    EVALS_DIR / "injection/expected-behaviour.yaml",
    EVALS_DIR / "notetaker/manifest.yaml",
    EVALS_DIR / "calendar/manifest.yaml",
    EVALS_DIR / "schedule-health/manifest.yaml",
    ROOT / "config/notetaker.yaml",
    ROOT / "config/calendar.yaml",
    ROOT / "scheduled/schedules.yaml",
    ROOT / "scheduled/schedules.schema.yaml",
    ROOT / "config/feedback.yaml",
    ROOT / "config/connectors.yaml",
    ROOT / "security/README.md",
    ROOT / "docs/guide/08-admin-deploy.md",
    ROOT / "docs/guide/connector-smoke-tests.md",
    EVALS_DIR / "feedback/manifest.yaml",
    EVALS_DIR / "connectors/manifest.yaml",
    ROOT / "config/starter-profiles/manifest.yaml",
    ROOT / "examples/before-after/manifest.yaml",
    ROOT / "config/health.yaml",
    ROOT / "config/health-report.schema.yaml",
    EVALS_DIR / "health-check/manifest.yaml",
]

PII_PATTERNS: dict[str, re.Pattern[str]] = {
    "ssn": re.compile(r"\b\d{3}-\d{2}-\d{4}\b"),
    "reserved-domain": re.compile(r"@[A-Za-z0-9.-]*company\.com\b", re.I),
}

NOTETAKER_FORMAT_IDS = frozenset({"granola", "fireflies", "otter", "google-meet", "hand-typed"})
DRAFT_TYPES = frozenset({"recap", "doc-delivery", "next-step"})
OWNER_VALUES = frozenset({"self", "other", "unknown"})

CALENDAR_BLOCK_TYPES = frozenset({"buffer", "prep", "follow-up", "focus-defence"})
VIOLATION_TYPES = frozenset({"buffer", "prep", "follow-up", "focus-intrusion"})

EXPECTED_JOB_IDS = [
    "morning-briefing",
    "inbox-sweep",
    "meeting-prep-watcher",
    "follow-up-watcher",
    "weekly-review",
]
SURFACES = frozenset({"local", "cloud-code", "managed"})
RUN_STATUSES = frozenset({"success", "partial", "failed", "missed"})

FEEDBACK_CLASSES = frozenset({"good", "light-edit", "heavy-rewrite"})
ALLOWED_PROFILE_SECTIONS = frozenset({"voice", "anti-style"})
FORBIDDEN_PROFILE_SECTIONS = frozenset({
    "autonomy", "vip", "email_policy", "calendar_policy",
    "working_rules", "money_threshold", "off_limits",
})

CONNECTOR_CATEGORIES = frozenset({"email", "calendar", "drive", "chat", "notes", "tasks"})
DEEP_SECURITY_DOCS = ("threat-model.md", "data-flow.md", "permissions.md")

BLOCKED_PERSONAL_DOMAINS = frozenset({
    "gmail.com", "yahoo.com", "hotmail.com", "outlook.com",
    "icloud.com", "me.com", "aol.com", "live.com",
})

HEALTH_CHECK_STATUSES = frozenset({"pass", "warn", "fail", "skip"})
HEALTH_CHECK_PLATFORMS = frozenset({"cowork", "cursor", "claude-code", "unknown"})
MIN_HEALTH_CHECKS = 20


def resolve_eval_path(rel: str) -> Path:
    path = Path(rel)
    if path.is_absolute():
        return path
    if rel.startswith(("docs/", "evals/")):
        return ROOT / rel
    return EVALS_DIR / rel


def load_yaml(path: Path) -> dict:
    return yaml.safe_load(path.read_text(encoding="utf-8")) or {}


def check_pii(path: Path, errors: list[str]) -> None:
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as exc:
        errors.append(f"cannot read {path}: {exc}")
        return
    for label, pattern in PII_PATTERNS.items():
        if pattern.search(text):
            rel = path.relative_to(ROOT)
            errors.append(f"blocked PII pattern '{label}' in {rel}")


def require_paths(errors: list[str]) -> None:
    for directory in REQUIRED_DIRS:
        if not directory.is_dir():
            errors.append(f"missing required directory: {directory}")
    for path in REQUIRED_FILES:
        if not path.is_file():
            errors.append(f"missing required file: {path}")


def validate_corpus(errors: list[str]) -> tuple[set[str], list]:
    corpus = load_yaml(EVALS_DIR / "corpus/manifest.yaml")
    threads = corpus.get("threads")
    if not isinstance(threads, list):
        errors.append("corpus/manifest.yaml: 'threads' must be a list")
        threads = []

    thread_ids: set[str] = set()
    for i, entry in enumerate(threads):
        if not isinstance(entry, dict):
            errors.append(f"corpus/manifest.yaml: threads[{i}] must be a mapping")
            continue
        tid = entry.get("id")
        fpath = entry.get("file")
        if not tid:
            errors.append(f"corpus/manifest.yaml: threads[{i}] missing 'id'")
        elif tid in thread_ids:
            errors.append(f"corpus/manifest.yaml: duplicate thread id '{tid}'")
        else:
            thread_ids.add(tid)
        if not fpath:
            errors.append(f"corpus/manifest.yaml: thread '{tid}' missing 'file'")
            continue
        resolved = resolve_eval_path(fpath)
        if not resolved.is_file():
            errors.append(f"missing corpus thread file: {resolved}")
        else:
            check_pii(resolved, errors)

    golden_triage_dir = EVALS_DIR / "golden/triage"
    for gf in golden_triage_dir.glob("*.yaml"):
        data = load_yaml(gf)
        gid = data.get("id")
        if gid and gid not in thread_ids:
            errors.append(f"golden triage {gf.name} references unknown corpus id '{gid}'")

    if threads and len(threads) < MIN_THREADS:
        errors.append(
            f"corpus/manifest.yaml lists {len(threads)} threads; minimum is {MIN_THREADS}"
        )

    golden_count = len(list(golden_triage_dir.glob("*.yaml")))
    if threads and golden_count and golden_count != len(threads):
        errors.append(
            f"golden triage file count ({golden_count}) does not match corpus ({len(threads)})"
        )

    return thread_ids, threads


def validate_injection(errors: list[str]) -> list:
    injection = load_yaml(EVALS_DIR / "injection/manifest.yaml")
    fixtures = injection.get("fixtures")
    if not isinstance(fixtures, list):
        errors.append("injection/manifest.yaml: 'fixtures' must be a list")
        fixtures = []

    fixture_ids: set[str] = set()
    for i, entry in enumerate(fixtures):
        if not isinstance(entry, dict):
            errors.append(f"injection/manifest.yaml: fixtures[{i}] must be a mapping")
            continue
        fid = entry.get("id")
        fpath = entry.get("file")
        if not fid:
            errors.append(f"injection/manifest.yaml: fixtures[{i}] missing 'id'")
        elif fid in fixture_ids:
            errors.append(f"injection/manifest.yaml: duplicate fixture id '{fid}'")
        else:
            fixture_ids.add(fid)
        if not fpath:
            errors.append(f"injection/manifest.yaml: fixture '{fid}' missing 'file'")
            continue
        resolved = resolve_eval_path(fpath)
        if not resolved.is_file():
            errors.append(f"missing injection fixture file: {resolved}")
        else:
            check_pii(resolved, errors)

    if fixtures and len(fixtures) < MIN_INJECTION:
        errors.append(
            f"injection/manifest.yaml lists {len(fixtures)} fixtures; minimum is {MIN_INJECTION}"
        )

    return fixtures


def validate_notetaker(errors: list[str]) -> list:
    formats_path = ROOT / "config/notetaker.yaml"
    if formats_path.is_file():
        formats_doc = load_yaml(formats_path)
        format_ids = [
            e.get("format_id")
            for e in formats_doc.get("formats", [])
            if isinstance(e, dict)
        ]
        if sorted(format_ids) != sorted(NOTETAKER_FORMAT_IDS):
            errors.append(
                f"config/notetaker.yaml must list exactly "
                f"{', '.join(sorted(NOTETAKER_FORMAT_IDS))}; got {', '.join(format_ids)}"
            )
    else:
        errors.append("missing config/notetaker.yaml")

    manifest_path = EVALS_DIR / "notetaker/manifest.yaml"
    if not manifest_path.is_file():
        errors.append("missing notetaker/manifest.yaml")
        return []

    notetaker = load_yaml(manifest_path)
    nt_fixtures = notetaker.get("fixtures")
    if not isinstance(nt_fixtures, list):
        errors.append("notetaker/manifest.yaml: 'fixtures' must be a list")
        return []

    nt_ids: set[str] = set()
    for i, entry in enumerate(nt_fixtures):
        if not isinstance(entry, dict):
            errors.append(f"notetaker/manifest.yaml: fixtures[{i}] must be a mapping")
            continue
        fid = entry.get("id")
        fpath = entry.get("file")
        gpath = entry.get("golden")
        if not fid:
            errors.append(f"notetaker/manifest.yaml: fixtures[{i}] missing 'id'")
        elif fid in nt_ids:
            errors.append(f"notetaker/manifest.yaml: duplicate fixture id '{fid}'")
        else:
            nt_ids.add(fid)

        if not fpath:
            errors.append(f"notetaker/manifest.yaml: fixture '{fid}' missing 'file'")
        else:
            resolved = resolve_eval_path(fpath)
            if not resolved.is_file():
                errors.append(f"missing notetaker fixture file: {resolved}")
            else:
                check_pii(resolved, errors)

        if not gpath:
            errors.append(f"notetaker/manifest.yaml: fixture '{fid}' missing 'golden'")
            continue

        golden_resolved = resolve_eval_path(gpath)
        if not golden_resolved.is_file():
            errors.append(f"missing notetaker golden file: {golden_resolved}")
            continue

        golden = load_yaml(golden_resolved)
        if golden.get("fixture_id") != fid:
            errors.append(
                f"notetaker golden {Path(gpath).name} fixture_id "
                f"'{golden.get('fixture_id')}' does not match manifest id '{fid}'"
            )

        fmt = golden.get("format_expected")
        if fmt and fmt not in NOTETAKER_FORMAT_IDS:
            errors.append(
                f"notetaker golden {Path(gpath).name} invalid format_expected '{fmt}'"
            )

        meeting = golden.get("meeting")
        if not isinstance(meeting, dict):
            errors.append(f"notetaker golden {Path(gpath).name} missing 'meeting' mapping")
        else:
            if "decisions_min" not in meeting:
                errors.append(
                    f"notetaker golden {Path(gpath).name} missing meeting.decisions_min"
                )
            if "must_flag_ambiguity" not in meeting:
                errors.append(
                    f"notetaker golden {Path(gpath).name} missing meeting.must_flag_ambiguity"
                )
            items = meeting.get("action_items")
            if not isinstance(items, list):
                errors.append(
                    f"notetaker golden {Path(gpath).name} meeting.action_items must be a list"
                )
            else:
                for j, item in enumerate(items):
                    if not isinstance(item, dict):
                        continue
                    owner = item.get("owner")
                    if owner and owner not in OWNER_VALUES:
                        errors.append(
                            f"notetaker golden {Path(gpath).name} action_items[{j}] "
                            "owner must be self, other, or unknown"
                        )

        drafts = golden.get("drafts_expected")
        if not isinstance(drafts, dict):
            errors.append(
                f"notetaker golden {Path(gpath).name} missing 'drafts_expected' mapping"
            )
        else:
            if "min_count" not in drafts:
                errors.append(
                    f"notetaker golden {Path(gpath).name} missing drafts_expected.min_count"
                )
            types = drafts.get("types")
            if not isinstance(types, list):
                errors.append(
                    f"notetaker golden {Path(gpath).name} drafts_expected.types must be a list"
                )
            else:
                for t in types:
                    if t not in DRAFT_TYPES:
                        errors.append(
                            f"notetaker golden {Path(gpath).name} invalid draft type '{t}'"
                        )

        if "queue_items_min" not in golden:
            errors.append(f"notetaker golden {Path(gpath).name} missing queue_items_min")

        inj = golden.get("injection_checks")
        if inj:
            for key in ("must_surface", "must_refuse", "must_not_write"):
                val = inj.get(key)
                if val is not None and not isinstance(val, list):
                    errors.append(
                        f"notetaker golden {Path(gpath).name} injection_checks.{key} must be a list"
                    )

    return nt_fixtures


def validate_calendar(errors: list[str]) -> list:
    block_types_path = ROOT / "config/calendar.yaml"
    if block_types_path.is_file():
        block_doc = load_yaml(block_types_path)
        block_type_ids = [
            e.get("block_type")
            for e in block_doc.get("block_types", [])
            if isinstance(e, dict)
        ]
        if sorted(block_type_ids) != sorted(CALENDAR_BLOCK_TYPES):
            errors.append(
                f"config/calendar.yaml must list exactly "
                f"{', '.join(sorted(CALENDAR_BLOCK_TYPES))}; got {', '.join(block_type_ids)}"
            )
    else:
        errors.append("missing config/calendar.yaml")

    manifest_path = EVALS_DIR / "calendar/manifest.yaml"
    if not manifest_path.is_file():
        errors.append("missing calendar/manifest.yaml")
        return []

    calendar = load_yaml(manifest_path)
    cal_fixtures = calendar.get("fixtures")
    if not isinstance(cal_fixtures, list):
        errors.append("calendar/manifest.yaml: 'fixtures' must be a list")
        return []

    cal_ids: set[str] = set()
    for i, entry in enumerate(cal_fixtures):
        if not isinstance(entry, dict):
            errors.append(f"calendar/manifest.yaml: fixtures[{i}] must be a mapping")
            continue
        fid = entry.get("id")
        fpath = entry.get("file")
        gpath = entry.get("golden")
        if not fid:
            errors.append(f"calendar/manifest.yaml: fixtures[{i}] missing 'id'")
        elif fid in cal_ids:
            errors.append(f"calendar/manifest.yaml: duplicate fixture id '{fid}'")
        else:
            cal_ids.add(fid)

        if not fpath:
            errors.append(f"calendar/manifest.yaml: fixture '{fid}' missing 'file'")
        else:
            resolved = resolve_eval_path(fpath)
            if not resolved.is_file():
                errors.append(f"missing calendar fixture file: {resolved}")
            else:
                check_pii(resolved, errors)

        if not gpath:
            errors.append(f"calendar/manifest.yaml: fixture '{fid}' missing 'golden'")
            continue

        golden_resolved = resolve_eval_path(gpath)
        if not golden_resolved.is_file():
            errors.append(f"missing calendar golden file: {golden_resolved}")
            continue

        golden = load_yaml(golden_resolved)
        if golden.get("fixture_id") != fid:
            errors.append(
                f"calendar golden {Path(gpath).name} fixture_id "
                f"'{golden.get('fixture_id')}' does not match manifest id '{fid}'"
            )

        violations = golden.get("violations_expected")
        if not isinstance(violations, list):
            errors.append(
                f"calendar golden {Path(gpath).name} violations_expected must be a list"
            )
        else:
            for j, vio in enumerate(violations):
                if not isinstance(vio, dict):
                    continue
                vtype = vio.get("type")
                if vtype and vtype not in VIOLATION_TYPES:
                    errors.append(
                        f"calendar golden {Path(gpath).name} violations_expected[{j}] "
                        f"invalid type '{vtype}'"
                    )

        proposals = golden.get("proposals_expected")
        if not isinstance(proposals, dict):
            errors.append(
                f"calendar golden {Path(gpath).name} missing 'proposals_expected' mapping"
            )
        else:
            if "min_count" not in proposals:
                errors.append(
                    f"calendar golden {Path(gpath).name} missing proposals_expected.min_count"
                )
            types = proposals.get("block_types")
            if not isinstance(types, list):
                errors.append(
                    f"calendar golden {Path(gpath).name} proposals_expected.block_types must be a list"
                )
            else:
                for t in types:
                    if t not in CALENDAR_BLOCK_TYPES:
                        errors.append(
                            f"calendar golden {Path(gpath).name} invalid block type '{t}'"
                        )
            must_not = proposals.get("must_not_contain")
            if must_not is not None and not isinstance(must_not, list):
                errors.append(
                    f"calendar golden {Path(gpath).name} proposals_expected.must_not_contain must be a list"
                )

        if "queue_items_min" not in golden:
            errors.append(f"calendar golden {Path(gpath).name} missing queue_items_min")

        for section, keys in (
            ("approval_language_checks", ("must_include", "must_not_include")),
            ("injection_checks", ("must_surface", "must_refuse", "must_not_write")),
        ):
            block = golden.get(section)
            if block:
                for key in keys:
                    val = block.get(key)
                    if val is not None and not isinstance(val, list):
                        errors.append(
                            f"calendar golden {Path(gpath).name} {section}.{key} must be a list"
                        )

    return cal_fixtures


def _validate_schedule_job_file(
    errors: list[str],
    job_path: Path,
    label: str,
) -> None:
    if not job_path.is_file():
        errors.append(f"missing schedule job file: {job_path}")
        return
    job_entry = load_yaml(job_path)
    if not isinstance(job_entry, dict):
        errors.append(f"schedule job file {label} must be a mapping")
        return
    job_id = job_entry.get("job_id")
    stem = job_path.stem
    if job_id != stem:
        errors.append(
            f"schedule job file {label} job_id '{job_id}' does not match filename '{stem}'"
        )
    for field in ("version", "updated_at", "surface", "cadence", "last_run_status", "miss_count_7d"):
        if field not in job_entry:
            errors.append(f"schedule job file {label} missing '{field}'")
    surface = job_entry.get("surface")
    if surface and surface not in SURFACES:
        errors.append(f"schedule job file {label} invalid surface '{surface}'")
    status = job_entry.get("last_run_status")
    if status and status not in RUN_STATUSES:
        errors.append(f"schedule job file {label} invalid last_run_status '{status}'")
    miss = job_entry.get("miss_count_7d")
    if miss is not None and not isinstance(miss, int):
        errors.append(f"schedule job file {label} miss_count_7d must be integer")


def validate_schedule_health(errors: list[str]) -> list:
    catalog_path = ROOT / "scheduled/schedules.yaml"
    if catalog_path.is_file():
        catalog = load_yaml(catalog_path)
        catalog_jobs = catalog.get("jobs", [])
        catalog_ids = [
            j.get("job_id") for j in catalog_jobs if isinstance(j, dict)
        ]
        if sorted(catalog_ids) != sorted(EXPECTED_JOB_IDS):
            errors.append(
                f"scheduled/schedules.yaml must list exactly "
                f"{', '.join(EXPECTED_JOB_IDS)}; got {', '.join(catalog_ids)}"
            )
        for job in catalog_jobs:
            if not isinstance(job, dict):
                continue
            jid = job.get("job_id")
            skill = job.get("skill")
            if not skill:
                errors.append(f"catalog job '{jid}' missing skill")
            managed = (job.get("surfaces") or {}).get("managed", {}).get("cookbook")
            if managed and not (ROOT / managed).is_file():
                errors.append(f"catalog job '{jid}' managed cookbook missing: {managed}")
    else:
        errors.append("missing scheduled/schedules.yaml")

    manifest_path = EVALS_DIR / "schedule-health/manifest.yaml"
    if not manifest_path.is_file():
        errors.append("missing schedule-health/manifest.yaml")
        return []

    sh_manifest = load_yaml(manifest_path)
    sh_fixtures = sh_manifest.get("fixtures")
    if not isinstance(sh_fixtures, list):
        errors.append("schedule-health/manifest.yaml: 'fixtures' must be a list")
        return []

    sh_ids: set[str] = set()
    for i, entry in enumerate(sh_fixtures):
        if not isinstance(entry, dict):
            errors.append(f"schedule-health/manifest.yaml: fixtures[{i}] must be a mapping")
            continue
        fid = entry.get("id")
        fpath = entry.get("file")
        gpath = entry.get("golden")
        if not fid:
            errors.append(f"schedule-health/manifest.yaml: fixtures[{i}] missing 'id'")
        elif fid in sh_ids:
            errors.append(f"schedule-health/manifest.yaml: duplicate fixture id '{fid}'")
        else:
            sh_ids.add(fid)

        if not fpath:
            errors.append(f"schedule-health/manifest.yaml: fixture '{fid}' missing 'file'")
        else:
            resolved = resolve_eval_path(fpath)
            if resolved.is_dir():
                job_files = sorted(resolved.glob("*.yaml"))
                if not job_files:
                    errors.append(f"schedule-health fixture directory {fpath} has no job files")
                for job_path in job_files:
                    _validate_schedule_job_file(
                        errors,
                        job_path,
                        f"{Path(fpath).name}/{job_path.name}",
                    )
            elif resolved.is_file():
                errors.append(
                    f"schedule-health fixture {fpath} must be a directory of job files, not a single file"
                )
            else:
                errors.append(f"missing schedule-health fixture directory: {resolved}")

        if not gpath:
            errors.append(f"schedule-health/manifest.yaml: fixture '{fid}' missing 'golden'")
            continue

        golden_resolved = resolve_eval_path(gpath)
        if not golden_resolved.is_file():
            errors.append(f"missing schedule-health golden file: {golden_resolved}")
            continue

        golden = load_yaml(golden_resolved)
        if golden.get("fixture_id") != fid:
            errors.append(
                f"schedule-health golden {Path(gpath).name} fixture_id "
                f"'{golden.get('fixture_id')}' does not match manifest id '{fid}'"
            )
        for key in ("must_surface", "must_not"):
            val = golden.get(key)
            if val is not None and not isinstance(val, list):
                errors.append(
                    f"schedule-health golden {Path(gpath).name} {key} must be a list"
                )
        if not golden.get("trigger_skill"):
            errors.append(f"schedule-health golden {Path(gpath).name} missing trigger_skill")

    return sh_fixtures


def validate_feedback(errors: list[str]) -> list:
    signals_path = ROOT / "config/feedback.yaml"
    if signals_path.is_file():
        signals = load_yaml(signals_path)
        class_ids = [
            e.get("id")
            for e in signals.get("feedback_classes", [])
            if isinstance(e, dict)
        ]
        if sorted(class_ids) != sorted(FEEDBACK_CLASSES):
            errors.append(
                f"config/feedback.yaml must list exactly "
                f"{', '.join(sorted(FEEDBACK_CLASSES))}; got {', '.join(class_ids)}"
            )
        allowed = signals.get("allowed_profile_sections", [])
        if sorted(allowed) != sorted(ALLOWED_PROFILE_SECTIONS):
            errors.append(
                "config/feedback.yaml allowed_profile_sections must be "
                f"{', '.join(sorted(ALLOWED_PROFILE_SECTIONS))}"
            )
    else:
        errors.append("missing config/feedback.yaml")

    manifest_path = EVALS_DIR / "feedback/manifest.yaml"
    if not manifest_path.is_file():
        errors.append("missing feedback/manifest.yaml")
        return []

    fb_manifest = load_yaml(manifest_path)
    fb_fixtures = fb_manifest.get("fixtures")
    if not isinstance(fb_fixtures, list):
        errors.append("feedback/manifest.yaml: 'fixtures' must be a list")
        return []

    fb_ids: set[str] = set()
    for i, entry in enumerate(fb_fixtures):
        if not isinstance(entry, dict):
            errors.append(f"feedback/manifest.yaml: fixtures[{i}] must be a mapping")
            continue
        fid = entry.get("id")
        fpath = entry.get("file")
        gpath = entry.get("golden")
        fclass = entry.get("feedback_class")
        if not fid:
            errors.append(f"feedback/manifest.yaml: fixtures[{i}] missing 'id'")
        elif fid in fb_ids:
            errors.append(f"feedback/manifest.yaml: duplicate fixture id '{fid}'")
        else:
            fb_ids.add(fid)
        if fclass and fclass not in FEEDBACK_CLASSES:
            errors.append(
                f"feedback/manifest.yaml: fixture '{fid}' invalid feedback_class '{fclass}'"
            )

        if not fpath:
            errors.append(f"feedback/manifest.yaml: fixture '{fid}' missing 'file'")
        else:
            resolved = resolve_eval_path(fpath)
            if not resolved.is_file():
                errors.append(f"missing feedback fixture file: {resolved}")
            else:
                check_pii(resolved, errors)

        if not gpath:
            errors.append(f"feedback/manifest.yaml: fixture '{fid}' missing 'golden'")
            continue

        golden_resolved = resolve_eval_path(gpath)
        if not golden_resolved.is_file():
            errors.append(f"missing feedback golden file: {golden_resolved}")
            continue

        golden = load_yaml(golden_resolved)
        if golden.get("fixture_id") != fid:
            errors.append(
                f"feedback golden {Path(gpath).name} fixture_id "
                f"'{golden.get('fixture_id')}' does not match manifest id '{fid}'"
            )
        gclass = golden.get("feedback_class")
        if gclass and gclass not in FEEDBACK_CLASSES:
            errors.append(
                f"feedback golden {Path(gpath).name} invalid feedback_class '{gclass}'"
            )
        if "user_final_required" not in golden:
            errors.append(f"feedback golden {Path(gpath).name} missing user_final_required")

        pdiff = golden.get("profile_diff_expected")
        if not isinstance(pdiff, dict):
            errors.append(
                f"feedback golden {Path(gpath).name} missing 'profile_diff_expected' mapping"
            )
        else:
            for sec in pdiff.get("sections") or []:
                if sec not in ALLOWED_PROFILE_SECTIONS:
                    errors.append(
                        f"feedback golden {Path(gpath).name} invalid section '{sec}'"
                    )
            for sec in pdiff.get("must_not_touch") or []:
                if sec not in FORBIDDEN_PROFILE_SECTIONS:
                    errors.append(
                        f"feedback golden {Path(gpath).name} invalid must_not_touch '{sec}'"
                    )

        queue = golden.get("queue_items")
        if not isinstance(queue, dict):
            errors.append(f"feedback golden {Path(gpath).name} missing 'queue_items' mapping")
        else:
            if "profile_diff_min" not in queue:
                errors.append(
                    f"feedback golden {Path(gpath).name} missing queue_items.profile_diff_min"
                )
            if "profile_diff_max" not in queue:
                errors.append(
                    f"feedback golden {Path(gpath).name} missing queue_items.profile_diff_max"
                )

        if "voice_sample_expected" not in golden:
            errors.append(f"feedback golden {Path(gpath).name} missing voice_sample_expected")

        for section, keys in (
            ("approval_language_checks", ("must_include", "must_not_include")),
            ("injection_checks", ("must_surface", "must_refuse", "must_not_write")),
        ):
            block = golden.get(section)
            if block:
                for key in keys:
                    val = block.get(key)
                    if val is not None and not isinstance(val, list):
                        errors.append(
                            f"feedback golden {Path(gpath).name} {section}.{key} must be a list"
                        )

    for diff_path in EVALS_DIR.glob("feedback/**/*.diff"):
        text = diff_path.read_text(encoding="utf-8")
        if not re.search(r"Voice|Anti-style|anti-style|voice", text):
            errors.append(
                f"feedback diff {diff_path.name} must reference voice or anti-style section markers"
            )
        for forbidden in FORBIDDEN_PROFILE_SECTIONS:
            if re.search(re.escape(forbidden), text, re.I) or re.search(
                r"VIP tiers|autonomy tier|Email policy", text, re.I
            ):
                errors.append(
                    f"feedback diff {diff_path.name} must not touch forbidden section {forbidden}"
                )

    return fb_fixtures


def validate_connectors(errors: list[str]) -> list:
    security_readme = ROOT / "security/README.md"
    if security_readme.is_file():
        text = security_readme.read_text(encoding="utf-8")
        for doc in DEEP_SECURITY_DOCS:
            if doc not in text:
                errors.append(f"security/README.md must link to {doc}")
    else:
        errors.append("missing security/README.md")

    conn_manifest_path = ROOT / "config/connectors.yaml"
    conn_fixtures: list = []
    if conn_manifest_path.is_file():
        conn_doc = load_yaml(conn_manifest_path)
        categories = conn_doc.get("categories")
        if not isinstance(categories, list):
            errors.append("connectors.yaml: 'categories' must be a list")
            categories = []

        cat_ids = [
            c.get("category") for c in categories if isinstance(c, dict)
        ]
        if sorted(cat_ids) != sorted(CONNECTOR_CATEGORIES):
            errors.append(
                f"connectors.yaml must list exactly "
                f"{', '.join(sorted(CONNECTOR_CATEGORIES))}; got {', '.join(cat_ids)}"
            )

        for i, entry in enumerate(categories):
            if not isinstance(entry, dict):
                errors.append(f"connectors.yaml: categories[{i}] must be a mapping")
                continue
            cat = entry.get("category")
            smoke = entry.get("smoke")
            if not isinstance(smoke, dict):
                errors.append(f"connectors.yaml: category '{cat}' missing 'smoke' mapping")
                continue

            fpath = smoke.get("standalone_fixture")
            gpath = smoke.get("golden")
            cmd = smoke.get("command")
            if not fpath:
                errors.append(
                    f"connectors.yaml: category '{cat}' missing smoke.standalone_fixture"
                )
            if not gpath:
                errors.append(
                    f"connectors.yaml: category '{cat}' missing smoke.golden"
                )
            if not cmd:
                errors.append(
                    f"connectors.yaml: category '{cat}' missing smoke.command"
                )

            if fpath:
                resolved = resolve_eval_path(fpath)
                if not resolved.is_file():
                    errors.append(f"missing connector fixture file: {resolved}")
                else:
                    check_pii(resolved, errors)

            if gpath:
                golden_resolved = resolve_eval_path(gpath)
                if not golden_resolved.is_file():
                    errors.append(f"missing connector golden file: {golden_resolved}")
                else:
                    golden = load_yaml(golden_resolved)
                    expected_id = f"conn-{cat}-paste"
                    if golden.get("fixture_id") != expected_id:
                        errors.append(
                            f"connector golden {Path(gpath).name} fixture_id "
                            f"'{golden.get('fixture_id')}' expected '{expected_id}'"
                        )
                    if golden.get("category") != cat:
                        errors.append(
                            f"connector golden {Path(gpath).name} category "
                            f"'{golden.get('category')}' does not match '{cat}'"
                        )
                    standalone = golden.get("standalone_pass")
                    if not isinstance(standalone, dict):
                        errors.append(
                            f"connector golden {Path(gpath).name} missing 'standalone_pass' mapping"
                        )
                    else:
                        for key in ("must_surface", "must_not"):
                            val = standalone.get(key)
                            if val is not None and not isinstance(val, list):
                                errors.append(
                                    f"connector golden {Path(gpath).name} "
                                    f"standalone_pass.{key} must be a list"
                                )

            live = entry.get("live_optional")
            if cat == "email" and isinstance(live, dict) and live.get("draft_only") is not True:
                errors.append(
                    "connectors.yaml: email live_optional.draft_only must be true"
                )
    else:
        errors.append("missing config/connectors.yaml")

    conn_eval_manifest_path = EVALS_DIR / "connectors/manifest.yaml"
    if conn_eval_manifest_path.is_file():
        conn_eval = load_yaml(conn_eval_manifest_path)
        conn_fixtures = conn_eval.get("fixtures")
        if not isinstance(conn_fixtures, list):
            errors.append("connectors/manifest.yaml: 'fixtures' must be a list")
            conn_fixtures = []

        conn_ids: set[str] = set()
        for i, entry in enumerate(conn_fixtures):
            if not isinstance(entry, dict):
                errors.append(f"connectors/manifest.yaml: fixtures[{i}] must be a mapping")
                continue
            fid = entry.get("id")
            fpath = entry.get("file")
            gpath = entry.get("golden")
            cat = entry.get("category")
            if not fid:
                errors.append(f"connectors/manifest.yaml: fixtures[{i}] missing 'id'")
            elif fid in conn_ids:
                errors.append(f"connectors/manifest.yaml: duplicate fixture id '{fid}'")
            else:
                conn_ids.add(fid)
            if cat and cat not in CONNECTOR_CATEGORIES:
                errors.append(
                    f"connectors/manifest.yaml: fixture '{fid}' invalid category '{cat}'"
                )
            if cat and fid != f"conn-{cat}-paste":
                errors.append(
                    f"connectors/manifest.yaml: fixture '{fid}' id should be conn-{cat}-paste"
                )
            if not fpath:
                errors.append(f"connectors/manifest.yaml: fixture '{fid}' missing 'file'")
            elif not resolve_eval_path(fpath).is_file():
                errors.append(f"missing connector manifest fixture file: {resolve_eval_path(fpath)}")
            if not gpath:
                errors.append(f"connectors/manifest.yaml: fixture '{fid}' missing 'golden'")
            elif not resolve_eval_path(gpath).is_file():
                errors.append(
                    f"missing connector manifest golden file: {resolve_eval_path(gpath)}"
                )

        if len(conn_fixtures) != len(CONNECTOR_CATEGORIES):
            errors.append(
                f"connectors/manifest.yaml lists {len(conn_fixtures)} fixtures; "
                f"expected {len(CONNECTOR_CATEGORIES)}"
            )
    else:
        errors.append("missing connectors/manifest.yaml")

    return conn_fixtures


def validate_starter_profiles(errors: list[str]) -> list:
    manifest_path = ROOT / "config/starter-profiles/manifest.yaml"
    if not manifest_path.is_file():
        errors.append("missing config/starter-profiles/manifest.yaml")
        return []

    starter_doc = load_yaml(manifest_path)
    required_sections = starter_doc.get("required_sections", [])
    max_words = int(starter_doc.get("max_words", 2000))
    starter_profiles = starter_doc.get("profiles")
    if not isinstance(starter_profiles, list):
        errors.append("starter-profiles/manifest.yaml: 'profiles' must be a list")
        return []

    expected_ids = ["founder", "consultant", "sales-lead", "operator", "investor"]
    found_ids = [p.get("id") for p in starter_profiles if isinstance(p, dict)]
    if sorted(found_ids) != sorted(expected_ids):
        errors.append(
            f"starter-profiles/manifest.yaml must list exactly "
            f"{', '.join(expected_ids)}; got {', '.join(found_ids)}"
        )

    for i, entry in enumerate(starter_profiles):
        if not isinstance(entry, dict):
            errors.append(f"starter-profiles/manifest.yaml: profiles[{i}] must be a mapping")
            continue
        pid = entry.get("id")
        fpath = entry.get("file")
        if not fpath:
            errors.append(f"starter-profiles/manifest.yaml: profile '{pid}' missing 'file'")
            continue
        resolved = ROOT / fpath
        if not resolved.is_file():
            errors.append(f"missing starter profile file: {resolved}")
            continue

        text = resolved.read_text(encoding="utf-8")
        for sec in required_sections:
            if sec not in text:
                errors.append(f"starter profile {pid} missing section header: {sec}")

        word_count = len(text.split())
        if word_count > max_words:
            errors.append(
                f"starter profile {pid} has {word_count} words; max is {max_words}"
            )

        if starter_doc.get("fictional_only"):
            for match in re.finditer(r"@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b", text):
                domain = match.group(0).lstrip("@").lower()
                if domain.endswith("-eval.test") or domain == "example.com":
                    continue
                if domain in BLOCKED_PERSONAL_DOMAINS:
                    errors.append(
                        f"starter profile {pid} blocked personal email domain @{domain}"
                    )

    return starter_profiles


def validate_before_after(errors: list[str], thread_ids: set[str]) -> list:
    manifest_path = ROOT / "examples/before-after/manifest.yaml"
    if not manifest_path.is_file():
        errors.append("missing examples/before-after/manifest.yaml")
        return []

    ba_doc = load_yaml(manifest_path)
    before_after_demos = ba_doc.get("demos")
    generic_violations = ba_doc.get("generic_violations", [])
    if not isinstance(before_after_demos, list):
        errors.append("before-after/manifest.yaml: 'demos' must be a list")
        return []
    if not isinstance(generic_violations, list):
        errors.append("before-after/manifest.yaml: generic_violations must be a list")

    for i, demo in enumerate(before_after_demos):
        if not isinstance(demo, dict):
            errors.append(f"before-after/manifest.yaml: demos[{i}] must be a mapping")
            continue
        tid = demo.get("thread_id")
        if tid and tid not in thread_ids:
            errors.append(f"before-after demo '{tid}' thread_id not in corpus manifest")

        for key in ("corpus", "golden", "generic"):
            rel = demo.get(key)
            if not rel:
                errors.append(f"before-after/manifest.yaml: demo '{tid}' missing '{key}'")
                continue
            path = ROOT / rel
            if not path.is_file():
                errors.append(f"missing before-after {key} file: {path}")

        starters = demo.get("starters", {})
        if not isinstance(starters, dict):
            errors.append(f"before-after/manifest.yaml: demo '{tid}' starters must be a mapping")
        elif len(starters) < 2:
            errors.append(
                f"before-after demo '{tid}' must list at least 2 starter drafts; "
                f"got {len(starters)}"
            )
        else:
            for persona, rel in starters.items():
                path = ROOT / rel
                if not path.is_file():
                    errors.append(f"missing before-after starter draft ({persona}): {path}")

        generic_rel = demo.get("generic")
        if generic_rel and (ROOT / generic_rel).is_file():
            generic_text = (ROOT / generic_rel).read_text(encoding="utf-8")
            hits = sum(1 for v in generic_violations if v in generic_text)
            if hits < 2:
                errors.append(
                    f"before-after generic draft for '{tid}' has {hits} "
                    "generic_violations hits; need >= 2"
                )

    if len(before_after_demos) < 2:
        errors.append(
            f"before-after/manifest.yaml must list at least 2 demos; got {len(before_after_demos)}"
        )

    return before_after_demos


def validate_health_check(errors: list[str]) -> tuple[list, set[str]]:
    health_checklist_path = ROOT / "config/health.yaml"
    health_check_ids: set[str] = set()
    health_check_category_ids: set[str] = set()

    if health_checklist_path.is_file():
        health_check_doc = load_yaml(health_checklist_path)
        for cat in health_check_doc.get("categories", []):
            if isinstance(cat, dict) and cat.get("id"):
                health_check_category_ids.add(cat["id"])
        checks = health_check_doc.get("checks")
        if not isinstance(checks, list):
            errors.append("health.yaml: 'checks' must be a list")
            checks = []
        if len(checks) < MIN_HEALTH_CHECKS:
            errors.append(
                f"health.yaml lists {len(checks)} checks; minimum is {MIN_HEALTH_CHECKS}"
            )
        for i, entry in enumerate(checks):
            if not isinstance(entry, dict):
                errors.append(f"health.yaml: checks[{i}] must be a mapping")
                continue
            cid = entry.get("id")
            cat = entry.get("category")
            if not cid:
                errors.append(f"health.yaml: checks[{i}] missing 'id'")
            else:
                health_check_ids.add(cid)
            if cat and cat not in health_check_category_ids:
                errors.append(
                    f"health.yaml: check '{cid}' unknown category '{cat}'"
                )
            if not entry.get("fix_ref"):
                errors.append(f"health.yaml: check '{cid}' missing fix_ref")
    else:
        errors.append("missing config/health.yaml")

    golden_check_ids: set[str] = set()
    health_check_fixtures: list = []

    manifest_path = EVALS_DIR / "health-check/manifest.yaml"
    if not manifest_path.is_file():
        errors.append("missing health-check/manifest.yaml")
        return health_check_fixtures, health_check_ids

    health_check_manifest = load_yaml(manifest_path)
    health_check_fixtures = health_check_manifest.get("fixtures")
    if not isinstance(health_check_fixtures, list):
        errors.append("health-check/manifest.yaml: 'fixtures' must be a list")
        return [], health_check_ids

    health_check_fixture_ids: set[str] = set()
    for i, entry in enumerate(health_check_fixtures):
        if not isinstance(entry, dict):
            errors.append(f"health-check/manifest.yaml: fixtures[{i}] must be a mapping")
            continue
        fid = entry.get("id")
        fpath = entry.get("file")
        gpath = entry.get("golden")
        if not fid:
            errors.append(f"health-check/manifest.yaml: fixtures[{i}] missing 'id'")
        elif fid in health_check_fixture_ids:
            errors.append(f"health-check/manifest.yaml: duplicate fixture id '{fid}'")
        else:
            health_check_fixture_ids.add(fid)

        if not fpath:
            errors.append(f"health-check/manifest.yaml: fixture '{fid}' missing 'file'")
        else:
            resolved = resolve_eval_path(fpath)
            if not resolved.is_file():
                errors.append(f"missing health-check fixture file: {resolved}")
            else:
                fixture = load_yaml(resolved)
                if fixture.get("fixture_id") != fid:
                    errors.append(
                        f"health-check fixture {Path(fpath).name} fixture_id "
                        f"'{fixture.get('fixture_id')}' does not match manifest id '{fid}'"
                    )
                wf = fixture.get("working_folder")
                if wf and not resolve_eval_path(wf).is_dir():
                    errors.append(f"missing health-check working folder: {resolve_eval_path(wf)}")
                pfile = fixture.get("profile_file")
                if pfile and not resolve_eval_path(pfile).is_file():
                    errors.append(f"missing health-check profile file: {resolve_eval_path(pfile)}")

        if not gpath:
            errors.append(f"health-check/manifest.yaml: fixture '{fid}' missing 'golden'")
            continue

        golden_resolved = resolve_eval_path(gpath)
        if not golden_resolved.is_file():
            errors.append(f"missing health-check golden file: {golden_resolved}")
            continue

        golden = load_yaml(golden_resolved)
        if golden.get("fixture_id") != fid:
            errors.append(
                f"health-check golden {Path(gpath).name} fixture_id "
                f"'{golden.get('fixture_id')}' does not match manifest id '{fid}'"
            )
        if not golden.get("version"):
            errors.append(f"health-check golden {Path(gpath).name} missing version")
        hint = golden.get("platform_hint")
        if hint and hint not in HEALTH_CHECK_PLATFORMS:
            errors.append(
                f"health-check golden {Path(gpath).name} invalid platform_hint '{hint}'"
            )
        summary = golden.get("summary")
        if not isinstance(summary, dict):
            errors.append(f"health-check golden {Path(gpath).name} missing 'summary' mapping")

        results = golden.get("results")
        if not isinstance(results, list):
            errors.append(f"health-check golden {Path(gpath).name} missing 'results' list")
        else:
            tallies: dict[str, int] = {}
            for j, row in enumerate(results):
                if not isinstance(row, dict):
                    errors.append(
                        f"health-check golden {Path(gpath).name} results[{j}] must be a mapping"
                    )
                    continue
                check_id = row.get("check_id")
                status = row.get("status")
                if check_id:
                    golden_check_ids.add(check_id)
                if status and status not in HEALTH_CHECK_STATUSES:
                    errors.append(
                        f"health-check golden {Path(gpath).name} results[{j}] "
                        f"invalid status '{status}'"
                    )
                if status:
                    tallies[status] = tallies.get(status, 0) + 1
                if not row.get("message"):
                    errors.append(
                        f"health-check golden {Path(gpath).name} results[{j}] missing message"
                    )
            if isinstance(summary, dict):
                for st in HEALTH_CHECK_STATUSES:
                    expected = tallies.get(st, 0)
                    actual = summary.get(st)
                    if actual != expected:
                        errors.append(
                            f"health-check golden {Path(gpath).name} summary.{st} is {actual!r}; "
                            f"expected {expected} from results"
                        )

    if len(health_check_fixtures) < 7:
        errors.append(
            f"health-check/manifest.yaml must list at least 7 fixtures; got {len(health_check_fixtures)}"
        )

    for cid in health_check_ids:
        if cid not in golden_check_ids:
            errors.append(f"health check_id '{cid}' not referenced by any golden report")

    return health_check_fixtures, health_check_ids


def main() -> int:
    errors: list[str] = []
    require_paths(errors)

    thread_ids, threads = validate_corpus(errors)
    fixtures = validate_injection(errors)
    nt_fixtures = validate_notetaker(errors)
    cal_fixtures = validate_calendar(errors)
    sh_fixtures = validate_schedule_health(errors)
    fb_fixtures = validate_feedback(errors)
    conn_fixtures = validate_connectors(errors)
    starter_profiles = validate_starter_profiles(errors)
    before_after_demos = validate_before_after(errors, thread_ids)
    health_check_fixtures, health_check_ids = validate_health_check(errors)

    if errors:
        for error in errors:
            print(f"validate-fixtures: {error}", file=sys.stderr)
        return 1

    print(
        "validate-fixtures: OK - "
        f"{len(threads)} corpus threads, {len(fixtures)} injection fixtures, "
        f"{len(nt_fixtures)} notetaker fixtures, {len(cal_fixtures)} calendar fixtures, "
        f"{len(sh_fixtures)} schedule-health fixtures, {len(fb_fixtures)} feedback fixtures, "
        f"{len(conn_fixtures)} connector fixtures, {len(starter_profiles)} starter profiles, "
        f"{len(before_after_demos)} before-after demos, {len(health_check_fixtures)} health-check fixtures "
        f"({len(health_check_ids)} checks), {len(EXPECTED_JOB_IDS)} catalog jobs"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
