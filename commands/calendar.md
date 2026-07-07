---
description: Calendar time protection and scheduling — scan for buffer/prep/follow-up
  gaps, draft block proposals, or find meeting times. Never books or creates events.
argument-hint: "[protect | schedule]"
---

Parse `$ARGUMENTS` for the verb. Default to **protect** when empty or unrecognized.

## protect (default)

Proactive time protection. Read and follow `skills/calendar-scheduling/SKILL.md` in **protect** mode.

Scan today + tomorrow (or user-specified horizon), detect buffer/prep/follow-up gaps and focus-time violations against profile calendar policy, and draft block proposals under `drafts/calendar-block-*.md`. Write `calendar-proposal` queue items. The user creates events manually — nothing is booked.

If the user has not pasted an agenda and no `~~calendar` connector is available, ask for a calendar paste and show an example format.

Natural language triggers ("protect my calendar", "I have no buffers tomorrow") also route here.

## schedule

Find meeting times and check conflicts — legacy scheduling behaviour. Read and follow `skills/calendar-scheduling/SKILL.md` in **schedule** mode.

Propose 2–3 specific slots with timezone, flag conflicts, and draft scheduling replies. Does not run the protect violation scan unless the user asks.
