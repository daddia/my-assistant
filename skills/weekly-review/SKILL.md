---
name: weekly-review
description: Structured end-of-week review — wins, misses, decisions, open loops,
  next week's priorities. Use when the user says "weekly review", "wrap up the week",
  or on Friday afternoon.
---

# Weekly review

## When to activate
- User asks for weekly review or end-of-week wrap-up
- Scheduled task invokes `/weekly-review`

## Steps

1. Read `MEMORY.md` (past 7 days of sections if present).
2. List files in `output/daily/` from the past 7 days; skim for substance.
3. Read `context/about-me.md` for stated priorities and goals.
4. Use `shared/templates/weekly-review.md` (or `templates/weekly-review.md` if overridden) as the outline.
5. Write to `output/weekly/YYYY-MM-DD-review.md`.
6. Propose any durable updates to `context/` — **ask before editing**.

## Output quality
- Wins need evidence, not vibes.
- Misses include cause, not blame.
- Next week's three priorities must be actionable this week.

## What this skill does NOT do
- Does not send email or modify calendar
- Does not edit context/ without confirmation
