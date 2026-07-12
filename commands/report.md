---
description: Weekly report — wins, open loops, stale tasks, and what to line up for
  Monday. Prunes tasks and memory with your confirmation.
---

## Preflight

- **Profile & paths** — Resolve per `rules/paths.md`. If missing, note it and offer `/assistant:setup`; the report still works from the working folder.
- **Working folder** — Confirm `TASKS.md`, `memory/`, `AGENTS.md`, and `review-YYYY-MM-DD.md` locations. Note if the folder is read-only.
- **Connectors** — Optional; note available `~~email`, `~~calendar`, `~~chat` for open-loop context.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Update tasks and memory only with confirmation.

## Plan

- Run `skills/weekly-review/SKILL.md`.
- Cover wins, open loops, stale tasks (interactive triage), memory prune, and next-week priorities.
- Propose `TASKS.md` and `memory/` changes; save output to `review-YYYY-MM-DD.md`. Apply nothing without confirmation.

## Commands

Run the weekly report. Read and follow `skills/weekly-review/SKILL.md`.

Read the profile first for goals and priorities. Cover wins / open loops / stale (triage interactively) / memory prune / next week. Update `TASKS.md` and `memory/` only with confirmation. Save output to `review-YYYY-MM-DD.md`.

## Verification

- Re-read `review-YYYY-MM-DD.md`, `TASKS.md`, and `memory/` changes — confirm they match the plan.
- Confirm nothing was deleted or moved without explicit approval.
- Surface read-only folder errors or incomplete open-loop data clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: weekly report
- **Status**: success | partial | failed
- **Details**: report path, tasks triaged, memory entries pruned
```

## Next Steps

- Run `/assistant:schedules` to confirm weekly report is on the calendar.
- Run `/assistant:update` to sync any remaining gaps.
- Run `/assistant:brief` Monday morning with next-week priorities in mind.
