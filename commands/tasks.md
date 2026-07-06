---
description: Add, review, or sync tasks in TASKS.md — your plain-markdown task list.
argument-hint: "[add|review|sync]"
---

Parse `$ARGUMENTS` for the verb. Default to **review** when empty or unrecognized.

## add

Capture a new task or commitment. Read and follow `skills/task-management/SKILL.md`.

Add to Active (or Waiting On if blocked) with enough context to act. Tell the user what was added. Use remaining arguments or ask what to capture if none provided.

## review (default)

Review the current task list. Read and follow `skills/task-management/SKILL.md`.

Read `TASKS.md`, summarise Active and Waiting On (overdue first), and interactively triage stale items — done? reschedule? move to Someday? Flag if Active exceeds ~40 items.

## sync

Sync tasks from recent activity into `TASKS.md`. Read and follow `skills/task-management/SKILL.md`.

Read `TASKS.md` and working memory. Surface action items from the current conversation or pasted content; offer to capture each — never auto-add. For connector-backed sync (email, calendar, chat), use `/assistant:update` instead — this verb scopes to the task list only.
