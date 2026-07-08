# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- _(none)_

## [0.1.0] - 2026-07-08

First tagged release of **My Assistant** as a single installable plugin. Supersedes the pre-0.1.0 multi-workspace ADK layout with no backward compatibility.

### Added

- **Single plugin package** — `.claude-plugin/plugin.json` and a single-plugin `marketplace.json` installable from the GitHub URL. Root `.mcp.json` connector suggestions (Slack, Notion, GitHub).
- **14 skills** — setup-interview, inbox-triage, email-drafting, email-feedback, follow-up-tracking, calendar-scheduling, meeting-prep, meeting-follow-up, daily-brief, task-management, memory-management, weekly-review, schedule-setup, install-doctor.
- **Commands** — `/assistant:setup`, `:inbox`, `:email`, `:calendar`, `:meeting`, `:tasks`, `:memory`, `:brief`, `:prep`, `:update`, `:review`, `:schedules`, `:doctor`.
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
