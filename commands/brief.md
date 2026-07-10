---
description: Morning briefing — today's calendar, priority unread, follow-ups going cold, and what needs your attention before noon.
---

## Preflight

- **Profile** — Read `~/.claude/plugins/config/my-assistant/profile.md` (or `profile.md` in the open workspace). If missing, note it and offer `/assistant:setup`; the brief still works with pasted content.
- **Working folder** — Confirm where `brief-YYYY-MM-DD.md` and any queue references will be written. Note if the folder is read-only.
- **Connectors** — Detect `~~email`, `~~calendar`, `~~chat`, `~~tasks`. State which sources are connector-backed vs paste-only; degrade gracefully when connectors are missing.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). The brief proposes actions only — never send, book, or spend.

## Plan

- Run `skills/daily-brief/SKILL.md`.
- Assemble today's calendar, priority unread, cold follow-ups, and flagged tasks into a concise brief (under ~400 words, most-important first).
- Draft-only: surface what needs attention; do not send replies or book meetings.

## Commands

Produce the daily brief. Read and follow `skills/daily-brief/SKILL.md`.

Read the profile first. Assemble from whatever connectors are available; degrade gracefully if some are missing. Keep it under ~400 words, most-important first. If the user has no connectors, ask them to paste their calendar and top unread. Never send email or book calendar events.

## Verification

- Re-read `brief-YYYY-MM-DD.md` (if written) and the in-chat brief — confirm it covers calendar, follow-ups, and priorities per the plan.
- Confirm nothing was sent, booked, or deleted without explicit approval.
- Surface connector errors, partial data, or schedule-health misses clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: morning brief
- **Status**: success | partial | failed
- **Details**: brief path, key flags, connector mode, word count
```

## Next Steps

- Run `/assistant:prep` for your first meeting.
- Act on flagged follow-ups via `/assistant:email review`.
- Run `/assistant:inbox triage` on priority unread.
- Run `/assistant:calendar protect` if the brief surfaced buffer gaps.
