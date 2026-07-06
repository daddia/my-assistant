---
name: weekly-review
description: A Friday review of the week — wins, open loops, stale tasks, and setup
  for next week. Activate when the user says "/my-assistant:review", "weekly review",
  "wrap up my week", or on a Friday-afternoon schedule.
---

# Weekly review

Close the week cleanly: what got done, what's still open, what's gone stale, and what to line up for Monday. Also the moment to prune tasks and memory.

## Read the profile first

Load goals/priorities (to judge what mattered), voice, and working hours.

## What it does

1. **Wins** — what closed this week. Pull from `TASKS.md` Done, and from the week's briefs/follow-ups if present.
2. **Open loops** — Active tasks and `follow-up-tracker` items still outstanding, most-important first.
3. **Stale** — tasks untouched 14+ days and follow-ups long cold. Present each for triage: still relevant? reschedule? move to Someday? drop?
4. **Memory prune** — surface stale or contradictory memory entries to confirm or remove.
5. **Next week** — what to line up for Monday: upcoming meetings needing prep (hand to `meeting-prep`), deadlines from goals, top 3 priorities.

## Output shape

```
Weekly review — week ending Fri 11 Jul

Wins (6 closed)
  • Shipped Q3 scope with Acme • Expense report in • ...

Open loops (4)
  • Q3 SOW draft — due next week
  • Acme contract — nudged twice, still silent (escalate?)

Stale — triage these
  • "Fix back fence" — untouched 21 days → Someday?
  • "Call accountant" — no context, 16 days → still needed?

Next week
  • Mon 9:00 board prep (deck ready?) • Renewal deadline Thu
  • Top 3: SOW, board deck, hiring loop
```

## Scheduled use

Runs well as a Friday 4pm scheduled task; save to `review-YYYY-MM-DD.md`. See `skills/schedules/SKILL.md`.

## Rules

- Triage interactively — don't auto-drop or auto-reschedule tasks.
- Update `TASKS.md` and `memory/` only with confirmation (writes to those are allowed, but a review is a good moment to confirm).
- Read-only on email/calendar; draft-only on any nudge.
