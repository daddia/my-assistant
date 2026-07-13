---
description: Calendar time protection and scheduling — scan for buffer/prep/follow-up/habit gaps, draft block proposals, or find meeting times. Never books or creates events.
argument-hint: "[protect | schedule]"
---

Parse `$ARGUMENTS` for the verb. Default to **protect** when empty or unrecognized.

## Preflight

- **Profile & paths** — Resolve per `rules/paths.md`. If missing, note it and offer `/assistant:setup`; calendar policy defaults still apply for pasted agendas.
- **Working folder** — Confirm where `drafts/calendar-block-*.md`, `drafts/calendar-*.md`, and `review-queue/index.yaml` will be written. Note if the folder is read-only.
- **Connectors** — Detect `~~calendar`. State whether the run is connector-backed or paste-only.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Never exceed it.
- **Habit blocks** — Read **Habit blocks** table from `calendar.policy.md`; note count (0 = habit scan skipped).

## Plan

- **protect** — Run `skills/calendar-scheduling/SKILL.md` in **protect** mode. Draft block proposals and `calendar-proposal` queue items; the user creates events manually — nothing is booked.
- **schedule** — Run `skills/calendar-scheduling/SKILL.md` in **schedule** mode. Propose slots, build rejected-slots table, draft scheduling replies. Does not run the protect violation scan unless the user asks.

## protect (default)

Proactive time protection. Read and follow `skills/calendar-scheduling/SKILL.md` in **protect** mode.

Scan today + tomorrow (or user-specified horizon), detect buffer/prep/follow-up/focus/habit gaps against profile calendar policy, and draft block proposals under `drafts/calendar-block-*.md`. Write `calendar-proposal` queue items. The user creates events manually — nothing is booked.

If the user has not pasted an agenda and no `~~calendar` connector is available, ask for a calendar paste and show an example format.

Natural language triggers ("protect my calendar", "I have no buffers tomorrow") also route here.

## schedule

Find meeting times and check conflicts. Read and follow `skills/calendar-scheduling/SKILL.md` in **schedule** mode.

Propose 2–3 specific slots with timezone, build a **Rejected slots** table when the calendar is busy, and draft scheduling replies under `drafts/calendar-*.md`. Does not run the protect violation scan unless the user asks. Never book or create events.

When ≥ 2 hard rejections are due to protection rules, suggest `/assistant:calendar protect` for a full scan.

## Verification

- Confirm unified report header: `Calendar — {protect | schedule} — {label}`.
- **Protect:** violation summary table includes Type, Severity, Meetings/window, Gap, Rationale; habit proposals when policy defines habits; focus severity labels on intrusions; assertive mode proposes `focus-defence` when applicable.
- **Schedule:** proposed slots table (2–3 when feasible); rejected-slots table (≥ 2 rows when busy) with Reason and Severity (hard/soft); timezone in every offered slot.
- Re-read `drafts/calendar-block-*.md`, `drafts/calendar-*.md`, and queue items — confirm they match the plan and use propose-only language.
- Confirm four-section approval frame when drafts or proposals exist; healthy protect runs omit queue footer.
- Confirm nothing was booked, cancelled, or deleted without explicit approval.
- Surface connector errors, partial calendar data, or autonomy-tier blocks clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: calendar protect | calendar schedule
- **Status**: success | partial | failed
- **Details**: violation count, block proposal paths, slot options, rejected-slot count, connector mode
```

## Next Steps

- Create proposed calendar blocks manually from `drafts/calendar-block-*.md`.
- Run `/assistant:meeting prep` before your next meeting.
- Run `/assistant:brief` to see today's calendar in context.
- Send scheduling reply drafts from your mail client.
