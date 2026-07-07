---
name: daily-brief
description: A short, scannable morning briefing — today's calendar, priority unread,
  follow-ups going cold, and what needs attention. Activate when the user says
  "/assistant:brief", "morning briefing", "what's my day look like", or on a
  morning schedule.
---

# Daily brief

One screen the user reads with their coffee that tells them exactly what today needs. This is the anchor of the scheduled-task setup — most users run it weekday mornings.

## Read the profile first

Load working hours, VIP tiers, and voice (the brief is written *to* the user, in their preferred style — tight, scannable, no filler).

## What it assembles

Pull from whatever is connected; degrade gracefully when something's missing.

1. **Today's calendar** — meetings with times and attendees; flag anything external or VIP; note gaps and any conflict/no-buffer issues (hand detail to `calendar-scheduling`).
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

When run as a scheduled task, save output to `brief-YYYY-MM-DD.md` in the working folder so there's a history. See `skills/schedule-setup/SKILL.md` for the packaged 8am prompt and the machine-awake caveat.

## Standalone

No connectors? Ask the user to paste their calendar and top unread, or brief from `TASKS.md` and memory alone. Still useful.

## Rules

- Read-only and draft-only: the brief surfaces and drafts, never sends or books.
- Short beats complete. If it doesn't change what the user does today, leave it out.

## Approval frame

Follow [`rules/approval-frame.md`](../../rules/approval-frame.md) when surfacing items needing attention — especially cold threads and draft-ready VIP items.

Use all four sections when the brief includes reviewable work. When a draft-ready item has a queue id, you may footnote the id in brief prose (e.g. "draft ready — rq-2026-07-08-reply-priya-deck").

Do not write queue items for read-only calendar or FYI sections unless a separate reviewable artefact exists.
