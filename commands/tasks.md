---
description: Add, review, or sync tasks in TASKS.md — your plain-markdown task list.
argument-hint: "[add|review|sync]"
---

Parse `$ARGUMENTS` for the verb. Default to **review** when empty or unrecognized.

## Preflight

- **Profile & paths** — Resolve per `rules/paths.md`. If missing, note it and offer `/assistant:setup` or `/assistant:start`; tasks still work in the working folder.
- **Working folder** — Confirm `TASKS.md` location and writability. Note if the folder is read-only.
- **Connectors** — For `sync`, detect `~~tasks` (project tracker, GitHub Issues) plus chat/paste. State which sources are available.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Never auto-add without confirmation.

## Plan

- **add** — Run `skills/task-management/SKILL.md`. Add to **To do** or **Blocked** with enough context to act.
- **review** — Run `skills/task-management/SKILL.md`. Summarise To do, In progress, In review, and Blocked; interactively triage stale items.
- **sync** — Run `skills/task-management/SKILL.md`. External diff when `~~tasks` connected; otherwise surface action items from conversation or paste.

## add

Capture a new task or commitment. Read and follow `skills/task-management/SKILL.md`.

Add to **To do** (or **Blocked** if waiting on someone) with enough context to act. Tell the user what was added. Use remaining arguments or ask what to capture if none provided.

## review (default)

Review the current task list. Read and follow `skills/task-management/SKILL.md`.

Read `TASKS.md`, summarise To do, In progress, In review, and Blocked (overdue first), and interactively triage stale items — done? in progress? blocked? cancelled? reschedule? Flag if To do + In progress exceeds ~40 items. Offer legacy section migration if the file still uses Active / Waiting On / Someday.

## sync

Sync tasks from external sources and recent activity into `TASKS.md`. Read and follow `skills/task-management/SKILL.md`.

**With `~~tasks` connected:** fetch open work assigned to the user (project tracker MCP or `gh issue list --assignee=@me --state=open`), run the external diff table, and present adds/completions/cancellations for confirmation.

**Without connectors:** read `TASKS.md` and surface action items from the current conversation or pasted content; offer to capture each — never auto-add.

For a full catch-up including memory gaps and follow-ups, use `/assistant:update` or `/assistant:update tasks --all`.

## Verification

- Re-read `TASKS.md` — confirm additions, moves, and triage outcomes match the plan.
- Confirm nothing was deleted without explicit approval.
- Surface read-only folder errors or malformed task entries clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: tasks add | tasks review | tasks sync
- **Status**: success | partial | failed
- **Details**: items added/triaged/synced, open counts by section, connector mode
```

## Next Steps

- Run `/assistant:update` for a full catch-up (tasks, memory enrichment, follow-ups).
- Run `/assistant:report` for a weekly task prune.
- Open `dashboard.html` for a visual task board.
