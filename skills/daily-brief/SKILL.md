---
name: daily-brief
description: A short, scannable morning briefing — today's calendar, priority unread,
  follow-ups going cold, and what needs attention. Activate when the user says
  "/assistant:brief", "morning briefing", "what's my day look like", or on a
  morning schedule.
---

# Daily brief

One screen the user reads with their coffee that tells them exactly what today needs. This is the anchor of the scheduled-task setup — most users run it weekday mornings. Catalog entry: `job_id: morning-briefing` in `config/schedule-catalog.yaml`.

## Read the profile first

Load working hours, VIP tiers, and voice (the brief is written *to* the user, in their preferred style — tight, scannable, no filler).

## Schedule health check (interactive runs only)

Before assembling the brief on an **interactive** run (`/assistant:brief`), check for a missed scheduled morning briefing. Do **not** run this block when the current session *is* the scheduled run recovering the job.

1. Load `{working-folder}/schedule-health/index.yaml` if present. If missing, treat as "never scheduled" — suggest `/assistant:schedules` once, then proceed. If corrupt, note "health ledger unreadable — re-run /assistant:schedules" and proceed.
2. Read the `morning-briefing` entry. **Skip miss detection** when `surface` is `managed` or `cloud-code` — local miss logic does not apply.
3. On `surface: local`, on a **weekday**, when local time is past the expected run window (**cron fire time + 90 minutes**; default 08:00 + 90m = 09:30), detect a miss when **either**:
   - `brief-{today}.md` is absent in the working folder, **or**
   - `last_run_at` is stale (before today's expected window).
4. On miss: increment `miss_count_7d` in the ledger, persist the index, then append **one** health block after normal brief output (see below). Do not auto-run a catch-up brief — the user may be intentionally running early or late.
5. When `miss_count_7d >= 2` for this critical job on `local`, add the escalation line to the health block.

**Expected run window:** cron from catalog (`0 8 * * 1-5`) + 90 minutes. Use profile `working_hours.timezone` when set; otherwise the user's stated local timezone.

### Schedule health block (append when miss detected)

```markdown
### Schedule health
- **Missed:** Morning briefing (expected ~08:00 weekdays on *local* surface)
- **Last success:** YYYY-MM-DD — `brief-YYYY-MM-DD.md`
- **Suggestion:** If this happens more than once a week, move this job to the managed-agent cookbook (`managed-agents/morning-briefing/agent.yaml`) or a Claude Code cloud schedule. Run `/assistant:schedules` to walk the decision tree.
```

When `miss_count_7d >= 2`, add:

> **This job has missed twice in the last seven days on a local schedule. Consider moving only this job to managed-agent or cloud-code — not your whole setup.**

Max one health block per chat turn.

## What it assembles

Pull from whatever is connected; degrade gracefully when something's missing.

1. **Today's calendar** — meetings with times and attendees; flag anything external or VIP; note gaps and any conflict/no-buffer issues. When back-to-back meetings or missing buffers are detected, append one line: "Run `/assistant:calendar protect` to draft buffer blocks." Optionally footnote: `calendar: N buffer gaps`. Hand scheduling detail to `calendar-scheduling` protect mode when the user confirms — default is offer, not silent inline scan (keeps brief under ~400 words).
2. **Priority unread** — top items from `~~email`/`~~chat` that need the user today, VIP-first (hand triage to `inbox-triage`). Don't list everything — just what matters before noon.
3. **Follow-ups going cold** — from `follow-up-tracking`: what's silent past threshold.
4. **Due tasks** — from `TASKS.md`: due or overdue today (via `task-management`).
5. **Needs attention before noon** — the 1–3 things that will hurt if missed.

## Output shape

Keep it under ~400 words. Lead with the day's shape.

```
Morning brief — Tue 8 Jul

Today: 3 meetings, first at 10:00.
  10:00 Acme quarterly (Sam Lee, external) — deck due, decision on Q3 scope
  14:00 1:1 Dana
  16:00 Focus block (protected)

Before noon
  • Reply to Priya re board deck (VIP) — draft ready
  • Send Sam the revised deck ahead of 10:00

Going cold
  • Acme contract — silent 4 days, nudge drafted

Due today
  • Submit expense report

Quiet otherwise. Have a good one.
```

## Scheduled use

When run as a scheduled task, save output to `brief-YYYY-MM-DD.md` in the working folder so there's a history. See `skills/schedule-setup/SKILL.md` for the packaged 8am prompt.

**Heartbeat:** at end of a scheduled run, update `schedule-health/index.yaml` for `morning-briefing`:

- `last_run_at`: now
- `last_run_status`: `success` if `brief-{today}.md` was written; else `partial` or `failed`
- `expected_artifact`: `brief-{today}.md`
- `artifact_present`: true/false
- `updated_at` on the index root

## Standalone

No connectors? Ask the user to paste their calendar and top unread, or brief from `TASKS.md` and memory alone. Still useful.

## Rules

- Read-only and draft-only: the brief surfaces and drafts, never sends or books.
- Short beats complete. If it doesn't change what the user does today, leave it out.

## Approval frame

Follow [`rules/approval-frame.md`](../../rules/approval-frame.md) when surfacing items needing attention — especially cold threads and draft-ready VIP items.

Use all four sections when the brief includes reviewable work. When a draft-ready item has a queue id, you may footnote the id in brief prose (e.g. "draft ready — rq-2026-07-08-reply-priya-deck").

Do not write queue items for read-only calendar or FYI sections unless a separate reviewable artefact exists.
