---
name: weekly-review
description: A Friday review of the week — wins, open loops, stale tasks, and setup
  for next week. Activate when the user says "/assistant:report", "weekly review",
  "weekly report", "wrap up my week", or on a Friday-afternoon schedule.
---

# Weekly review

Close the week cleanly: what got done, what's still open, what's gone stale, and what to line up for Monday. Also the moment to prune tasks and memory. Catalog entry: `job_id: weekly-review` in `scheduled/schedules.yaml`.

## Read the profile first

Load goals/priorities (to judge what mattered), voice, and working hours.

## Schedule health check (optional, interactive Friday runs)

On an **interactive** Friday run after the expected window (**cron 16:00 Friday + 90 minutes = 17:30**), optionally surface a low-priority miss hint for `weekly-review` when:

- `scheduled/weekly-review.yaml` exists and `surface` is `local`
- `review-{today}.md` is absent and `last_run_at` is stale

Use the same `### Schedule health` block format as `daily-brief`, naming the weekly review job. Suggest `cloud-code` (no managed cookbook for this job). Skip when `surface` is `managed` or `cloud-code`. Max one health block per chat turn; do not block the review.

## What it does

1. **Wins** — what closed this week. Pull from `TASKS.md` Done, and from the week's briefs/follow-ups if present.
2. **Open loops** — To do, In progress, In review, and Blocked tasks plus `follow-up-tracking` items still outstanding, most-important first.
3. **Stale** — tasks untouched 14+ days and follow-ups long cold. Present each for triage: still relevant? in progress? blocked? cancelled?
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
  • "Fix back fence" — untouched 21 days → cancel or keep in To do?
  • "Call accountant" — no context, 16 days → still needed?

Next week
  • Mon 9:00 board prep (deck ready?) • Renewal deadline Thu
  • Top 3: SOW, board deck, hiring loop
```

## Scheduled use

Runs well as a Friday 4pm scheduled task; save to `review-YYYY-MM-DD.md`. See `skills/schedule-setup/SKILL.md`.

**Heartbeat:** at end of a scheduled run, update the ledger via bash (required):

```bash
python3 scripts/update_ledger.py \
  --job-id weekly-review \
  --status {success|partial|failed} \
  --artifact review-{today}.md \
  --working-folder {working-folder}
```

Before ending, confirm `last_run_at` in `scheduled/weekly-review.yaml` matches this run.

## Rules

- Triage interactively — don't auto-drop or auto-reschedule tasks.
- Update `TASKS.md` and `memory/` only with confirmation (writes to those are allowed, but a review is a good moment to confirm).
- Read-only on email/calendar; draft-only on any nudge.

## Approval frame

Follow [`rules/approval-frame.md`](../../rules/approval-frame.md) when surfacing recommendations that need user decisions.

Use all four sections for actionable recommendations. Do **not** write queue items for read-only review sections (closed items, stale task lists) unless a separate pending approval artefact exists — e.g. a nudge draft or profile diff proposal.
