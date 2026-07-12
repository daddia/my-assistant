---
description: Add, review, or sync tasks in TASKS.md — your plain-markdown task list.
argument-hint: "[add|review|sync]"
---

Parse `$ARGUMENTS` for the verb. Default to **review** when empty or unrecognized.

## Preflight

- **Profile & paths** — Resolve per `rules/paths.md`. If missing, note it and offer `/assistant:setup`; tasks still work in the working folder.
- **Working folder** — Confirm `TASKS.md` location and writability. Note if the folder is read-only.
- **Connectors** — Not required for `add`/`review`; for `sync`, note whether context comes from chat/paste only (connector-backed sync uses `/assistant:update tasks --all` or `/assistant:update --all`).
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Never auto-add without confirmation.

## Plan

- **add** — Run `skills/task-management/SKILL.md`. Add to Active or Waiting On with enough context to act.
- **review** — Run `skills/task-management/SKILL.md`. Summarise Active and Waiting On; interactively triage stale items.
- **sync** — Run `skills/task-management/SKILL.md`. Surface action items from conversation or pasted content; offer to capture each — never auto-add.

## add

Capture a new task or commitment. Read and follow `skills/task-management/SKILL.md`.

Add to Active (or Waiting On if blocked) with enough context to act. Tell the user what was added. Use remaining arguments or ask what to capture if none provided.

## review (default)

Review the current task list. Read and follow `skills/task-management/SKILL.md`.

Read `TASKS.md`, summarise Active and Waiting On (overdue first), and interactively triage stale items — done? reschedule? move to Someday? Flag if Active exceeds ~40 items.

## sync

Sync tasks from recent activity into `TASKS.md`. Read and follow `skills/task-management/SKILL.md`.

Read `TASKS.md` and working memory. Surface action items from the current conversation or pasted content; offer to capture each — never auto-add. For connector-backed sync (email, calendar, chat), use `/assistant:update tasks --all` or `/assistant:update --all` — this verb scopes to the task list and chat/paste only.

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
- **Details**: items added/triaged/synced, Active/Waiting On counts
```

## Next Steps

- Run `/assistant:update` for a full catch-up (tasks, memory, follow-ups).
- Run `/assistant:report` for a weekly task prune.
- Open `skills/dashboard.html` for a visual task board.
