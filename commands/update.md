---
description: Sync your tasks and memory — triage stale tasks, surface follow-ups
  going cold, and fill memory gaps. Add --comprehensive to deep-scan connected sources.
argument-hint: "[--comprehensive]"
---

## Preflight

- **Profile** — Read `~/.claude/plugins/config/my-assistant/profile.md` (or `profile.md` in the open workspace). If missing, note it and offer `/assistant:setup`; sync still works from the working folder.
- **Working folder** — Confirm `TASKS.md`, `memory/`, `CLAUDE.md`, and queue locations. Note if the folder is read-only.
- **Connectors** — Detect `~~email`, `~~calendar`, `~~chat`, `~~drive` when `--comprehensive` is set. State which are available; skip missing connectors and note the gap.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Present each capture for confirmation — never auto-add. Draft-only: never send, book, or spend.

## Plan

- Run `skills/task-management/SKILL.md`, `skills/follow-up-tracking/SKILL.md`, and `skills/memory-management/SKILL.md`.
- **Default:** triage stale/overdue tasks, surface cold follow-ups, decode entities against memory and ask about gaps.
- **`--comprehensive`:** additionally deep-scan available connectors for action items and new people/projects not yet captured. Present each for the user to add — never auto-add.

## Commands

Sync tasks and memory. Follow `skills/task-management/SKILL.md`, `skills/follow-up-tracking/SKILL.md`, and `skills/memory-management/SKILL.md`.

**Default:** read `TASKS.md`, `memory/`, and working memory. Triage stale/overdue tasks (present each — done? reschedule? Someday?). Surface follow-ups gone cold via `follow-up-tracking`. Decode task entities against memory and ask about gaps. For task-list-only sync, `/assistant:tasks sync` is narrower.

**`--comprehensive`:** additionally deep-scan available connectors (`~~email`, `~~calendar`, `~~chat`, `~~drive`) for action items not yet in `TASKS.md` and new people/projects not yet in memory. Present each for the user to add — never auto-add. Skip any missing connector and note the gap.

## Verification

- Re-read `TASKS.md`, `memory/`, and any follow-up drafts — confirm changes match the plan.
- Confirm nothing was sent, booked, deleted, or auto-added without explicit approval.
- Surface connector errors, partial scans, or autonomy-tier blocks clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: update sync | update --comprehensive
- **Status**: success | partial | failed
- **Details**: tasks triaged, follow-ups surfaced, memory gaps, connector mode
```

## Next Steps

- Run `/assistant:tasks review` for interactive task triage.
- Run `/assistant:email review` for threads awaiting a response.
- Run `/assistant:memory add` for entities you confirmed.
- Run `/assistant:review` for a full weekly pass.
