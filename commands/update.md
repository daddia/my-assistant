---
description: Sync your tasks and memory — triage stale tasks, surface follow-ups
  going cold, and fill memory gaps. Add --comprehensive to deep-scan connected sources.
argument-hint: "[--comprehensive]"
---

Sync tasks and memory. Follow `skills/task-management/SKILL.md`, `skills/follow-up-tracking/SKILL.md`, and `skills/memory-management/SKILL.md`.

**Default:** read `TASKS.md`, `memory/`, and working memory. Triage stale/overdue tasks (present each — done? reschedule? Someday?). Surface follow-ups gone cold via `follow-up-tracking`. Decode task entities against memory and ask about gaps. For task-list-only sync, `/assistant:tasks sync` is narrower.

**`--comprehensive`:** additionally deep-scan available connectors (`~~email`, `~~calendar`, `~~chat`, `~~drive`) for action items not yet in `TASKS.md` and new people/projects not yet in memory. Present each for the user to add — never auto-add. Skip any missing connector and note the gap.
