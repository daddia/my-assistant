#!/usr/bin/env python3
"""
Deterministic schedule health ledger writer.

Merges a run result into {working-folder}/scheduled/{job_id}.yaml, preserving
existing surface, cadence, and miss_count_7d history.

Usage:
  python3 scripts/update_ledger.py \\
    --job-id inbox-sweep \\
    --status success \\
    --artifact sweep-2026-07-13-0800.md \\
    --working-folder ~/MyAssistant

  python3 scripts/update_ledger.py \\
    --job-id morning-briefing \\
    --status partial \\
    --artifact brief-2026-07-13.md \\
    --working-folder ~/MyAssistant \\
    --notes "Brief written but connector gap on priority unread"

Exits 0 on success, non-zero on failure.
"""
from __future__ import annotations

import argparse
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import yaml
except ImportError:
    print(
        "update_ledger: PyYAML required — pip install pyyaml",
        file=sys.stderr,
    )
    raise SystemExit(1) from None

ROOT = Path(__file__).resolve().parents[1]
SCHEDULES_CATALOG = ROOT / "scheduled" / "schedules.yaml"
RUN_STATUSES = frozenset({"success", "partial", "failed", "missed"})


def load_catalog_job(job_id: str) -> dict | None:
    if not SCHEDULES_CATALOG.is_file():
        return None
    with SCHEDULES_CATALOG.open(encoding="utf-8") as handle:
        catalog = yaml.safe_load(handle)
    if not isinstance(catalog, dict):
        return None
    for job in catalog.get("jobs") or []:
        if isinstance(job, dict) and job.get("job_id") == job_id:
            return job
    return None


def read_ledger(path: Path) -> dict:
    if not path.is_file():
        return {}
    with path.open(encoding="utf-8") as handle:
        data = yaml.safe_load(handle)
    return data if isinstance(data, dict) else {}


def write_ledger(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        yaml.dump(
            data,
            handle,
            default_flow_style=False,
            allow_unicode=True,
            sort_keys=False,
        )


def iso_now() -> str:
    return datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")


def merge_ledger(
    *,
    working_folder: Path,
    job_id: str,
    status: str,
    artifact: str | None,
    notes: str | None,
) -> dict:
    ledger_path = working_folder / "scheduled" / f"{job_id}.yaml"
    existing = read_ledger(ledger_path)
    catalog_job = load_catalog_job(job_id)
    now = iso_now()

    cadence = existing.get("cadence")
    if not cadence and catalog_job:
        cadence = catalog_job.get("cron")

    surface = existing.get("surface") or "local"
    miss_count = existing.get("miss_count_7d")
    if not isinstance(miss_count, int) or miss_count < 0:
        miss_count = 0

    artifact_present: bool | None = None
    expected_artifact: str | None = None
    if artifact:
        expected_artifact = artifact
        artifact_path = working_folder / artifact
        artifact_present = artifact_path.is_file()

    merged: dict = {
        "version": existing.get("version") or "0.1",
        "job_id": job_id,
        "updated_at": now,
        "surface": surface,
        "cadence": cadence or "unknown",
        "last_run_at": now,
        "last_run_status": status,
        "miss_count_7d": miss_count,
    }

    if expected_artifact is not None:
        merged["expected_artifact"] = expected_artifact
        merged["artifact_present"] = artifact_present
    elif "expected_artifact" in existing:
        merged["expected_artifact"] = existing.get("expected_artifact")
        merged["artifact_present"] = existing.get("artifact_present")

    if notes:
        merged["notes"] = notes
    elif existing.get("notes") is not None and status == "success":
        merged["notes"] = None
    elif existing.get("notes") is not None:
        merged["notes"] = existing.get("notes")

    write_ledger(ledger_path, merged)
    return merged


def main() -> int:
    parser = argparse.ArgumentParser(description="Update schedule health ledger")
    parser.add_argument("--job-id", required=True)
    parser.add_argument(
        "--status",
        required=True,
        choices=sorted(RUN_STATUSES),
    )
    parser.add_argument(
        "--artifact",
        default=None,
        help="Relative path to expected artefact in the working folder",
    )
    parser.add_argument("--working-folder", required=True)
    parser.add_argument(
        "--notes",
        default=None,
        help="Optional freeform context (e.g. connector gap)",
    )
    args = parser.parse_args()

    working_folder = Path(args.working_folder).expanduser().resolve()
    if not working_folder.is_dir():
        print(
            f"update_ledger: working folder not found: {working_folder}",
            file=sys.stderr,
        )
        return 1

    if args.job_id != Path(f"{args.job_id}.yaml").stem:
        print("update_ledger: job-id must be a safe filename stem", file=sys.stderr)
        return 1

    merged = merge_ledger(
        working_folder=working_folder,
        job_id=args.job_id,
        status=args.status,
        artifact=args.artifact,
        notes=args.notes,
    )

    print(
        f"Updated {working_folder / 'scheduled' / (args.job_id + '.yaml')}: "
        f"last_run_at={merged['last_run_at']} status={merged['last_run_status']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
