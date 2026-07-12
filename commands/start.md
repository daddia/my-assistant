---
description: Initialize tasks and memory — scaffold files, open the dashboard, bootstrap
  shorthand from your todo list. Light first run; use /assistant:setup for full profile.
---

## Preflight

- **Profile & paths** — Resolve per `rules/paths.md`. Profile is **not** required; note if missing and mention `/assistant:setup` for voice and inbox sharpness.
- **Working folder** — Suggest `~/MyAssistant` if no `my-assistant.json`; confirm absolute path before writes.
- **Connectors** — Advisory only; optional comprehensive scan uses connectors when `--all` is run separately.
- **Autonomy tier** — Default Tier 1 — Draft. Present each memory capture for confirmation — never auto-add.

## Plan

- Run `skills/start/SKILL.md`.
- Scaffold missing `TASKS.md`, `AGENTS.md`, `CLAUDE.md`, `memory/`, and `dashboard.html`.
- If memory is empty, bootstrap from the user's task list (decode shorthand interactively).
- Offer `/assistant:update --all` for a connector deep-scan; do not block on OAuth.

## Commands

Initialize tasks and memory. Read and follow `skills/start/SKILL.md`.

Create missing working-folder files, point the user at `dashboard.html`, and bootstrap memory from their todo list when `AGENTS.md` is empty. For profile, voice, VIP tiers, and policies, defer to `/assistant:setup`.

## Verification

- Confirm `TASKS.md` uses the six status sections (To do, In progress, In review, Done, Cancelled, Blocked).
- Confirm `AGENTS.md`, `memory/glossary.md`, and `dashboard.html` exist in the working folder.
- Confirm `CLAUDE.md` contains `@AGENTS.md` when created.
- Confirm nothing was auto-added to memory without user confirmation.

## Summary

```
## Result
- **Action**: start
- **Status**: success | partial | failed
- **Details**: assistantPath, tasks count, memory seeded (people/terms/projects)
```

## Next Steps

- Open `dashboard.html` in Chrome or Edge for tasks and memory.
- Run `/assistant:update` to triage tasks and fill memory gaps.
- Run `/assistant:setup` for profile, voice, and email/calendar policies.
- Run `/assistant:health` for a full install check.
