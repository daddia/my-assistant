---
name: task-management
description: Track tasks and commitments in TASKS.md. Activate when the user mentions
  a task or todo, says "add a task", "what's on my list", "remind me to", "I'm done
  with X", or when another skill surfaces an action item to capture.
---

# Task management

Tasks live in `TASKS.md` — one plain markdown file the user and the assistant both read and write. No app, no lock-in.

## Location

`TASKS.md` in the working folder. Create it from the template below if missing.

## Format

```markdown
# Tasks

## Active
- [ ] Send Acme the revised deck — by Thu
- [ ] Draft Q3 SOW — next week

## Waiting On
- [ ] Insurance document — chasing provider (since 10 May)
- [ ] Acme contract reply — nudged 8 Jul

## Someday
- [ ] Fix the back fence

## Done
- [x] ~~Submit expense report~~ (8 Jul)
```

Task line: `- [ ] Description — context, due date`
Done: `- [x] ~~Task~~ (date)` — keep ~1 week in Done, then drop.

The four sections mirror the productivity model: **Active / Waiting On / Someday / Done**.

## How to interact

- **"What's on my list":** read `TASKS.md`, summarise Active and Waiting On, surface overdue items first.
- **"Add a task" / "remind me to":** add to Active with context; tell the user what was added.
- **"I'm done with X":** mark `[x]`, date it, move to Done.
- **From another skill:** when `inbox-triage`, `meeting-follow-up`, or `follow-up-tracker` surfaces an action, offer to capture it — don't add silently.
- **Blocked-on items:** put in Waiting On; this is the same list `follow-up-tracker` reads.

## Conventions

- Don't add a task without telling the user.
- Don't add vague tasks — ask for enough detail to act.
- Don't auto-complete — wait for confirmation.
- Flag if Active exceeds ~40 items; suggest a review (hand to `weekly-review`).
- Never store credentials or account numbers in tasks.
