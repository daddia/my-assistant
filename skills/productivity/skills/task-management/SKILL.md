---
name: task-management
description: Markdown task tracking using TASKS.md. Reference when the user asks
  about tasks, wants to add or complete tasks, or needs help tracking commitments.
user-invocable: false
---

# Task management

Tasks are tracked in `TASKS.md` — a plain markdown file you and my-assistant both read and write.

## File location

**Always use `TASKS.md` in the workspace root.**

## Format

```markdown
# Tasks

## This week

- [ ] Call plumber about kitchen tap — by Thursday
- [ ] Reply to school newsletter

## Upcoming

- [ ] Renew car rego — due June

## Waiting / blocked

- [ ] Insurance claim — waiting on document from provider (since 10 May)

## Someday / maybe

- [ ] Fix the back fence
```

Task format: `- [ ] Task description — context, due date`
Completed: `- [x] ~~Task~~ (date)`

## How to interact

**"What's on my list" / "my tasks":**
Read `TASKS.md`, summarise This week and Waiting sections, highlight overdue items.

**"Add a task" / "remind me to":**
Add to This week with context if provided. Tell the user what was added.

**"Done with X" / "finished X":**
Mark `[x]`, add date, move to a Done section (keep ~1 week, then archive).

**Extracting tasks from conversation:**
If the user's message implies a task, note it: "Sounds like you need to follow up on the insurance — want me to add it?"

## Conventions

- Don't add tasks without telling the user
- Don't add vague tasks — ask for enough detail to act
- Don't auto-complete — wait for confirmation
- Flag if active tasks exceed 40 — suggest a review
