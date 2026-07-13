#!/usr/bin/env python3
"""Unit tests for scripts/update_ledger.py."""
from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UPDATE_LEDGER = ROOT / "scripts" / "update_ledger.py"


class UpdateLedgerTests(unittest.TestCase):
    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory()
        self.working = Path(self._tmp.name)

    def tearDown(self) -> None:
        self._tmp.cleanup()

    def run_ledger(self, *extra: str) -> subprocess.CompletedProcess[str]:
        cmd = [
            sys.executable,
            str(UPDATE_LEDGER),
            "--job-id",
            "inbox-sweep",
            "--status",
            "success",
            "--working-folder",
            str(self.working),
            *extra,
        ]
        return subprocess.run(cmd, capture_output=True, text=True, cwd=ROOT)

    def test_writes_last_run_at(self) -> None:
        artifact = self.working / "sweep-2026-07-13-1200.md"
        artifact.write_text("# sweep\n", encoding="utf-8")
        result = self.run_ledger(
            "--artifact",
            "sweep-2026-07-13-1200.md",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        ledger_path = self.working / "scheduled" / "inbox-sweep.yaml"
        self.assertTrue(ledger_path.is_file())
        content = ledger_path.read_text(encoding="utf-8")
        self.assertIn("last_run_at:", content)
        self.assertIn("last_run_status: success", content)
        self.assertIn("artifact_present: true", content)

    def test_preserves_miss_count(self) -> None:
        scheduled = self.working / "scheduled"
        scheduled.mkdir(parents=True)
        (scheduled / "inbox-sweep.yaml").write_text(
            "miss_count_7d: 2\nsurface: local\n",
            encoding="utf-8",
        )
        artifact = self.working / "sweep-2026-07-13-1600.md"
        artifact.write_text("# sweep\n", encoding="utf-8")
        result = self.run_ledger(
            "--artifact",
            "sweep-2026-07-13-1600.md",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        content = (scheduled / "inbox-sweep.yaml").read_text(encoding="utf-8")
        self.assertIn("miss_count_7d: 2", content)

    def test_partial_status_with_notes(self) -> None:
        artifact = self.working / "sweep-2026-07-13-0800.md"
        artifact.write_text("# sweep\n", encoding="utf-8")
        cmd = [
            sys.executable,
            str(UPDATE_LEDGER),
            "--job-id",
            "inbox-triage-am",
            "--status",
            "partial",
            "--artifact",
            "sweep-2026-07-13-0800.md",
            "--working-folder",
            str(self.working),
            "--notes",
            "Email connector not connected",
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, cwd=ROOT)
        self.assertEqual(result.returncode, 0, result.stderr)
        content = (self.working / "scheduled" / "inbox-triage-am.yaml").read_text(
            encoding="utf-8"
        )
        self.assertIn("last_run_status: partial", content)
        self.assertIn("Email connector not connected", content)

    def test_missing_working_folder_fails(self) -> None:
        cmd = [
            sys.executable,
            str(UPDATE_LEDGER),
            "--job-id",
            "inbox-sweep",
            "--status",
            "success",
            "--working-folder",
            "/nonexistent/path/for/update_ledger_test",
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, cwd=ROOT)
        self.assertNotEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()
