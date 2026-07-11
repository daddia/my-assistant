#!/usr/bin/env python3
"""
Structural validation for the My Assistant plugin.

Checks plugin manifests, SKILL.md frontmatter, command conventions,
AGENTS.md routing sync, skill cross-references, hooks, and rules.

Usage: python3 scripts/validate.py [options]
  --format pretty|json   Output format (default: pretty)
  --strict               Treat missing command sections as errors
  --help                 Print usage and exit

Exits 0 on success, non-zero on failure.

See commands/_conventions.md for command authoring rules.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable

ROOT = Path(__file__).resolve().parents[1]

MANIFEST_PATHS = (
    ROOT / ".claude-plugin" / "plugin.json",
    ROOT / ".cursor-plugin" / "plugin.json",
)
MARKETPLACE_PATHS = (
    ROOT / ".claude-plugin" / "marketplace.json",
    ROOT / ".cursor-plugin" / "marketplace.json",
)

PLUGIN_REQUIRED_FIELDS = ("name", "version", "description")
PLUGIN_SYNC_FIELDS = ("name", "version", "description", "skills", "commands", "agents", "hooks", "rules")
MARKETPLACE_SYNC_FIELDS = ("name",)

_FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
_FRONTMATTER_KEY_RE = re.compile(r"^(\s*)([A-Za-z0-9_-]+):\s*(.*)$")
_MD_LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
_SKILL_REF_RE = re.compile(r"skills/([a-z][a-z0-9-]*)/SKILL\.md")
_CMD_TMPL_REF_RE = re.compile(r"commands/([a-z][a-z0-9-]*)\.md\.tmpl")
_AGENTS_COMMAND_RE = re.compile(r"`/assistant:([a-z][a-z0-9-]*)`")

CRITICAL_COMMAND_SECTIONS = ("Preflight", "Verification")
RECOMMENDED_COMMAND_SECTIONS = ("Plan", "Commands", "Summary", "Next Steps")
ALL_COMMAND_SECTIONS = CRITICAL_COMMAND_SECTIONS + RECOMMENDED_COMMAND_SECTIONS

TRUST_COMMANDS = frozenset({"inbox", "email", "calendar", "meeting", "brief", "update"})
TRUST_PATTERNS = (
    re.compile(r"never\s+send", re.I),
    re.compile(r"draft[- ]only", re.I),
    re.compile(r"never\s+book", re.I),
    re.compile(r"does\s+not\s+(?:book|send)", re.I),
    re.compile(r"drafts?\s+everything", re.I),
)

RULE_FILES = (
    "rules/core-behaviour.md",
    "rules/untrusted-content.md",
    "rules/file-safety.md",
)


@dataclass
class Issue:
    code: str
    severity: str  # "error" | "warning"
    message: str
    check: str
    file: str | None = None
    line: int | None = None
    hint: str | None = None


@dataclass
class CheckResult:
    name: str
    label: str
    status: str  # pass | fail | warn
    duration_ms: int
    error_count: int
    warning_count: int


@dataclass
class ValidationReport:
    version: int
    timestamp: str
    summary: dict[str, int]
    check_results: list[CheckResult]
    metrics: list[dict[str, Any]]
    issues: list[Issue]
    orphan_skills: list[str] = field(default_factory=list)


class Validator:
    def __init__(self, fmt: str, strict: bool) -> None:
        self.fmt = fmt
        self.strict = strict
        self.issues: list[Issue] = []
        self.check_results: list[CheckResult] = []
        self.metrics: list[dict[str, Any]] = []
        self.check_count = 0
        self.current_check = "unknown"
        self.orphan_skills: list[str] = []

    def rel(self, path: Path) -> str:
        try:
            return str(path.relative_to(ROOT))
        except ValueError:
            return str(path)

    def fail(
        self,
        code: str,
        message: str,
        *,
        file: str | None = None,
        line: int | None = None,
        hint: str | None = None,
    ) -> None:
        self.issues.append(
            Issue(code, "error", message, self.current_check, file, line, hint)
        )
        if self.fmt == "pretty":
            print(f"  ✗ {message}", file=sys.stderr)

    def warn(
        self,
        code: str,
        message: str,
        *,
        file: str | None = None,
        line: int | None = None,
        hint: str | None = None,
    ) -> None:
        self.issues.append(
            Issue(code, "warning", message, self.current_check, file, line, hint)
        )
        if self.fmt == "pretty":
            print(f"  ⚠ {message}")

    def pass_(self, message: str) -> None:
        if self.fmt == "pretty":
            print(f"  ✓ {message}")

    def section(self, label: str) -> None:
        self.check_count += 1
        if self.fmt == "pretty":
            print(f"\n{label}")

    def timed(self, name: str, label: str, fn: Callable[[], None]) -> None:
        self.current_check = name
        before = len(self.issues)
        start = time.perf_counter()
        fn()
        duration_ms = round((time.perf_counter() - start) * 1000)
        self.metrics.append({"name": name, "durationMs": duration_ms})
        check_issues = self.issues[before:]
        error_count = sum(1 for i in check_issues if i.severity == "error")
        warning_count = sum(1 for i in check_issues if i.severity == "warning")
        status = "fail" if error_count else ("warn" if warning_count else "pass")
        self.check_results.append(
            CheckResult(name, label, status, duration_ms, error_count, warning_count)
        )

    def load_json(self, path: Path) -> Any | None:
        try:
            with path.open(encoding="utf-8") as handle:
                return json.load(handle)
        except FileNotFoundError:
            self.fail("JSON_MISSING", f"{self.rel(path)} not found", file=self.rel(path))
        except json.JSONDecodeError as exc:
            self.fail(
                "JSON_INVALID",
                f"{self.rel(path)} is not valid JSON: {exc}",
                file=self.rel(path),
                hint="Fix JSON syntax errors",
            )
        return None

    def strip_scalar(self, value: str) -> str | None:
        value = value.strip()
        if not value:
            return None
        if value in {"|", ">"}:
            return value
        if (value.startswith('"') and value.endswith('"')) or (
            value.startswith("'") and value.endswith("'")
        ):
            return value[1:-1]
        return value

    def parse_frontmatter(self, text: str) -> tuple[dict[str, Any] | None, str, list[str]]:
        match = _FRONTMATTER_RE.match(text)
        if not match:
            return None, text, ["missing YAML frontmatter delimiters (---)"]
        raw = match.group(1)
        if not raw.strip():
            return None, text[match.end() :], ["empty frontmatter block"]

        root: dict[str, Any] = {}
        metadata: dict[str, str] = {}
        in_metadata = False
        lines = raw.splitlines()
        index = 0

        while index < len(lines):
            line = lines[index]
            key_match = _FRONTMATTER_KEY_RE.match(line)
            if not key_match:
                index += 1
                continue

            indent, key, rest = key_match.groups()
            level = len(indent)
            scalar = self.strip_scalar(rest)
            index += 1

            if level == 0 and key == "metadata":
                in_metadata = True
                root["metadata"] = metadata
                continue

            if level == 0:
                in_metadata = False

            target = metadata if in_metadata and level >= 2 else root if level == 0 else None
            if target is None:
                continue

            if scalar in (">", "|"):
                block_lines: list[str] = []
                while index < len(lines):
                    next_line = lines[index]
                    if next_line.strip() == "":
                        block_lines.append("")
                        index += 1
                        continue
                    next_match = _FRONTMATTER_KEY_RE.match(next_line)
                    if next_match and len(next_match.group(1)) <= level:
                        break
                    if next_match and not in_metadata and len(next_match.group(1)) == 0:
                        break
                    block_lines.append(next_line.strip())
                    index += 1
                folded = " ".join(part for part in block_lines if part).strip()
                if folded:
                    target[key] = folded
                continue

            if scalar is None and rest.strip() == "":
                list_items: list[str] = []
                while index < len(lines):
                    next_line = lines[index]
                    item_match = re.match(r"^\s+-\s+(.*)$", next_line)
                    if not item_match:
                        break
                    item = self.strip_scalar(item_match.group(1))
                    if item:
                        list_items.append(item)
                    index += 1
                if list_items:
                    target[key] = list_items
                continue

            if scalar is not None and scalar not in {"|", ">"}:
                target[key] = scalar

        return root, text[match.end() :], []

    def command_files(self) -> list[Path]:
        commands_dir = ROOT / "commands"
        if not commands_dir.is_dir():
            return []
        return sorted(
            path
            for path in commands_dir.glob("*.md")
            if not path.name.startswith("_")
        )

    def skill_dirs(self) -> list[str]:
        skills_dir = ROOT / "skills"
        if not skills_dir.is_dir():
            return []
        return sorted(
            path.name
            for path in skills_dir.iterdir()
            if path.is_dir() and (path / "SKILL.md").is_file()
        )

    def section_heading_present(self, content: str, section_name: str) -> bool:
        pattern = re.compile(
            rf"^#{{2,3}}\s+.*{re.escape(section_name).replace(r'\ ', r'\s+')}",
            re.MULTILINE | re.IGNORECASE,
        )
        return bool(pattern.search(content))

    def has_verb_headings(self, content: str) -> bool:
        return bool(re.search(r"^##\s+[a-z][a-z0-9-]*", content, re.MULTILINE))

    def resolve_markdown_target(self, base: Path, target: str) -> Path | None:
        target = target.strip()
        if not target or target.startswith(("http://", "https://", "mailto:", "#")):
            return None
        if target.startswith("<") and target.endswith(">"):
            inner = target[1:-1]
            if inner.startswith(("http://", "https://", "mailto:", "#")):
                return None
            target = inner
        path_part = target.split("#", 1)[0]
        if not path_part:
            return None
        return (base / path_part).resolve()

    # ------------------------------------------------------------------
    # Checks
    # ------------------------------------------------------------------

    def check_plugin_manifests(self) -> None:
        manifests: dict[str, dict[str, Any]] = {}
        for manifest_path in MANIFEST_PATHS:
            rel = self.rel(manifest_path)
            data = self.load_json(manifest_path)
            if not isinstance(data, dict):
                continue
            manifests[rel] = data
            for field_name in PLUGIN_REQUIRED_FIELDS:
                if data.get(field_name):
                    self.pass_(f'{rel} has "{field_name}"')
                else:
                    self.fail(
                        "PLUGIN_FIELD_MISSING",
                        f'{rel} missing required field "{field_name}"',
                        file=rel,
                    )

        if len(manifests) == 2:
            left_name, left = next(iter(manifests.items()))
            right_name, right = next(reversed(manifests.items()))
            drift: list[str] = []
            for field_name in PLUGIN_SYNC_FIELDS:
                if left.get(field_name) != right.get(field_name):
                    drift.append(field_name)
                    self.fail(
                        "PLUGIN_PARITY",
                        f"{field_name}: {left_name}={left.get(field_name)!r} "
                        f"{right_name}={right.get(field_name)!r}",
                        file=left_name,
                        hint="Keep .claude-plugin/plugin.json and .cursor-plugin/plugin.json in sync",
                    )
            if not drift:
                self.pass_("Claude and Cursor plugin.json manifests are aligned")

    def check_marketplace_manifests(self) -> None:
        entries: list[tuple[str, dict[str, Any]]] = []
        for marketplace_path in MARKETPLACE_PATHS:
            rel = self.rel(marketplace_path)
            data = self.load_json(marketplace_path)
            if not isinstance(data, dict):
                continue
            plugins = data.get("plugins")
            if not isinstance(plugins, list):
                self.fail(
                    "MARKETPLACE_PLUGINS_INVALID",
                    f"{rel} plugins must be an array",
                    file=rel,
                )
                continue
            for entry in plugins:
                if isinstance(entry, dict):
                    entries.append((rel, entry))
            self.pass_(f"{rel} lists {len(plugins)} plugin(s)")

        claude = self.load_json(MARKETPLACE_PATHS[0])
        cursor = self.load_json(MARKETPLACE_PATHS[1])
        if isinstance(claude, dict) and isinstance(cursor, dict):
            def key(entry: dict[str, Any]) -> tuple[str, str]:
                return (str(entry.get("name", "")), str(entry.get("source", "")))

            claude_plugins = claude.get("plugins", [])
            cursor_plugins = cursor.get("plugins", [])
            if isinstance(claude_plugins, list) and isinstance(cursor_plugins, list):
                claude_set = {key(p) for p in claude_plugins if isinstance(p, dict)}
                cursor_set = {key(p) for p in cursor_plugins if isinstance(p, dict)}
                if claude_set == cursor_set:
                    self.pass_("Claude and Cursor marketplace manifests list the same plugins")
                else:
                    only_claude = claude_set - cursor_set
                    only_cursor = cursor_set - claude_set
                    if only_claude:
                        self.fail(
                            "MARKETPLACE_PARITY",
                            f"plugins only in Claude marketplace: {sorted(only_claude)!r}",
                            file=self.rel(MARKETPLACE_PATHS[0]),
                        )
                    if only_cursor:
                        self.fail(
                            "MARKETPLACE_PARITY",
                            f"plugins only in Cursor marketplace: {sorted(only_cursor)!r}",
                            file=self.rel(MARKETPLACE_PATHS[1]),
                        )

        plugin_manifest = self.load_json(MANIFEST_PATHS[0])
        if isinstance(plugin_manifest, dict):
            for rel, entry in entries:
                if entry.get("name") != plugin_manifest.get("name"):
                    continue
                for field_name in MARKETPLACE_SYNC_FIELDS:
                    if entry.get(field_name) != plugin_manifest.get(field_name):
                        self.fail(
                            "MARKETPLACE_DRIFT",
                            f"marketplace {field_name}={entry.get(field_name)!r} "
                            f"plugin={plugin_manifest.get(field_name)!r}",
                            file=rel,
                            hint="Keep marketplace.json description/name aligned with plugin.json",
                        )

    def check_skill_frontmatter(self) -> None:
        for skill_name in self.skill_dirs():
            skill_path = ROOT / "skills" / skill_name / "SKILL.md"
            rel = self.rel(skill_path)
            try:
                text = skill_path.read_text(encoding="utf-8")
            except OSError as exc:
                self.fail("SKILL_UNREADABLE", f"{rel}: cannot read file: {exc}", file=rel)
                continue

            frontmatter, _, parse_errs = self.parse_frontmatter(text)
            for msg in parse_errs:
                self.fail("FM_PARSE", f"{rel}: {msg}", file=rel)

            if frontmatter is None:
                continue

            if not frontmatter.get("name"):
                self.fail("FM_NO_NAME", f"{rel} missing frontmatter name", file=rel)
            elif frontmatter["name"] != skill_name:
                self.fail(
                    "FM_NAME_MISMATCH",
                    f"{rel} frontmatter name {frontmatter['name']!r} != directory {skill_name!r}",
                    file=rel,
                )
            else:
                self.pass_(f'{rel} name matches directory "{skill_name}"')

            if not frontmatter.get("description"):
                self.fail("FM_NO_DESC", f"{rel} missing frontmatter description", file=rel)
            else:
                self.pass_(f"{rel} has description")

    def check_command_conventions(self) -> None:
        command_paths = self.command_files()
        if not command_paths:
            self.fail(
                "COMMANDS_DIR_MISSING",
                "commands/ has no slash command files",
                file="commands/",
                hint="Add .md command files to commands/",
            )
            return

        for command_path in command_paths:
            rel = self.rel(command_path)
            slug = command_path.stem
            try:
                content = command_path.read_text(encoding="utf-8")
            except OSError as exc:
                self.fail("CMD_UNREADABLE", f"{rel}: cannot read file: {exc}", file=rel)
                continue

            frontmatter, _, parse_errs = self.parse_frontmatter(content)
            for msg in parse_errs:
                self.fail("CMD_FM_PARSE", f"{rel}: {msg}", file=rel)

            if not frontmatter or not frontmatter.get("description"):
                self.fail(
                    "CMD_NO_DESCRIPTION",
                    f"{rel} missing frontmatter description",
                    file=rel,
                    hint="Add YAML frontmatter with a description field",
                )
            else:
                self.pass_(f"{rel} has frontmatter description")

            skill_refs = sorted(set(_SKILL_REF_RE.findall(content)))
            tmpl_refs = sorted(set(_CMD_TMPL_REF_RE.findall(content)))
            if not skill_refs and not tmpl_refs:
                self.fail(
                    "CMD_NO_SKILL_REF",
                    f"{rel} has no skills/<name>/SKILL.md or commands/<name>.md.tmpl reference",
                    file=rel,
                    hint="Route to at least one skill file or a command template",
                )
            else:
                for skill_name in skill_refs:
                    skill_path = ROOT / "skills" / skill_name / "SKILL.md"
                    if skill_path.is_file():
                        self.pass_(f"{rel} → skills/{skill_name}/SKILL.md")
                    else:
                        self.fail(
                            "CMD_SKILL_REF_BROKEN",
                            f"{rel} references missing skills/{skill_name}/SKILL.md",
                            file=rel,
                            hint=f"Create skills/{skill_name}/SKILL.md or fix the reference",
                        )
                for tmpl_slug in tmpl_refs:
                    tmpl_path = ROOT / "commands" / f"{tmpl_slug}.md.tmpl"
                    if tmpl_path.is_file():
                        self.pass_(f"{rel} → commands/{tmpl_slug}.md.tmpl")
                    else:
                        self.fail(
                            "CMD_TMPL_REF_BROKEN",
                            f"{rel} references missing commands/{tmpl_slug}.md.tmpl",
                            file=rel,
                            hint=f"Create commands/{tmpl_slug}.md.tmpl or fix the reference",
                        )

            missing_sections: list[str] = []
            for section_name in ALL_COMMAND_SECTIONS:
                if section_name == "Commands" and self.has_verb_headings(content):
                    continue
                if not self.section_heading_present(content, section_name):
                    missing_sections.append(section_name)

            if missing_sections:
                critical = [s for s in missing_sections if s in CRITICAL_COMMAND_SECTIONS]
                recommended = [s for s in missing_sections if s in RECOMMENDED_COMMAND_SECTIONS]
                reporter = self.fail if self.strict else self.warn
                if critical:
                    reporter(
                        "CMD_MISSING_CRITICAL_SECTIONS",
                        f"{rel} missing critical sections: {', '.join(critical)}",
                        file=rel,
                        hint="See commands/_conventions.md",
                    )
                if recommended:
                    reporter(
                        "CMD_MISSING_SECTIONS",
                        f"{rel} missing recommended sections: {', '.join(recommended)}",
                        file=rel,
                        hint="See commands/_conventions.md",
                    )
            else:
                self.pass_(f"{rel} has required convention sections")

            if slug in TRUST_COMMANDS and not any(p.search(content) for p in TRUST_PATTERNS):
                reporter = self.fail if self.strict else self.warn
                reporter(
                    "CMD_TRUST_LANGUAGE",
                    f"{rel} touches outbound actions but lacks draft-only trust language",
                    file=rel,
                    hint='State "never send", "draft-only", or similar per rules/core-behaviour.md',
                )

    def check_agents_routing(self) -> None:
        agents_path = ROOT / "AGENTS.md"
        if not agents_path.is_file():
            self.fail("AGENTS_MISSING", "AGENTS.md not found", file="AGENTS.md")
            return

        content = agents_path.read_text(encoding="utf-8")
        routed_commands = sorted(set(_AGENTS_COMMAND_RE.findall(content)))
        command_slugs = {path.stem for path in self.command_files()}

        for slug in routed_commands:
            if slug in command_slugs:
                self.pass_(f"AGENTS.md routes /assistant:{slug} → commands/{slug}.md")
            else:
                self.fail(
                    "AGENTS_COMMAND_MISSING",
                    f"AGENTS.md routes /assistant:{slug} but commands/{slug}.md not found",
                    file="AGENTS.md",
                    hint=f"Create commands/{slug}.md",
                )

        for slug in sorted(command_slugs - set(routed_commands)):
            self.warn(
                "AGENTS_COMMAND_UNLISTED",
                f"commands/{slug}.md exists but is not listed in AGENTS.md command routing",
                file=f"commands/{slug}.md",
                hint="Add the command to the routing table in AGENTS.md",
            )

    def check_orphan_skills(self) -> None:
        agents_path = ROOT / "AGENTS.md"
        if not agents_path.is_file():
            return

        agents_text = agents_path.read_text(encoding="utf-8")
        referenced = set(_SKILL_REF_RE.findall(agents_text))
        for command_path in self.command_files():
            referenced.update(_SKILL_REF_RE.findall(command_path.read_text(encoding="utf-8")))

        for skill_name in self.skill_dirs():
            if skill_name in referenced:
                self.pass_(f"skills/{skill_name} referenced from AGENTS.md or commands/")
            else:
                self.orphan_skills.append(skill_name)
                self.warn(
                    "ORPHAN_SKILL",
                    f"skills/{skill_name} is not referenced from AGENTS.md or any command file",
                    file=f"skills/{skill_name}/SKILL.md",
                    hint="Add a routing entry in AGENTS.md or reference the skill from a command",
                )

    def check_hooks_json(self) -> None:
        hooks_path = ROOT / "hooks" / "hooks.json"
        hooks = self.load_json(hooks_path)
        if isinstance(hooks, dict):
            self.pass_("hooks/hooks.json is valid JSON")
            if not hooks.get("hooks"):
                self.warn(
                    "HOOKS_EMPTY",
                    "hooks/hooks.json has no hooks registered",
                    file="hooks/hooks.json",
                )

    def check_rules(self) -> None:
        for rel_path in RULE_FILES:
            path = ROOT / rel_path
            if path.is_file():
                self.pass_(f"{rel_path} exists")
            else:
                self.fail(
                    "RULE_MISSING",
                    f"{rel_path} not found",
                    file=rel_path,
                    hint="Create the rule file and reference it from AGENTS.md",
                )

    def check_markdown_references(self) -> None:
        checked_dirs = (
            ROOT / "commands",
            ROOT / "skills",
            ROOT / "rules",
            ROOT / "agents",
        )
        checked_files: list[Path] = []
        for base in checked_dirs:
            if not base.is_dir():
                continue
            checked_files.extend(sorted(base.rglob("*.md")))

        broken = 0
        for md_path in checked_files:
            if md_path.name.startswith("_"):
                continue
            rel = self.rel(md_path)
            try:
                content = md_path.read_text(encoding="utf-8")
            except OSError:
                continue

            for match in _MD_LINK_RE.finditer(content):
                target = match.group(1)
                resolved = self.resolve_markdown_target(md_path.parent, target)
                if resolved is None:
                    continue
                if not resolved.exists():
                    broken += 1
                    self.fail(
                        "MD_LINK_BROKEN",
                        f"{rel} broken link {target!r} → {self.rel(resolved)}",
                        file=rel,
                        hint="Fix the relative path or add the missing file",
                    )

        if broken == 0:
            self.pass_(f"All markdown links resolve in {len(checked_files)} checked file(s)")

    def check_agents(self) -> None:
        agents_dir = ROOT / "agents"
        if not agents_dir.is_dir():
            self.warn("AGENTS_DIR_MISSING", "agents/ directory not found", file="agents/")
            return

        agent_files = sorted(agents_dir.glob("*.md"))
        if not agent_files:
            self.warn("AGENTS_EMPTY", "agents/ has no agent prompt files", file="agents/")
            return

        for agent_path in agent_files:
            self.pass_(f"{self.rel(agent_path)} exists")

    def check_json_files(self) -> None:
        skip_parts = {".git", "node_modules", "evals"}
        json_files = sorted(
            path
            for path in ROOT.rglob("*.json")
            if not any(part in skip_parts for part in path.parts)
        )
        invalid = 0
        for json_path in json_files:
            if self.load_json(json_path) is None and json_path.exists():
                invalid += 1
        if invalid == 0:
            self.pass_(f"All {len(json_files)} JSON file(s) parse cleanly")

    # ------------------------------------------------------------------
    # Main
    # ------------------------------------------------------------------

    def run(self) -> int:
        if self.fmt == "pretty":
            print("My Assistant — Structural Validation\n" + "=" * 40)

        checks: list[tuple[str, str, Callable[[], None]]] = [
            ("pluginManifests", "Plugin manifest validity and parity", self.check_plugin_manifests),
            ("marketplaceManifests", "Marketplace manifest validity", self.check_marketplace_manifests),
            ("skillFrontmatter", "SKILL.md YAML frontmatter", self.check_skill_frontmatter),
            ("commandConventions", "Command conventions", self.check_command_conventions),
            ("agentsRouting", "AGENTS.md command routing sync", self.check_agents_routing),
            ("orphanSkills", "Orphan skill detection", self.check_orphan_skills),
            ("hooksJson", "hooks/hooks.json validity", self.check_hooks_json),
            ("rules", "Core rule files", self.check_rules),
            ("markdownReferences", "Markdown cross-reference resolution", self.check_markdown_references),
            ("agents", "Agent prompt files", self.check_agents),
            ("jsonFiles", "Repository JSON sanity", self.check_json_files),
        ]

        for name, label, fn in checks:
            self.section(f"[{self.check_count + 1}] {label}")
            self.timed(name, label, fn)

        error_count = sum(1 for issue in self.issues if issue.severity == "error")
        warn_count = sum(1 for issue in self.issues if issue.severity == "warning")

        if self.fmt == "json":
            report = ValidationReport(
                version=1,
                timestamp=datetime.now(timezone.utc).isoformat(),
                summary={
                    "errors": error_count,
                    "warnings": warn_count,
                    "checks": self.check_count,
                },
                check_results=self.check_results,
                metrics=self.metrics,
                issues=self.issues,
                orphan_skills=sorted(self.orphan_skills),
            )
            print(json.dumps(asdict(report), indent=2))
        else:
            print("\n" + "=" * 40)
            if error_count > 0:
                print(
                    f"\nFAILED — {error_count} error(s)"
                    + (f", {warn_count} warning(s)" if warn_count else "")
                    + "\n",
                    file=sys.stderr,
                )
            elif warn_count > 0:
                print(f"\nPASSED with {warn_count} warning(s)\n")
            else:
                print("\nPASSED — all checks OK\n")

        return 1 if error_count > 0 else 0


def print_usage() -> None:
    print(__doc__.strip())


def main() -> int:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--format", choices=("pretty", "json"), default="pretty")
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Treat missing command convention sections as errors",
    )
    parser.add_argument("--help", action="store_true")
    args = parser.parse_args()

    if args.help:
        print_usage()
        return 0

    validator = Validator(args.format, args.strict)
    return validator.run()


if __name__ == "__main__":
    raise SystemExit(main())
