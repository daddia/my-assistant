---
name: todo-review
description: Review open todos from output/drafts/todos.md, suggest priorities, and mark
  done items. Use when the user says "review todos", "what's on my list", or "clear my tasks".
---

# Todo review

## When to activate
- User asks to review todos or task list

## Steps

1. Read `output/drafts/todos.md` if it exists; otherwise check recent `MEMORY.md` open loops.
2. Present open items as a table: task | context | due | suggested priority.
3. Ask which items to mark done, defer, or drop.
4. Update `output/drafts/todos.md` on confirmation only.

## What this skill does NOT do
- Does not delete MEMORY.md history
- Does not auto-complete items without user confirmation
