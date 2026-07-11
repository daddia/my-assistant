---
name: health-check
description: Install and setup health check for the assistant plugin. Activate on
  "/assistant:health", "run health check", "health check", "is my assistant set up correctly",
  or "diagnose my install". Read-only validator — proposes fixes, never auto-remediates.
---

# Health check

Structured health check for plugin install, profile, working folder, scheduled jobs, connectors (advisory), and platform fit. **Read-only** — health check proposes fixes and routes to commands or guide chapters; it never sends, books, schedules, rewrites the profile, or writes inside the plugin directory.

The only optional write: `health-report-YYYY-MM-DD.md` in the working folder when the user passes `--save` and the folder is writable.

## Load the checklist

Read `skills/health-check/assets/health.yaml` from the plugin directory. If missing, stop with an honest error:

> Plugin install incomplete — reinstall from the marketplace. The health check checklist (`skills/health-check/assets/health.yaml`) is missing.

Run checks in **category order** from the checklist. Each result maps to one row: `check_id`, `category`, `status` (`pass` | `warn` | `fail` | `skip`), `message`, optional `detail`, and `fix_ref` from the checklist when status is not `pass`.

## Resolve paths

Follow `rules/paths.md` — same order as `hooks/load-profile.sh`.

### Install config

Locate `my-assistant.json` (workspace `config/`, then `~/MyAssistant/config/`, then legacy plugin config). Record `config_path` in the report when found.

| check_id | Pass when | Fail / warn |
|----------|-----------|-------------|
| `config-exists` | `my-assistant.json` found at a resolved path | **warn** — suggest re-running `/assistant:setup` or completing working-folder step |
| `config-valid` | JSON parses; `assistantPath`, `configPath`, `policiesPath`, `scope`, `setupAt`, `lastUpdated` present per schema | **warn** with detail |
| `config-profile-aligned` | `{configPath}/profile.md` exists when config is present | **warn** |
| `config-policies-aligned` | `{policiesPath}/` exists when config is present | **warn** |

### Profile

1. `{configPath}/profile.md` from `my-assistant.json` when valid
2. Fallback order in `rules/paths.md` (workspace `config/profile.md`, workspace root, `~/MyAssistant/config/`, legacy plugin config)

Record the path in the report as `profile_path` (or `null`).

### Working folder

1. `assistantPath` from `my-assistant.json` when valid
2. Parent of `config/profile.md` when profile lives under a `config/` subdirectory
3. User-stated path in chat
4. Open workspace / current working directory in Cowork or Cursor
5. If still ambiguous, default to cwd with a **warn** on `working-folder-identified` and ask the user to confirm or open their working folder (`~/MyAssistant` by default)

Never write health or health-check files under the plugin directory (`rules/file-safety.md`).

### Platform hint

Best-effort inference for `platform_hint`:

| Signal | Hint |
|--------|------|
| User mentions Cursor, or session is Cursor plugin | `cursor` |
| Cowork scheduled sidebar or `/schedule` mentioned | `cowork` |
| Claude Code scheduled tasks mentioned | `claude-code` |
| None of the above | `unknown` |

When `unknown`, platform-specific checks **skip** with a message to re-run after stating the platform.

## Check logic

### Plugin

| check_id | Pass when | Fail / warn |
|----------|-----------|-------------|
| `plugin-manifest-present` | `.claude-plugin/plugin.json` or `.cursor-plugin/plugin.json` exists in plugin root | **fail** |
| `plugin-skills-present` | `skills/` contains ≥10 skill directories with `SKILL.md` | **fail** |
| `plugin-commands-present` | `commands/` contains ≥10 `.md` command files | **fail** |
| `plugin-hooks-session-start` | `hooks/hooks.json` defines `SessionStart` | **warn** |
| `plugin-rules-present` | `rules/core-behaviour.md`, `rules/untrusted-content.md`, `rules/file-safety.md` exist | **fail** |
| `plugin-health-checklist` | `skills/health-check/assets/health.yaml` and `skills/health-check/assets/health-report.schema.yaml` exist | **fail** |

### Profile

If `profile-exists` **fails**, **skip** all downstream profile checks (`profile-readable`, `profile-sections-complete`, `profile-word-count`, `profile-optional-sections`) with message "Profile missing — skipped."

| check_id | Pass when | Fail / warn |
|----------|-----------|-------------|
| `profile-exists` | Profile file found at resolved path | **fail** — fix: `/assistant:setup`; note plugin works with pasted content until then |
| `profile-readable` | File reads without error | **fail** with path attempted |
| `profile-sections-complete` | Required profile sections filled (heuristic below) | **warn** |
| `profile-word-count` | Profile under ~1,200 words (policies counted separately) | **warn** if over |
| `profile-optional-sections` | Anti-style and goals have real content | **warn** if still template placeholders |

**Profile section completeness** — compare against `config/profile.template.md` bracket placeholders:

**Required for pass on `profile-sections-complete`:**

1. **Identity** — name, timezone, working hours
2. **Voice** — one-line voice description (not template quote only)
3. **Working rules** — autonomy tier explicitly set (not template default line only)

Sections 3 (anti-style) and 5 (goals) are checked by `profile-optional-sections` — warn if skipped, do not fail post-setup quick-start.

### Policies

Policies live at `{policiesPath}/` from `my-assistant.json` when present, else `{assistantPath}/policies/*.policy.md`. Master templates ship in the plugin's `policies/` directory.

If `profile-exists` **fails**, skip policy checks with "Profile missing — skipped."

| check_id | Pass when | Fail / warn |
|----------|-----------|-------------|
| `policies-dir-exists` | `{policiesPath}/` or `{assistantPath}/policies/` directory exists | **warn** — suggest `/assistant:setup` |
| `policies-email-present` | `email.policy.md` exists and is readable | **warn** |
| `policies-calendar-present` | `calendar.policy.md` exists and is readable | **warn** |
| `policies-sections-complete` | VIP tiers + reply threshold in email policy; working hours in calendar policy | **warn** |
| `profile-legacy-policy-sections` | `profile.md` does **not** still contain `## 5. VIP tiers`, `## 6. Email policy`, or `## 7. Calendar policy` | **warn** — offer split via `/assistant:setup` |

**Required for pass on `policies-sections-complete`:**

1. **VIP tiers** — at least one Tier 1 or Tier 2 entry with a real name or address (in `email.policy.md`)
2. **Email policy** — reply threshold stated (in `email.policy.md`)
3. **Calendar policy** — working hours stated (in `calendar.policy.md`)

### Working folder

If `working-folder-identified` **warns** (ambiguous), folder file checks may **skip** with "Working folder not confirmed."

| check_id | Pass when | Fail / warn |
|----------|-----------|-------------|
| `working-folder-identified` | Path resolved and user context clear | **warn** if defaulted to cwd without confirmation |
| `tasks-md-present` | `TASKS.md` exists and is readable | **warn** — run `skills/setup-interview/scripts/scaffold-working-folder.sh {assistantPath} --tasks`, or `/assistant:tasks add` |
| `memory-scaffold` | `memory/` directory exists | **warn** — run `skills/setup-interview/scripts/scaffold-working-folder.sh {assistantPath}` (dirs only) |
| `claude-md-present` | `CLAUDE.md` exists in working folder | **warn** |

### Always-on

When `{working-folder}/scheduled/` is **absent or empty**: `schedule-ledger-present` → **skip** (not fail) with info message "No scheduled jobs configured — optional; run `/assistant:schedules` when ready." Skip `schedule-health-valid`, `schedule-catalog-jobs-match`, `schedule-critical-local-misses`.

When the directory **exists** with one or more job files:

| check_id | Pass when | Fail / warn |
|----------|-----------|-------------|
| `schedule-ledger-present` | At least one `scheduled/{job_id}.yaml` exists | **pass** |
| `schedule-health-valid` | Each file shape matches `scheduled/schedules.schema.yaml` (version, job_id, updated_at, surface, cadence, last_run_status, miss_count_7d); filename matches `job_id` | **warn** if corrupt — "Re-run `/assistant:schedules` to recreate ledger." |
| `schedule-catalog-jobs-match` | Every `job_id` in `scheduled/` exists in `scheduled/schedules.yaml` | **warn** |
| `schedule-critical-local-misses` | No `morning-briefing.yaml` with `surface: local` and `miss_count_7d >= 2` | **warn** with fix_ref `docs/guide/07-always-on-reliability.md#decision-tree` — mirror escalation table; do **not** increment counters or duplicate `daily-brief` miss-block logic |

### Connectors (advisory)

**Ask-first UX** for standalone parity — do not assume OAuth or MCP visibility.

Ask inline: "Which connector categories do you have connected? (email / calendar / chat / drive / notes / tasks — or none / paste-only)"

| check_id | Behaviour |
|----------|-----------|
| `connector-email-advisory` | **pass** if email connected or user confirms paste-only; **warn** if unsure; **skip** if user declines to answer |
| `connector-calendar-advisory` | Same pattern |
| `connector-chat-advisory` | Same pattern |
| `connector-drive-notes-tasks-advisory` | **pass** if any of drive/notes/tasks connected or paste-only confirmed; **warn** if gaps noted; **skip** if declined |

Link `docs/guide/connector-smoke-tests.md` for paste smoke steps. Never run live OAuth probes (MA08).

### Platform

| check_id | Behaviour |
|----------|-----------|
| `platform-inferred` | **pass** when hint is not `unknown`; **skip** when unknown |
| `platform-cursor-local-schedules` | When `platform_hint: cursor` and ledger shows critical job (`morning-briefing`) on `local` → **warn** to consider `cloud-code` or `managed` per reliability guide |
| `platform-cowork-schedules` | When `platform_hint: cowork` → **pass** if local schedules are viable; **skip** otherwise |
| `platform-unknown-skip` | When `platform_hint: unknown` → **skip** with message to state platform and re-run |

## Post-setup subset

When invoked from `setup-interview` after initial profile write, run **only** profile + working-folder categories:

- `checks: [profile, working-folder]` — skip plugin, always-on, connectors, platform unless user asks for full health check
- Render a compact **Setup health** block (≤8 lines): summary counts + top fails/warns with fix refs
- Do **not** block the wedge CTA on warnings — always offer `/assistant:inbox triage` and `/assistant:brief` after the block
- Chat-only — no auto-save of `health-report-*.md` after setup

## Build and render the report

Aggregate results into `HealthCheckReport` matching `skills/health-check/assets/health-report.schema.yaml`:

```yaml
version: "0.1"
generated_at: <ISO-8601 now>
platform_hint: <inferred>
working_folder: <path or null>
profile_path: <path or null>
summary: { pass, warn, fail, skip }
results: [ ... ]
```

### Markdown output (approval frame)

Use the four-part frame from `rules/approval-frame.md`:

**What I found** — summary line: `Health check: {pass} pass · {warn} warn · {fail} fail · {skip} skip` plus profile and working-folder paths.

**What I drafted** — "Nothing yet" (health check does not create drafts).

**What I recommend** — Top 1–3 fixes ranked by severity (fails first, then warns).

**What needs your approval** — Enumerate actions requiring user decision (e.g. run `/assistant:setup`, scaffold `TASKS.md`, upgrade schedule surface). No queue writes unless surfacing an existing review-queue gap.

Then render a **checklist table** grouped by category:

```text
| Status | Check | Message | Fix |
|--------|-------|---------|-----|
| ✅ pass | profile-exists | Profile found | — |
| ⚠️ warn | profile-sections-complete | VIP tiers thin | /assistant:setup |
```

Use ✅ pass · ⚠️ warn · ❌ fail · ⏭️ skip in the Status column.

### Optional save (`--save`)

Write `health-report-YYYY-MM-DD.md` to the working folder with the same markdown body. If the folder is not writable, render in chat only and note the save failure.

## Error paths

| Condition | Behaviour |
|-----------|-----------|
| No profile | `profile-exists` **fail**; downstream profile checks **skip** |
| Profile unreadable | `profile-exists` **fail** with detail; do not guess contents |
| Working folder unknown | folder checks **skip**; note assumption |
| Corrupt schedule ledger | `schedule-health-valid` **warn** |
| No schedule ledger | always-on checks **skip** (not fail) |
| Checklist missing | Abort with reinstall message |

Every failure maps to a checklist row with `fix_ref` — no opaque errors.

## Maintainer fixtures

Synthetic states and golden expected reports live in `evals/health-check/`. See `evals/health-check/README.md` for fixture validation.
