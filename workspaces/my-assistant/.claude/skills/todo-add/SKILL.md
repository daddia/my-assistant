---
name: todo-add
description: Capture a new task or reminder clearly — to output/drafts/ or the user's
  stated task system. Use when the user says "add a todo", "remind me", "don't forget",
  or gives a actionable item to track.
---

# Todo add

## When to activate
- User wants something tracked
- Action item emerges from a session

## Steps

1. Clarify if missing: what, when (if any), context, priority.
2. Append to `output/drafts/todos.md` under today's date:

```markdown
## YYYY-MM-DD
- [ ] [task] — [context] — due: [date or none]
```

3. Confirm what was captured.
4. If the workspace CLAUDE.md specifies an external task system (Apple Reminders, TickTick, etc.), offer to format for that system — **ask before** using automation.

## What this skill does NOT do
- Does not create calendar events without confirmation
- Does not send reminders to third parties
