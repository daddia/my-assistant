# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Positioning & roadmap docs** — `.agency/roadmap.md`, `.agency/positioning/positioning.md`, `.agency/positioning/competitors.md`.

### Changed

- **Positioning docs** — consolidated under `.agency/positioning/` (moved out of public `docs/`; not user-facing). `compare-alternatives.md` merged into `competitors.md`.

- **Plugin command prefix** — `/my-assistant:` → `/assistant:` (plugin registers as `assistant`; profile path unchanged at `~/.claude/plugins/config/my-assistant/`).
- **Skill names** — `{domain}-{job}` convention: `email-drafting`, `follow-up-tracking`, `calendar-scheduling`, `schedule-setup`.
- **Domain commands** — noun + verb arguments: `/assistant:inbox [triage|sweep]`, `/assistant:email [draft|review]`, `/assistant:tasks [add|review|sync]`, `/assistant:memory [add|prune]`.
- **Command routing table** — documented in `AGENTS.md` and `docs/guide/03-skills-and-commands.md`.

### Fixed

- **`.agency/product.md` roadmap link** — fixed dangling roadmap reference to `./roadmap.md`.
- **`.gitignore`** — anchor `TASKS.md` and `MEMORY.md` to repo root so `commands/tasks.md` and `commands/memory.md` are not excluded on case-insensitive filesystems.

## [1.0.0] - 2026-07-06

Complete restructure from the multi-workspace ADK into a single installable **my-assistant** plugin — your AI chief of staff. No backward compatibility with the 0.1.x layout.

### Added

- **Single plugin package** — `.claude-plugin/plugin.json` and a single-plugin `marketplace.json` installable from the GitHub URL. Root `.mcp.json` connector suggestions.
- **12 skills** — setup-interview, inbox-triage, reply-drafting, follow-up-tracker, calendar-manager, meeting-prep, meeting-follow-up, daily-brief, task-management, memory-management, weekly-review, schedules.
- **7 commands** — `/my-assistant:setup`, `:inbox`, `:brief`, `:prep`, `:update`, `:review`, `:schedules`.
- **3 named + schedulable agents** and **3 managed-agent cookbooks** (`agent.yaml`) for headless, always-on deployment.
- **Profile-based personalisation** at `~/.claude/plugins/config/my-assistant/profile.md`, outside the plugin so `/plugin update` never overwrites it; loaded via a `SessionStart` hook.
- **Graduated autonomy** (Tiers 0–3, default Draft) and the draft-don't-send guarantee in `rules/core-behaviour.md`.
- **Packaged scheduled-task prompts** with machine-awake and tool-preapproval caveats.
- Root `CONNECTORS.md`; `config/profile.template.md`.
- **Visual dashboard** (`skills/dashboard.html`) — browser UI for `TASKS.md` (board/list) and two-tier memory (`CLAUDE.md`, `memory/`).

### Changed

- `AGENTS.md` rewritten as the plugin's trigger→skill orchestration.
- README, docs guide, and product docs rewritten for the single-plugin model.

### Removed

- Multi-workspace layout (`workspaces/`), the separate `assistant` and `productivity` plugins, the `adk` marketplace, repo-level `.claude/skills/` (`install`, `setup`), `.agents/`, `config/*.example.*`, and `rules/tone.md`. Personalisation now lives in the profile.

## [0.1.0] - 2026-05-24

- Initial public release (multi-workspace AI Assistant ADK).
