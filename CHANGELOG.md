# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **`scripts/update_ledger.py`** — deterministic schedule heartbeat writer; skills invoke it instead of hand-editing YAML.
- **`policies/actions.policy.md`** — template for non-reply actions (calendar holds, tasks, forms) with detect→confirm→codify loop.
- **Inbox action taxonomy** — per-thread action types, two-pass scan (delta + lingerers), and action proposals in triage.
- **Health checks** — `policies-actions-present` and `schedule-ledger-out-of-sync`.

### Changed

- **Schedule split** — `inbox-triage-am` (08:00 triage with drafts) and `inbox-sweep` (12:00/16:00 light sweep); triage still writes `sweep-*.md` for morning brief handoff.
- **Connector pre-check** — email-drafting and inbox-triage surface permission failures; fallback markdown labelled explicitly; `partial` ledger status when degraded.
- **Packaged prompts** — schedule-setup prompts include `update_ledger.py` invocation and completion self-check.

### Fixed

- **Ledger write-back** — `last_run_at: null` bug addressed via deterministic script + artefact-derived fallback in health/brief.

## [1.6.0] - 2026-07-12

### Added

- **Inbox batch digest and VIP ordering** — triage report shape with FYI/marketing digest tables and VIP-first ordering (MA12).
- **Task proposals from triage** — inbox triage proposes tasks from emails needing action.
- **Sweep → brief integration** — inbox sweeps write `sweep-YYYY-MM-DD-{slot}.md`; morning brief consumes recent sweep files.
- **35-thread eval corpus** — adversarial injection, VIP edge cases, batch digest, and school VIP fixtures.
- **Inbox automation registry** — `evals/automation/manifest.yaml` with 90% rubric pass threshold for release gating.

### Changed

- **Inbox-triage skill** — formal report shape, ambiguous score-0 handling, injection surfacing, and verification checks; `commands/inbox.md` updated.
- **Schedule catalog** — inbox-sweep expected artifacts updated in `scheduled/schedules.yaml`.

### Fixed

## [1.5.0] - 2026-07-12

### Added

- **`/assistant:start`** — lightweight tasks-and-memory bootstrap without a full profile interview (`commands/start.md` → `start`).
- **Memory bootstrap in setup** — setup scaffolds `AGENTS.md`, `memory/glossary.md`, and related deliverables as first-class working-folder assets.
- **Task-tracker MCP servers** — bundled Notion and GitHub task connectors with `~~tasks` sync documentation.

### Changed

- **AGENTS.md memory model** — standardised as the working-folder hot cache across skills, paths, dashboard, and health checks; deep memory stays in `memory/`.
- **Six-status task workflow** — `TASKS.md` uses To do / In progress / In review / Done / Cancelled / Blocked.
- **Update loops** — productivity-style task and memory sync guidance in `/assistant:update` and related skills.

### Fixed

- **Health-check golden fixtures** — corrected `summary.warn` tallies for scaffold fixtures after AGENTS.md checks were added.

## [1.4.0] - 2026-07-12

### Added

- **`/assistant:draft`** — draft email, chat, or letter replies in your voice (`commands/draft.md` → `email-drafting`).
- **`/assistant:review`** — review awaiting email and chat follow-ups; nudge drafts for items gone cold (`commands/review.md` → `follow-up-tracking`).

### Changed

- **`/assistant:health` restored** — `/assistant:status` renamed back to `/assistant:health` for the install/setup health check.
- **Weekly review → report** — weekly ritual moved to `/assistant:report`; `/assistant:review` now covers follow-up review only.
- **Setup skill renamed** — `setup` → `assistant-setup` across commands, docs, rules, and health-check fixtures.

### Fixed

## [1.3.3] - 2026-07-12

### Added

### Changed

- **Setup skill renamed** — `setup-interview` → `setup` across commands, docs, rules, and health-check fixtures.
- **Command conventions** — metadata section (description, user-invocable) added to `commands/_conventions.md`.

### Fixed

## [1.3.2] - 2026-07-12

### Added

- **Working-folder scaffold script** — setup calls `scaffold-working-folder.sh` for idempotent creation of `config/`, `policies/`, `memory/`, `drafts/`, `scheduled/`, and `review-queue/`; optional `--tasks` scaffolds `TASKS.md` from template.

### Changed

- **Health → status** — `/assistant:health` replaced with `/assistant:status` (read-only install/setup report); checklist and report schema live in `commands/status.md.tmpl`.
- **Memory command consolidated** — standalone `/assistant:memory` removed; use `/assistant:update memory` or chat for memory updates.
- **`/assistant:update` scopes** — accepts `tasks`, `memory`, or `--all` (deprecated alias `--comprehensive`) for scoped syncs and connector deep-scans.

### Fixed

- _(none)_

## [1.3.1] - 2026-07-11

### Added

- **`policiesPath` in install config** — `my-assistant.json` now records `{assistantPath}/policies` alongside `assistantPath` and `configPath`; setup writes it on new installs and backfills on update.
- **Working-folder `AGENTS.md`** — setup scaffolds `AGENTS.md` from a template (orientation and memory hot cache) alongside optional `TASKS.md` and `memory/`.

### Changed

- **Health check assets** — checklist and report schema moved to `skills/health-check/assets/` (was `config/`).

### Fixed

- **Policies path** — user policies live at `{assistantPath}/policies/` (working-folder root), not `{assistantPath}/config/policies/`. SessionStart hook, setup, health check, and skills updated; legacy `{configPath}/policies/` still read for existing installs.

## [1.3.0] - 2026-07-11

### Changed

- **Policies split from profile** — VIP tiers, email rules, and calendar rules now live in `{configPath}/policies/*.policy.md` (e.g. `email.policy.md`, `calendar.policy.md`). Master templates ship in the plugin's `policies/` directory. `profile.md` holds identity, voice, anti-style, working rules, and goals only.
- **Schedule catalog moved** — `schedules.yaml` and `schedules.schema.yaml` moved from `config/` to `scheduled/` (plugin reference files; user heartbeats remain at `{assistantPath}/scheduled/{job_id}.yaml`).
- **Schedule health ledger layout** — working-folder heartbeats now live at `scheduled/{job_id}.yaml` (one file per job; was `schedules/index.yaml`).

### Added

- **Working-folder setup** — `/assistant:setup` now establishes a working directory (default `~/MyAssistant`) before the profile interview.
- **`config/my-assistant.json`** — selective machine-readable install config (`assistantPath`, `configPath`, `scope`, `platform`, `setupAt`, `lastUpdated`) at `{assistantPath}/config/my-assistant.json`; schema in `config/my-assistant.schema.yaml`.
- **`rules/paths.md`** — canonical resolution for working folder, config, and profile (legacy paths still supported).

### Changed

- **Profile location** — setup writes once to `{assistantPath}/config/profile.md` instead of duplicating under `~/.claude/plugins/config/my-assistant/` and the workspace.
- **SessionStart hook** — resolves profile via `my-assistant.json` then fallback paths per `rules/paths.md`.
- **Health check** — new `config-exists`, `config-valid`, and `config-profile-aligned` checks.

### Fixed

- **Duplicate profile on setup** — explicit single-write rule prevents Cowork from saving profile to both legacy config and workspace paths.
- **Health-check golden fixtures** — policy check IDs now referenced in eval golden reports.

## [1.2.1] - 2026-07-10

### Added

- **Before/after demo** — operator contract-renewal draft example in `examples/before-after/04-needs-reply-contract-renewal/`.

### Changed

- **Config filenames** — simplified plugin manifests and schemas under `config/`: `calendar.yaml`, `connectors.yaml`, `schedules.yaml`, `schedules.schema.yaml`, `notetaker.yaml`, `feedback.yaml`, `health.yaml`, `review.schema.yaml` (replacing long hyphenated names).
- **Health command** — `/assistant:doctor` renamed to `/assistant:health`; `install-doctor` skill and `evals/doctor` corpus renamed to `health-check`.
- **Meeting commands** — `/assistant:prep` consolidated into `/assistant:meeting prep`; `follow-up` remains the default verb on `/assistant:meeting`.

### Fixed

- _(none)_

## [1.2.0] - 2026-07-10

### Changed

- **Schedule health ledger path** — working-folder heartbeats now live at `schedules/index.yaml` (was `schedule-health/index.yaml`); docs, skills, health-check fixtures, and schema comments updated.
- **Command descriptions** — standardized frontmatter across all 13 slash commands for clearer discovery.

### Fixed

- **Cowork command loading** — removed redundant component-path fields from both plugin manifests so auto-discovery loads `commands/`, `skills/`, `agents/`, and hooks from their default locations; fixes `/assistant:*` reporting "Unknown command" in Claude Cowork.

## [1.1.0] - 2026-07-08

### Fixed

- **Doctor eval fixtures** — add `.gitkeep` scaffold files for `fx-folder-scaffold` and `fx-no-profile` working directories so structural validation passes on fresh checkouts.

## [0.2.1] - 2026-07-08

### Added

- **Release skill** — `.claude/skills/release/SKILL.md`, a maintainer-only workflow for gating, version bumping, changelog updates, commit, tag, and push.

### Fixed

- **`scripts/validate_fixtures.py`** — removed the obsolete `evals/scripts` required-directory check left over from the Ruby→Python CI migration, which was failing the fixture gate (and CI) on `main`.

## [0.2] - 2026-07-08

### Changed

- **Command conventions** — all 13 slash commands now include Preflight, Plan, Verification, Summary, and Next Steps sections per `commands/_conventions.md`; existing skill routing preserved.

### Fixed

- **`scripts/validate.py`** — section-heading regex (`^#{2,3}`) no longer broken by f-string brace interpolation.

## [0.1.0] - 2026-07-08

First tagged release of **My Assistant** as a single installable plugin. Supersedes the pre-0.1.0 multi-workspace ADK layout with no backward compatibility.

### Added

- **Single plugin package** — `.claude-plugin/plugin.json` and a single-plugin `marketplace.json` installable from the GitHub URL. Root `.mcp.json` connector suggestions (Slack, Notion, GitHub).
- **14 skills** — assistant-setup, inbox-triage, email-drafting, email-feedback, follow-up-tracking, calendar-scheduling, meeting-prep, meeting-follow-up, daily-brief, task-management, memory-management, weekly-review, schedule-setup, health-check.
- **Commands** — `/assistant:setup`, `:inbox`, `:email`, `:calendar`, `:meeting`, `:tasks`, `:memory`, `:brief`, `:prep`, `:update`, `:review`, `:schedules`, `:health`.
- **3 named + schedulable agents** and **3 managed-agent cookbooks** (`agent.yaml`) for headless, always-on deployment.
- **Profile-based personalisation** at `~/.claude/plugins/config/my-assistant/profile.md`, outside the plugin so `/plugin update` never overwrites it; loaded via a `SessionStart` hook.
- **Graduated autonomy** (Tiers 0–3, default Draft) and the draft-don't-send guarantee in `rules/core-behaviour.md`.
- **Starter profiles & examples gallery (MA09)** — five vertical ICP starter profiles in `config/starter-profiles/`; `examples/` gallery with workflow walkthroughs and before/after draft demos.
- **Trust artefacts (MA08)** — admin/deployment guide, security index, connector category manifest, connector smoke-test guide and eval corpus.
- **Feedback loop (MA07)** — `/assistant:email feedback`, `email-feedback` skill, feedback signal taxonomy.
- **Time protection (MA05)** — `/assistant:calendar protect`, calendar block type model, calendar eval corpus.
- **Always-on reliability (MA06)** — schedule catalog, schedule-health ledger, miss detection in brief/review.
- **Notetaker import (MA04)** — `/assistant:meeting follow-up`, notetaker format fingerprints, notetaker eval corpus.
- **Visual dashboard** (`skills/dashboard.html`) — browser UI for `TASKS.md` and two-tier memory.
- **CI** — structural validation via `scripts/validate.py` and eval fixture validation in GitHub Actions.

### Changed

- **Naming clarified** — display name **My Assistant**; repo, marketplace, and profile path `my-assistant`; plugin manifest `name` `assistant`; commands `/assistant:*`.
- **`.mcp.json` trimmed** — removed Google email/calendar/drive MCP entries; email, calendar, and drive use host MCP providers or paste-first.
- **Plugin command prefix** — `/my-assistant:` → `/assistant:`.
- **Skill names** — `{domain}-{job}` convention throughout.
- **Domain commands** — noun + verb arguments documented in `AGENTS.md` and `docs/guide/03-skills-and-commands.md`.
- `AGENTS.md` rewritten as the plugin's trigger→skill orchestration.
- README, docs guide, and product docs rewritten for the single-plugin model.

### Removed

- Multi-workspace layout (`workspaces/`), the separate `assistant` and `productivity` plugins, the `adk` marketplace, repo-level `.claude/skills/` (`install`, `setup`), `.agents/`, `config/*.example.*`, and `rules/tone.md`. Personalisation now lives in the profile.

### Fixed

- **`.agency/product.md` roadmap link** — fixed dangling roadmap reference.
- **`.gitignore`** — anchor `TASKS.md` and `MEMORY.md` to repo root on case-insensitive filesystems.
