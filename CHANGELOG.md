# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

### Changed

- `AGENTS.md` rewritten as the plugin's trigger→skill orchestration.
- README, docs guide, and product docs rewritten for the single-plugin model.

### Removed

- Multi-workspace layout (`workspaces/`), the separate `assistant` and `productivity` plugins, the `adk` marketplace, repo-level `.claude/skills/` (`install`, `setup`), `.agents/`, `config/*.example.*`, and `rules/tone.md`. Personalisation now lives in the profile.

## [0.1.0] - 2026-05-24

- Initial public release (multi-workspace AI Assistant ADK).
